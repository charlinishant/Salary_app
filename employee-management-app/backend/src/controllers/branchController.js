import { prisma } from '../config/prisma.js';
import { asyncHandler } from '../utils/asyncHandler.js';
import { HttpError } from '../utils/httpError.js';

export const getBranches = asyncHandler(async (req, res) => {
  const { search, status } = req.query;

  const where = {};
  if (status && status !== 'All') {
    where.isActive = status === 'Active';
  }

  if (search) {
    where.OR = [
      { name: { contains: search } },
      { code: { contains: search } },
      { city: { contains: search } },
    ];
  }

  const branches = await prisma.branch.findMany({
    where,
    include: {
      company: { select: { id: true, name: true } },
      manager: { select: { id: true, firstName: true, lastName: true, email: true } },
      _count: {
        select: {
          employees: true,
          departments: true,
        },
      },
    },
    orderBy: { createdAt: 'desc' },
  });

  const formatted = branches.map((b) => ({
    ...b,
    employeeCount: b._count.employees,
    departmentCount: b._count.departments,
    status: b.isActive ? 'Active' : 'Inactive',
  }));

  res.json({
    success: true,
    message: 'Branches retrieved successfully',
    data: formatted,
  });
});

export const getBranchById = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const branch = await prisma.branch.findUnique({
    where: { id: parseInt(id) },
    include: {
      company: true,
      manager: true,
      departments: true,
      _count: { select: { employees: true } },
    },
  });

  if (!branch) {
    throw new HttpError(404, 'Branch not found');
  }

  res.json({
    success: true,
    message: 'Branch details retrieved',
    data: {
      ...branch,
      employeeCount: branch._count.employees,
    },
  });
});

export const createBranch = asyncHandler(async (req, res) => {
  const { name, code, companyId, address, city, state, country, postalCode, phone, email, latitude, longitude, geofenceRadius, timezone, managerId, isActive } = req.body;

  if (!name || !code) {
    throw new HttpError(400, 'Branch Name and Branch Code are required');
  }

  const existingCode = await prisma.branch.findUnique({ where: { code } });
  if (existingCode) {
    throw new HttpError(400, 'Branch code already exists');
  }

  let finalCompanyId = companyId;
  if (!finalCompanyId) {
    const comp = await prisma.company.findFirst();
    if (comp) finalCompanyId = comp.id;
  }

  const branch = await prisma.branch.create({
    data: {
      name,
      code,
      companyId: finalCompanyId,
      address,
      city,
      state,
      country,
      postalCode,
      phone,
      email,
      latitude: latitude ? parseFloat(latitude) : null,
      longitude: longitude ? parseFloat(longitude) : null,
      geofenceRadius: geofenceRadius ? parseFloat(geofenceRadius) : 100,
      timezone: timezone || 'Asia/Kolkata',
      managerId: managerId ? parseInt(managerId) : null,
      isActive: isActive !== undefined ? Boolean(isActive) : true,
    },
  });

  await prisma.auditLog.create({
    data: {
      employeeId: req.user.employeeId,
      action: 'CREATE',
      module: 'Branches',
      entity: 'Branch',
      entityId: branch.id,
      newValue: JSON.stringify(req.body),
    },
  });

  res.status(201).json({
    success: true,
    message: 'Branch created successfully',
    data: branch,
  });
});

export const updateBranch = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const branchId = parseInt(id);

  const existing = await prisma.branch.findUnique({ where: { id: branchId } });
  if (!existing) {
    throw new HttpError(404, 'Branch not found');
  }

  const { name, code, address, city, state, country, postalCode, phone, email, latitude, longitude, geofenceRadius, timezone, managerId, isActive } = req.body;

  if (code && code !== existing.code) {
    const duplicate = await prisma.branch.findUnique({ where: { code } });
    if (duplicate) {
      throw new HttpError(400, 'Branch code already exists');
    }
  }

  const updated = await prisma.branch.update({
    where: { id: branchId },
    data: {
      name,
      code,
      address,
      city,
      state,
      country,
      postalCode,
      phone,
      email,
      latitude: latitude ? parseFloat(latitude) : null,
      longitude: longitude ? parseFloat(longitude) : null,
      geofenceRadius: geofenceRadius ? parseFloat(geofenceRadius) : undefined,
      timezone,
      managerId: managerId ? parseInt(managerId) : null,
      isActive: isActive !== undefined ? Boolean(isActive) : undefined,
    },
  });

  res.json({
    success: true,
    message: 'Branch updated successfully',
    data: updated,
  });
});

export const deleteBranch = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const branchId = parseInt(id);

  const employeeCount = await prisma.employee.count({ where: { branchId } });

  if (employeeCount > 0) {
    throw new HttpError(
      400,
      `Cannot delete this branch because ${employeeCount} employees are assigned to it. Deactivate the branch instead.`
    );
  }

  await prisma.branch.delete({ where: { id: branchId } });

  res.json({
    success: true,
    message: 'Branch deleted successfully',
  });
});
