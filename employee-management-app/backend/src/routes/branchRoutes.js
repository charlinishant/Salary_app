import { Router } from 'express';
import { getBranches, getBranchById, createBranch, updateBranch, deleteBranch } from '../controllers/branchController.js';
import { requireAuth } from '../middleware/auth.js';
import { checkPermission } from '../middleware/rbacMiddleware.js';

const router = Router();

router.use(requireAuth);

router.get('/', checkPermission('branch.view', 'view'), getBranches);
router.get('/:id', checkPermission('branch.view', 'view'), getBranchById);
router.post('/', checkPermission('branch.create', 'create'), createBranch);
router.put('/:id', checkPermission('branch.edit', 'edit'), updateBranch);
router.delete('/:id', checkPermission('branch.delete', 'delete'), deleteBranch);

export default router;
