import { prisma } from '../config/prisma.js';
import { asyncHandler } from '../utils/asyncHandler.js';

export const reportController = {
  // GET /api/reports/employees
  employeeReport: asyncHandler(async (req, res) => {
    const { departmentId, designationId, status } = req.query;
    const where = {};
    if (departmentId) where.departmentId = Number(departmentId);
    if (designationId) where.designationId = Number(designationId);
    if (status) {
      where.user = { isActive: status === 'active' };
    }

    const employees = await prisma.employee.findMany({
      where,
      include: {
        department: true,
        designation: true,
        shift: true,
        user: { select: { isActive: true } },
      },
      orderBy: { firstName: 'asc' },
    });

    const data = employees.map((e) => ({
      id: e.id,
      employeeCode: e.employeeCode,
      name: `${e.firstName} ${e.lastName}`,
      email: e.email,
      phone: e.phone || 'N/A',
      department: e.department?.name || 'N/A',
      designation: e.designation?.name || 'N/A',
      joiningDate: e.joiningDate ? e.joiningDate.toISOString().split('T')[0] : 'N/A',
      employmentType: e.employmentType,
      status: e.user.isActive ? 'Active' : 'Inactive',
    }));

    res.json({ success: true, count: data.length, data });
  }),

  // GET /api/reports/attendance
  attendanceReport: asyncHandler(async (req, res) => {
    const { fromDate, toDate, departmentId, status } = req.query;
    const where = {};

    if (fromDate && toDate) {
      const s = new Date(fromDate);
      s.setHours(0, 0, 0, 0);
      const e = new Date(toDate);
      e.setHours(23, 59, 59, 999);
      where.attendanceDate = { gte: s, lte: e };
    }
    if (status) where.attendanceStatus = status;
    if (departmentId) where.employee = { departmentId: Number(departmentId) };

    const records = await prisma.attendance.findMany({
      where,
      include: { employee: { include: { department: true, designation: true } } },
      orderBy: { attendanceDate: 'desc' },
    });

    const data = records.map((r) => {
      const hours = r.totalWorkingMinutes ? Math.floor(r.totalWorkingMinutes / 60) : 0;
      const mins = r.totalWorkingMinutes ? r.totalWorkingMinutes % 60 : 0;
      return {
        id: r.id,
        employeeCode: r.employee.employeeCode,
        employeeName: `${r.employee.firstName} ${r.employee.lastName}`,
        department: r.employee.department?.name || 'N/A',
        date: r.attendanceDate.toISOString().split('T')[0],
        status: r.attendanceStatus,
        checkIn: r.punchInTime ? r.punchInTime.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' }) : '--',
        checkOut: r.punchOutTime ? r.punchOutTime.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' }) : '--',
        workingHours: `${hours}h ${mins}m`,
        lateMinutes: r.lateMinutes,
      };
    });

    res.json({ success: true, count: data.length, data });
  }),

  // GET /api/reports/late-attendance
  lateReport: asyncHandler(async (req, res) => {
    const { fromDate, toDate, departmentId } = req.query;
    const where = { attendanceStatus: 'LATE' };

    if (fromDate && toDate) {
      const s = new Date(fromDate);
      s.setHours(0, 0, 0, 0);
      const e = new Date(toDate);
      e.setHours(23, 59, 59, 999);
      where.attendanceDate = { gte: s, lte: e };
    }
    if (departmentId) where.employee = { departmentId: Number(departmentId) };

    const records = await prisma.attendance.findMany({
      where,
      include: { employee: { include: { department: true, designation: true } } },
      orderBy: { attendanceDate: 'desc' },
    });

    const data = records.map((r) => ({
      id: r.id,
      employeeCode: r.employee.employeeCode,
      employeeName: `${r.employee.firstName} ${r.employee.lastName}`,
      department: r.employee.department?.name || 'N/A',
      date: r.attendanceDate.toISOString().split('T')[0],
      checkIn: r.punchInTime ? r.punchInTime.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' }) : '--',
      lateMinutes: r.lateMinutes,
    }));

    res.json({ success: true, count: data.length, data });
  }),

  // GET /api/reports/working-hours
  workingHoursReport: asyncHandler(async (req, res) => {
    const { fromDate, toDate, departmentId } = req.query;
    const where = { totalWorkingMinutes: { gt: 0 } };

    if (fromDate && toDate) {
      const s = new Date(fromDate);
      s.setHours(0, 0, 0, 0);
      const e = new Date(toDate);
      e.setHours(23, 59, 59, 999);
      where.attendanceDate = { gte: s, lte: e };
    }
    if (departmentId) where.employee = { departmentId: Number(departmentId) };

    const records = await prisma.attendance.findMany({
      where,
      include: { employee: { include: { department: true } } },
      orderBy: { attendanceDate: 'desc' },
    });

    const data = records.map((r) => {
      const hours = Math.floor(r.totalWorkingMinutes / 60);
      const mins = r.totalWorkingMinutes % 60;
      return {
        id: r.id,
        employeeCode: r.employee.employeeCode,
        employeeName: `${r.employee.firstName} ${r.employee.lastName}`,
        department: r.employee.department?.name || 'N/A',
        date: r.attendanceDate.toISOString().split('T')[0],
        totalWorkingMinutes: r.totalWorkingMinutes,
        workingHoursFormatted: `${hours}h ${mins}m`,
      };
    });

    res.json({ success: true, count: data.length, data });
  }),

  // GET /api/reports/leave
  leaveReport: asyncHandler(async (req, res) => {
    const { status, leaveTypeId, departmentId } = req.query;
    const where = {};
    if (status) where.status = status;
    if (leaveTypeId) where.leaveTypeId = Number(leaveTypeId);
    if (departmentId) where.employee = { departmentId: Number(departmentId) };

    const requests = await prisma.leaveRequest.findMany({
      where,
      include: {
        employee: { include: { department: true } },
        leaveType: true,
      },
      orderBy: { createdAt: 'desc' },
    });

    const data = requests.map((r) => ({
      id: r.id,
      employeeCode: r.employee.employeeCode,
      employeeName: `${r.employee.firstName} ${r.employee.lastName}`,
      department: r.employee.department?.name || 'N/A',
      leaveType: r.leaveType.name,
      fromDate: r.fromDate.toISOString().split('T')[0],
      toDate: r.toDate.toISOString().split('T')[0],
      numberOfDays: r.numberOfDays,
      reason: r.reason,
      status: r.status,
    }));

    res.json({ success: true, count: data.length, data });
  }),

  // GET /api/reports/expenses
  expenseReport: asyncHandler(async (req, res) => {
    const { status, expenseType, departmentId } = req.query;
    const where = {};
    if (status) where.status = status;
    if (expenseType) where.expenseType = expenseType;
    if (departmentId) where.employee = { departmentId: Number(departmentId) };

    const expenses = await prisma.expense.findMany({
      where,
      include: { employee: { include: { department: true } } },
      orderBy: { date: 'desc' },
    });

    const data = expenses.map((e) => ({
      id: e.id,
      employeeCode: e.employee.employeeCode,
      employeeName: `${e.employee.firstName} ${e.employee.lastName}`,
      department: e.employee.department?.name || 'N/A',
      category: e.expenseType,
      amount: Number(e.amount),
      date: e.date.toISOString().split('T')[0],
      description: e.description || 'N/A',
      status: e.status,
    }));

    res.json({ success: true, count: data.length, data });
  }),

  // GET /api/reports/documents
  documentsReport: asyncHandler(async (req, res) => {
    const { documentType, status, departmentId } = req.query;
    const where = {};
    if (documentType) where.documentType = documentType;
    if (status) where.status = status;
    if (departmentId) where.employee = { departmentId: Number(departmentId) };

    const docs = await prisma.employeeDocument.findMany({
      where,
      include: { employee: { include: { department: true } } },
      orderBy: { createdAt: 'desc' },
    });

    const data = docs.map((d) => ({
      id: d.id,
      employeeCode: d.employee.employeeCode,
      employeeName: `${d.employee.firstName} ${d.employee.lastName}`,
      department: d.employee.department?.name || 'N/A',
      documentType: d.documentType,
      fileUrl: d.fileUrl,
      status: d.status,
      uploadedAt: d.createdAt.toISOString().split('T')[0],
    }));

    res.json({ success: true, count: data.length, data });
  }),
};
