import '../../../core/network/api_client.dart';
import '../models/department_model.dart';

class DepartmentService {
  final ApiClient _apiClient;

  DepartmentService(this._apiClient);

  Future<List<DepartmentModel>> fetchDepartments({String? search, int? branchId, String? status}) async {
    final data = await _apiClient.get(
      '/api/departments',
      query: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (branchId != null) 'branchId': branchId,
        if (status != null && status != 'All') 'status': status,
      },
    );
    final List list = data is List ? data : (data['data'] ?? []);
    return list.map((json) => DepartmentModel.fromJson(json)).toList();
  }

  Future<DepartmentModel> createDepartment(Map<String, dynamic> data) async {
    final res = await _apiClient.post('/api/departments', data: data);
    final json = res is Map<String, dynamic> && res.containsKey('data') ? res['data'] : res;
    return DepartmentModel.fromJson(json);
  }

  Future<DepartmentModel> updateDepartment(int id, Map<String, dynamic> data) async {
    final res = await _apiClient.put('/api/departments/$id', data: data);
    final json = res is Map<String, dynamic> && res.containsKey('data') ? res['data'] : res;
    return DepartmentModel.fromJson(json);
  }

  Future<void> deleteDepartment(int id) async {
    await _apiClient.delete('/api/departments/$id');
  }
}
