import '../../../core/network/api_client.dart';
import '../models/role_model.dart';

class RoleService {
  final ApiClient _apiClient;

  RoleService(this._apiClient);

  Future<List<RoleModel>> fetchRoles() async {
    final res = await _apiClient.get('/api/roles');
    final List list = res is List ? res : (res['data'] ?? []);
    return list.map((json) => RoleModel.fromJson(json)).toList();
  }

  Future<List<RolePermissionModel>> fetchAllPermissions() async {
    final res = await _apiClient.get('/api/roles/permissions');
    final Map<String, dynamic> data = res is Map<String, dynamic> && res.containsKey('all') ? res : (res['data'] ?? res);
    final List all = data['all'] ?? [];
    return all.map((json) => RolePermissionModel.fromJson(json)).toList();
  }

  Future<RoleModel> createRole(Map<String, dynamic> data) async {
    final res = await _apiClient.post('/api/roles', data: data);
    final json = res is Map<String, dynamic> && res.containsKey('data') ? res['data'] : res;
    return RoleModel.fromJson(json);
  }

  Future<void> updateRolePermissions(int roleId, List<RolePermissionModel> permissions) async {
    final body = {
      'permissions': permissions.map((p) => p.toJson()).toList(),
    };
    await _apiClient.put('/api/roles/$roleId/permissions', data: body);
  }
}
