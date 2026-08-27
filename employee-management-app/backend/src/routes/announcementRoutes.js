import { Router } from 'express';
import { prisma } from '../config/prisma.js';
import { requireAuth } from '../middleware/auth.js';
import { asyncHandler } from '../utils/asyncHandler.js';

const router = Router();

router.use(requireAuth);
router.get('/', asyncHandler(async (_req, res) => {
  const data = await prisma.announcement.findMany({ orderBy: { publishedAt: 'desc' } });
  res.json({ success: true, data });
}));
router.get('/:id', asyncHandler(async (req, res) => {
  const data = await prisma.announcement.findUnique({ where: { id: Number(req.params.id) } });
  res.json({ success: true, data });
}));

export default router;
