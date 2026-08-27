import 'package:flutter/foundation.dart';
import '../../core/config/app_config.dart';
import '../../core/config/demo_data.dart';
import '../../shared/models/app_state.dart';
import 'resource_service.dart';

class ResourceProvider extends ChangeNotifier {
  ResourceProvider(this.service);
  final ResourceService service;
  AppState<List<Map<String, dynamic>>> state = const AppState();

  Future<void> load() async {
    state = const AppState(status: LoadStatus.loading);
    notifyListeners();
    if (AppConfig.demoMode) {
      final rows = DemoData.rowsForEndpoint(service.endpoint);
      state = AppState(status: rows.isEmpty ? LoadStatus.empty : LoadStatus.success, data: rows);
      notifyListeners();
      return;
    }
    try {
      final rows = await service.list();
      state = AppState(status: rows.isEmpty ? LoadStatus.empty : LoadStatus.success, data: rows);
    } catch (error) {
      state = AppState(status: LoadStatus.error, message: error.toString());
    }
    notifyListeners();
  }
}
