class EmployeeModel {
  EmployeeModel({required this.id, required this.employeeCode, required this.name, this.email, this.profilePhoto});
  final int id;
  final String employeeCode;
  final String name;
  final String? email;
  final String? profilePhoto;

  factory EmployeeModel.fromJson(Map<String, dynamic> json) => EmployeeModel(
        id: json['id'] as int,
        employeeCode: json['employeeCode']?.toString() ?? '',
        name: '${json['firstName'] ?? ''} ${json['lastName'] ?? ''}'.trim(),
        email: json['email']?.toString(),
        profilePhoto: json['profilePhoto']?.toString(),
      );
}
