import { prisma } from '../config/prisma.js';
import { asyncHandler } from '../utils/asyncHandler.js';

export const dashboardController = {
  // GET /api/dashboard (Employee Dashboard or auto-detected)
  index: asyncHandler(async (req, res) => {
    const role = (req.user.role || 'EMPLOYEE').toUpperCase();
    if (role === 'ADMIN') {
      return dashboardController.adminSummary(req, res);
    }
    return dashboardController.employeeSummary(req, res);
  }),

  // GET /api/dashboard/admin
  adminSummary: asyncHandler(async (_req, res) => {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const todayEnd = new Date();
    todayEnd.setHours(23, 59, 59, 999);

    const [
      totalEmployees,
      activeEmployees,
      todayAttendances,
      pendingLeaves,
      pendingExpenses,
      recentEmployees,
      departments,
    ] = await Promise.all([
      prisma.employee.count(),
      prisma.employee.count({ where: { user: { isActive: true } } }),
      prisma.attendance.findMany({
        where: { attendanceDate: { gte: today, lte: todayEnd } },
        include: { employee: { include: { department: true } } },
      }),
      prisma.leaveRequest.count({ where: { status: 'PENDING' } }),
      prisma.expense.count({ where: { status: 'PENDING' } }),
      prisma.employee.findMany({
        take: 5,
        orderBy: { createdAt: 'desc' },
        include: { department: true, designation: true },
      }),
      prisma.department.findMany({
        include: { employees: { select: { id: true } } },
      }),
    ]);

    const presentToday = todayAttendances.filter((a) => a.attendanceStatus === 'PRESENT').length;
    const lateToday = todayAttendances.filter((a) => a.attendanceStatus === 'LATE').length;
    const onLeave = todayAttendances.filter((a) => a.attendanceStatus === 'LEAVE').length;
    const punchedIn = todayAttendances.filter((a) => a.punchInTime && !a.punchOutTime).length;
    const punchCompleted = todayAttendances.filter((a) => a.punchInTime && a.punchOutTime).length;
    const absentToday = Math.max(0, activeEmployees - (presentToday + lateToday + onLeave));

    const departmentStats = departments.map((dept) => {
      const deptEmpIds = new Set(dept.employees.map((e) => e.id));
      const presentCount = todayAttendances.filter((a) => deptEmpIds.has(a.employeeId)).length;
      return {
        id: dept.id,
        name: dept.name,
        totalEmployees: dept.employees.length,
        presentToday: presentCount,
      };
    });

    const formattedRecentAttendance = todayAttendances.slice(0, 10).map((a) => ({
      id: a.id,
      employeeName: `${a.employee.firstName} ${a.employee.lastName}`,
      department: a.employee.department?.name || 'N/A',
      status: a.attendanceStatus,
      punchInTime: a.punchInTime,
      punchOutTime: a.punchOutTime,
    }));

    res.json({
      success: true,
      data: {
        summary: {
          totalEmployees,
          activeEmployees,
          presentToday,
          absentToday,
          lateToday,
          onLeave,
          punchedIn,
          punchCompleted,
          pendingLeaves,
          pendingExpenses,
        },
        departmentStats,
        recentEmployees: recentEmployees.map((e) => ({
          id: e.id,
          name: `${e.firstName} ${e.lastName}`,
          code: e.employeeCode,
          department: e.department?.name || 'N/A',
          designation: e.designation?.name || 'N/A',
        })),
        recentAttendance: formattedRecentAttendance,
        pendingRequestsCount: pendingLeaves + pendingExpenses,
      },
    });
  }),

  // GET /api/dashboard/employee
  employeeSummary: asyncHandler(async (req, res) => {
    const employeeId = req.user.employeeId;
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const [employee, attendance, leaveBalances, pendingRequests, upcomingHoliday] = await Promise.all([
      prisma.employee.findUnique({
        where: { id: employeeId },
        include: { department: true, designation: true, shift: true },
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
