import { Router } from 'express';
import { requireAuth } from '../middleware/auth.js';
import { reportController } from '../controllers/reportController.js';

const router = Router();

router.use(requireAuth);
router.get('/employees', reportController.employeeReport);
router.get('/attendance', reportController.attendanceReport);
router.get('/late-attendance', reportController.lateReport);
router.get('/working-hours', reportController.workingHoursReport);
router.get('/leave', reportController.leaveReport);
router.get('/expenses', reportController.expenseReport);
router.get('/documents', reportController.documentsReport);

export default router;
