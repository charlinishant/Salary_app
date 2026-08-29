import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../models/employee_model.dart';

class AuthService {
  AuthService(this.api, this.storage);
  final ApiClient api;
  final SecureStorage storage;

  Future<EmployeeModel> login(String identifier, String password) async {
    final data = await api.post('/auth/login',
        data: {'identifier': identifier, 'password': password});
    if (data is Map && data['token'] != null) {
      await storage.saveToken(data['token'].toString());
    }
    final empMap = (data is Map && data['employee'] != null)
        ? data['employee']
        : (data is Map && data['data'] != null ? data['data'] : data);
    return EmployeeModel.fromJson(Map<String, dynamic>.from(empMap as Map));
  }

  Future<EmployeeModel?> me() async {
    final token = await storage.readToken();
    if (token == null || token.isEmpty) return null;
    final data = await api.get('/auth/me');
    final empMap = (data is Map && data['employee'] != null)
        ? data['employee']
        : (data is Map && data['data'] != null
            ? (data['data'] is Map && data['data']['employee'] != null
                ? data['data']['employee']
                : data['data'])
            : data);
    if (empMap is Map) {
      return EmployeeModel.fromJson(Map<String, dynamic>.from(empMap));
    }
    return null;
  }

  Future<void> logout() => storage.clear();
}
