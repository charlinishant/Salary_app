import { prisma } from '../config/prisma.js';
import { asyncHandler } from '../utils/asyncHandler.js';
import { HttpError } from '../utils/httpError.js';

export const getCompany = asyncHandler(async (_req, res) => {
  let company = await prisma.company.findFirst({
    include: {
      _count: {
        select: {
          branches: true,
          departments: true,
          employees: true,
        },
      },
    },
  });

  if (!company) {
    company = await prisma.company.create({
      data: {
        name: 'Wivexa Technologies Pvt Ltd',
        companyCode: 'WIV001',
        legalName: 'Wivexa Technologies Private Limited',
        currency: 'INR',
        timezone: 'Asia/Kolkata',
      },
      include: {
        _count: {
          select: {
            branches: true,
            departments: true,
            employees: true,
          },
        },
      },
    });
  }

  res.json({
    success: true,
    message: 'Company details retrieved successfully',
    data: company,
  });
});

export const updateCompany = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const companyId = parseInt(id);

  const existing = await prisma.company.findUnique({ where: { id: companyId } });
  if (!existing) {
    throw new HttpError(404, 'Company not found');
  }

  const updated = await prisma.company.update({
    where: { id: companyId },
    data: {
      name: req.body.name,
      legalName: req.body.legalName,
      companyCode: req.body.companyCode,
      industry: req.body.industry,
      email: req.body.email,
      phone: req.body.phone,
      website: req.body.website,
      logo: req.body.logo,
      address: req.body.address,
      city: req.body.city,
      state: req.body.state,
      country: req.body.country,
      postalCode: req.body.postalCode,
      gstin: req.body.gstin,
      pan: req.body.pan,
      tan: req.body.tan,
      pfNumber: req.body.pfNumber,
      esiNumber: req.body.esiNumber,
      ptNumber: req.body.ptNumber,
      currency: req.body.currency,
      timezone: req.body.timezone,
      weekStartDay: req.body.weekStartDay,
    },
  });

  // Audit log
  await prisma.auditLog.create({
    data: {
      employeeId: req.user.employeeId,
      action: 'UPDATE',
      module: 'Company',
      entity: 'Company',
      entityId: companyId,
      newValue: JSON.stringify(req.body),
    },
  });

  res.json({
    success: true,
    message: 'Company details updated successfully',
    data: updated,
  });
});
