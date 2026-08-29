import { Router } from 'express';
import { prisma } from '../config/prisma.js';
import { requireAuth } from '../middleware/auth.js';
import { upload } from '../middleware/upload.js';
import { asyncHandler } from '../utils/asyncHandler.js';
import { HttpError } from '../utils/httpError.js';
import { getLeaveTypes, createLeaveType, getLeavePolicies, createLeavePolicy } from '../controllers/leavePolicyController.js';

const router = Router();
router.use(requireAuth);

// Types & Policies
router.get('/types', getLeaveTypes);
router.post('/types', createLeaveType);

router.get('/policies', getLeavePolicies);
router.post('/policies', createLeavePolicy);

// Balances
router.get('/balance', asyncHandler(async (req, res) => {
  let employeeId = req.user.employeeId;
  if (!employeeId && req.query.employeeId) {
    employeeId = Number(req.query.employeeId);
  }

  if (!employeeId) {
    const firstEmp = await prisma.employee.findFirst();
    employeeId = firstEmp?.id || 1;
  }

  // Ensure balance rows exist for all leave types
  const types = await prisma.leaveType.findMany({ where: { isActive: true } });
  const currentBalances = await prisma.leaveBalance.findMany({
    where: { employeeId },
    include: { leaveType: true },
  });

  const existingTypeIds = new Set(currentBalances.map((b) => b.leaveTypeId));
  const missing = types.filter((t) => !existingTypeIds.has(t.id));

  if (missing.length > 0) {
    for (const m of missing) {
      await prisma.leaveBalance.create({
        data: {
          employeeId,
          leaveTypeId: m.id,
          totalDays: m.annualAllocation || 12,
          usedDays: 0,
          remainingDays: m.annualAllocation || 12,
        },
      });
    }
  }

  const data = await prisma.leaveBalance.findMany({
    where: { employeeId },
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

// Create request
router.post('/', upload.single('attachment'), asyncHandler(async (req, res) => {
  const leaveTypeId = Number(req.body.leaveTypeId);
  const days = Number(req.body.numberOfDays || 1);
  const employeeId = req.user.employeeId || Number(req.body.employeeId) || 1;

  const fromDateRaw = req.body.fromDate || req.body.startDate || new Date();
  const toDateRaw = req.body.toDate || req.body.endDate || fromDateRaw;

  const data = await prisma.leaveRequest.create({
    data: {
      employeeId,
      leaveTypeId,
      fromDate: new Date(fromDateRaw),
      toDate: new Date(toDateRaw),
      numberOfDays: days,
      dayPart: req.body.dayPart || (req.body.isHalfDay ? 'FIRST_HALF' : 'FULL_DAY'),
      reason: req.body.reason || 'Personal Leave',
      attachmentUrl: req.file ? `/${req.file.path.replaceAll('\\', '/')}` : null,
      status: 'PENDING',
    },
    include: { leaveType: true },
  });

  res.status(201).json({ success: true, data });
}));

// Approve leave request
router.patch('/:id/approve', asyncHandler(async (req, res) => {
  const leaveRequestId = Number(req.params.id);

  const request = await prisma.leaveRequest.findUnique({
    where: { id: leaveRequestId },
    include: { leaveType: true },
  });

  if (!request) {
    throw new HttpError(404, 'Leave request not found');
  }

  const updated = await prisma.leaveRequest.update({
    where: { id: leaveRequestId },
    data: {
      status: 'APPROVED',
      approvedBy: req.user.email || 'Admin',
    },
  });

  // Deduct balance if balance record exists
  const balance = await prisma.leaveBalance.findFirst({
    where: { employeeId: request.employeeId, leaveTypeId: request.leaveTypeId },
  });

  if (balance) {
    await prisma.leaveBalance.update({
      where: { id: balance.id },
      data: {
        usedDays: balance.usedDays + request.numberOfDays,
        remainingDays: Math.max(0, balance.remainingDays - request.numberOfDays),
      },
    });
  }

  res.json({ success: true, message: 'Leave request approved', data: updated });
}));

// Reject leave request
router.patch('/:id/reject', asyncHandler(async (req, res) => {
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
