import { Router } from 'express';
import { documentController } from '../controllers/documentController.js';
import { requireAuth } from '../middleware/auth.js';
import { upload } from '../middleware/upload.js';

const router = Router();

router.use(requireAuth);

router.get('/', documentController.list);
router.get('/:id', documentController.get);
router.post('/', upload.single('document'), documentController.create);
router.patch('/:id/status', documentController.updateStatus);
router.delete('/:id', documentController.remove);

export default router;
