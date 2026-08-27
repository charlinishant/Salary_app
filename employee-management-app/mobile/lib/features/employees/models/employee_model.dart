class EmployeeModel {
  EmployeeModel({
    required this.id,
    required this.employeeCode,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.departmentName,
    this.designationName,
    this.shiftName,
    this.isActive = true,
    this.todayAttendanceStatus,
    this.profilePhoto,
  });

  final int id;
  final String employeeCode;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? departmentName;
  final String? designationName;
  final String? shiftName;
  final bool isActive;
  final String? todayAttendanceStatus;
  final String? profilePhoto;

  String get name => '$firstName $lastName'.trim();

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    final dept = json['department'] is Map ? json['department']['name'] : json['departmentName'];
    final desig = json['designation'] is Map ? json['designation']['name'] : json['designationName'];
    final sft = json['shift'] is Map ? json['shift']['name'] : json['shiftName'];
    final active = json['user'] is Map ? (json['user']['isActive'] ?? true) : (json['isActive'] ?? true);
    final att = json['todayAttendance'] is Map ? json['todayAttendance']['status'] : json['todayAttendanceStatus'];

    return EmployeeModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      employeeCode: json['employeeCode']?.toString() ?? 'EMP-0000',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
      departmentName: dept?.toString(),
      designationName: desig?.toString(),
      shiftName: sft?.toString(),
      isActive: active == true,
      todayAttendanceStatus: att?.toString(),
      profilePhoto: json['profilePhoto']?.toString(),
    );
  }
}
