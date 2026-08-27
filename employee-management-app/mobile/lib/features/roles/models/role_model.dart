class RolePermissionModel {
  final int permissionId;
  final String code;
  final String category;
  final String name;
  bool canView;
  bool canCreate;
  bool canEdit;
  bool canApprove;
  bool canDelete;

  RolePermissionModel({
    required this.permissionId,
    required this.code,
    required this.category,
    required this.name,
    this.canView = true,
    this.canCreate = false,
    this.canEdit = false,
    this.canApprove = false,
    this.canDelete = false,
  });

  factory RolePermissionModel.fromJson(Map<String, dynamic> json) {
    return RolePermissionModel(
      permissionId: json['permissionId'] ?? json['id'] ?? 0,
      code: json['code'] ?? '',
      category: json['category'] ?? 'General',
      name: json['name'] ?? '',
      canView: json['canView'] ?? true,
      canCreate: json['canCreate'] ?? false,
      canEdit: json['canEdit'] ?? false,
      canApprove: json['canApprove'] ?? false,
      canDelete: json['canDelete'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'permissionId': permissionId,
        'code': code,
        'category': category,
        'name': name,
        'canView': canView,
        'canCreate': canCreate,
        'canEdit': canEdit,
        'canApprove': canApprove,
        'canDelete': canDelete,
      };
}

class RoleModel {
  final int id;
  final String name;
  final String? description;
  final bool isSystem;
  final int employeeCount;
  final List<RolePermissionModel> permissions;

  RoleModel({
    required this.id,
    required this.name,
    this.description,
    this.isSystem = false,
    this.employeeCount = 0,
    required this.permissions,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    final perms = (json['permissions'] as List? ?? [])
        .map((p) => RolePermissionModel.fromJson(p))
        .toList();
    return RoleModel(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'],
      isSystem: json['isSystem'] ?? false,
      employeeCount: json['employeeCount'] ?? json['_count']?['employees'] ?? 0,
      permissions: perms,
    );
  }
}
