import '../../../core/network/api_client.dart';
import '../models/branch_model.dart';

class BranchService {
  final ApiClient _apiClient;

  BranchService(this._apiClient);

  Future<List<BranchModel>> fetchBranches({String? search, String? status}) async {
    final data = await _apiClient.get(
      '/api/branches',
      query: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (status != null && status != 'All') 'status': status,
      },
    );
    final List list = data is List ? data : (data['data'] ?? []);
    return list.map((json) => BranchModel.fromJson(json)).toList();
  }

  Future<BranchModel> createBranch(Map<String, dynamic> data) async {
    final res = await _apiClient.post('/api/branches', data: data);
    final json = res is Map<String, dynamic> && res.containsKey('data') ? res['data'] : res;
    return BranchModel.fromJson(json);
  }

  Future<BranchModel> updateBranch(int id, Map<String, dynamic> data) async {
    final res = await _apiClient.put('/api/branches/$id', data: data);
    final json = res is Map<String, dynamic> && res.containsKey('data') ? res['data'] : res;
    return BranchModel.fromJson(json);
  }

  Future<void> deleteBranch(int id) async {
    await _apiClient.delete('/api/branches/$id');
  }
}
