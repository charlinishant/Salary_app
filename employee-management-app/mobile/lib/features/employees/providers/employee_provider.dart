import 'package:flutter/foundation.dart';
import '../../../shared/models/app_state.dart';
import '../models/employee_model.dart';
import '../services/employee_api_service.dart';

class EmployeeProvider extends ChangeNotifier {
  EmployeeProvider(this._service);
  final EmployeeApiService _service;

  AppState<Map<String, dynamic>> listState = const AppState();
  AppState<Map<String, dynamic>> detailState = const AppState();

  bool get isLoading => listState.status == LoadStatus.loading;

  List<EmployeeModel> get employees {
    final rawData = listState.data?['data'];
    if (rawData is List) {
      return rawData.map((e) => EmployeeModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<void> loadEmployees({
    String? search,
    int? departmentId,
    int? designationId,
    String? status,
    int page = 1,
  }) => loadList(
        search: search,
        departmentId: departmentId,
        designationId: designationId,
        status: status,
        page: page,
      );

  Future<void> loadList({
    String? search,
    int? departmentId,
    int? designationId,
    String? status,
    int page = 1,
  }) async {
    listState = const AppState(status: LoadStatus.loading);
    notifyListeners();
    try {
      final res = await _service.list(
        search: search,
        departmentId: departmentId,
        designationId: designationId,
        status: status,
        page: page,
      );
      listState = AppState(status: LoadStatus.success, data: res);
    } catch (error) {
      listState = AppState(status: LoadStatus.error, message: error.toString());
    }
    notifyListeners();
  }

  Future<void> loadDetail(int id) async {
    detailState = const AppState(status: LoadStatus.loading);
    notifyListeners();
    try {
      final data = await _service.getById(id);
      detailState = AppState(status: LoadStatus.success, data: data);
    } catch (error) {
      detailState = AppState(status: LoadStatus.error, message: error.toString());
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>> createEmployee(Map<String, dynamic> data, {String? photoPath}) async {
    final res = await _service.create(data, photoPath: photoPath);
    await loadList();
    return res;
  }

  Future<Map<String, dynamic>> updateEmployee(int id, Map<String, dynamic> data, {String? photoPath}) async {
    final res = await _service.update(id, data, photoPath: photoPath);
    await loadList();
    return res;
  }

  Future<Map<String, dynamic>> updateMyProfile({Map<String, dynamic>? data, String? photoPath}) async {
    final res = await _service.updateMe(data: data, photoPath: photoPath);
    await loadList();
    return res;
  }

  Future<void> toggleStatus(int id, bool isActive) async {
    await _service.toggleStatus(id, isActive);
    await loadList();
  }
}
