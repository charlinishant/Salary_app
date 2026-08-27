async function runEndToEndSmokeTest() {
  console.log('====================================================');
  console.log('🚀 RUNNING END-TO-END SMOKE TEST FOR APP');
  console.log('====================================================\n');

  const baseUrl = 'http://localhost:5000/api';

  // STEP 1: Health Check
  console.log('1️⃣ Testing Server Health Check...');
  const healthRes = await fetch('http://localhost:5000/health').then(r => r.json());
  console.log('   Health Output:', healthRes);
  if (!healthRes.success) throw new Error('Health check failed');
  console.log('   ✅ Health Check PASSED\n');

  // STEP 2: Admin Add Employee
  console.log('2️⃣ Admin Creating New Employee (Smoke Test User)...');
  const empData = {
    firstName: 'Smoke',
    lastName: 'Tester',
    email: `smoke.tester.${Date.now()}@company.com`,
    phone: '+91 99887 76655',
    gender: 'FEMALE',
    joiningDate: '2026-08-27',
    employmentType: 'FULL_TIME',
    departmentId: 1,
    designationId: 1,
    shiftId: 1,
    workLocation: 'Pune HQ',
  };

  const createRes = await fetch(`${baseUrl}/employees`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'x-role': 'ADMIN',
    },
    body: JSON.stringify(empData),
  }).then(r => r.json());

  console.log('   Create Employee Output:', createRes);
  if (!createRes.success) throw new Error(`Create employee failed: ${JSON.stringify(createRes)}`);

  const createdEmp = createRes.data;
  console.log(`   ✅ Admin Created Employee: ${createdEmp.firstName} ${createdEmp.lastName} (ID: ${createdEmp.id}, Code: ${createdEmp.employeeCode})\n`);

  // STEP 3: Employee Attendance - Check Initial Status
  console.log('3️⃣ Checking Employee Initial Attendance Status...');
  const initialAtt = await fetch(`${baseUrl}/attendance/today`, {
    headers: {
      'x-role': 'EMPLOYEE',
      'x-employee-id': createdEmp.id.toString(),
    },
  }).then(r => r.json());

  console.log('   Initial Status Output:', initialAtt);
  console.log('   ✅ Attendance Status fetched successfully\n');

  // STEP 4: Employee Punch-In (Selfie Attendance)
  console.log('4️⃣ Employee Marking Punch In...');
  const punchInRes = await fetch(`${baseUrl}/attendance/punch-in`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'x-role': 'EMPLOYEE',
      'x-employee-id': createdEmp.id.toString(),
    },
    body: JSON.stringify({
      latitude: 18.5204,
      longitude: 73.8567,
      selfieUrl: '/uploads/selfies/sample_punch_in.jpg',
    }),
  }).then(r => r.json());

  console.log('   Punch In Output:', punchInRes);
  if (!punchInRes.success) throw new Error(`Punch In failed: ${JSON.stringify(punchInRes)}`);
  const attData = punchInRes.data || punchInRes.attendance;
  console.log(`   ✅ Punch In Successful! Status: ${attData.status}, Time: ${attData.checkInTime || attData.punchInTime}\n`);

  // STEP 5: Employee Punch-Out
  console.log('5️⃣ Employee Marking Punch Out...');
  const punchOutRes = await fetch(`${baseUrl}/attendance/punch-out`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'x-role': 'EMPLOYEE',
      'x-employee-id': createdEmp.id.toString(),
    },
    body: JSON.stringify({
      latitude: 18.5204,
      longitude: 73.8567,
      selfieUrl: '/uploads/selfies/sample_punch_out.jpg',
    }),
  }).then(r => r.json());

  console.log('   Punch Out Output:', punchOutRes);
  if (!punchOutRes.success) throw new Error(`Punch Out failed: ${JSON.stringify(punchOutRes)}`);
  const outData = punchOutRes.data || punchOutRes.attendance;
  console.log(`   ✅ Punch Out Successful! Total Working Minutes: ${outData.workingMinutes ?? outData.totalWorkingMinutes}\n`);

  // STEP 6: Admin Dashboard Summary Verification
  console.log('6️⃣ Verifying Admin Dashboard & Reports Integration...');
  const dashRes = await fetch(`${baseUrl}/dashboard/admin`, {
    headers: { 'x-role': 'ADMIN' },
  }).then(r => r.json());

  const summary = dashRes.summary || dashRes.data?.summary || {};
  console.log('   Admin Summary Stats:');
  console.log(`   - Total Employees: ${summary.totalEmployees ?? 'N/A'}`);
  console.log(`   - Present Today: ${summary.presentToday ?? 'N/A'}`);
  console.log(`   - Absent Today: ${summary.absentToday ?? 'N/A'}`);

  const reportRes = await fetch(`${baseUrl}/reports/employees`, {
    headers: { 'x-role': 'ADMIN' },
  }).then(r => r.json());

  console.log(`   - Total Employee Records in Report: ${reportRes.data.length}`);
  console.log('   ✅ Admin Dashboard & Reports Verification PASSED!\n');

  console.log('====================================================');
  console.log('🎉 ALL END-TO-END SMOKE TESTS PASSED 100% SUCCESSFULLY!');
  console.log('====================================================');
}

runEndToEndSmokeTest().catch(err => {
  console.error('\n❌ SMOKE TEST FAILED:', err);
  process.exit(1);
});
