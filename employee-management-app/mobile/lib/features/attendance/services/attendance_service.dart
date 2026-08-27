import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class AttendanceService {
  AttendanceService(this.api);
  final ApiClient api;

  Future<Map<String, dynamic>?> today() async {
    final data = await api.get('/attendance/today');
    return data == null ? null : Map<String, dynamic>.from(data as Map);
  }

  Future<List<Map<String, dynamic>>> history() async {
    final data = await api.get('/attendance/history');
    return data is List ? data.cast<Map<String, dynamic>>() : [];
  }

  Future<void> punch(String action, {MultipartFile? selfie, double? latitude, double? longitude}) async {
    final form = FormData.fromMap({
      if (selfie != null) 'selfie': selfie,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    });
    await api.multipart('/attendance/$action', form);
  }
}
