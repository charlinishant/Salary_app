import { Router } from 'express';
import { requireAuth } from '../middleware/auth.js';
import { upload } from '../middleware/upload.js';
import { attendanceController } from '../controllers/attendanceController.js';

const router = Router();

router.use(requireAuth);

// Employee Attendance Routes
router.post('/punch-in', upload.single('selfie'), attendanceController.punchIn);
router.post('/punch-out', upload.single('selfie'), attendanceController.punchOut);
router.get('/today', attendanceController.today);
router.get('/history', attendanceController.history);
router.get('/my-history', attendanceController.history);

// Admin Attendance Routes
router.get('/admin/list', attendanceController.adminList);
router.get('/admin/summary', attendanceController.adminList);
router.get('/admin/:id', attendanceController.adminGetById);
router.put('/admin/:id', attendanceController.adminUpdate);

export default router;
