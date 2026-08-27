import { prisma } from '../config/prisma.js';
import { asyncHandler } from '../utils/asyncHandler.js';

export const dashboardController = {
  index: asyncHandler(async (req, res) => {
    const employeeId = req.user.employeeId;
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const [employee, attendance, leaveBalances, pendingRequests, upcomingHoliday] = await Promise.all([
      prisma.employee.findUnique({
        where: { id: employeeId },
        include: { department: true, designation: true },
      }),
      prisma.attendance.findFirst({ where: { employeeId, attendanceDate: today } }),
      prisma.leaveBalance.findMany({ where: { employeeId }, include: { leaveType: true } }),
      prisma.leaveRequest.count({ where: { employeeId, status: 'PENDING' } }),
      prisma.holiday.findFirst({ where: { date: { gte: today } }, orderBy: { date: 'asc' } }),
    ]);

    res.json({
      success: true,
      data: {
        employee,
        attendance,
        remainingLeave: leaveBalances.reduce((total, row) => total + row.remainingDays, 0),
        pendingRequests,
        upcomingHoliday,
      },
    });
  }),
};
