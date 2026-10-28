import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'test_wrapper.dart';

/// Konum ve bildirim izni pencereleri işletim sistemine aittir, Flutter ağacında yoktur.
/// Bildirim penceresi Android'de sadece 13+ (API 33) sürümlerde çıkar.
/// Test aracı native otomasyona (XCUITest / UiAutomator) geçmek zorundadır.
class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  String _status = 'Bilinmiyor';
  String _position = '-';
  String _notificationStatus = 'Bilinmiyor';

  Future<void> _requestNotification() async {
    final status = await Permission.notification.request();
    if (mounted) setState(() => _notificationStatus = status.name);
  }

  Future<void> _request() async {
    final permission = await Geolocator.requestPermission();
    if (mounted) setState(() => _status = permission.name);
  }

  Future<void> _getPosition() async {
    try {
      final p = await Geolocator.getCurrentPosition();
      if (mounted) setState(() => _position = '${p.latitude.toStringAsFixed(4)}, ${p.longitude.toStringAsFixed(4)}');
    } catch (e) {
      if (mounted) setState(() => _position = 'Hata: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return TestWrapper(
      dataTestId: 'permissions-scaffold',
      child: Scaffold(
        appBar: AppBar(title: const Text('Native İzinler')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TestWrapper(
              dataTestId: 'request-location-button',
              child: ElevatedButton.icon(
                onPressed: _request,
                icon: const Icon(Icons.location_on),
                label: const Text('Konum izni iste'),
              ),
            ),
            const SizedBox(height: 8),
            TestWrapper(
              dataTestId: 'location-permission-status',
              child: Text('İzin durumu: $_status'),
            ),
            const SizedBox(height: 24),
            TestWrapper(
              dataTestId: 'get-location-button',
              child: OutlinedButton.icon(
                onPressed: _getPosition,
                icon: const Icon(Icons.my_location),
                label: const Text('Konumu al'),
              ),
            ),
            const SizedBox(height: 8),
            TestWrapper(
              dataTestId: 'location-value',
              child: Text('Konum: $_position'),
            ),
            const Divider(height: 48),
            TestWrapper(
              dataTestId: 'request-notification-button',
              child: ElevatedButton.icon(
                onPressed: _requestNotification,
                icon: const Icon(Icons.notifications),
                label: const Text('Bildirim izni iste'),
              ),
            ),
            const SizedBox(height: 8),
            TestWrapper(
              dataTestId: 'notification-permission-status',
              child: Text('Bildirim izni: $_notificationStatus'),
            ),
          ],
        ),
      ),
    );
  }
}
