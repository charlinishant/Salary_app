import { Router } from 'express';
import { prisma } from '../config/prisma.js';
import { requireAuth } from '../middleware/auth.js';
import { asyncHandler } from '../utils/asyncHandler.js';

const router = Router();
router.use(requireAuth);
router.get('/current', asyncHandler(async (req, res) => {
  const data = await prisma.salaryStructure.findFirst({ where: { employeeId: req.user.employeeId }, orderBy: { effectiveFrom: 'desc' } });
  res.json({ success: true, data });
}));
router.get('/', asyncHandler(async (req, res) => {
  const data = await prisma.payslip.findMany({ where: { employeeId: req.user.employeeId }, orderBy: [{ year: 'desc' }, { month: 'desc' }] });
  res.json({ success: true, data });
}));
router.get('/:id', asyncHandler(async (req, res) => {
  const data = await prisma.payslip.findFirst({ where: { id: Number(req.params.id), employeeId: req.user.employeeId } });
  res.json({ success: true, data });
}));
export default router;
