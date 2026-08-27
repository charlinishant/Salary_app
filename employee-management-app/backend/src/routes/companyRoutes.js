import { Router } from 'express';
import { getCompany, updateCompany } from '../controllers/companyController.js';
import { requireAuth } from '../middleware/auth.js';
import { checkPermission } from '../middleware/rbacMiddleware.js';

const router = Router();

router.use(requireAuth);

router.get('/', checkPermission('company.view', 'view'), getCompany);
router.put('/:id', checkPermission('company.edit', 'edit'), updateCompany);

export default router;
