import { Router } from 'express';
import { prisma } from '../config/prisma.js';
import { requireAuth } from '../middleware/auth.js';
import { upload } from '../middleware/upload.js';
import { asyncHandler } from '../utils/asyncHandler.js';
import { HttpError } from '../utils/httpError.js';
import { getLeaveTypes, createLeaveType, getLeavePolicies, createLeavePolicy } from '../controllers/leavePolicyController.js';
import { checkPermission } from '../middleware/rbacMiddleware.js';

const router = Router();
router.use(requireAuth);

// Types & Policies
router.get('/types', checkPermission('leave.view', 'view'), getLeaveTypes);
router.post('/types', checkPermission('leave.managePolicy', 'create'), createLeaveType);

router.get('/policies', checkPermission('leave.managePolicy', 'view'), getLeavePolicies);
router.post('/policies', checkPermission('leave.managePolicy', 'create'), createLeavePolicy);

// Balances
router.get('/balance', asyncHandler(async (req, res) => {
  const data = await prisma.leaveBalance.findMany({
    where: { employeeId: req.user.employeeId },
    include: { leaveType: true },
  });
  res.json({ success: true, data });
}));

// Requests list
router.get('/', asyncHandler(async (req, res) => {
  const isManagerOrAdmin = req.user.role === 'ADMIN' || req.query.all === 'true';

  const where = isManagerOrAdmin ? {} : { employeeId: req.user.employeeId };

  const data = await prisma.leaveRequest.findMany({
    where,
    include: {
      leaveType: true,
      employee: { select: { id: true, firstName: true, lastName: true, employeeCode: true, department: { select: { name: true } } } },
    },
    orderBy: { createdAt: 'desc' },
  });

  res.json({ success: true, data });
}));

// Create request with balance check & policy validation
router.post('/', upload.single('attachment'), asyncHandler(async (req, res) => {
  const leaveTypeId = Number(req.body.leaveTypeId);
  const days = Number(req.body.numberOfDays || 1);

  const leaveType = await prisma.leaveType.findUnique({ where: { id: leaveTypeId } });
  if (!leaveType) {
    throw new HttpError(404, 'Leave type not found');
  }

  const policy = await prisma.leavePolicy.findFirst({
    where: { leaveTypeId },
  });

  const balance = await prisma.leaveBalance.findFirst({
    where: { employeeId: req.user.employeeId, leaveTypeId },
  });

  const allowNegative = policy ? policy.allowNegativeBalance : false;
  const currentRemaining = balance ? balance.remainingDays : 0;

  if (leaveType.isLimited && !allowNegative && currentRemaining < days) {
    throw new HttpError(422, `Insufficient leave balance. Available: ${currentRemaining} days, Requested: ${days} days.`);
  }

  const data = await prisma.leaveRequest.create({
    data: {
      employeeId: req.user.employeeId,
      leaveTypeId,
      fromDate: new Date(req.body.fromDate),
      toDate: new Date(req.body.toDate),
      numberOfDays: days,
      dayPart: req.body.dayPart || 'FULL_DAY',
      reason: req.body.reason,
      attachmentUrl: req.file ? `/${req.file.path.replaceAll('\\', '/')}` : null,
      status: 'PENDING',
    },
    include: { leaveType: true },
  });

  res.status(201).json({ success: true, data });
}));

// Approve leave request
router.patch('/:id/approve', checkPermission('leave.approve', 'approve'), asyncHandler(async (req, res) => {
  const leaveRequestId = Number(req.params.id);

  const request = await prisma.leaveRequest.findUnique({
    where: { id: leaveRequestId },
    include: { leaveType: true },
  });

  if (!request) {
    throw new HttpError(404, 'Leave request not found');
  }

  if (request.status === 'APPROVED') {
    throw new HttpError(400, 'Leave request is already approved');
  }

  const updated = await prisma.leaveRequest.update({
    where: { id: leaveRequestId },
    data: {
      status: 'APPROVED',
      approvedBy: req.user.email,
    },
  });

  // Deduct balance
  const balance = await prisma.leaveBalance.findFirst({
    where: { employeeId: request.employeeId, leaveTypeId: request.leaveTypeId },
  });

  if (balance) {
    await prisma.leaveBalance.update({
      where: { id: balance.id },
      data: {
        usedDays: balance.usedDays + request.numberOfDays,
        remainingDays: balance.remainingDays - request.numberOfDays,
      },
    });
  }

  res.json({ success: true, message: 'Leave request approved', data: updated });
}));

// Reject leave request
router.patch('/:id/reject', checkPermission('leave.reject', 'approve'), asyncHandler(async (req, res) => {
  const leaveRequestId = Number(req.params.id);

  const request = await prisma.leaveRequest.findUnique({ where: { id: leaveRequestId } });
  if (!request) {
    throw new HttpError(404, 'Leave request not found');
  }

  const updated = await prisma.leaveRequest.update({
    where: { id: leaveRequestId },
    data: {
      status: 'REJECTED',
      rejectionReason: req.body.rejectionReason || 'Rejected by Admin',
    },
  });

  res.json({ success: true, message: 'Leave request rejected', data: updated });
}));

router.get('/:id', asyncHandler(async (req, res) => {
  const data = await prisma.leaveRequest.findFirst({
    where: { id: Number(req.params.id) },
    include: { leaveType: true, employee: true },
  });
  res.json({ success: true, data });
}));

router.delete('/:id', asyncHandler(async (req, res) => {
  await prisma.leaveRequest.update({ where: { id: Number(req.params.id) }, data: { status: 'CANCELLED' } });
  res.json({ success: true });
}));

export default router;
