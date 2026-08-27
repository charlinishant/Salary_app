import 'package:flutter/foundation.dart';
import '../../../core/config/app_config.dart';
import '../../../core/config/demo_data.dart';
import '../../../shared/models/app_state.dart';
import '../services/profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileProvider(this._service);
  final ProfileService _service;
  AppState<Map<String, dynamic>> state = const AppState();

  Future<void> load() async {
    state = const AppState(status: LoadStatus.loading);
    notifyListeners();
    if (AppConfig.demoMode) {
      state = AppState(status: LoadStatus.success, data: DemoData.profile);
      notifyListeners();
      return;
    }
    try {
      state = AppState(status: LoadStatus.success, data: await _service.load());
    } catch (error) {
      state = AppState(status: LoadStatus.error, message: error.toString());
    }
    notifyListeners();
  }
}
