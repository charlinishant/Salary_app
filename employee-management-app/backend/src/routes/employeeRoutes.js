import { Router } from 'express';
import { requireAuth } from '../middleware/auth.js';
import { employeeController } from '../controllers/employeeController.js';

const router = Router();

router.use(requireAuth);
router.get('/me', employeeController.me);
router.put('/me', employeeController.updateMe);

export default router;
