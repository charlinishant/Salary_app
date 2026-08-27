import { prisma } from '../config/prisma.js';
import { HttpError } from '../utils/httpError.js';
import { asyncHandler } from '../utils/asyncHandler.js';

export const checkPermission = (permissionCode, action = 'view') => {
  return asyncHandler(async (req, _res, next) => {
    // ADMIN or SUPER ADMIN role bypass check
    if (req.user.role === 'ADMIN') {
      return next();
    }

    const employee = await prisma.employee.findUnique({
      where: { id: req.user.employeeId },
      include: {
        roleRef: {
          include: {
            permissions: {
              include: {
                permission: true,
              },
            },
          },
        },
      },
    });

    if (!employee || !employee.roleRef) {
      throw new HttpError(403, 'Permission denied. Role not assigned.');
    }

    const perm = employee.roleRef.permissions.find(
      (rp) => rp.permission.code === permissionCode
    );

    if (!perm) {
      throw new HttpError(403, `Permission denied for ${permissionCode}`);
    }

    let allowed = false;
    switch (action) {
      case 'view':
        allowed = perm.canView;
        break;
      case 'create':
        allowed = perm.canCreate;
        break;
      case 'edit':
        allowed = perm.canEdit;
        break;
      case 'approve':
        allowed = perm.canApprove;
        break;
      case 'delete':
        allowed = perm.canDelete;
        break;
      default:
        allowed = perm.canView;
    }

    if (!allowed) {
      throw new HttpError(403, `Permission denied: Insufficient privileges for action '${action}' on '${permissionCode}'`);
    }

    next();
  });
};

export const enforceDataScope = asyncHandler(async (req, _res, next) => {
  const employee = await prisma.employee.findUnique({
    where: { id: req.user.employeeId },
    select: { id: true, companyId: true, branchId: true, departmentId: true, roleRef: { select: { name: true } } },
  });

  if (employee) {
    req.dataScope = {
      roleName: employee.roleRef?.name || req.user.role,
      companyId: employee.companyId,
      branchId: employee.branchId,
      departmentId: employee.departmentId,
      employeeId: employee.id,
    };
  } else {
    req.dataScope = {
      roleName: req.user.role,
      employeeId: req.user.employeeId,
    };
  }

  next();
});
