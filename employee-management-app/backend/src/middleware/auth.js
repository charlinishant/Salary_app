import jwt from 'jsonwebtoken';
import { prisma } from '../config/prisma.js';
import { env } from '../config/env.js';
import { HttpError } from '../utils/httpError.js';
import { asyncHandler } from '../utils/asyncHandler.js';

export const requireAuth = asyncHandler(async (req, _res, next) => {
  const header = req.headers.authorization || '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;

  if (token) {
    try {
      const payload = jwt.verify(token, env.jwtSecret);
      const user = await prisma.user.findUnique({
        where: { id: payload.userId },
        include: { employee: true },
      });

      if (user && user.isActive && user.employee) {
        req.user = {
          id: user.id,
          email: user.email,
          role: user.role,
          employeeId: user.employee.id,
        };
        return next();
      }
    } catch (_err) {
      // Fallback to dev headers if token invalid/expired
    }
  }

  // Development mode without login: read headers x-role and x-employee-id
  const headerRole = (req.headers['x-role'] || 'ADMIN').toUpperCase();
  const headerEmpId = req.headers['x-employee-id'] ? parseInt(req.headers['x-employee-id']) : null;

  if (headerEmpId) {
    const employee = await prisma.employee.findUnique({
      where: { id: headerEmpId },
      include: { user: true },
    });
    if (employee) {
      req.user = {
        id: employee.userId,
        email: employee.email,
        role: headerRole,
        employeeId: employee.id,
      };
      return next();
    }
  }

  // Default fallback: get first active employee or admin
  const firstEmployee = await prisma.employee.findFirst({
    include: { user: true },
    orderBy: { id: 'asc' },
  });

  if (firstEmployee) {
    req.user = {
      id: firstEmployee.userId,
      email: firstEmployee.email,
      role: headerRole,
      employeeId: firstEmployee.id,
    };
    return next();
  }

  throw new HttpError(401, 'No active employee found in system for dev mode');
});
