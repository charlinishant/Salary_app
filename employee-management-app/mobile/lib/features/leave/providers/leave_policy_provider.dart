import 'package:flutter/material.dart';
import '../models/leave_policy_model.dart';
import '../services/leave_policy_service.dart';

class LeavePolicyProvider with ChangeNotifier {
  final LeavePolicyService _service;

  List<LeaveTypeModel> _leaveTypes = [];
  List<LeavePolicyModel> _leavePolicies = [];
  bool _isLoading = false;
  String? _error;

  List<LeaveTypeModel> get leaveTypes => _leaveTypes;
  List<LeavePolicyModel> get leavePolicies => _leavePolicies;
  bool get isLoading => _isLoading;
  String? get error => _error;

  LeavePolicyProvider(this._service);

  Future<void> loadData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _leaveTypes = await _service.fetchLeaveTypes();
      _leavePolicies = await _service.fetchLeavePolicies();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createLeaveType(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _service.createLeaveType(data);
      await loadData();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> createLeavePolicy(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _service.createLeavePolicy(data);
      await loadData();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
