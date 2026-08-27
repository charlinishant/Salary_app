import 'package:flutter/material.dart';
import '../models/company_model.dart';
import '../services/company_service.dart';

class CompanyProvider with ChangeNotifier {
  final CompanyService _service;

  CompanyModel? _company;
  bool _isLoading = false;
  String? _error;

  CompanyModel? get company => _company;
  bool get isLoading => _isLoading;
  String? get error => _error;

  CompanyProvider(this._service);

  Future<void> loadCompany() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _company = await _service.fetchCompany();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateCompany(Map<String, dynamic> data) async {
    if (_company == null) return false;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _company = await _service.updateCompany(_company!.id, data);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
