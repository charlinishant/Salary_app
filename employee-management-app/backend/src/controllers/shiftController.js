import { prisma } from '../config/prisma.js';
import { asyncHandler } from '../utils/asyncHandler.js';
import { HttpError } from '../utils/httpError.js';

export const getShifts = asyncHandler(async (req, res) => {
  const { search, status } = req.query;

  const where = {};
  if (status && status !== 'All') {
    where.isActive = status === 'Active';
  }
  if (search) {
    where.OR = [
      { name: { contains: search } },
      { code: { contains: search } },
    ];
  }

  const shifts = await prisma.shift.findMany({
    where,
    include: {
      company: { select: { id: true, name: true } },
      branch: { select: { id: true, name: true } },
      _count: { select: { employees: true, shiftAssignments: true } },
    },
    orderBy: { createdAt: 'desc' },
  });

  const formatted = shifts.map((s) => ({
    ...s,
    assignedEmployeesCount: s._count.employees,
    status: s.isActive ? 'Active' : 'Inactive',
  }));

  res.json({
    success: true,
    message: 'Shifts retrieved successfully',
    data: formatted,
  });
});

export const createShift = asyncHandler(async (req, res) => {
  const {
    name,
    code,
    companyId,
    branchId,
    startTime,
    endTime,
    graceMinutes,
    halfDayHours,
    fullDayHours,
    breakMinutes,
    earlyCheckInLimit,
    lateMarkAfter,
    earlyExitBefore,
    overtimeAfter,
    weeklyOff,
    isOvernight,
    isActive,
  } = req.body;

  if (!name || !startTime || !endTime) {
    throw new HttpError(400, 'Shift Name, Start Time, and End Time are required');
  }

  let finalCompanyId = companyId;
  if (!finalCompanyId) {
    const comp = await prisma.company.findFirst();
    if (comp) finalCompanyId = comp.id;
  }

  const shiftCode = code || `SFT-${name.substring(0, 3).toUpperCase()}-${Date.now().toString().slice(-4)}`;

  const shift = await prisma.shift.create({
    data: {
      name,
      code: shiftCode,
      companyId: finalCompanyId,
      branchId: branchId ? parseInt(branchId) : null,
      startTime,
      endTime,
      graceMinutes: graceMinutes !== undefined ? parseInt(graceMinutes) : 15,
      halfDayHours: halfDayHours !== undefined ? parseFloat(halfDayHours) : 4,
      fullDayHours: fullDayHours !== undefined ? parseFloat(fullDayHours) : 8,
      breakMinutes: breakMinutes !== undefined ? parseInt(breakMinutes) : 60,
      earlyCheckInLimit: earlyCheckInLimit !== undefined ? parseInt(earlyCheckInLimit) : 60,
      lateMarkAfter: lateMarkAfter !== undefined ? parseInt(lateMarkAfter) : 15,
      earlyExitBefore: earlyExitBefore !== undefined ? parseInt(earlyExitBefore) : 15,
      overtimeAfter: overtimeAfter !== undefined ? parseInt(overtimeAfter) : 480,
      weeklyOff: weeklyOff || 'Sunday',
      isOvernight: isOvernight !== undefined ? Boolean(isOvernight) : false,
      isActive: isActive !== undefined ? Boolean(isActive) : true,
    },
  });

  res.status(201).json({
    success: true,
    message: 'Shift created successfully',
    data: shift,
  });
});

export const updateShift = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const shiftId = parseInt(id);

  const existing = await prisma.shift.findUnique({ where: { id: shiftId } });
  if (!existing) {
    throw new HttpError(404, 'Shift not found');
  }

  const updated = await prisma.shift.update({
    where: { id: shiftId },
    data: {
      name: req.body.name,
      code: req.body.code,
      branchId: req.body.branchId ? parseInt(req.body.branchId) : null,
      startTime: req.body.startTime,
      endTime: req.body.endTime,
      graceMinutes: req.body.graceMinutes !== undefined ? parseInt(req.body.graceMinutes) : undefined,
      halfDayHours: req.body.halfDayHours !== undefined ? parseFloat(req.body.halfDayHours) : undefined,
      fullDayHours: req.body.fullDayHours !== undefined ? parseFloat(req.body.fullDayHours) : undefined,
      breakMinutes: req.body.breakMinutes !== undefined ? parseInt(req.body.breakMinutes) : undefined,
      earlyCheckInLimit: req.body.earlyCheckInLimit !== undefined ? parseInt(req.body.earlyCheckInLimit) : undefined,
      lateMarkAfter: req.body.lateMarkAfter !== undefined ? parseInt(req.body.lateMarkAfter) : undefined,
      earlyExitBefore: req.body.earlyExitBefore !== undefined ? parseInt(req.body.earlyExitBefore) : undefined,
      overtimeAfter: req.body.overtimeAfter !== undefined ? parseInt(req.body.overtimeAfter) : undefined,
      weeklyOff: req.body.weeklyOff,
      isOvernight: req.body.isOvernight !== undefined ? Boolean(req.body.isOvernight) : undefined,
      isActive: req.body.isActive !== undefined ? Boolean(req.body.isActive) : undefined,
    },
  });

  res.json({
    success: true,
    message: 'Shift updated successfully',
    data: updated,
  });
});

export const assignShift = asyncHandler(async (req, res) => {
  const { shiftId, employeeIds, departmentId, branchId, effectiveFrom, effectiveTo } = req.body;

  if (!shiftId) {
    throw new HttpError(400, 'Shift ID is required');
  }

  const shift = await prisma.shift.findUnique({ where: { id: parseInt(shiftId) } });
  if (!shift) {
    throw new HttpError(404, 'Shift not found');
  }

  let targetEmployeeIds = [];

  if (Array.isArray(employeeIds) && employeeIds.length > 0) {
    targetEmployeeIds = employeeIds.map((id) => parseInt(id));
  } else if (departmentId) {
    const emps = await prisma.employee.findMany({
      where: { departmentId: parseInt(departmentId) },
      select: { id: true },
    });
    targetEmployeeIds = emps.map((e) => e.id);
  } else if (branchId) {
    const emps = await prisma.employee.findMany({
      where: { branchId: parseInt(branchId) },
      select: { id: true },
    });
    targetEmployeeIds = emps.map((e) => e.id);
  }

  if (targetEmployeeIds.length === 0) {
    throw new HttpError(400, 'No target employees found to assign shift');
  }

  const fromDate = effectiveFrom ? new Date(effectiveFrom) : new Date();
  const toDate = effectiveTo ? new Date(effectiveTo) : null;

  const assignments = [];
  for (const empId of targetEmployeeIds) {
    await prisma.employee.update({
      where: { id: empId },
      data: { shiftId: shift.id },
    });

    const assignment = await prisma.shiftAssignment.create({
      data: {
        employeeId: empId,
        shiftId: shift.id,
        effectiveFrom: fromDate,
        effectiveTo: toDate,
        assignedBy: req.user.email,
      },
    });
    assignments.push(assignment);
  }

  res.json({
    success: true,
    message: `Shift '${shift.name}' assigned to ${targetEmployeeIds.length} employee(s) successfully`,
    data: { assignedCount: targetEmployeeIds.length, assignments },
  });
});
