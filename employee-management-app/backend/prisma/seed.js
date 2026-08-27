import bcrypt from 'bcrypt';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

const main = async () => {
  console.log('Seeding rich employee management database...');

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
      name: 'Pune Main Branch',
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

  // 3. 4 Departments
  const deptsData = [
    { name: 'HR', code: 'DEP-HR', description: 'Human Resources & Talent Management', branchId: puneBranch.id },
    { name: 'Sales', code: 'DEP-SLS', description: 'Sales & Business Development', branchId: puneBranch.id },
    { name: 'Engineering', code: 'DEP-ENG', description: 'Software Engineering & IT Infrastructure', branchId: puneBranch.id },
    { name: 'Finance', code: 'DEP-FIN', description: 'Accounts & Finance Management', branchId: mumbaiBranch.id },
  ];

  const depts = {};
  for (const d of deptsData) {
    const dept = await prisma.department.upsert({
      where: { name_companyId: { name: d.name, companyId: company.id } },
      update: { code: d.code, description: d.description },
      create: { companyId: company.id, branchId: d.branchId, name: d.name, code: d.code, description: d.description },
    });
    depts[d.name] = dept;
  }

  // 4. 6 Designations
  const desigNames = [
    'HR Manager',
    'Sales Executive',
    'Senior Developer',
    'Accountant',
    'Field Executive',
    'Support Lead',
  ];

  const desigs = {};
  for (const name of desigNames) {
    const des = await prisma.designation.upsert({
      where: { name },
      update: {},
      create: { name },
    });
    desigs[name] = des;
  }

  // 5. Roles
  const rolesList = ['Admin', 'Manager', 'Employee'];
  const createdRoles = {};
  for (const name of rolesList) {
    const role = await prisma.role.upsert({
      where: { name },
      update: {},
      create: { name, description: `${name} access role`, isSystem: true },
    });
    createdRoles[name] = role;
  }

  // 6. 2 Shifts
  const generalShift = await prisma.shift.upsert({
    where: { code: 'SFT-GEN' },
    update: {},
    create: {
      companyId: company.id,
      branchId: puneBranch.id,
      name: 'General Shift',
      code: 'SFT-GEN',
      startTime: '09:00',
      endTime: '18:00',
      graceMinutes: 15,
      halfDayHours: 4,
      fullDayHours: 8,
      breakMinutes: 60,
      weeklyOff: 'Sunday',
    },
  });

  const nightShift = await prisma.shift.upsert({
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

  // 7. 10 Employees
  const passwordHash = await bcrypt.hash('Password@123', 10);

  const seedEmployees = [
    { code: 'EMP-0001', firstName: 'Kuldeep', lastName: 'Kumavat', email: 'kuldeep@wivexa.com', phone: '9011108510', dept: 'Sales', desig: 'Sales Executive', role: 'Admin', shift: generalShift, gender: 'MALE' },
    { code: 'EMP-0002', firstName: 'Ananya', lastName: 'Sharma', email: 'ananya@wivexa.com', phone: '9822012345', dept: 'HR', desig: 'HR Manager', role: 'Admin', shift: generalShift, gender: 'FEMALE' },
    { code: 'EMP-0003', firstName: 'Rahul', lastName: 'Verma', email: 'rahul@wivexa.com', phone: '9822023456', dept: 'Engineering', desig: 'Senior Developer', role: 'Employee', shift: generalShift, gender: 'MALE' },
    { code: 'EMP-0004', firstName: 'Priya', lastName: 'Deshmukh', email: 'priya@wivexa.com', phone: '9822034567', dept: 'Finance', desig: 'Accountant', role: 'Employee', shift: generalShift, gender: 'FEMALE' },
    { code: 'EMP-0005', firstName: 'Amit', lastName: 'Patil', email: 'amit@wivexa.com', phone: '9822045678', dept: 'Sales', desig: 'Field Executive', role: 'Employee', shift: generalShift, gender: 'MALE' },
    { code: 'EMP-0006', firstName: 'Neha', lastName: 'Kulkarni', email: 'neha@wivexa.com', phone: '9822056789', dept: 'Engineering', desig: 'Support Lead', role: 'Employee', shift: nightShift, gender: 'FEMALE' },
    { code: 'EMP-0007', firstName: 'Siddharth', lastName: 'Joshi', email: 'siddharth@wivexa.com', phone: '9822067890', dept: 'Engineering', desig: 'Senior Developer', role: 'Employee', shift: generalShift, gender: 'MALE' },
    { code: 'EMP-0008', firstName: 'Pooja', lastName: 'Mehta', email: 'pooja@wivexa.com', phone: '9822078901', dept: 'HR', desig: 'HR Manager', role: 'Employee', shift: generalShift, gender: 'FEMALE' },
    { code: 'EMP-0009', firstName: 'Vikram', lastName: 'Rathore', email: 'vikram@wivexa.com', phone: '9822089012', dept: 'Sales', desig: 'Sales Executive', role: 'Employee', shift: generalShift, gender: 'MALE' },
    { code: 'EMP-0010', firstName: 'Sneha', lastName: 'Nair', email: 'sneha@wivexa.com', phone: '9822090123', dept: 'Finance', desig: 'Accountant', role: 'Employee', shift: generalShift, gender: 'FEMALE' },
  ];

  const dbEmployees = [];
  for (const empData of seedEmployees) {
    const userRole = empData.role === 'Admin' ? 'ADMIN' : 'EMPLOYEE';
    const user = await prisma.user.upsert({
      where: { email: empData.email },
      update: { role: userRole },
      create: { email: empData.email, passwordHash, role: userRole, isActive: true },
    });

    const emp = await prisma.employee.upsert({
      where: { employeeCode: empData.code },
      update: {
        firstName: empData.firstName,
        lastName: empData.lastName,
        phone: empData.phone,
        departmentId: depts[empData.dept].id,
        designationId: desigs[empData.desig].id,
        roleId: createdRoles[empData.role].id,
        shiftId: empData.shift.id,
      },
      create: {
        userId: user.id,
        employeeCode: empData.code,
        firstName: empData.firstName,
        lastName: empData.lastName,
        email: empData.email,
        phone: empData.phone,
        gender: empData.gender,
        companyId: company.id,
        branchId: puneBranch.id,
        departmentId: depts[empData.dept].id,
        designationId: desigs[empData.desig].id,
        roleId: createdRoles[empData.role].id,
        shiftId: empData.shift.id,
        joiningDate: new Date('2024-01-15'),
        workLocation: 'Pune Main Branch',
        reportingManager: 'Kuldeep Kumavat',
        bankName: 'HDFC Bank',
        accountNumber: '50100234567890',
        ifsc: 'HDFC0001234',
        branch: 'Baner, Pune',
        accountHolderName: `${empData.firstName} ${empData.lastName}`,
        upiId: `${empData.phone}@okaxis`,
      },
    });
    dbEmployees.push(emp);
  }

  // 8. Attendance Records
  const today = new Date();
  today.setHours(0, 0, 0, 0);

  const statuses = ['PRESENT', 'PRESENT', 'LATE', 'PRESENT', 'ABSENT', 'PRESENT', 'LATE', 'PRESENT', 'PRESENT', 'PRESENT'];
  for (let i = 0; i < dbEmployees.length; i++) {
    const emp = dbEmployees[i];
    const status = statuses[i];
    if (status !== 'ABSENT') {
      const punchIn = new Date(today);
      punchIn.setHours(9, status === 'LATE' ? 45 : 15, 0, 0);
      const punchOut = new Date(today);
      punchOut.setHours(18, 0, 0, 0);

      await prisma.attendance.upsert({
        where: { employeeId_attendanceDate: { employeeId: emp.id, attendanceDate: today } },
        update: { attendanceStatus: status },
        create: {
          employeeId: emp.id,
          attendanceDate: today,
          punchInTime: punchIn,
          punchOutTime: i % 2 === 0 ? punchOut : null,
          totalWorkingMinutes: i % 2 === 0 ? 525 : null,
          attendanceStatus: status,
          lateMinutes: status === 'LATE' ? 30 : 0,
          attendanceMode: 'SELFIE',
        },
      });
    }
  }

  // 9. Leave Types & Requests
  const clType = await prisma.leaveType.upsert({
    where: { name: 'Casual Leave' },
    update: {},
    create: { name: 'Casual Leave', code: 'CL', isPaid: true, annualAllocation: 12, color: '#3B82F6' },
  });
  const slType = await prisma.leaveType.upsert({
    where: { name: 'Sick Leave' },
    update: {},
    create: { name: 'Sick Leave', code: 'SL', isPaid: true, annualAllocation: 10, color: '#EF4444' },
  });

  for (const emp of dbEmployees) {
    await prisma.leaveBalance.upsert({
      where: { employeeId_leaveTypeId: { employeeId: emp.id, leaveTypeId: clType.id } },
      update: {},
      create: { employeeId: emp.id, leaveTypeId: clType.id, totalDays: 12, usedDays: 1, remainingDays: 11 },
    });
  }

  await prisma.leaveRequest.createMany({
    data: [
      { employeeId: dbEmployees[2].id, leaveTypeId: clType.id, fromDate: new Date('2026-09-01'), toDate: new Date('2026-09-02'), numberOfDays: 2, reason: 'Personal work at home', status: 'PENDING' },
      { employeeId: dbEmployees[4].id, leaveTypeId: slType.id, fromDate: new Date('2026-08-20'), toDate: new Date('2026-08-20'), numberOfDays: 1, reason: 'Fever and cold', status: 'APPROVED' },
    ],
    skipDuplicates: true,
  });

  // 10. Expenses
  await prisma.expense.createMany({
    data: [
      { employeeId: dbEmployees[0].id, expenseType: 'Travel', amount: 1250.0, date: new Date('2026-08-25'), description: 'Client visit taxi fare', status: 'PENDING', paymentMode: 'UPI' },
      { employeeId: dbEmployees[4].id, expenseType: 'Food & Meals', amount: 650.0, date: new Date('2026-08-24'), description: 'Team dinner meeting', status: 'APPROVED', paymentMode: 'CASH' },
    ],
    skipDuplicates: true,
  });

  // 11. Announcements
  await prisma.announcement.createMany({
    data: [
      { title: 'Independence Day Celebration', message: 'Join us in the cafeteria at 10 AM on August 15 for flag hoisting.', priority: 'HIGH', createdBy: 'HR Team' },
      { title: 'New Attendance & Selfie System', message: 'All employees are requested to mark punch-in using front camera selfie starting this week.', priority: 'NORMAL', createdBy: 'Admin' },
    ],
    skipDuplicates: true,
  });

  // 12. Holidays
  await prisma.holiday.createMany({
    data: [
      { companyId: company.id, branchId: puneBranch.id, name: 'Independence Day', date: new Date('2026-08-15'), day: 'Saturday', holidayType: 'National', description: 'National Holiday' },
      { companyId: company.id, branchId: puneBranch.id, name: 'Ganesh Chaturthi', date: new Date('2026-09-14'), day: 'Monday', holidayType: 'Festival', description: 'Ganesh Festival' },
      { companyId: company.id, branchId: puneBranch.id, name: 'Diwali', date: new Date('2026-11-08'), day: 'Sunday', holidayType: 'Festival', description: 'Festival of Lights' },
    ],
    skipDuplicates: true,
  });

  // 13. Documents
  for (const emp of dbEmployees.slice(0, 5)) {
    await prisma.employeeDocument.createMany({
      data: [
        { employeeId: emp.id, documentType: 'Aadhaar Card', status: 'VERIFIED', remarks: 'Verified by HR' },
        { employeeId: emp.id, documentType: 'PAN Card', status: 'VERIFIED', remarks: 'Verified by Accounts' },
      ],
      skipDuplicates: true,
    });
  }

  console.log('Database seeding completed successfully with 10 employees!');
};

main()
  .catch((e) => {
    console.error('Seed error:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
