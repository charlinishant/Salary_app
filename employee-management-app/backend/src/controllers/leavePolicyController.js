import { prisma } from '../config/prisma.js';
import { asyncHandler } from '../utils/asyncHandler.js';
import { HttpError } from '../utils/httpError.js';

export const getLeaveTypes = asyncHandler(async (_req, res) => {
  const types = await prisma.leaveType.findMany({
    include: {
      _count: { select: { requests: true, balances: true } },
    },
    orderBy: { id: 'asc' },
  });

  res.json({
    success: true,
    message: 'Leave types retrieved successfully',
    data: types,
  });
});

export const createLeaveType = asyncHandler(async (req, res) => {
  const { name, code, isLimited, isPaid, annualAllocation, carryForward, maxCarryForward, requiresApproval, halfDayAllowed, color, isActive } = req.body;

  if (!name) {
    throw new HttpError(400, 'Leave Type Name is required');
  }

  const existing = await prisma.leaveType.findUnique({ where: { name } });
  if (existing) {
    throw new HttpError(400, 'Leave Type already exists');
  }

  const type = await prisma.leaveType.create({
    data: {
      name,
      code: code || name.substring(0, 4).toUpperCase(),
      isLimited: isLimited !== undefined ? Boolean(isLimited) : true,
      isPaid: isPaid !== undefined ? Boolean(isPaid) : true,
      annualAllocation: annualAllocation ? parseFloat(annualAllocation) : 12,
      carryForward: carryForward !== undefined ? Boolean(carryForward) : false,
      maxCarryForward: maxCarryForward ? parseFloat(maxCarryForward) : 0,
      requiresApproval: requiresApproval !== undefined ? Boolean(requiresApproval) : true,
      halfDayAllowed: halfDayAllowed !== undefined ? Boolean(halfDayAllowed) : true,
      color: color || '#3B82F6',
      isActive: isActive !== undefined ? Boolean(isActive) : true,
    },
  });

  res.status(201).json({
    success: true,
    message: 'Leave type created successfully',
    data: type,
  });
});

export const getLeavePolicies = asyncHandler(async (_req, res) => {
  const policies = await prisma.leavePolicy.findMany({
    include: {
      leaveType: true,
      company: { select: { id: true, name: true } },
    },
    orderBy: { createdAt: 'desc' },
  });

  res.json({
    success: true,
    message: 'Leave policies retrieved successfully',
    data: policies,
  });
});

export const createLeavePolicy = asyncHandler(async (req, res) => {
  const { name, companyId, leaveTypeId, annualBalance, monthlyAccrual, carryForward, maxConsecutiveDays, minNoticePeriodDays, docsRequiredAfterDays, allowNegativeBalance, approvalRequired, approvalFlow } = req.body;

  if (!name || !leaveTypeId || !annualBalance) {
    throw new HttpError(400, 'Policy Name, Leave Type, and Annual Balance are required');
  }

  let finalCompanyId = companyId;
  if (!finalCompanyId) {
    const comp = await prisma.company.findFirst();
    if (comp) finalCompanyId = comp.id;
  }

  const policy = await prisma.leavePolicy.create({
    data: {
      name,
      companyId: finalCompanyId,
      leaveTypeId: parseInt(leaveTypeId),
      annualBalance: parseFloat(annualBalance),
      monthlyAccrual: monthlyAccrual !== undefined ? parseFloat(monthlyAccrual) : 1.0,
      carryForward: carryForward !== undefined ? Boolean(carryForward) : false,
      maxConsecutiveDays: maxConsecutiveDays !== undefined ? parseInt(maxConsecutiveDays) : 14,
      minNoticePeriodDays: minNoticePeriodDays !== undefined ? parseInt(minNoticePeriodDays) : 1,
      docsRequiredAfterDays: docsRequiredAfterDays !== undefined ? parseInt(docsRequiredAfterDays) : 3,
      allowNegativeBalance: allowNegativeBalance !== undefined ? Boolean(allowNegativeBalance) : false,
      approvalRequired: approvalRequired !== undefined ? Boolean(approvalRequired) : true,
      approvalFlow: approvalFlow || 'MANAGER_THEN_HR',
    },
    include: { leaveType: true },
  });

  res.status(201).json({
    success: true,
    message: 'Leave policy created successfully',
    data: policy,
  });
});
