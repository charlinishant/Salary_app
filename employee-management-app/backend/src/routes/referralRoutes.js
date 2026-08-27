import { Router } from 'express';
import { prisma } from '../config/prisma.js';
import { requireAuth } from '../middleware/auth.js';
import { asyncHandler } from '../utils/asyncHandler.js';

const router = Router();
router.use(requireAuth);
router.get('/me', asyncHandler(async (req, res) => {
  const data = await prisma.referral.findMany({ where: { employeeId: req.user.employeeId }, orderBy: { createdAt: 'desc' } });
  res.json({ success: true, data });
}));
router.post('/', asyncHandler(async (req, res) => {
  const data = await prisma.referral.create({ data: { ...req.body, employeeId: req.user.employeeId } });
  res.status(201).json({ success: true, data });
}));
export default router;
