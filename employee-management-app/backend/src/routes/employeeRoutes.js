import { Router } from 'express';
import { requireAuth } from '../middleware/auth.js';
import { upload } from '../middleware/upload.js';
import { employeeController } from '../controllers/employeeController.js';

const router = Router();

router.use(requireAuth);

router.get('/me', employeeController.me);
router.put('/me', upload.single('profilePhoto'), employeeController.updateMe);

router.get('/', employeeController.list);
router.get('/:id', employeeController.getById);
router.post('/', upload.single('profilePhoto'), employeeController.create);
router.put('/:id', upload.single('profilePhoto'), employeeController.update);
router.patch('/:id/status', employeeController.toggleStatus);
router.get('/:id/attendance', employeeController.employeeAttendanceHistory);

export default router;
