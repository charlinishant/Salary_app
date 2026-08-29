import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class EmployeeApiService {
  EmployeeApiService(this.api);
  final ApiClient api;

  Future<Map<String, dynamic>> list({
    String? search,
    int? departmentId,
    int? designationId,
    String? status,
    int page = 1,
  }) async {
    final query = <String, dynamic>{
      if (search != null && search.isNotEmpty) 'search': search,
      if (departmentId != null) 'departmentId': departmentId,
      if (designationId != null) 'designationId': designationId,
      if (status != null && status.isNotEmpty) 'status': status,
      'page': page,
      'limit': 20,
    };
    final res = await api.get('/employees', query: query);
    return res is Map<String, dynamic> ? res : {'data': [], 'pagination': {}};
  }

  Future<Map<String, dynamic>> getById(int id) async {
    final res = await api.get('/employees/$id');
    return res is Map<String, dynamic> ? res : {};
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> data, {String? photoPath}) async {
    final formMap = Map<String, dynamic>.from(data);
    if (photoPath != null && photoPath.isNotEmpty) {
      formMap['profilePhoto'] = await MultipartFile.fromFile(photoPath, filename: 'profile.jpg');
    }
    final form = FormData.fromMap(formMap);
    final res = await api.multipart('/employees', form);
    return res is Map<String, dynamic> ? res : {'success': true};
  }

  Future<Map<String, dynamic>> update(int id, Map<String, dynamic> data, {String? photoPath}) async {
    final formMap = Map<String, dynamic>.from(data);
    if (photoPath != null && photoPath.isNotEmpty) {
      formMap['profilePhoto'] = await MultipartFile.fromFile(photoPath, filename: 'profile.jpg');
    }
    final form = FormData.fromMap(formMap);
    final res = await api.multipart('/employees/$id', form);
    return res is Map<String, dynamic> ? res : {'success': true};
  }

  Future<Map<String, dynamic>> updateMe({Map<String, dynamic>? data, String? photoPath}) async {
    final formMap = data != null ? Map<String, dynamic>.from(data) : <String, dynamic>{};
    if (photoPath != null && photoPath.isNotEmpty) {
      formMap['profilePhoto'] = await MultipartFile.fromFile(photoPath, filename: 'profile.jpg');
    }
    final form = FormData.fromMap(formMap);
    final res = await api.multipart('/employees/me', form);
    return res is Map<String, dynamic> ? res : {'success': true};
  }

  Future<void> toggleStatus(int id, bool isActive) async {
    await api.post('/employees/$id/status', data: {'isActive': isActive});
  }
}
