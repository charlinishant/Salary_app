import 'package:flutter/foundation.dart';
import '../../../core/config/app_config.dart';
import '../../../core/config/demo_data.dart';
import '../../../shared/models/app_state.dart';
import '../models/employee_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._service);
  final AuthService _service;
  AppState<EmployeeModel> state = const AppState();

  bool get isAuthenticated => state.data != null;

  Future<void> bootstrap() async {
    state = const AppState(status: LoadStatus.loading);
    notifyListeners();
    if (AppConfig.demoMode) {
      state = AppState(status: LoadStatus.success, data: DemoData.employee);
      notifyListeners();
      return;
    }
    try {
      final employee = await _service.me();
      state = AppState(status: employee == null ? LoadStatus.empty : LoadStatus.success, data: employee);
    } catch (_) {
      state = const AppState(status: LoadStatus.empty);
    }
    notifyListeners();
  }

  Future<void> login(String identifier, String password) async {
    state = const AppState(status: LoadStatus.loading);
    notifyListeners();
    if (AppConfig.demoMode) {
      state = AppState(status: LoadStatus.success, data: DemoData.employee);
      notifyListeners();
      return;
    }
    try {
      final employee = await _service.login(identifier, password);
      state = AppState(status: LoadStatus.success, data: employee);
    } catch (error) {
      state = AppState(status: LoadStatus.error, message: error.toString());
    }
    notifyListeners();
  }

  Future<void> logout() async {
    await _service.logout();
    state = const AppState(status: LoadStatus.empty);
    notifyListeners();
  }
}
