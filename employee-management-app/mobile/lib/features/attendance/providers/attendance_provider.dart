import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import '../../../core/config/app_config.dart';
import '../../../core/config/demo_data.dart';
import '../../../shared/models/app_state.dart';
import '../services/attendance_service.dart';

class AttendanceModelData {
  AttendanceModelData({
    required this.canPunchIn,
    required this.canPunchOut,
    this.checkIn,
    this.checkOut,
    this.workingHoursFormatted,
    this.status,
  });

  final bool canPunchIn;
  final bool canPunchOut;
  final String? checkIn;
  final String? checkOut;
  final String? workingHoursFormatted;
  final String? status;
}

class AttendanceProvider extends ChangeNotifier {
  AttendanceProvider(this._service);
  final AttendanceService _service;

  AppState<Map<String, dynamic>> todayState = const AppState();
  AppState<List<Map<String, dynamic>>> historyState = const AppState();
  AppState<Map<String, dynamic>> adminAttendanceState = const AppState();

  AttendanceModelData? get todayAttendance {
    final data = todayState.data;
    if (data == null) return null;
    final att = data['attendance'] is Map ? data['attendance'] : data;

    final canIn = att['canPunchIn'] == true;
    final canOut = att['canPunchOut'] == true;
    final checkIn = att['checkIn']?.toString();
    final checkOut = att['checkOut']?.toString();
    final mins = att['workingMinutes'] is int ? att['workingMinutes'] as int : 0;
    final hours = math.max(0, mins ~/ 60);
    final remMins = math.max(0, mins % 60);
    final formattedHours = mins > 0 ? '${hours}h ${remMins}m' : null;

    return AttendanceModelData(
      canPunchIn: canIn,
      canPunchOut: canOut,
      checkIn: checkIn,
      checkOut: checkOut,
      workingHoursFormatted: formattedHours,
      status: att['status']?.toString(),
    );
  }

  bool get punchedIn {
    final att = todayState.data?['attendance'] ?? todayState.data;
    if (att == null) return false;
    final checkIn = att['checkIn'] ?? att['punchInTime'];
    final checkOut = att['checkOut'] ?? att['punchOutTime'];
    return checkIn != null && (checkOut == null || checkOut == '--');
  }

  bool get punchedOut {
    final att = todayState.data?['attendance'] ?? todayState.data;
    if (att == null) return false;
    final checkIn = att['checkIn'] ?? att['punchInTime'];
    final checkOut = att['checkOut'] ?? att['punchOutTime'];
    return checkIn != null && checkOut != null && checkOut != '--';
  }

  Future<void> loadTodayAttendance() => loadToday();

  Future<void> loadToday() async {
    todayState = const AppState(status: LoadStatus.loading);
    notifyListeners();
    if (AppConfig.demoMode) {
      todayState = AppState(status: LoadStatus.success, data: DemoData.attendanceToday);
      notifyListeners();
      return;
    }
    try {
      final res = await _service.today();
      todayState = AppState(status: res == null ? LoadStatus.empty : LoadStatus.success, data: res);
    } catch (error) {
      todayState = AppState(status: LoadStatus.error, message: error.toString());
    }
    notifyListeners();
  }

  Future<void> loadHistory({int? month, int? year, String? status}) async {
    historyState = const AppState(status: LoadStatus.loading);
    notifyListeners();
    if (AppConfig.demoMode) {
      historyState = AppState(status: LoadStatus.success, data: DemoData.attendanceHistory);
      notifyListeners();
      return;
    }
    try {
      final rows = await _service.history(month: month, year: year, status: status);
      historyState = AppState(status: rows.isEmpty ? LoadStatus.empty : LoadStatus.success, data: rows);
    } catch (error) {
      historyState = AppState(status: LoadStatus.error, message: error.toString());
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>> submitPunchIn(String selfiePath, {double? latitude, double? longitude}) async {
    try {
      final result = await _service.punchIn(selfiePath, latitude: latitude, longitude: longitude);
      await loadToday();
      return result;
    } catch (error) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> submitPunchOut(String selfiePath, {double? latitude, double? longitude}) async {
    try {
      final result = await _service.punchOut(selfiePath, latitude: latitude, longitude: longitude);
      await loadToday();
      return result;
    } catch (error) {
      rethrow;
    }
  }

  // Admin Attendance Management
  Future<void> loadAdminAttendance({
    String? date,
    String? search,
    int? departmentId,
    String? status,
    int page = 1,
  }) async {
    adminAttendanceState = const AppState(status: LoadStatus.loading);
    notifyListeners();
    try {
      final res = await _service.adminList(
        date: date,
        search: search,
        departmentId: departmentId,
        status: status,
        page: page,
      );
      adminAttendanceState = AppState(status: LoadStatus.success, data: res);
    } catch (error) {
      adminAttendanceState = AppState(status: LoadStatus.error, message: error.toString());
    }
    notifyListeners();
  }

  Future<void> adminCorrectAttendance(
    int id, {
    required String status,
    required String changeReason,
    String? punchInTime,
    String? punchOutTime,
    String? remarks,
  }) async {
    await _service.adminUpdateAttendance(
      id,
      status: status,
      changeReason: changeReason,
      punchInTime: punchInTime,
      punchOutTime: punchOutTime,
      remarks: remarks,
    );
  }
}
