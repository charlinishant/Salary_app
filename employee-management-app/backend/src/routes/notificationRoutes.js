import { Router } from 'express';
import { prisma } from '../config/prisma.js';
import { requireAuth } from '../middleware/auth.js';
import { asyncHandler } from '../utils/asyncHandler.js';

const router = Router();
router.use(requireAuth);
router.get('/', asyncHandler(async (req, res) => {
  const data = await prisma.notification.findMany({ where: { employeeId: req.user.employeeId }, orderBy: { createdAt: 'desc' } });
  res.json({ success: true, data });
}));
router.put('/:id/read', asyncHandler(async (req, res) => {
  const data = await prisma.notification.update({ where: { id: Number(req.params.id) }, data: { readAt: new Date() } });
  res.json({ success: true, data });
}));
router.put('/read-all', asyncHandler(async (req, res) => {
  await prisma.notification.updateMany({ where: { employeeId: req.user.employeeId, readAt: null }, data: { readAt: new Date() } });
  res.json({ success: true });
}));
export default router;
