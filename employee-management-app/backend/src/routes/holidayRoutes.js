import { Router } from 'express';
import { prisma } from '../config/prisma.js';
import { requireAuth } from '../middleware/auth.js';
import { asyncHandler } from '../utils/asyncHandler.js';

const router = Router();
router.get('/', requireAuth, asyncHandler(async (req, res) => {
  const { year, month } = req.query;
  const where = {};
  if (year && month) {
    where.date = { gte: new Date(Number(year), Number(month) - 1, 1), lt: new Date(Number(year), Number(month), 1) };
  } else if (year) {
    where.date = { gte: new Date(Number(year), 0, 1), lt: new Date(Number(year) + 1, 0, 1) };
  }
  const data = await prisma.holiday.findMany({ where, orderBy: { date: 'asc' } });
  res.json({ success: true, data });
}));
export default router;
