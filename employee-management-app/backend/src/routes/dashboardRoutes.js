import { Router } from 'express';
import { requireAuth } from '../middleware/auth.js';
import { dashboardController } from '../controllers/dashboardController.js';

const router = Router();

router.use(requireAuth);
router.get('/', dashboardController.index);
router.get('/admin', dashboardController.adminSummary);
router.get('/employee', dashboardController.employeeSummary);

export default router;
