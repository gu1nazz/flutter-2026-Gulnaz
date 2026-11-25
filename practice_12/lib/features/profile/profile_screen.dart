import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../settings/settings_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _picker = ImagePicker();
  bool _busy = false;

  /// Gallery: no runtime permission needed (the system picker).
  Future<void> _choosePhoto() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (picked == null) return; // Cancel → null, nothing to do
    if (!mounted) return;
    await _keep(picked);
  }

  /// Camera: ask at the moment of the tap — never in initState.
  Future<void> _takePhoto() async {
    final status = await Permission.camera.request();
    if (!mounted) return;

    switch (status) {
      case PermissionStatus.granted:
      case PermissionStatus.limited:
      case PermissionStatus.provisional:
        final picked = await _picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1024,
          imageQuality: 85,
        );
        if (picked == null || !mounted) return;
        await _keep(picked);
      case PermissionStatus.denied:
        _snack(
          'Camera access is needed to take a photo. '
          'You can still choose one from the gallery.',
        );
      case PermissionStatus.permanentlyDenied:
        await _showOpenSettingsDialog();
      case PermissionStatus.restricted:
        _snack('The camera is restricted on this device.');
    }
  }

  /// Copy into Documents as avatar.jpg and remember the path in prefs,
  /// so the photo survives a restart.
  Future<void> _keep(XFile picked) async {
    final settings = context.read<SettingsModel>();
    setState(() => _busy = true);
    try {
      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/avatar.jpg';
      await File(picked.path).copy(path);
      // Same path as the old photo → drop the cached image, or the old
      // one stays on screen.
      await FileImage(File(path)).evict();
      await settings.setAvatarPath(path);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Our own dialog for the "never ask again" state.
  Future<void> _showOpenSettingsDialog() async {
    final open = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.no_photography),
        title: const Text('Camera access is off'),
        content: const Text(
          'You said No to the camera, so the system will not ask again. '
          'To take a photo, turn the camera on in Settings → Permissions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Open settings'),
          ),
        ],
      ),
    );
    if (open ?? false) await openAppSettings();
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final path = context.watch<SettingsModel>().avatarPath;
    final file = path == null ? null : File(path);
    final photo = (file != null && file.existsSync()) ? FileImage(file) : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: CircleAvatar(
              radius: 64,
              backgroundImage: photo,
              child: photo == null ? const Icon(Icons.person, size: 64) : null,
            ),
          ),
          const SizedBox(height: 24),
          if (_busy) const LinearProgressIndicator(),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _busy ? null : _choosePhoto,
            icon: const Icon(Icons.photo_library),
            label: const Text('Choose photo'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _busy ? null : _takePhoto,
            icon: const Icon(Icons.photo_camera),
            label: const Text('Take photo'),
          ),
          const SizedBox(height: 24),
          const Text(
            'The app works without a photo — saying No only turns this '
            'one feature off.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
