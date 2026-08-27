import 'package:permission_handler/permission_handler.dart';

class AppPermissions {
  static Future<bool> cameraAndLocation() async {
    final camera = await Permission.camera.request();
    final location = await Permission.locationWhenInUse.request();
    return camera.isGranted && location.isGranted;
  }
}
