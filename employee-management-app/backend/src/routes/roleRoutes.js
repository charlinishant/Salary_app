import { Router } from 'express';
import { getRoles, getPermissions, createRole, updateRolePermissions } from '../controllers/roleController.js';
import { requireAuth } from '../middleware/auth.js';
import { checkPermission } from '../middleware/rbacMiddleware.js';

const router = Router();

router.use(requireAuth);

router.get('/permissions', checkPermission('role.view', 'view'), getPermissions);
router.get('/', checkPermission('role.view', 'view'), getRoles);
router.post('/', checkPermission('role.create', 'create'), createRole);
router.put('/:id/permissions', checkPermission('permission.assign', 'edit'), updateRolePermissions);

export default router;
