import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/utils/permissions.dart';
import '../../../shared/widgets/app_button.dart';

class SelfiePunchScreen extends StatefulWidget {
  const SelfiePunchScreen({super.key, required this.action});
  final String action;

  @override
  State<SelfiePunchScreen> createState() => _SelfiePunchScreenState();
}

class _SelfiePunchScreenState extends State<SelfiePunchScreen> {
  XFile? _selfie;
  Position? _position;

  Future<void> _capture() async {
    final allowed = await AppPermissions.cameraAndLocation();
    if (!allowed) return;
    final image = await ImagePicker().pickImage(source: ImageSource.camera, preferredCameraDevice: CameraDevice.front);
    final position = await Geolocator.getCurrentPosition();
    setState(() { _selfie = image; _position = position; });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(widget.action == 'punch-in' ? 'Punch In' : 'Punch Out')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            AppButton(label: 'Take Selfie', icon: Icons.photo_camera, onPressed: _capture),
            const SizedBox(height: 12),
            Text(_selfie == null ? 'Selfie not captured' : 'Selfie ready: ${_selfie!.name}'),
            Text(_position == null ? 'Location pending' : 'GPS: ${_position!.latitude}, ${_position!.longitude}'),
            const Spacer(),
            AppButton(label: 'Submit', icon: Icons.cloud_upload, onPressed: _selfie == null ? null : () => Navigator.pop(context)),
          ]),
        ),
      );
}
