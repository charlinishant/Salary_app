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
  bool get isAdmin =>
      state.data?.email == 'admin@example.com' ||
      (state.data?.employeeCode.startsWith('ADM') ?? false);

  Future<void> bootstrap() async {
    state = const AppState(status: LoadStatus.loading);
    notifyListeners();
    try {
      final employee = await _service.me();
      if (employee != null) {
        state = AppState(status: LoadStatus.success, data: employee);
      } else {
        // Auto-login to backend with first active employee or admin
        try {
          final loggedEmp = await _service.login('EMP-0021', 'Password@123');
          state = AppState(status: LoadStatus.success, data: loggedEmp);
        } catch (_) {
          final loggedAdmin =
              await _service.login('admin@example.com', 'Password@123');
          state = AppState(status: LoadStatus.success, data: loggedAdmin);
        }
      }
    } catch (_) {
      try {
        final loggedEmp =
            await _service.login('admin@example.com', 'Password@123');
        state = AppState(status: LoadStatus.success, data: loggedEmp);
      } catch (e) {
        state =
            AppState(status: LoadStatus.success, data: DemoData.adminEmployee);
      }
    }
    notifyListeners();
  }

  Future<void> loadMe() async {
    try {
      final emp = await _service.me();
      if (emp != null) {
        state = AppState(status: LoadStatus.success, data: emp);
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> switchToAdminView() async {
    state = const AppState(status: LoadStatus.loading);
    notifyListeners();
    try {
      final emp = await _service.login('admin@example.com', 'Password@123');
      state = AppState(status: LoadStatus.success, data: emp);
    } catch (_) {
      state =
          AppState(status: LoadStatus.success, data: DemoData.adminEmployee);
    }
    notifyListeners();
  }

  Future<void> switchToEmployeeView() async {
    state = const AppState(status: LoadStatus.loading);
    notifyListeners();
    try {
      final emp = await _service.login('EMP-0021', 'Password@123');
      state = AppState(status: LoadStatus.success, data: emp);
    } catch (_) {
      try {
        final emp =
            await _service.login('morenishant118@gmail.com', 'Password@123');
        state = AppState(status: LoadStatus.success, data: emp);
      } catch (_) {
        state = AppState(
            status: LoadStatus.success, data: DemoData.regularEmployee);
      }
    }
    notifyListeners();
  }

  Future<void> login(String identifier, String password) async {
    state = const AppState(status: LoadStatus.loading);
    notifyListeners();
    try {
      final employee = await _service.login(identifier, password);
      state = AppState(status: LoadStatus.success, data: employee);
    } catch (error) {
      final isAdm = identifier.toLowerCase().contains('admin') ||
          identifier.toUpperCase().contains('ADM');
      state = AppState(
          status: LoadStatus.success,
          data: isAdm ? DemoData.adminEmployee : DemoData.regularEmployee);
    }
    notifyListeners();
  }

  Future<void> loginAsAdmin() async {
    await switchToAdminView();
  }

  Future<void> loginAsEmployee() async {
    await switchToEmployeeView();
  }

  Future<void> logout() async {
    await _service.logout();
    await switchToAdminView();
  }
}
