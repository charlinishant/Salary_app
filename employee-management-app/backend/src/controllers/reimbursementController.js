import { prisma } from '../config/prisma.js';
import { asyncHandler } from '../utils/asyncHandler.js';
import { HttpError } from '../utils/httpError.js';

export const reimbursementController = {
  // GET /api/reimbursements
  list: asyncHandler(async (req, res) => {
    const { status, employeeId } = req.query;
    const targetEmployeeId = req.user.role === 'ADMIN' && employeeId
        ? Number(employeeId)
        : req.user.employeeId;

    const where = {};
    if (targetEmployeeId) {
      where.employeeId = targetEmployeeId;
    }
    if (status && status !== 'ALL') {
      where.status = status;
    }

    const reimbursements = await prisma.expense.findMany({
      where,
      orderBy: { createdAt: 'desc' },
      include: {
        attachments: true,
        employee: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            employeeCode: true,
            profilePhoto: true,
          },
        },
      },
    });

    res.json({
      success: true,
      data: reimbursements,
    });
  }),

  // GET /api/reimbursements/:id
  get: asyncHandler(async (req, res) => {
    const id = Number(req.params.id);
    const reimbursement = await prisma.expense.findUnique({
      where: { id },
      include: {
        attachments: true,
        employee: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            employeeCode: true,
          },
        },
      },
    });

    if (!reimbursement) {
      throw new HttpError(404, 'Reimbursement record not found');
    }

    // Ensure non-admin users only view their own
    if (req.user.role !== 'ADMIN' && reimbursement.employeeId !== req.user.employeeId) {
      throw new HttpError(403, 'Forbidden access to this reimbursement');
    }

    res.json({ success: true, data: reimbursement });
  }),

  // POST /api/reimbursements
  create: asyncHandler(async (req, res) => {
    const {
      amount,
      paymentAmount,
      date,
      paymentDate,
      notes,
      description,
      expenseType = 'Reimbursement',
      paymentMode = 'OTHER',
    } = req.body;

    const parsedAmount = parseFloat(amount || paymentAmount);
    if (isNaN(parsedAmount) || parsedAmount <= 0) {
      throw new HttpError(400, 'Please enter a valid positive payment amount');
    }

    const parsedDate = date || paymentDate ? new Date(date || paymentDate) : new Date();
    const finalDescription = notes || description || 'Reimbursement Request';

    const files = req.files || (req.file ? [req.file] : []);

    const expense = await prisma.expense.create({
      data: {
        employeeId: req.user.employeeId,
        amount: parsedAmount,
        date: parsedDate,
        description: finalDescription,
        expenseType,
        paymentMode,
        status: 'PENDING',
        attachments: {
          create: files.map((file) => ({
            fileUrl: `/${file.path.replaceAll('\\', '/')}`,
          })),
        },
      },
      include: {
        attachments: true,
        employee: {
          select: {
            firstName: true,
            lastName: true,
            employeeCode: true,
          },
        },
      },
    });

    res.status(201).json({
      success: true,
      message: 'Reimbursement request submitted successfully',
      data: expense,
    });
  }),

  // PATCH /api/reimbursements/:id/status
  updateStatus: asyncHandler(async (req, res) => {
    const id = Number(req.params.id);
    const { status } = req.body;

    if (!['PENDING', 'APPROVED', 'REJECTED', 'PAID'].includes(status)) {
      throw new HttpError(400, 'Invalid status value');
    }

    const existing = await prisma.expense.findUnique({ where: { id } });
    if (!existing) {
      throw new HttpError(404, 'Reimbursement record not found');
    }

    const updated = await prisma.expense.update({
      where: { id },
      data: { status },
      include: {
        attachments: true,
      },
    });

    res.json({
      success: true,
      message: `Reimbursement status updated to ${status}`,
      data: updated,
    });
  }),

  // DELETE /api/reimbursements/:id
  remove: asyncHandler(async (req, res) => {
    const id = Number(req.params.id);
    const existing = await prisma.expense.findUnique({ where: { id } });

    if (!existing) {
      throw new HttpError(404, 'Reimbursement record not found');
    }

    if (req.user.role !== 'ADMIN' && existing.employeeId !== req.user.employeeId) {
      throw new HttpError(403, 'Forbidden access to this reimbursement');
    }

    await prisma.expense.delete({ where: { id } });

    res.json({
      success: true,
      message: 'Reimbursement request deleted successfully',
    });
  }),
};
