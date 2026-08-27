import 'package:flutter/material.dart';
import '../models/shift_model.dart';
import '../services/shift_service.dart';

class ShiftProvider with ChangeNotifier {
  final ShiftService _service;

  List<ShiftModel> _shifts = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  List<ShiftModel> get shifts => _shifts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ShiftProvider(this._service);

  void setSearchQuery(String query) {
    _searchQuery = query;
    loadShifts();
  }

  Future<void> loadShifts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _shifts = await _service.fetchShifts(search: _searchQuery);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createShift(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _service.createShift(data);
      await loadShifts();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateShift(int id, Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _service.updateShift(id, data);
      await loadShifts();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> assignShift(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _service.assignShift(data);
      await loadShifts();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
