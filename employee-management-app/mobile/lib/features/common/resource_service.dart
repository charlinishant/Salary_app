import '../../core/network/api_client.dart';

class ResourceService {
  ResourceService(this.api, this.endpoint);
  final ApiClient api;
  final String endpoint;

  Future<List<Map<String, dynamic>>> list({Map<String, dynamic>? query}) async {
    final data = await api.get(endpoint, query: query);
    if (data is List) return data.cast<Map<String, dynamic>>();
    if (data is Map && data['data'] is List) return (data['data'] as List).cast<Map<String, dynamic>>();
    return <Map<String, dynamic>>[];
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> body) async {
    final data = await api.post(endpoint, data: body);
    return Map<String, dynamic>.from(data as Map);
  }
}
