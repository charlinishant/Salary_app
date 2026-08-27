import { prisma } from '../config/prisma.js';
import { HttpError } from '../utils/httpError.js';

export const createEmployeeCrudService = (modelName, options = {}) => {
  const model = prisma[modelName];
  const orderBy = options.orderBy || { createdAt: 'desc' };

  return {
    list: (employeeId, query = {}) => model.findMany({
      where: { employeeId, ...(options.filter?.(query) || {}) },
      orderBy,
      include: options.include,
    }),
    get: async (employeeId, id) => {
      const row = await model.findFirst({
        where: { id: Number(id), employeeId },
        include: options.include,
      });
      if (!row) throw new HttpError(404, 'Record not found');
      return row;
    },
    create: (employeeId, data) => model.create({ data: { ...data, employeeId } }),
    update: async (employeeId, id, data) => {
      const existing = await model.findFirst({ where: { id: Number(id), employeeId } });
      if (!existing) throw new HttpError(404, 'Record not found');
      return model.update({ where: { id: Number(id) }, data });
    },
    remove: async (employeeId, id) => {
      const existing = await model.findFirst({ where: { id: Number(id), employeeId } });
      if (!existing) throw new HttpError(404, 'Record not found');
      return model.delete({ where: { id: Number(id) } });
    },
  };
};
