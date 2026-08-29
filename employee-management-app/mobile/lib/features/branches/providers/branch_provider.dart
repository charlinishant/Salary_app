import 'package:flutter/material.dart';
import '../models/branch_model.dart';
import '../services/branch_service.dart';

class BranchProvider with ChangeNotifier {
  final BranchService _service;

  List<BranchModel> _branches = [];
  bool _isLoading = false;
  String? _error;
  String _selectedFilter = 'All';
  String _searchQuery = '';

  List<BranchModel> get branches => _branches;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedFilter => _selectedFilter;

  BranchProvider(this._service);

  void setFilter(String filter) {
    _selectedFilter = filter;
    loadBranches();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    loadBranches();
  }

  Future<void> loadBranches() async {
    _isLoading = true;
    _error = null;
    notifyListeners();



    try {
      _branches = await _service.fetchBranches(
        search: _searchQuery,
        status: _selectedFilter,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createBranch(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _service.createBranch(data);
      await loadBranches();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateBranch(int id, Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _service.updateBranch(id, data);
      await loadBranches();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteBranch(int id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _service.deleteBranch(id);
      await loadBranches();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}

