import { prisma } from '../config/prisma.js';
import { HttpError } from '../utils/httpError.js';
import { asyncHandler } from '../utils/asyncHandler.js';

const todayOnly = () => {
  const date = new Date();
  date.setHours(0, 0, 0, 0);
  return date;
};

export const attendanceController = {
  today: asyncHandler(async (req, res) => {
    const data = await prisma.attendance.findFirst({
      where: { employeeId: req.user.employeeId, attendanceDate: todayOnly() },
    });
    res.json({ success: true, data });
  }),
  history: asyncHandler(async (req, res) => {
    const { month, year, status } = req.query;
    const where = { employeeId: req.user.employeeId };
    if (status) where.attendanceStatus = status;
    if (month && year) {
      const start = new Date(Number(year), Number(month) - 1, 1);
      const end = new Date(Number(year), Number(month), 1);
      where.attendanceDate = { gte: start, lt: end };
    }
    const data = await prisma.attendance.findMany({ where, orderBy: { attendanceDate: 'desc' } });
    res.json({ success: true, data });
  }),
  punchIn: asyncHandler(async (req, res) => {
    const employeeId = req.user.employeeId;
    const attendanceDate = todayOnly();
    const active = await prisma.attendance.findFirst({ where: { employeeId, attendanceDate, punchOutTime: null } });
    if (active) throw new HttpError(409, 'Already punched in');

    const data = await prisma.attendance.create({
      data: {
        employeeId,
        attendanceDate,
        punchInTime: new Date(),
        punchInSelfie: req.file ? `/${req.file.path.replaceAll('\\', '/')}` : null,
        punchInLatitude: req.body.latitude ? Number(req.body.latitude) : null,
        punchInLongitude: req.body.longitude ? Number(req.body.longitude) : null,
        punchInAddress: req.body.address,
        attendanceStatus: 'PRESENT',
        remarks: req.body.remarks,
      },
    });
    res.status(201).json({ success: true, data });
  }),
  punchOut: asyncHandler(async (req, res) => {
    const employeeId = req.user.employeeId;
    const attendanceDate = todayOnly();
    const active = await prisma.attendance.findFirst({ where: { employeeId, attendanceDate, punchOutTime: null } });
    if (!active) throw new HttpError(409, 'No active punch-in found');

    const punchOutTime = new Date();
    const minutes = Math.max(0, Math.round((punchOutTime - active.punchInTime) / 60000));
    const data = await prisma.attendance.update({
      where: { id: active.id },
      data: {
        punchOutTime,
        punchOutSelfie: req.file ? `/${req.file.path.replaceAll('\\', '/')}` : null,
        punchOutLatitude: req.body.latitude ? Number(req.body.latitude) : null,
        punchOutLongitude: req.body.longitude ? Number(req.body.longitude) : null,
        punchOutAddress: req.body.address,
        totalWorkingMinutes: minutes,
        remarks: req.body.remarks,
      },
    });
    res.json({ success: true, data });
  }),
};
