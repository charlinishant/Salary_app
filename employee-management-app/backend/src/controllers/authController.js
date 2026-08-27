import { body } from 'express-validator';
import { authService } from '../services/authService.js';
import { asyncHandler } from '../utils/asyncHandler.js';
import { validate } from '../validators/validate.js';

export const loginRules = [
  body('identifier').trim().notEmpty().withMessage('Employee ID or email is required'),
  body('password').notEmpty().withMessage('Password is required'),
  validate,
];

export const authController = {
  login: asyncHandler(async (req, res) => {
    const data = await authService.login(req.body);
    res.json({ success: true, ...data });
  }),
  me: asyncHandler(async (req, res) => {
    const data = await authService.me(req.user.id);
    res.json({ success: true, data });
  }),
  logout: (_req, res) => res.json({ success: true }),
};
