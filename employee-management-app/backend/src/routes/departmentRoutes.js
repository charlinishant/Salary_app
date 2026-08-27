import { Router } from 'express';
import { getDepartments, createDepartment, updateDepartment, deleteDepartment } from '../controllers/departmentController.js';
import { requireAuth } from '../middleware/auth.js';
import { checkPermission } from '../middleware/rbacMiddleware.js';

const router = Router();

router.use(requireAuth);

router.get('/', checkPermission('department.view', 'view'), getDepartments);
router.post('/', checkPermission('department.create', 'create'), createDepartment);
router.put('/:id', checkPermission('department.edit', 'edit'), updateDepartment);
router.delete('/:id', checkPermission('department.delete', 'delete'), deleteDepartment);

export default router;
