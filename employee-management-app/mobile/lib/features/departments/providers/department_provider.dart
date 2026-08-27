import 'package:flutter/material.dart';
import '../models/department_model.dart';
import '../services/department_service.dart';

class DepartmentProvider with ChangeNotifier {
  final DepartmentService _service;

  List<DepartmentModel> _departments = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  List<DepartmentModel> get departments => _departments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  DepartmentProvider(this._service);

  void setSearchQuery(String query) {
    _searchQuery = query;
    loadDepartments();
  }

  Future<void> loadDepartments() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _departments = await _service.fetchDepartments(search: _searchQuery);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createDepartment(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _service.createDepartment(data);
      await loadDepartments();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateDepartment(int id, Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _service.updateDepartment(id, data);
      await loadDepartments();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteDepartment(int id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _service.deleteDepartment(id);
      await loadDepartments();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
