import '../../../core/network/api_client.dart';

class DashboardService {
  DashboardService(this.api);
  final ApiClient api;
  Future<Map<String, dynamic>> load() async => Map<String, dynamic>.from(await api.get('/dashboard') as Map);
}
