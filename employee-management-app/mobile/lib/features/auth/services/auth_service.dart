import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../models/employee_model.dart';

class AuthService {
  AuthService(this.api, this.storage);
  final ApiClient api;
  final SecureStorage storage;

  Future<EmployeeModel> login(String identifier, String password) async {
    final data = await api.post('/auth/login', data: {'identifier': identifier, 'password': password});
    await storage.saveToken(data['token'].toString());
    return EmployeeModel.fromJson(Map<String, dynamic>.from(data['employee'] as Map));
  }

  Future<EmployeeModel?> me() async {
    final token = await storage.readToken();
    if (token == null) return null;
    final data = await api.get('/auth/me');
    return EmployeeModel.fromJson(Map<String, dynamic>.from(data['employee'] as Map));
  }

  Future<void> logout() => storage.clear();
}
