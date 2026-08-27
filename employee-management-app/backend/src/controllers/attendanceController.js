import { prisma } from '../config/prisma.js';
import { HttpError } from '../utils/httpError.js';
import { asyncHandler } from '../utils/asyncHandler.js';

const getTodayOnly = () => {
  const date = new Date();
  date.setHours(0, 0, 0, 0);
  return date;
};


const formatTime12h = (dateObj) => {
  if (!dateObj) return null;
  const d = new Date(dateObj);
  let hours = d.getHours();
  const minutes = String(d.getMinutes()).padStart(2, '0');
  const ampm = hours >= 12 ? 'PM' : 'AM';
  hours = hours % 12 || 12;
  return `${String(hours).padStart(2, '0')}:${minutes} ${ampm}`;
};

export const attendanceController = {
  // GET /api/attendance/today
  today: asyncHandler(async (req, res) => {
    const employeeId = req.user.employeeId;
    const attendanceDate = getTodayOnly();
    const data = await prisma.attendance.findFirst({
      where: { employeeId, attendanceDate },
    });

    const canPunchIn = !data || !data.punchInTime;
    const canPunchOut = Boolean(data && data.punchInTime && !data.punchOutTime);

    res.json({
      success: true,
      attendance: data
        ? {
          id: data.id,
          date: data.attendanceDate.toISOString().split('T')[0],
          status: data.attendanceStatus,
          checkIn: formatTime12h(data.punchInTime),
          checkOut: formatTime12h(data.punchOutTime),
          punchInSelfie: data.punchInSelfie,
          punchOutSelfie: data.punchOutSelfie,
          workingMinutes: data.totalWorkingMinutes || 0,
          canPunchIn,
          canPunchOut,
        }
        : {
          date: attendanceDate.toISOString().split('T')[0],
          status: 'NOT_PUNCHED_IN',
          checkIn: null,
          checkOut: null,
          workingMinutes: 0,
          canPunchIn: true,
          canPunchOut: false,
        },
      raw: data,
    });
  }),


  // GET /api/attendance/history or /my-history
  history: asyncHandler(async (req, res) => {
    const employeeId = req.user.employeeId;
    const { month, year, status } = req.query;
    const where = { employeeId };

    if (status) where.attendanceStatus = status;
    if (month && year) {
      const start = new Date(Number(year), Number(month) - 1, 1);
      const end = new Date(Number(year), Number(month), 1);
      where.attendanceDate = { gte: start, lt: end };
    }

    const records = await prisma.attendance.findMany({
      where,
      orderBy: { attendanceDate: 'desc' },
    });

    const formatted = records.map((rec) => {
      const hours = rec.totalWorkingMinutes ? Math.floor(rec.totalWorkingMinutes / 60) : 0;
      const mins = rec.totalWorkingMinutes ? rec.totalWorkingMinutes % 60 : 0;
      return {
        id: rec.id,
        date: rec.attendanceDate,
        status: rec.attendanceStatus,
        checkIn: formatTime12h(rec.punchInTime),
        checkOut: formatTime12h(rec.punchOutTime),
        punchInSelfie: rec.punchInSelfie,
        punchOutSelfie: rec.punchOutSelfie,
        workingHoursFormatted: rec.totalWorkingMinutes ? `${hours}h ${mins}m` : rec.punchInTime && !rec.punchOutTime ? 'Running' : '--',
        totalWorkingMinutes: rec.totalWorkingMinutes,
      };
    });

    res.json({ success: true, data: formatted, raw: records });
  }),

  // POST /api/attendance/punch-in
  punchIn: asyncHandler(async (req, res) => {
    const employeeId = req.user.employeeId;
    if (!employeeId) throw new HttpError(400, 'Employee profile not associated with user');

    const employee = await prisma.employee.findUnique({
      where: { id: employeeId },
      include: { user: true, shift: true },
    });
    if (!employee || !employee.user.isActive) {
      throw new HttpError(403, 'Employee account is inactive or invalid');
    }

    const selfieUrl = req.file
      ? `/${req.file.path.replaceAll('\\', '/')}`
      : (req.body.selfieUrl || req.body.selfie || null);

    if (!selfieUrl) throw new HttpError(400, 'Check-in selfie image is required');

    const now = new Date();
    const attendanceDate = getTodayOnly();

    const existing = await prisma.attendance.findFirst({
      where: { employeeId, attendanceDate },
    });

    if (existing && existing.punchInTime) {
      throw new HttpError(409, 'You have already punched in today.');
    }

    let status = 'PRESENT';
    let lateMinutes = 0;

    // Check shift start time if assigned
    if (employee.shift && employee.shift.startTime) {
      const [sh, sm] = employee.shift.startTime.split(':').map(Number);
      const shiftStart = new Date(now);
      shiftStart.setHours(sh, sm + (employee.shift.graceMinutes || 15), 0, 0);

      if (now > shiftStart) {
        status = 'LATE';
        lateMinutes = Math.round((now - shiftStart) / 60000);
      }
    }

    let record;
    if (existing) {
      record = await prisma.attendance.update({
        where: { id: existing.id },
        data: {
          punchInTime: now,
          punchInSelfie: selfieUrl,
          punchInLatitude: req.body.latitude ? Number(req.body.latitude) : null,
          punchInLongitude: req.body.longitude ? Number(req.body.longitude) : null,
          punchInAddress: req.body.address || null,
          attendanceStatus: status,
          lateMinutes,
        },
      });
    } else {
      record = await prisma.attendance.create({
        data: {
          employeeId,
          attendanceDate,
          punchInTime: now,
          punchInSelfie: selfieUrl,
          punchInLatitude: req.body.latitude ? Number(req.body.latitude) : null,
          punchInLongitude: req.body.longitude ? Number(req.body.longitude) : null,
          punchInAddress: req.body.address || null,
          attendanceStatus: status,
          lateMinutes,
          attendanceMode: 'SELFIE',
        },
      });
    }

    res.status(201).json({
      success: true,
      message: 'Attendance marked successfully',
      data: {
        id: record.id,
        status: record.attendanceStatus,
        checkInTime: formatTime12h(record.punchInTime),
        attendanceDate: record.attendanceDate,
      },
    });
  }),

  // POST /api/attendance/punch-out
  punchOut: asyncHandler(async (req, res) => {
    const employeeId = req.user.employeeId;
    if (!employeeId) throw new HttpError(400, 'Employee profile not associated with user');

    const employee = await prisma.employee.findUnique({
      where: { id: employeeId },
      include: { user: true },
    });
    if (!employee || !employee.user.isActive) {
      throw new HttpError(403, 'Employee account is inactive or invalid');
    }

    const selfieUrl = req.file
      ? `/${req.file.path.replaceAll('\\', '/')}`
      : (req.body.selfieUrl || req.body.selfie || null);

    if (!selfieUrl) throw new HttpError(400, 'Check-out selfie image is required');

    const now = new Date();
    const attendanceDate = getTodayOnly();
    const activeRecord = await prisma.attendance.findFirst({
      where: { employeeId, attendanceDate },
    });

    if (!activeRecord || !activeRecord.punchInTime) {
      throw new HttpError(409, 'No punch-in record found for today.');
    }
    if (activeRecord.punchOutTime) {
      throw new HttpError(409, 'You have already punched out today.');
    }

    const minutes = Math.max(0, Math.round((now - activeRecord.punchInTime) / 60000));

    const updated = await prisma.attendance.update({
      where: { id: activeRecord.id },
      data: {
        punchOutTime: now,
        punchOutSelfie: selfieUrl,
        punchOutLatitude: req.body.latitude ? Number(req.body.latitude) : null,
        punchOutLongitude: req.body.longitude ? Number(req.body.longitude) : null,
        punchOutAddress: req.body.address || null,
        totalWorkingMinutes: minutes,
      },
    });

    const hours = Math.floor(minutes / 60);
    const mins = minutes % 60;

    res.json({
      success: true,
      message: 'Punch out successful',
      data: {
        id: updated.id,
        checkInTime: formatTime12h(updated.punchInTime),
        checkOutTime: formatTime12h(updated.punchOutTime),
        workingMinutes: minutes,
        workingHoursFormatted: `${hours}h ${mins}m`,
      },
    });
  }),

  // ADMIN: GET /api/admin/attendance (Get attendance management list & summary)
  adminList: asyncHandler(async (req, res) => {
    const { date, startDate, endDate, departmentId, designationId, status, search, page = 1, limit = 20 } = req.query;
    const skip = (Number(page) - 1) * Number(limit);
    const take = Number(limit);

    let dateFilter = getTodayOnly();
    if (date) {
      dateFilter = new Date(date);
      dateFilter.setHours(0, 0, 0, 0);
    }

    const where = {};
    if (startDate && endDate) {
      const s = new Date(startDate);
      s.setHours(0, 0, 0, 0);
      const e = new Date(endDate);
      e.setHours(23, 59, 59, 999);
      where.attendanceDate = { gte: s, lte: e };
    } else {
      const endOfFilterDay = new Date(dateFilter);
      endOfFilterDay.setHours(23, 59, 59, 999);
      where.attendanceDate = { gte: dateFilter, lte: endOfFilterDay };
    }

    if (status) where.attendanceStatus = status;

    if (search || departmentId || designationId) {
      where.employee = {};
      if (departmentId) where.employee.departmentId = Number(departmentId);
      if (designationId) where.employee.designationId = Number(designationId);
      if (search) {
        where.employee.OR = [
          { firstName: { contains: search } },
          { lastName: { contains: search } },
          { employeeCode: { contains: search } },
        ];
      }
    }

    const [totalEmployees, totalRecords, records] = await Promise.all([
      prisma.employee.count({ where: { user: { isActive: true } } }),
      prisma.attendance.count({ where }),
      prisma.attendance.findMany({
        where,
        skip,
        take,
        orderBy: { attendanceDate: 'desc' },
        include: {
          employee: {
            include: { department: true, designation: true, shift: true },
          },
        },
      }),
    ]);

    // Summary counts for current filter day
    const dayStart = new Date(dateFilter);
    dayStart.setHours(0, 0, 0, 0);
    const dayEnd = new Date(dateFilter);
    dayEnd.setHours(23, 59, 59, 999);

    const summaryRecords = await prisma.attendance.findMany({
      where: { attendanceDate: { gte: dayStart, lte: dayEnd } },
    });

    const presentToday = summaryRecords.filter((r) => r.attendanceStatus === 'PRESENT').length;
    const lateToday = summaryRecords.filter((r) => r.attendanceStatus === 'LATE').length;
    const onLeave = summaryRecords.filter((r) => r.attendanceStatus === 'LEAVE').length;
    const absentToday = Math.max(0, totalEmployees - (presentToday + lateToday + onLeave));

    const formattedRecords = records.map((r) => {
      const hours = r.totalWorkingMinutes ? Math.floor(r.totalWorkingMinutes / 60) : 0;
      const mins = r.totalWorkingMinutes ? r.totalWorkingMinutes % 60 : 0;
      return {
        id: r.id,
        employeeId: r.employeeId,
        employeeCode: r.employee.employeeCode,
        employeeName: `${r.employee.firstName} ${r.employee.lastName}`.trim(),
        profilePhoto: r.employee.profilePhoto,
        department: r.employee.department?.name || 'N/A',
        designation: r.employee.designation?.name || 'N/A',
        date: r.attendanceDate,
        status: r.attendanceStatus,
        punchInTime: formatTime12h(r.punchInTime),
        punchOutTime: formatTime12h(r.punchOutTime),
        punchInSelfie: r.punchInSelfie,
        punchOutSelfie: r.punchOutSelfie,
        workingHours: r.totalWorkingMinutes ? `${hours}h ${mins}m` : r.punchInTime && !r.punchOutTime ? 'Running' : '--',
        lateMinutes: r.lateMinutes,
        updatedBy: r.updatedBy,
        changeReason: r.changeReason,
      };
    });

    res.json({
      success: true,
      summary: {
        totalEmployees,
        presentToday,
        absentToday,
        lateToday,
        onLeave,
      },
      data: formattedRecords,
      pagination: {
        total: totalRecords,
        page: Number(page),
        limit: Number(limit),
        totalPages: Math.ceil(totalRecords / Number(limit)),
      },
    });
  }),

  // ADMIN: GET /api/admin/attendance/:id
  adminGetById: asyncHandler(async (req, res) => {
    const id = Number(req.params.id);
    const data = await prisma.attendance.findUnique({
      where: { id },
      include: {
        employee: {
          include: { department: true, designation: true, shift: true },
        },
      },
    });
    if (!data) throw new HttpError(404, 'Attendance record not found');
    res.json({ success: true, data });
  }),

  // ADMIN: PUT /api/admin/attendance/:id (Manual Correction)
  adminUpdate: asyncHandler(async (req, res) => {
    const id = Number(req.params.id);
    const { attendanceStatus, punchInTime, punchOutTime, remarks, changeReason } = req.body;

    if (!changeReason || changeReason.trim() === '') {
      throw new HttpError(400, 'Reason for modification is required for admin corrections');
    }

    const existing = await prisma.attendance.findUnique({ where: { id } });
    if (!existing) throw new HttpError(404, 'Attendance record not found');

    const updateData = {
      changeReason,
      updatedBy: req.user.email || `Admin (#${req.user.id})`,
    };

    if (attendanceStatus) updateData.attendanceStatus = attendanceStatus;
    if (remarks !== undefined) updateData.remarks = remarks;

    if (punchInTime) updateData.punchInTime = new Date(punchInTime);
    if (punchOutTime) updateData.punchOutTime = new Date(punchOutTime);

    // Recalculate working minutes if both times exist
    const pIn = updateData.punchInTime || existing.punchInTime;
    const pOut = updateData.punchOutTime || existing.punchOutTime;
    if (pIn && pOut) {
      updateData.totalWorkingMinutes = Math.max(0, Math.round((new Date(pOut) - new Date(pIn)) / 60000));
    }

    const updated = await prisma.attendance.update({
      where: { id },
      data: updateData,
    });

    res.json({ success: true, message: 'Attendance record updated by admin', data: updated });
  }),
};
