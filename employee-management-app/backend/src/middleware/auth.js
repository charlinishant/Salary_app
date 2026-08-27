import jwt from 'jsonwebtoken';
import { prisma } from '../config/prisma.js';
import { env } from '../config/env.js';
import { HttpError } from '../utils/httpError.js';
import { asyncHandler } from '../utils/asyncHandler.js';

export const requireAuth = asyncHandler(async (req, _res, next) => {
  const header = req.headers.authorization || '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;

  if (!token) {
    throw new HttpError(401, 'Authentication token is required');
  }

  const payload = jwt.verify(token, env.jwtSecret);
  const user = await prisma.user.findUnique({
    where: { id: payload.userId },
    include: { employee: true },
  });

  if (!user || !user.isActive || !user.employee) {
    throw new HttpError(401, 'Invalid or inactive user');
  }

  req.user = {
    id: user.id,
    email: user.email,
    role: user.role,
    employeeId: user.employee.id,
  };
  next();
});
