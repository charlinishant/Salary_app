import '../../features/auth/models/employee_model.dart';

class DemoData {
  static final adminEmployee = EmployeeModel(
    id: 1,
    employeeCode: 'ADM001',
    name: 'System Admin',
    email: 'admin@example.com',
  );

  static final regularEmployee = EmployeeModel(
    id: 2,
    employeeCode: 'EMP001',
    name: 'Sample Employee',
    email: 'employee@example.com',
  );

  static final employee = regularEmployee;

  static final dashboard = <String, dynamic>{
    'attendance': {
      'punchInTime': '09:30 AM',
      'punchOutTime': '--',
    },
    'remainingLeave': 8,
    'pendingRequests': 2,
  };

  static final profile = <String, dynamic>{
    'employeeCode': 'EMP001',
    'firstName': 'Demo',
    'lastName': 'Employee',
    'email': 'demo@yogeshkrushi.com',
    'phone': '+91 98765 43210',
    'gender': 'MALE',
    'dateOfBirth': '1995-08-10',
    'address': 'Pune, Maharashtra',
    'department': {'name': 'Operations'},
    'designation': {'name': 'Field Executive'},
    'joiningDate': '2024-04-01',
    'employmentType': 'FULL_TIME',
    'reportingManager': 'Admin Manager',
    'shift': {'name': 'General Shift'},
    'workLocation': 'Pune',
    'bankName': 'Demo Bank',
    'accountNumber': '1234567890',
    'ifsc': 'DEMO0001234',
    'branch': 'Pune',
    'accountHolderName': 'Demo Employee',
  };

  static final attendanceToday = <String, dynamic>{
    'attendanceDate': '2026-08-20',
    'punchInTime': '09:30 AM',
    'punchOutTime': null,
    'attendanceStatus': 'PRESENT',
  };

  static final attendanceHistory = <Map<String, dynamic>>[
    {'attendanceDate': '2026-08-19', 'punchInTime': '09:28 AM', 'punchOutTime': '06:12 PM', 'attendanceStatus': 'PRESENT'},
    {'attendanceDate': '2026-08-18', 'punchInTime': '09:46 AM', 'punchOutTime': '06:05 PM', 'attendanceStatus': 'LATE'},
  ];

  static List<Map<String, dynamic>> rowsForEndpoint(String endpoint) {
    return switch (endpoint) {
      '/leaves' => [
          {'title': 'Casual Leave', 'fromDate': '2026-08-26', 'toDate': '2026-08-26', 'status': 'PENDING'},
          {'title': 'Sick Leave', 'fromDate': '2026-07-12', 'toDate': '2026-07-13', 'status': 'APPROVED'},
        ],
      '/announcements' => [
          {'title': 'Monthly team meeting', 'message': 'All employees should attend the 10 AM meeting.', 'priority': 'HIGH'},
          {'title': 'Holiday notice', 'message': 'Office will remain closed on the published holiday.', 'priority': 'NORMAL'},
        ],
      '/notifications' => [
          {'title': 'Punch-in reminder', 'message': 'Remember to mark attendance before shift start.', 'type': 'ATTENDANCE'},
          {'title': 'Payslip generated', 'message': 'Your latest payslip is available.', 'type': 'SALARY'},
        ],
      '/trips' => [
          {'title': 'Client visit', 'destination': 'Nashik', 'purpose': 'Vendor meeting'},
          {'title': 'Field survey', 'destination': 'Pune Rural', 'purpose': 'Site inspection'},
        ],
      '/expenses' => [
          {'title': 'Travel reimbursement', 'amount': '1250', 'status': 'PENDING'},
          {'title': 'Meal expense', 'amount': '320', 'status': 'APPROVED'},
        ],
      '/notes' => [
          {'title': 'Client follow-up', 'note': 'Call the client before Friday.'},
          {'title': 'Document pending', 'note': 'Upload updated PAN copy.'},
        ],
      '/holidays' => [
          {'name': 'Independence Day', 'date': '2026-08-15', 'holidayType': 'National'},
          {'name': 'Diwali', 'date': '2026-11-08', 'holidayType': 'Festival'},
        ],
      '/documents' => [
          {'documentType': 'Aadhaar Card', 'status': 'VERIFIED'},
          {'documentType': 'PAN Card', 'status': 'PENDING'},
        ],
      '/referrals/me' => [
          {'referralCode': 'EMP001REF', 'candidateName': 'Rahul Sharma', 'status': 'INVITED'},
        ],
      '/payslips' => [
          {'title': 'July 2026 Payslip', 'amount': '45000', 'status': 'Paid'},
          {'title': 'June 2026 Payslip', 'amount': '45000', 'status': 'Paid'},
        ],
      _ => [
          {'title': 'Demo item', 'subtitle': 'Sample information'},
        ],
    };
  }
}
