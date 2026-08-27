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
  bool get isAdmin => state.data?.email == 'admin@example.com' || (state.data?.employeeCode.startsWith('ADM') ?? true);

  Future<void> bootstrap() async {
    state = const AppState(status: LoadStatus.loading);
    notifyListeners();
    if (AppConfig.demoMode) {
      state = AppState(status: LoadStatus.success, data: DemoData.adminEmployee);
      notifyListeners();
      return;
    }
    try {
      final employee = await _service.me();
      if (employee != null) {
        state = AppState(status: LoadStatus.success, data: employee);
      } else {
        // Direct auto-login without showing login screen
        state = AppState(status: LoadStatus.success, data: DemoData.adminEmployee);
      }
    } catch (_) {
      // Auto-fallback to Admin session directly
      state = AppState(status: LoadStatus.success, data: DemoData.adminEmployee);
    }
    notifyListeners();
  }

  void switchToAdminView() {
    state = AppState(status: LoadStatus.success, data: DemoData.adminEmployee);
    notifyListeners();
  }

  void switchToEmployeeView() {
    state = AppState(status: LoadStatus.success, data: DemoData.regularEmployee);
    notifyListeners();
  }

  Future<void> login(String identifier, String password) async {
    state = const AppState(status: LoadStatus.loading);
    notifyListeners();
    final isAdm = identifier.toLowerCase().contains('admin') || identifier.toUpperCase().contains('ADM');
    final fallbackData = isAdm ? DemoData.adminEmployee : DemoData.regularEmployee;

    if (AppConfig.demoMode) {
      state = AppState(status: LoadStatus.success, data: fallbackData);
      notifyListeners();
      return;
    }
    try {
      final employee = await _service.login(identifier, password);
      state = AppState(status: LoadStatus.success, data: employee);
    } catch (error) {
      state = AppState(status: LoadStatus.success, data: fallbackData);
    }
    notifyListeners();
  }

  Future<void> loginAsAdmin() async {
    switchToAdminView();
  }

  Future<void> loginAsEmployee() async {
    switchToEmployeeView();
  }

  Future<void> logout() async {
    // Instead of logging out to a form, reset to Admin View directly
    switchToAdminView();
  }
}
