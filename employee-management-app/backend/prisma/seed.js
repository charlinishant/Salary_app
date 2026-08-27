import bcrypt from 'bcrypt';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

const main = async () => {
  console.log('Seeding database...');

  // 1. Company
  const company = await prisma.company.upsert({
    where: { companyCode: 'WIV001' },
    update: {},
    create: {
      name: 'Wivexa Technologies Pvt Ltd',
      legalName: 'Wivexa Technologies Private Limited',
      companyCode: 'WIV001',
      industry: 'Information Technology',
      email: 'hr@wivexa.com',
      phone: '+91 9876543210',
      website: 'https://wivexa.com',
      logo: 'https://via.placeholder.com/150',
      address: 'Tech Park, Baner',
      city: 'Pune',
      state: 'Maharashtra',
      country: 'India',
      postalCode: '411045',
      gstin: '27AAAAA0000A1Z5',
      pan: 'AAAAA0000A',
      tan: 'PUNE00000A',
      pfNumber: 'MH/PUN/0012345/000',
      esiNumber: '31000123450000101',
      ptNumber: '27000123456P',
      currency: 'INR',
      timezone: 'Asia/Kolkata',
      weekStartDay: 'Monday',
    },
  });

  // 2. Branches
  const puneBranch = await prisma.branch.upsert({
    where: { code: 'PUN01' },
    update: {},
    create: {
      companyId: company.id,
      name: 'Pune Branch',
      code: 'PUN01',
      address: 'IT Park, Baner',
      city: 'Pune',
      state: 'Maharashtra',
      country: 'India',
      postalCode: '411045',
      phone: '020-12345678',
      email: 'pune@wivexa.com',
      latitude: 18.5204,
      longitude: 73.8567,
      geofenceRadius: 100,
      timezone: 'Asia/Kolkata',
      isActive: true,
    },
  });

  const mumbaiBranch = await prisma.branch.upsert({
    where: { code: 'MUM01' },
    update: {},
    create: {
      companyId: company.id,
      name: 'Mumbai Branch',
      code: 'MUM01',
      address: 'BKC Business Center',
      city: 'Mumbai',
      state: 'Maharashtra',
      country: 'India',
      postalCode: '400051',
      phone: '022-87654321',
      email: 'mumbai@wivexa.com',
      latitude: 19.076,
      longitude: 72.8777,
      geofenceRadius: 150,
      timezone: 'Asia/Kolkata',
      isActive: true,
    },
  });

  await prisma.branch.upsert({
    where: { code: 'NSK01' },
    update: {},
    create: {
      companyId: company.id,
      name: 'Nashik Branch',
      code: 'NSK01',
      address: 'MIDC Ambad',
      city: 'Nashik',
      state: 'Maharashtra',
      country: 'India',
      postalCode: '422010',
      phone: '0253-1122334',
      email: 'nashik@wivexa.com',
      latitude: 19.9975,
      longitude: 73.7898,
      geofenceRadius: 100,
      timezone: 'Asia/Kolkata',
      isActive: true,
    },
  });

  // 3. Departments
  const deptHR = await prisma.department.upsert({
    where: { name_companyId: { name: 'HR', companyId: company.id } },
    update: {},
    create: {
      companyId: company.id,
      branchId: puneBranch.id,
      name: 'HR',
      code: 'DEP-HR',
      description: 'Human Resources & Talent Management',
    },
  });

  const deptSales = await prisma.department.upsert({
    where: { name_companyId: { name: 'Sales', companyId: company.id } },
    update: {},
    create: {
      companyId: company.id,
      branchId: puneBranch.id,
      name: 'Sales',
      code: 'DEP-SLS',
      description: 'Sales & Business Development',
    },
  });

  const deptIT = await prisma.department.upsert({
    where: { name_companyId: { name: 'IT', companyId: company.id } },
    update: {},
    create: {
      companyId: company.id,
      branchId: puneBranch.id,
      name: 'IT',
      code: 'DEP-IT',
      description: 'Software Engineering & IT Infrastructure',
    },
  });

  await prisma.department.upsert({
    where: { name_companyId: { name: 'Accounts', companyId: company.id } },
    update: {},
    create: {
      companyId: company.id,
      branchId: mumbaiBranch.id,
      name: 'Accounts',
      code: 'DEP-ACC',
      description: 'Finance & Accounts',
    },
  });

  // 4. Permissions
  const permissionsData = [
    { code: 'dashboard.view', category: 'Dashboard', name: 'View Dashboard' },

    { code: 'employee.view', category: 'Employees', name: 'View Employees' },
    { code: 'employee.create', category: 'Employees', name: 'Create Employee' },
    { code: 'employee.edit', category: 'Employees', name: 'Edit Employee' },
    { code: 'employee.delete', category: 'Employees', name: 'Delete Employee' },
    { code: 'employee.documents', category: 'Employees', name: 'Manage Employee Documents' },
    { code: 'employee.salary.view', category: 'Employees', name: 'View Employee Salary' },
    { code: 'employee.salary.edit', category: 'Employees', name: 'Edit Employee Salary' },

    { code: 'attendance.view', category: 'Attendance', name: 'View Attendance' },
    { code: 'attendance.mark', category: 'Attendance', name: 'Mark Attendance' },
    { code: 'attendance.edit', category: 'Attendance', name: 'Edit Attendance' },
    { code: 'attendance.approve', category: 'Attendance', name: 'Approve Attendance' },
    { code: 'attendance.report', category: 'Attendance', name: 'Attendance Reports' },
    { code: 'attendance.settings', category: 'Attendance', name: 'Attendance Settings' },

    { code: 'leave.view', category: 'Leave', name: 'View Leaves' },
    { code: 'leave.apply', category: 'Leave', name: 'Apply Leave' },
    { code: 'leave.approve', category: 'Leave', name: 'Approve Leave' },
    { code: 'leave.reject', category: 'Leave', name: 'Reject Leave' },
    { code: 'leave.managePolicy', category: 'Leave', name: 'Manage Leave Policies' },
    { code: 'leave.manageBalance', category: 'Leave', name: 'Manage Leave Balances' },

    { code: 'payroll.view', category: 'Payroll', name: 'View Payroll' },
    { code: 'payroll.process', category: 'Payroll', name: 'Process Payroll' },
    { code: 'payroll.edit', category: 'Payroll', name: 'Edit Payroll' },
    { code: 'payroll.approve', category: 'Payroll', name: 'Approve Payroll' },
    { code: 'payroll.payslip', category: 'Payroll', name: 'Generate Payslip' },
    { code: 'payroll.report', category: 'Payroll', name: 'Payroll Reports' },

    { code: 'company.view', category: 'Organization', name: 'View Company' },
    { code: 'company.edit', category: 'Organization', name: 'Edit Company' },
    { code: 'branch.view', category: 'Organization', name: 'View Branches' },
    { code: 'branch.create', category: 'Organization', name: 'Create Branch' },
    { code: 'branch.edit', category: 'Organization', name: 'Edit Branch' },
    { code: 'branch.delete', category: 'Organization', name: 'Delete Branch' },
    { code: 'department.view', category: 'Organization', name: 'View Departments' },
    { code: 'department.create', category: 'Organization', name: 'Create Department' },
    { code: 'department.edit', category: 'Organization', name: 'Edit Department' },
    { code: 'department.delete', category: 'Organization', name: 'Delete Department' },

    { code: 'shift.view', category: 'Shift', name: 'View Shifts' },
    { code: 'shift.create', category: 'Shift', name: 'Create Shift' },
    { code: 'shift.edit', category: 'Shift', name: 'Edit Shift' },
    { code: 'shift.assign', category: 'Shift', name: 'Assign Shift' },

    { code: 'role.view', category: 'Roles', name: 'View Roles' },
    { code: 'role.create', category: 'Roles', name: 'Create Role' },
    { code: 'role.edit', category: 'Roles', name: 'Edit Role' },
    { code: 'permission.assign', category: 'Roles', name: 'Assign Permissions' },
  ];

  const dbPermissions = await Promise.all(
    permissionsData.map((p) =>
      prisma.permission.upsert({
        where: { code: p.code },
        update: { category: p.category, name: p.name },
        create: p,
      })
    )
  );

  // 5. Roles
  const rolesList = [
    { name: 'Super Admin', description: 'Full access to all companies and system settings', isSystem: true },
    { name: 'Admin', description: 'Company-wide administrative access', isSystem: true },
    { name: 'HR Admin', description: 'HR and workforce management access', isSystem: true },
    { name: 'Branch Admin', description: 'Branch-level administrative access', isSystem: true },
    { name: 'Manager', description: 'Department and team management access', isSystem: true },
    { name: 'Attendance Manager', description: 'Attendance tracking and approvals', isSystem: true },
    { name: 'Payroll Manager', description: 'Payroll calculations and payslip generation', isSystem: true },
    { name: 'Employee', description: 'Self-service employee portal access', isSystem: true },
    { name: 'CA / Report Viewer', description: 'Read-only financial and report access', isSystem: true },
  ];

  const createdRoles = {};
  for (const r of rolesList) {
    const role = await prisma.role.upsert({
      where: { name: r.name },
      update: { description: r.description },
      create: r,
    });
    createdRoles[r.name] = role;
  }

  // Grant all permissions to Super Admin and Admin
  for (const p of dbPermissions) {
    await prisma.rolePermission.upsert({
      where: { roleId_permissionId: { roleId: createdRoles['Admin'].id, permissionId: p.id } },
      update: { canView: true, canCreate: true, canEdit: true, canApprove: true, canDelete: true },
      create: { roleId: createdRoles['Admin'].id, permissionId: p.id, canView: true, canCreate: true, canEdit: true, canApprove: true, canDelete: true },
    });
  }

  // 6. Shifts
  const generalShift = await prisma.shift.upsert({
    where: { code: 'SFT-GEN' },
    update: {},
    create: {
      companyId: company.id,
      branchId: puneBranch.id,
      name: 'General Shift',
      code: 'SFT-GEN',
      startTime: '09:30',
      endTime: '18:30',
      graceMinutes: 15,
      halfDayHours: 4,
      fullDayHours: 8,
      breakMinutes: 60,
      weeklyOff: 'Sunday',
      isOvernight: false,
    },
  });

  await prisma.shift.upsert({
    where: { code: 'SFT-MORN' },
    update: {},
    create: {
      companyId: company.id,
      branchId: puneBranch.id,
      name: 'Morning Shift',
      code: 'SFT-MORN',
      startTime: '07:00',
      endTime: '16:00',
      graceMinutes: 15,
      halfDayHours: 4,
      fullDayHours: 8,
      breakMinutes: 60,
      weeklyOff: 'Sunday',
      isOvernight: false,
    },
  });

  await prisma.shift.upsert({
    where: { code: 'SFT-NIGHT' },
    update: {},
    create: {
      companyId: company.id,
      branchId: puneBranch.id,
      name: 'Night Shift',
      code: 'SFT-NIGHT',
      startTime: '21:00',
      endTime: '06:00',
      graceMinutes: 15,
      halfDayHours: 4,
      fullDayHours: 8,
      breakMinutes: 60,
      weeklyOff: 'Sunday',
      isOvernight: true,
    },
  });

  // 7. Designation
  const designation = await prisma.designation.upsert({
    where: { name: 'Field Executive' },
    update: {},
    create: { name: 'Field Executive' },
  });

  // 8. Users & Employees
  const passwordHash = await bcrypt.hash('Password@123', 10);

  // Admin User
  const adminUser = await prisma.user.upsert({
    where: { email: 'admin@example.com' },
    update: {},
    create: { email: 'admin@example.com', passwordHash, role: 'ADMIN' },
  });

  await prisma.employee.upsert({
    where: { employeeCode: 'ADM001' },
    update: { companyId: company.id, branchId: puneBranch.id, departmentId: deptHR.id, roleId: createdRoles['Admin'].id },
    create: {
      userId: adminUser.id,
      employeeCode: 'ADM001',
      firstName: 'System',
      lastName: 'Admin',
      email: 'admin@example.com',
      phone: '9876543210',
      gender: 'MALE',
      companyId: company.id,
      branchId: puneBranch.id,
      departmentId: deptHR.id,
      designationId: designation.id,
      roleId: createdRoles['Admin'].id,
      shiftId: generalShift.id,
      joiningDate: new Date('2024-01-01'),
      workLocation: 'Pune Branch',
      reportingManager: 'Board of Directors',
    },
  });

  // Employee User
  const empUser = await prisma.user.upsert({
    where: { email: 'employee@example.com' },
    update: {},
    create: { email: 'employee@example.com', passwordHash, role: 'EMPLOYEE' },
  });

  const employee = await prisma.employee.upsert({
    where: { employeeCode: 'EMP001' },
    update: { companyId: company.id, branchId: puneBranch.id, departmentId: deptSales.id, roleId: createdRoles['Employee'].id },
    create: {
      userId: empUser.id,
      employeeCode: 'EMP001',
      firstName: 'Sample',
      lastName: 'Employee',
      email: 'employee@example.com',
      phone: '9999999999',
      gender: 'MALE',
      companyId: company.id,
      branchId: puneBranch.id,
      departmentId: deptSales.id,
      designationId: designation.id,
      roleId: createdRoles['Employee'].id,
      shiftId: generalShift.id,
      joiningDate: new Date('2024-04-01'),
      workLocation: 'Pune Branch',
      reportingManager: 'System Admin',
    },
  });

  // 9. Leave Types & Policies
  const leaveTypesList = [
    { name: 'Casual Leave', code: 'CL', isPaid: true, annualAllocation: 12, color: '#3B82F6' },
    { name: 'Sick Leave', code: 'SL', isPaid: true, annualAllocation: 10, color: '#EF4444' },
    { name: 'Paid Leave', code: 'PL', isPaid: true, annualAllocation: 15, carryForward: true, maxCarryForward: 5, color: '#10B981' },
    { name: 'Unpaid Leave', code: 'LWP', isPaid: false, annualAllocation: 0, isLimited: false, color: '#6B7280' },
  ];

  for (const lt of leaveTypesList) {
    const leaveType = await prisma.leaveType.upsert({
      where: { name: lt.name },
      update: lt,
      create: lt,
    });

    await prisma.leaveBalance.upsert({
      where: { employeeId_leaveTypeId: { employeeId: employee.id, leaveTypeId: leaveType.id } },
      update: { totalDays: lt.annualAllocation, remainingDays: lt.annualAllocation },
      create: {
        employeeId: employee.id,
        leaveTypeId: leaveType.id,
        totalDays: lt.annualAllocation,
        usedDays: 0,
        remainingDays: lt.annualAllocation,
      },
    });

    await prisma.leavePolicy.upsert({
      where: { id: leaveType.id },
      update: {},
      create: {
        name: `${lt.name} Policy`,
        companyId: company.id,
        leaveTypeId: leaveType.id,
        annualBalance: lt.annualAllocation,
        monthlyAccrual: 1.0,
        carryForward: lt.carryForward || false,
        maxConsecutiveDays: 14,
        allowNegativeBalance: false,
        approvalRequired: true,
      },
    });
  }

  // 10. Holidays
  await prisma.holiday.createMany({
    data: [
      { companyId: company.id, branchId: puneBranch.id, name: 'Independence Day', date: new Date('2026-08-15'), day: 'Saturday', holidayType: 'National', description: 'National Holiday' },
      { companyId: company.id, branchId: puneBranch.id, name: 'Diwali', date: new Date('2026-11-08'), day: 'Sunday', holidayType: 'Company', description: 'Festival of Lights' },
      { companyId: company.id, branchId: puneBranch.id, name: 'Republic Day', date: new Date('2026-01-26'), day: 'Monday', holidayType: 'National', description: 'Republic Day Celebration' },
    ],
    skipDuplicates: true,
  });

  // 11. Salary Structure
  await prisma.salaryStructure.upsert({
    where: { id: 1 },
    update: {},
    create: {
      employeeId: employee.id,
      basic: 20000,
      hra: 8000,
      allowances: 12000,
      grossSalary: 40000,
      pf: 1600,
      professionalTax: 200,
      otherDeductions: 200,
      netSalary: 38000,
      effectiveFrom: new Date('2026-08-01'),
    },
  });

  console.log('Database seeding completed successfully!');
};

main()
  .catch((e) => {
    console.error('Seed error:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
