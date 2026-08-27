import 'package:flutter/foundation.dart';
import '../../../core/config/app_config.dart';
import '../../../core/config/demo_data.dart';
import '../../../shared/models/app_state.dart';
import '../services/attendance_service.dart';

class AttendanceProvider extends ChangeNotifier {
  AttendanceProvider(this._service);
  final AttendanceService _service;
  AppState<Map<String, dynamic>> todayState = const AppState();
  AppState<List<Map<String, dynamic>>> historyState = const AppState();

  bool get punchedIn => todayState.data?['punchInTime'] != null && todayState.data?['punchOutTime'] == null;

  Future<void> loadToday() async {
    todayState = const AppState(status: LoadStatus.loading);
    notifyListeners();
    if (AppConfig.demoMode) {
      todayState = AppState(status: LoadStatus.success, data: DemoData.attendanceToday);
      notifyListeners();
      return;
    }
    try {
      final row = await _service.today();
      todayState = AppState(status: row == null ? LoadStatus.empty : LoadStatus.success, data: row);
    } catch (error) {
      todayState = AppState(status: LoadStatus.error, message: error.toString());
    }
    notifyListeners();
  }

  Future<void> loadHistory() async {
    historyState = const AppState(status: LoadStatus.loading);
    notifyListeners();
    if (AppConfig.demoMode) {
      historyState = AppState(status: LoadStatus.success, data: DemoData.attendanceHistory);
      notifyListeners();
      return;
    }
    try {
      final rows = await _service.history();
      historyState = AppState(status: rows.isEmpty ? LoadStatus.empty : LoadStatus.success, data: rows);
    } catch (error) {
      historyState = AppState(status: LoadStatus.error, message: error.toString());
    }
    notifyListeners();
  }
}
