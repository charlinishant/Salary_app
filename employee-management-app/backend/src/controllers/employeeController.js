import bcrypt from 'bcrypt';
import { prisma } from '../config/prisma.js';
import { asyncHandler } from '../utils/asyncHandler.js';
import { HttpError } from '../utils/httpError.js';

const getTodayRange = () => {
  const start = new Date();
  start.setHours(0, 0, 0, 0);
  const end = new Date();
  end.setHours(23, 59, 59, 999);
  return { start, end };
};

export const employeeController = {
  // GET /api/employees/me
  me: asyncHandler(async (req, res) => {
    const data = await prisma.employee.findUnique({
      where: { id: req.user.employeeId },
      include: {
        department: true,
        designation: true,
        shift: true,
        roleRef: true,
        company: true,
        branchRef: true,
        user: { select: { email: true, role: true, isActive: true } },
      },
    });
    res.json({ success: true, data });
  }),

  // PUT /api/employees/me
  updateMe: asyncHandler(async (req, res) => {
    const allowed = (({
      phone,
      address,
      bankName,
      accountNumber,
      ifsc,
      branch,
      accountHolderName,
      upiId,
    }) => ({ phone, address, bankName, accountNumber, ifsc, branch, accountHolderName, upiId }))(req.body);

    const updateData = Object.fromEntries(Object.entries(allowed).filter(([, value]) => value !== undefined));
    if (req.file) {
      updateData.profilePhoto = `/${req.file.path.replaceAll('\\', '/')}`;
    }

    const data = await prisma.employee.update({
      where: { id: req.user.employeeId },
      data: updateData,
      include: {
        department: true,
        designation: true,
        shift: true,
        roleRef: true,
        user: { select: { email: true, role: true, isActive: true } },
      },
    });
    res.json({ success: true, data });
  }),

  // GET /api/employees (Admin list with filters, pagination & today's attendance status)
  list: asyncHandler(async (req, res) => {
    const { search, departmentId, designationId, status, page = 1, limit = 20 } = req.query;
    const skip = (Number(page) - 1) * Number(limit);
    const take = Number(limit);

    const where = {};
    if (search) {
      where.OR = [
        { firstName: { contains: search } },
        { lastName: { contains: search } },
        { employeeCode: { contains: search } },
        { email: { contains: search } },
        { phone: { contains: search } },
      ];
    }
    if (departmentId) where.departmentId = Number(departmentId);
    if (designationId) where.designationId = Number(designationId);
    if (status !== undefined && status !== '') {
      const isActive = status === 'active' || status === 'true' || status === '1';
      where.user = { isActive };
    }

    const [total, employees] = await Promise.all([
      prisma.employee.count({ where }),
      prisma.employee.findMany({
        where,
        skip,
        take,
        orderBy: { createdAt: 'desc' },
        include: {
          department: true,
          designation: true,
          shift: true,
          roleRef: true,
          user: { select: { isActive: true, role: true } },
        },
      }),
    ]);

    const { start, end } = getTodayRange();
    const employeeIds = employees.map((e) => e.id);

    const todayAttendances = await prisma.attendance.findMany({
      where: {
        employeeId: { in: employeeIds },
        attendanceDate: { gte: start, lte: end },
      },
    });

    const attendanceMap = new Map(todayAttendances.map((a) => [a.employeeId, a]));

    const data = employees.map((emp) => {
      const att = attendanceMap.get(emp.id);
      return {
        ...emp,
        name: `${emp.firstName} ${emp.lastName}`.trim(),
        todayAttendance: att
          ? {
            status: att.attendanceStatus,
            punchInTime: att.punchInTime,
            punchOutTime: att.punchOutTime,
          }
          : { status: 'ABSENT', punchInTime: null, punchOutTime: null },
      };
    });

    res.json({
      success: true,
      data,
      pagination: {
        total,
        page: Number(page),
        limit: Number(limit),
        totalPages: Math.ceil(total / Number(limit)),
      },
    });
  }),

  // GET /api/employees/:id
  getById: asyncHandler(async (req, res) => {
    const id = Number(req.params.id);
    const data = await prisma.employee.findUnique({
      where: { id },
      include: {
        department: true,
        designation: true,
        shift: true,
        roleRef: true,
        company: true,
        branchRef: true,
        user: { select: { email: true, role: true, isActive: true } },
        documents: true,
      },
    });
    if (!data) throw new HttpError(404, 'Employee not found');
    res.json({ success: true, data: { ...data, name: `${data.firstName} ${data.lastName}`.trim() } });
  }),

  // POST /api/employees (Add Employee)
  create: asyncHandler(async (req, res) => {
    const {
      firstName,
      lastName,
      email,
      phone,
      gender,
      dateOfBirth,
      address,
      departmentId,
      designationId,
      joiningDate,
      employmentType = 'FULL_TIME',
      reportingManager,
      shiftId,
      workLocation,
      bankName,
      accountNumber,
      ifsc,
      branch,
      accountHolderName,
      upiId,
      appRole = 'EMPLOYEE',
    } = req.body;

    if (!firstName || !lastName || !email || !phone) {
      throw new HttpError(400, 'First name, last name, email, and phone are required');
    }

    const existingUser = await prisma.user.findUnique({ where: { email } });
    if (existingUser) throw new HttpError(400, 'User with this email already exists');

    // Auto-generate employee code (EMP-0001 format)
    const count = await prisma.employee.count();
    const employeeCode = `EMP-${String(count + 1).padStart(4, '0')}`;

    const passwordHash = await bcrypt.hash('Password@123', 10);
    const roleEnum = appRole === 'ADMIN' ? 'ADMIN' : 'EMPLOYEE';

    const user = await prisma.user.create({
      data: {
        email,
        passwordHash,
        role: roleEnum,
        isActive: true,
      },
    });

    const profilePhotoUrl = req.file ? `/${req.file.path.replaceAll('\\', '/')}` : null;

    const employee = await prisma.employee.create({
      data: {
        userId: user.id,
        employeeCode,
        firstName,
        lastName,
        email,
        phone,
        gender: gender ? gender.toUpperCase() : null,
        dateOfBirth: dateOfBirth ? new Date(dateOfBirth) : null,
        address,
        profilePhoto: profilePhotoUrl,
        departmentId: departmentId ? Number(departmentId) : null,
        designationId: designationId ? Number(designationId) : null,
        shiftId: shiftId ? Number(shiftId) : null,
        joiningDate: joiningDate ? new Date(joiningDate) : new Date(),
        employmentType: employmentType ? employmentType.toUpperCase() : 'FULL_TIME',
        reportingManager,
        workLocation,
        bankName,
        accountNumber,
        ifsc,
        branch,
        accountHolderName,
        upiId,
      },
      include: { department: true, designation: true, shift: true },
    });

    res.status(201).json({ success: true, data: employee });
  }),

  // PUT /api/employees/:id
  update: asyncHandler(async (req, res) => {
    const id = Number(req.params.id);
    const employeeExists = await prisma.employee.findUnique({ where: { id } });
    if (!employeeExists) throw new HttpError(404, 'Employee not found');

    const updateData = { ...req.body };
    delete updateData.id;
    delete updateData.userId;
    delete updateData.employeeCode;

    if (req.file) {
      updateData.profilePhoto = `/${req.file.path.replaceAll('\\', '/')}`;
    }
    if (updateData.departmentId) updateData.departmentId = Number(updateData.departmentId);
    if (updateData.designationId) updateData.designationId = Number(updateData.designationId);
    if (updateData.shiftId) updateData.shiftId = Number(updateData.shiftId);
    if (updateData.dateOfBirth) updateData.dateOfBirth = new Date(updateData.dateOfBirth);
    if (updateData.joiningDate) updateData.joiningDate = new Date(updateData.joiningDate);

    const updated = await prisma.employee.update({
      where: { id },
      data: updateData,
      include: { department: true, designation: true, shift: true },
    });

    res.json({ success: true, data: updated });
  }),

  // PATCH /api/employees/:id/status (Toggle Activate/Deactivate)
  toggleStatus: asyncHandler(async (req, res) => {
    const id = Number(req.params.id);
    const emp = await prisma.employee.findUnique({ where: { id }, include: { user: true } });
    if (!emp) throw new HttpError(404, 'Employee not found');

    const newStatus = req.body.isActive !== undefined ? Boolean(req.body.isActive) : !emp.user.isActive;

    await prisma.user.update({
      where: { id: emp.userId },
      data: { isActive: newStatus },
    });

    res.json({ success: true, message: `Employee status updated to ${newStatus ? 'Active' : 'Inactive'}`, isActive: newStatus });
  }),

  // GET /api/employees/:id/attendance (Employee attendance history for Admin)
  employeeAttendanceHistory: asyncHandler(async (req, res) => {
    const id = Number(req.params.id);
    const { month, year } = req.query;
    const where = { employeeId: id };

    if (month && year) {
      const start = new Date(Number(year), Number(month) - 1, 1);
      const end = new Date(Number(year), Number(month), 1);
      where.attendanceDate = { gte: start, lt: end };
    }

    const data = await prisma.attendance.findMany({
      where,
      orderBy: { attendanceDate: 'desc' },
    });

    res.json({ success: true, data });
  }),

};
