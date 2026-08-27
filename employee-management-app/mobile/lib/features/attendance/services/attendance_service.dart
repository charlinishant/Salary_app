import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class AttendanceService {
  AttendanceService(this.api);
  final ApiClient api;

  Future<Map<String, dynamic>?> today() async {
    final res = await api.get('/attendance/today');
    if (res is Map<String, dynamic>) return res;
    return null;
  }

  Future<List<Map<String, dynamic>>> history({int? month, int? year, String? status}) async {
    final query = <String, dynamic>{
      if (month != null) 'month': month,
      if (year != null) 'year': year,
      if (status != null) 'status': status,
    };
    final data = await api.get('/attendance/my-history', query: query);
    if (data is List) return data.cast<Map<String, dynamic>>();
    if (data is Map && data['data'] is List) return (data['data'] as List).cast<Map<String, dynamic>>();
    return [];
  }

  Future<Map<String, dynamic>> punchIn(String filePath, {double? latitude, double? longitude}) async {
    final form = FormData.fromMap({
      'selfie': await MultipartFile.fromFile(filePath, filename: 'selfie.jpg'),
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    });
    final res = await api.multipart('/attendance/punch-in', form);
    return res is Map<String, dynamic> ? res : {'success': true};
  }

  Future<Map<String, dynamic>> punchOut(String filePath, {double? latitude, double? longitude}) async {
    final form = FormData.fromMap({
      'selfie': await MultipartFile.fromFile(filePath, filename: 'selfie.jpg'),
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    });
    final res = await api.multipart('/attendance/punch-out', form);
    return res is Map<String, dynamic> ? res : {'success': true};
  }

  // Admin APIs
  Future<Map<String, dynamic>> adminList({
    String? date,
    String? search,
    int? departmentId,
    String? status,
    int page = 1,
  }) async {
    final query = <String, dynamic>{
      if (date != null && date.isNotEmpty) 'date': date,
      if (search != null && search.isNotEmpty) 'search': search,
      if (departmentId != null) 'departmentId': departmentId,
      if (status != null && status.isNotEmpty) 'status': status,
      'page': page,
      'limit': 20,
    };
    final res = await api.get('/attendance/admin/list', query: query);
    return res is Map<String, dynamic> ? res : {'data': [], 'summary': {}};
  }

  Future<void> adminUpdateAttendance(
    int id, {
    required String status,
    required String changeReason,
    String? punchInTime,
    String? punchOutTime,
    String? remarks,
  }) async {
    await api.put('/attendance/admin/$id', data: {
      'attendanceStatus': status,
      'changeReason': changeReason,
      if (punchInTime != null) 'punchInTime': punchInTime,
      if (punchOutTime != null) 'punchOutTime': punchOutTime,
      if (remarks != null) 'remarks': remarks,
    });
  }
}
