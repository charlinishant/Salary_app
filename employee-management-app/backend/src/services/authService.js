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
  profilePhoto: true,
  department: true,
  designation: true,
};

export const authService = {
  login: async ({ identifier, password }) => {
    const user = await prisma.user.findFirst({
      where: {
        OR: [{ email: identifier }, { employee: { employeeCode: identifier } }],
      },
      include: { employee: { select: publicEmployee } },
    });

    if (!user || !user.isActive) throw new HttpError(401, 'Invalid credentials');
    const ok = await bcrypt.compare(password, user.passwordHash);
    if (!ok) throw new HttpError(401, 'Invalid credentials');

    const token = jwt.sign({ userId: user.id, employeeId: user.employee.id }, env.jwtSecret, {
      expiresIn: env.jwtExpiresIn,
    });

    return { token, employee: user.employee };
  },
  me: (userId) => prisma.user.findUnique({
    where: { id: userId },
    select: { id: true, email: true, role: true, employee: { select: publicEmployee } },
  }),
};
