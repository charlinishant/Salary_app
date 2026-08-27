import { Router } from 'express';
import { getShifts, createShift, updateShift, assignShift } from '../controllers/shiftController.js';
import { requireAuth } from '../middleware/auth.js';
import { checkPermission } from '../middleware/rbacMiddleware.js';

const router = Router();

router.use(requireAuth);

router.get('/', checkPermission('shift.view', 'view'), getShifts);
router.post('/', checkPermission('shift.create', 'create'), createShift);
router.put('/:id', checkPermission('shift.edit', 'edit'), updateShift);
router.post('/assign', checkPermission('shift.assign', 'create'), assignShift);

export default router;
