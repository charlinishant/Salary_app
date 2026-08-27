import { prisma } from '../config/prisma.js';
import { asyncHandler } from '../utils/asyncHandler.js';
import { HttpError } from '../utils/httpError.js';

export const getDepartments = asyncHandler(async (req, res) => {
  const { search, branchId, status } = req.query;

  const where = {};
  if (status && status !== 'All') {
    where.isActive = status === 'Active';
  }

  if (branchId) {
    where.branchId = parseInt(branchId);
  }

  if (search) {
    where.OR = [
      { name: { contains: search } },
      { code: { contains: search } },
    ];
  }

  const departments = await prisma.department.findMany({
    where,
    include: {
      company: { select: { id: true, name: true } },
      branch: { select: { id: true, name: true, code: true } },
      head: { select: { id: true, firstName: true, lastName: true, email: true } },
      _count: { select: { employees: true } },
    },
    orderBy: { createdAt: 'desc' },
  });

  const formatted = departments.map((d) => ({
    ...d,
    employeeCount: d._count.employees,
    branchName: d.branch?.name || 'All Branches',
    departmentHeadName: d.head ? `${d.head.firstName} ${d.head.lastName}` : 'Unassigned',
    status: d.isActive ? 'Active' : 'Inactive',
  }));

  res.json({
    success: true,
    message: 'Departments retrieved successfully',
    data: formatted,
  });
});

export const createDepartment = asyncHandler(async (req, res) => {
  const { name, code, companyId, branchId, headId, description, isActive } = req.body;

  if (!name) {
    throw new HttpError(400, 'Department Name is required');
  }

  let finalCompanyId = companyId;
  if (!finalCompanyId) {
    const comp = await prisma.company.findFirst();
    if (comp) finalCompanyId = comp.id;
  }

  const existing = await prisma.department.findFirst({
    where: { name, companyId: finalCompanyId },
  });
  if (existing) {
    throw new HttpError(400, 'Department with this name already exists in the company');
  }

  const department = await prisma.department.create({
    data: {
      name,
      code: code || `DEP-${name.substring(0, 3).toUpperCase()}`,
      companyId: finalCompanyId,
      branchId: branchId ? parseInt(branchId) : null,
      headId: headId ? parseInt(headId) : null,
      description,
      isActive: isActive !== undefined ? Boolean(isActive) : true,
    },
  });

  res.status(201).json({
    success: true,
    message: 'Department created successfully',
    data: department,
  });
});

export const updateDepartment = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const deptId = parseInt(id);

  const existing = await prisma.department.findUnique({ where: { id: deptId } });
  if (!existing) {
    throw new HttpError(404, 'Department not found');
  }

  const { name, code, branchId, headId, description, isActive } = req.body;

  const updated = await prisma.department.update({
    where: { id: deptId },
    data: {
      name,
      code,
      branchId: branchId ? parseInt(branchId) : null,
      headId: headId ? parseInt(headId) : null,
      description,
      isActive: isActive !== undefined ? Boolean(isActive) : undefined,
    },
  });

  res.json({
    success: true,
    message: 'Department updated successfully',
    data: updated,
  });
});

export const deleteDepartment = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const deptId = parseInt(id);

  const employeeCount = await prisma.employee.count({ where: { departmentId: deptId } });

  if (employeeCount > 0) {
    throw new HttpError(
      400,
      `Cannot delete department because ${employeeCount} employees are assigned to it. Deactivate the department instead.`
    );
  }

  await prisma.department.delete({ where: { id: deptId } });

  res.json({
    success: true,
    message: 'Department deleted successfully',
  });
});
