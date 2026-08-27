import 'package:flutter/material.dart';
import '../models/role_model.dart';
import '../services/role_service.dart';

class RoleProvider with ChangeNotifier {
  final RoleService _service;

  List<RoleModel> _roles = [];
  List<RolePermissionModel> _allPermissions = [];
  bool _isLoading = false;
  String? _error;

  List<RoleModel> get roles => _roles;
  List<RolePermissionModel> get allPermissions => _allPermissions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  RoleProvider(this._service);

  Future<void> loadRoles() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _roles = await _service.fetchRoles();
      _allPermissions = await _service.fetchAllPermissions();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createRole(String name, String description) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _service.createRole({'name': name, 'description': description});
      await loadRoles();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePermissions(int roleId, List<RolePermissionModel> permissions) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _service.updateRolePermissions(roleId, permissions);
      await loadRoles();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
