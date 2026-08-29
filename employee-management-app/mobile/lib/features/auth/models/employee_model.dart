class EmployeeModel {
  EmployeeModel({
    required this.id,
    required this.employeeCode,
    required this.name,
    this.email,
    this.phone,
    this.profilePhoto,
    this.departmentName,
    this.designationName,
  });

  final int id;
  final String employeeCode;
  final String name;
  final String? email;
  final String? phone;
  final String? profilePhoto;
  final String? departmentName;
  final String? designationName;

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    String computedName = json['name']?.toString() ?? '';
    if (computedName.isEmpty) {
      computedName = '${json['firstName'] ?? ''} ${json['lastName'] ?? ''}'.trim();
    }
    if (computedName.isEmpty) computedName = 'Employee';

    String? deptName;
    if (json['department'] is Map) {
      deptName = json['department']['name']?.toString();
    } else if (json['departmentName'] != null) {
      deptName = json['departmentName']?.toString();
    }

    String? desigName;
    if (json['designation'] is Map) {
      desigName = json['designation']['name']?.toString();
    } else if (json['designationName'] != null) {
      desigName = json['designationName']?.toString();
    }

    return EmployeeModel(
      id: json['id'] is int ? json['id'] : (int.tryParse(json['id']?.toString() ?? '') ?? 1),
      employeeCode: json['employeeCode']?.toString() ?? 'EMP-0001',
      name: computedName,
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      profilePhoto: json['profilePhoto']?.toString(),
      departmentName: deptName,
      designationName: desigName,
    );
  }
}
