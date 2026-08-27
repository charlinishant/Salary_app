class DepartmentModel {
  final int id;
  final int? companyId;
  final int? branchId;
  final String name;
  final String? code;
  final String? description;
  final int? headId;
  final bool isActive;
  final String branchName;
  final String departmentHeadName;
  final int employeeCount;

  DepartmentModel({
    required this.id,
    this.companyId,
    this.branchId,
    required this.name,
    this.code,
    this.description,
    this.headId,
    this.isActive = true,
    this.branchName = 'All Branches',
    this.departmentHeadName = 'Unassigned',
    this.employeeCount = 0,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      id: json['id'],
      companyId: json['companyId'],
      branchId: json['branchId'],
      name: json['name'] ?? '',
      code: json['code'],
      description: json['description'],
      headId: json['headId'],
      isActive: json['isActive'] ?? true,
      branchName: json['branchName'] ?? json['branch']?['name'] ?? 'All Branches',
      departmentHeadName: json['departmentHeadName'] ??
          (json['head'] != null ? '${json['head']['firstName']} ${json['head']['lastName']}' : 'Unassigned'),
      employeeCount: json['employeeCount'] ?? json['_count']?['employees'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'companyId': companyId,
        'branchId': branchId,
        'name': name,
        'code': code,
        'description': description,
        'headId': headId,
        'isActive': isActive,
      };
}
