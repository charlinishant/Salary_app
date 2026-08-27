import { Router } from 'express';
import { requireAuth } from '../middleware/auth.js';
import { upload } from '../middleware/upload.js';
import { attendanceController } from '../controllers/attendanceController.js';

const router = Router();

router.use(requireAuth);
router.post('/punch-in', upload.single('selfie'), attendanceController.punchIn);
router.post('/punch-out', upload.single('selfie'), attendanceController.punchOut);
router.get('/today', attendanceController.today);
router.get('/history', attendanceController.history);

export default router;
