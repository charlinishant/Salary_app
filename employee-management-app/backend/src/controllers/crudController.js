import { asyncHandler } from '../utils/asyncHandler.js';

export const createCrudController = (service) => ({
  list: asyncHandler(async (req, res) => {
    const data = await service.list(req.user.employeeId, req.query);
    res.json({ success: true, data });
  }),
  get: asyncHandler(async (req, res) => {
    const data = await service.get(req.user.employeeId, req.params.id);
    res.json({ success: true, data });
  }),
  create: asyncHandler(async (req, res) => {
    const files = req.files || (req.file ? [req.file] : []);
    const data = await service.create(req.user.employeeId, {
      ...req.body,
      ...(files.length ? { attachmentUrl: `/${files[0].path.replaceAll('\\', '/')}` } : {}),
    });
    res.status(201).json({ success: true, data });
  }),
  update: asyncHandler(async (req, res) => {
    const data = await service.update(req.user.employeeId, req.params.id, req.body);
    res.json({ success: true, data });
  }),
  remove: asyncHandler(async (req, res) => {
    await service.remove(req.user.employeeId, req.params.id);
    res.json({ success: true });
  }),
});
