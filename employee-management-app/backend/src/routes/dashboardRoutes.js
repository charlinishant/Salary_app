import { Router } from 'express';
import { requireAuth } from '../middleware/auth.js';
import { dashboardController } from '../controllers/dashboardController.js';

const router = Router();

router.get('/', requireAuth, dashboardController.index);

export default router;
