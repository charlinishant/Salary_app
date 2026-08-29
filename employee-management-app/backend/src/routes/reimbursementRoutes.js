import { Router } from 'express';
import { reimbursementController } from '../controllers/reimbursementController.js';
import { requireAuth } from '../middleware/auth.js';
import { upload } from '../middleware/upload.js';

const router = Router();

router.use(requireAuth);

router.get('/', reimbursementController.list);
router.post('/', upload.array('attachments', 10), reimbursementController.create);
router.get('/:id', reimbursementController.get);
router.patch('/:id/status', reimbursementController.updateStatus);
router.delete('/:id', reimbursementController.remove);

export default router;
