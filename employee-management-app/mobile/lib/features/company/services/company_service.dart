import '../../../core/network/api_client.dart';
import '../models/company_model.dart';

class CompanyService {
  final ApiClient _apiClient;

  CompanyService(this._apiClient);

  Future<CompanyModel> fetchCompany() async {
    final res = await _apiClient.get('/api/company');
    final json = res is Map<String, dynamic> && res.containsKey('data') ? res['data'] : res;
    return CompanyModel.fromJson(json);
  }

  Future<CompanyModel> updateCompany(int id, Map<String, dynamic> data) async {
    final res = await _apiClient.put('/api/company/$id', data: data);
    final json = res is Map<String, dynamic> && res.containsKey('data') ? res['data'] : res;
    return CompanyModel.fromJson(json);
  }
}
