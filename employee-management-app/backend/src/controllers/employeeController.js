import { prisma } from '../config/prisma.js';
import { asyncHandler } from '../utils/asyncHandler.js';

export const employeeController = {
  me: asyncHandler(async (req, res) => {
    const data = await prisma.employee.findUnique({
      where: { id: req.user.employeeId },
      include: { department: true, designation: true, shift: true, salaryStructure: true },
    });
    res.json({ success: true, data });
  }),
  updateMe: asyncHandler(async (req, res) => {
    const allowed = (({
      phone,
      address,
      bankName,
      accountNumber,
      ifsc,
      branch,
      accountHolderName,
    }) => ({ phone, address, bankName, accountNumber, ifsc, branch, accountHolderName }))(req.body);
    const data = await prisma.employee.update({
      where: { id: req.user.employeeId },
      data: Object.fromEntries(Object.entries(allowed).filter(([, value]) => value !== undefined)),
    });
    res.json({ success: true, data });
  }),
};
