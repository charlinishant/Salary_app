import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { prisma } from '../config/prisma.js';
import { env } from '../config/env.js';
import { HttpError } from '../utils/httpError.js';

const publicEmployee = {
  id: true,
  employeeCode: true,
  firstName: true,
  lastName: true,
  email: true,
  phone: true,
  gender: true,
  dateOfBirth: true,
  address: true,
  profilePhoto: true,
  joiningDate: true,
  employmentType: true,
  reportingManager: true,
  workLocation: true,
  bankName: true,
  accountNumber: true,
  ifsc: true,
  branch: true,
  accountHolderName: true,
  upiId: true,
  department: true,
  designation: true,
  shift: true,
  roleRef: true,
};

export const authService = {
  login: async ({ identifier, password }) => {
    const user = await prisma.user.findFirst({
      where: {
        OR: [{ email: identifier }, { employee: { employeeCode: identifier } }],
      },
      include: { employee: { include: { department: true, designation: true, shift: true, roleRef: true } } },
    });

    if (!user || !user.isActive) throw new HttpError(401, 'Invalid credentials');
    const ok = await bcrypt.compare(password, user.passwordHash);
    if (!ok) throw new HttpError(401, 'Invalid credentials');

    const emp = user.employee || {};
    const employeePayload = {
      ...emp,
      name: `${emp.firstName || ''} ${emp.lastName || ''}`.trim(),
      role: user.role,
    };

    const token = jwt.sign({ userId: user.id, employeeId: user.employee?.id }, env.jwtSecret, {
      expiresIn: env.jwtExpiresIn,
    });

    return { token, employee: employeePayload, data: employeePayload };
  },

  me: async (userId) => {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        email: true,
        role: true,
        employee: {
          include: { department: true, designation: true, shift: true, roleRef: true },
        },
      },
    });
    if (!user) return null;
    const emp = user.employee || {};
    return {
      ...emp,
      name: `${emp.firstName || ''} ${emp.lastName || ''}`.trim(),
      role: user.role,
      user: { id: user.id, email: user.email, role: user.role },
    };
  },
};


