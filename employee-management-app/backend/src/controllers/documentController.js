import { prisma } from '../config/prisma.js';
import { asyncHandler } from '../utils/asyncHandler.js';
import { HttpError } from '../utils/httpError.js';

export const documentController = {
  // GET /api/documents
  list: asyncHandler(async (req, res) => {
    const employeeId = req.user.role === 'ADMIN' && req.query.employeeId
      ? Number(req.query.employeeId)
      : (req.user.employeeId || req.user.id);

    const documents = await prisma.employeeDocument.findMany({
      where: employeeId ? { employeeId } : {},
      include: {
        employee: {
          select: { id: true, firstName: true, lastName: true, employeeCode: true }
        }
      },
      orderBy: { createdAt: 'desc' },
    });

    res.json({ success: true, count: documents.length, data: documents });
  }),

  // GET /api/documents/:id
  get: asyncHandler(async (req, res) => {
    const document = await prisma.employeeDocument.findUnique({
      where: { id: Number(req.params.id) },
      include: { employee: true },
    });

    if (!document) throw new HttpError(404, 'Document not found');
    res.json({ success: true, data: document });
  }),

  // POST /api/documents
  create: asyncHandler(async (req, res) => {
    const employeeId = req.user.employeeId || req.user.id || Number(req.body.employeeId);
    if (!employeeId) throw new HttpError(400, 'Employee ID is required');

    const { documentType, remarks, status } = req.body;
    if (!documentType) throw new HttpError(400, 'Document Type is required');

    let fileUrl = req.body.fileUrl || null;
    if (req.file) {
      fileUrl = `/uploads/documents/${req.file.filename}`;
    }

    const document = await prisma.employeeDocument.create({
      data: {
        employeeId,
        documentType,
        remarks: remarks || null,
        fileUrl,
        status: status || 'PENDING',
      },
      include: { employee: true },
    });

    res.status(201).json({ success: true, message: 'Document uploaded successfully', data: document });
  }),

  // PATCH /api/documents/:id/status
  updateStatus: asyncHandler(async (req, res) => {
    const { status, remarks } = req.body;
    const document = await prisma.employeeDocument.update({
      where: { id: Number(req.params.id) },
      data: {
        status: status || 'VERIFIED',
        remarks: remarks !== undefined ? remarks : undefined,
      },
    });

    res.json({ success: true, message: 'Document status updated', data: document });
  }),

  // DELETE /api/documents/:id
  remove: asyncHandler(async (req, res) => {
    await prisma.employeeDocument.delete({
      where: { id: Number(req.params.id) },
    });

    res.json({ success: true, message: 'Document deleted successfully' });
  }),
};
