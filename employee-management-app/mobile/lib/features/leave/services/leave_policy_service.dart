import '../../../core/network/api_client.dart';
import '../models/leave_policy_model.dart';

class LeavePolicyService {
  final ApiClient _apiClient;

  LeavePolicyService(this._apiClient);

  Future<List<LeaveTypeModel>> fetchLeaveTypes() async {
    final res = await _apiClient.get('/api/leaves/types');
    final List list = res is List ? res : (res['data'] ?? []);
    return list.map((json) => LeaveTypeModel.fromJson(json)).toList();
  }

  Future<LeaveTypeModel> createLeaveType(Map<String, dynamic> data) async {
    final res = await _apiClient.post('/api/leaves/types', data: data);
    final json = res is Map<String, dynamic> && res.containsKey('data') ? res['data'] : res;
    return LeaveTypeModel.fromJson(json);
  }

  Future<List<LeavePolicyModel>> fetchLeavePolicies() async {
    final res = await _apiClient.get('/api/leaves/policies');
    final List list = res is List ? res : (res['data'] ?? []);
    return list.map((json) => LeavePolicyModel.fromJson(json)).toList();
  }

  Future<LeavePolicyModel> createLeavePolicy(Map<String, dynamic> data) async {
    final res = await _apiClient.post('/api/leaves/policies', data: data);
    final json = res is Map<String, dynamic> && res.containsKey('data') ? res['data'] : res;
    return LeavePolicyModel.fromJson(json);
  }
}
