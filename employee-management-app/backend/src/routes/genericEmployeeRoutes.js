import { Router } from 'express';
import { createCrudController } from '../controllers/crudController.js';
import { createEmployeeCrudService } from '../services/crudService.js';
import { requireAuth } from '../middleware/auth.js';
import { upload } from '../middleware/upload.js';

export const employeeCrudRouter = (modelName, options = {}) => {
  const router = Router();
  const controller = createCrudController(createEmployeeCrudService(modelName, options));
  router.use(requireAuth);
  router.get('/', controller.list);
  router.post('/', upload.any(), controller.create);
  router.get('/:id', controller.get);
  router.put('/:id', controller.update);
  if (options.allowDelete) router.delete('/:id', controller.remove);
  return router;
};
