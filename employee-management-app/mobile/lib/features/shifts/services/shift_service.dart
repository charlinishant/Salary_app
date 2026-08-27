import '../../../core/network/api_client.dart';
import '../models/shift_model.dart';

class ShiftService {
  final ApiClient _apiClient;

  ShiftService(this._apiClient);

  Future<List<ShiftModel>> fetchShifts({String? search, String? status}) async {
    final data = await _apiClient.get(
      '/api/shifts',
      query: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (status != null && status != 'All') 'status': status,
      },
    );
    final List list = data is List ? data : (data['data'] ?? []);
    return list.map((json) => ShiftModel.fromJson(json)).toList();
  }

  Future<ShiftModel> createShift(Map<String, dynamic> data) async {
    final res = await _apiClient.post('/api/shifts', data: data);
    final json = res is Map<String, dynamic> && res.containsKey('data') ? res['data'] : res;
    return ShiftModel.fromJson(json);
  }

  Future<ShiftModel> updateShift(int id, Map<String, dynamic> data) async {
    final res = await _apiClient.put('/api/shifts/$id', data: data);
    final json = res is Map<String, dynamic> && res.containsKey('data') ? res['data'] : res;
    return ShiftModel.fromJson(json);
  }

  Future<void> assignShift(Map<String, dynamic> data) async {
    await _apiClient.post('/api/shifts/assign', data: data);
  }
}
