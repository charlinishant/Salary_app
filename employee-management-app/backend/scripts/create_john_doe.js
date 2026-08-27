import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function main() {
  console.log('Creating smoke test employee John Doe...');

  // Check if user already exists
  let user = await prisma.user.findUnique({ where: { email: 'john.doe@company.com' } });
  if (!user) {
    const passwordHash = await bcrypt.hash('password123', 10);
    user = await prisma.user.create({
      data: {
        email: 'john.doe@company.com',
        passwordHash: passwordHash,
        role: 'EMPLOYEE',
        isActive: true,
      },
    });
  }

  // Check if employee already exists
  let employee = await prisma.employee.findFirst({ where: { email: 'john.doe@company.com' } });

  if (!employee) {
    // Get department & designation
    const dept = await prisma.department.findFirst({ where: { name: 'Engineering' } }) || await prisma.department.findFirst();
    const desig = await prisma.designation.findFirst({ where: { name: 'Software Engineer' } }) || await prisma.designation.findFirst();

    // Count employees to format EMP-xxxx
    const count = await prisma.employee.count();
    const empCode = `EMP-${(count + 1).toString().padStart(4, '0')}`;

    employee = await prisma.employee.create({
      data: {
        userId: user.id,
        employeeCode: empCode,
        firstName: 'John',
        lastName: 'Doe',
        email: 'john.doe@company.com',
        phone: '+91 98765 43210',
        dateOfBirth: new Date('1995-05-15'),
        gender: 'MALE',
        joiningDate: new Date(),
        employmentType: 'FULL_TIME',
        departmentId: dept ? dept.id : null,
        designationId: desig ? desig.id : null,
      },
      include: {
        user: true,
        department: true,
        designation: true,
      },
    });
  }

  console.log('\n========================================');
  console.log('Successfully Created Smoke Test Employee');
  console.log('========================================');
  console.log(`ID: ${employee.id}`);
  console.log(`Employee Code: ${employee.employeeCode}`);
  console.log(`Name: ${employee.firstName} ${employee.lastName}`);
  console.log(`Email: ${employee.email}`);
  console.log(`Department: ${employee.department?.name || 'N/A'}`);
  console.log(`Designation: ${employee.designation?.name || 'N/A'}`);
  console.log('========================================\n');
}

main()
  .catch((e) => {
    console.error('Error creating employee:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
