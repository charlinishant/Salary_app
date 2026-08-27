import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages temporary development mode session state (role and selected employee).
///
/// TODO: Replace selectedEmployeeId with authenticated employee ID when JWT login is added.
class AppSession extends ChangeNotifier {
  AppSession._();
  static final AppSession instance = AppSession._();

  static const String _keyRole = 'dev_app_role';
  static const String _keyEmployeeId = 'dev_selected_employee_id';
  static const String _keyEmployeeName = 'dev_selected_employee_name';
  static const String _keyEmployeeCode = 'dev_selected_employee_code';

  String _role = 'ADMIN'; // 'ADMIN' or 'EMPLOYEE'
  int? _selectedEmployeeId = 1;
  String? _selectedEmployeeName;
  String? _selectedEmployeeCode;

  String get role => _role;
  bool get isAdmin => _role == 'ADMIN';
  bool get isEmployee => _role == 'EMPLOYEE';
  int? get selectedEmployeeId => _selectedEmployeeId;
  String? get selectedEmployeeName => _selectedEmployeeName;
  String? get selectedEmployeeCode => _selectedEmployeeCode;

  Map<String, String> get headers => {
        'x-role': _role,
        if (_selectedEmployeeId != null) 'x-employee-id': _selectedEmployeeId.toString(),
      };

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _role = prefs.getString(_keyRole) ?? 'ADMIN';
    _selectedEmployeeId = prefs.getInt(_keyEmployeeId) ?? 1;
    _selectedEmployeeName = prefs.getString(_keyEmployeeName);
    _selectedEmployeeCode = prefs.getString(_keyEmployeeCode);
    notifyListeners();
  }

  Future<void> setRole(String newRole) async {
    _role = newRole;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyRole, newRole);
    notifyListeners();
  }

  Future<void> setSelectedEmployee({
    required int id,
    required String name,
    required String code,
  }) async {
    _selectedEmployeeId = id;
    _selectedEmployeeName = name;
    _selectedEmployeeCode = code;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyEmployeeId, id);
    await prefs.setString(_keyEmployeeName, name);
    await prefs.setString(_keyEmployeeCode, code);
    notifyListeners();
  }

  Future<void> clearEmployee() async {
    _selectedEmployeeId = null;
    _selectedEmployeeName = null;
    _selectedEmployeeCode = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyEmployeeId);
    await prefs.remove(_keyEmployeeName);
    await prefs.remove(_keyEmployeeCode);
    notifyListeners();
  }
}
