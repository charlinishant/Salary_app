import '../../../core/network/api_client.dart';

class ProfileService {
  ProfileService(this.api);
  final ApiClient api;
  Future<Map<String, dynamic>> load() async => Map<String, dynamic>.from(await api.get('/employees/me') as Map);
  Future<Map<String, dynamic>> update(Map<String, dynamic> body) async => Map<String, dynamic>.from(await api.put('/employees/me', data: body) as Map);
}
