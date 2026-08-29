import { Router } from 'express';
import { prisma } from '../config/prisma.js';
import { requireAuth } from '../middleware/auth.js';
import { upload } from '../middleware/upload.js';
import { asyncHandler } from '../utils/asyncHandler.js';

const router = Router();
router.use(requireAuth);

// GET /api/notes - list notes for current employee
router.get('/', asyncHandler(async (req, res) => {
  let employeeId = req.user.employeeId;
  if (!employeeId && req.query.employeeId) {
    employeeId = Number(req.query.employeeId);
  }
  if (!employeeId) {
    const first = await prisma.employee.findFirst();
    employeeId = first?.id || 1;
  }

  const notes = await prisma.employeeNote.findMany({
    where: { employeeId },
    orderBy: { createdAt: 'asc' },
  });

  res.json({ success: true, data: notes });
}));

// POST /api/notes - create note
router.post('/', upload.single('attachment'), asyncHandler(async (req, res) => {
  let employeeId = req.user.employeeId;
  if (!employeeId && req.body.employeeId) {
    employeeId = Number(req.body.employeeId);
  }
  if (!employeeId) {
    const first = await prisma.employee.findFirst();
    employeeId = first?.id || 1;
  }

  const noteText = req.body.note || req.body.text || req.body.message || '';
  const title = req.body.title || 'Note';
  const attachmentUrl = req.file
    ? `/${req.file.path.replaceAll('\\', '/')}`
    : (req.body.attachmentUrl || null);

  const created = await prisma.employeeNote.create({
    data: {
      employeeId,
      title,
      note: noteText,
      attachmentUrl,
    },
  });

  res.status(201).json({ success: true, data: created });
}));

// DELETE /api/notes/:id - delete note
router.delete('/:id', asyncHandler(async (req, res) => {
  const id = Number(req.params.id);
  await prisma.employeeNote.delete({
    where: { id },
  });
  res.json({ success: true, message: 'Note deleted' });
}));

export default router;
