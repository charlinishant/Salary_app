import { prisma } from '../config/prisma.js';
import { asyncHandler } from '../utils/asyncHandler.js';
import { HttpError } from '../utils/httpError.js';

export const getRoles = asyncHandler(async (_req, res) => {
  const roles = await prisma.role.findMany({
    include: {
      permissions: {
        include: {
          permission: true,
        },
      },
      _count: {
        select: { employees: true },
      },
    },
    orderBy: { id: 'asc' },
  });

  const formatted = roles.map((r) => ({
    id: r.id,
    name: r.name,
    description: r.description,
    isSystem: r.isSystem,
    employeeCount: r._count.employees,
    permissionsCount: r.permissions.length,
    permissions: r.permissions.map((rp) => ({
      permissionId: rp.permissionId,
      code: rp.permission.code,
      category: rp.permission.category,
      name: rp.permission.name,
      canView: rp.canView,
      canCreate: rp.canCreate,
      canEdit: rp.canEdit,
      canApprove: rp.canApprove,
      canDelete: rp.canDelete,
    })),
  }));

  res.json({
    success: true,
    message: 'Roles retrieved successfully',
    data: formatted,
  });
});

export const getPermissions = asyncHandler(async (_req, res) => {
  const permissions = await prisma.permission.findMany({
    orderBy: [{ category: 'asc' }, { code: 'asc' }],
  });

  const grouped = permissions.reduce((acc, p) => {
    if (!acc[p.category]) acc[p.category] = [];
    acc[p.category].push(p);
    return acc;
  }, {});

  res.json({
    success: true,
    message: 'Permissions retrieved successfully',
    data: {
      all: permissions,
      byCategory: grouped,
    },
  });
});

export const createRole = asyncHandler(async (req, res) => {
  const { name, description, permissions } = req.body;

  if (!name) {
    throw new HttpError(400, 'Role name is required');
  }

  const existing = await prisma.role.findUnique({ where: { name } });
  if (existing) {
    throw new HttpError(400, 'Role with this name already exists');
  }

  const role = await prisma.role.create({
    data: {
      name,
      description,
      isSystem: false,
    },
  });

  if (Array.isArray(permissions) && permissions.length > 0) {
    for (const p of permissions) {
      if (p.permissionId) {
        await prisma.rolePermission.create({
          data: {
            roleId: role.id,
            permissionId: parseInt(p.permissionId),
            canView: p.canView !== undefined ? Boolean(p.canView) : true,
            canCreate: p.canCreate !== undefined ? Boolean(p.canCreate) : false,
            canEdit: p.canEdit !== undefined ? Boolean(p.canEdit) : false,
            canApprove: p.canApprove !== undefined ? Boolean(p.canApprove) : false,
            canDelete: p.canDelete !== undefined ? Boolean(p.canDelete) : false,
          },
        });
      }
    }
  }

  res.status(201).json({
    success: true,
    message: 'Role created successfully',
    data: role,
  });
});

export const updateRolePermissions = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const roleId = parseInt(id);

  const role = await prisma.role.findUnique({ where: { id: roleId } });
  if (!role) {
    throw new HttpError(404, 'Role not found');
  }

  const { name, description, permissions } = req.body;

  if (name && !role.isSystem) {
    await prisma.role.update({
      where: { id: roleId },
      data: { name, description },
    });
  } else if (description) {
    await prisma.role.update({
      where: { id: roleId },
      data: { description },
    });
  }

  if (Array.isArray(permissions)) {
    for (const p of permissions) {
      if (p.permissionId) {
        await prisma.rolePermission.upsert({
          where: { roleId_permissionId: { roleId, permissionId: parseInt(p.permissionId) } },
          update: {
            canView: Boolean(p.canView),
            canCreate: Boolean(p.canCreate),
            canEdit: Boolean(p.canEdit),
            canApprove: Boolean(p.canApprove),
            canDelete: Boolean(p.canDelete),
          },
          create: {
            roleId,
            permissionId: parseInt(p.permissionId),
            canView: Boolean(p.canView),
            canCreate: Boolean(p.canCreate),
            canEdit: Boolean(p.canEdit),
            canApprove: Boolean(p.canApprove),
            canDelete: Boolean(p.canDelete),
          },
        });
      }
    }
  }

  const updatedRole = await prisma.role.findUnique({
    where: { id: roleId },
    include: { permissions: { include: { permission: true } } },
  });

  res.json({
    success: true,
    message: 'Role permissions updated successfully',
    data: updatedRole,
  });
});
