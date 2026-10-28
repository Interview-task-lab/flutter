import 'package:flutter/material.dart';
import 'chaos.dart';
import 'date_pickers_screen.dart';
import 'drag_drop_screen.dart';
import 'locator_traps_screen.dart';
import 'login_screen.dart';
import 'otp_screen.dart';
import 'permissions_screen.dart';
import 'records_screen.dart';
import 'test_wrapper.dart';
import 'timing_screen.dart';

class HomeScreen extends StatelessWidget {
  final String? selectedCity;
  final bool isPremium;

  const HomeScreen({
    super.key,
    this.selectedCity,
    this.isPremium = false,
  });

  @override
  Widget build(BuildContext context) {
    return TestWrapper(
      dataTestId: "home-scaffold",
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ana Sayfa'),
          actions: [
            TestWrapper(
              dataTestId: "logout-button",
              child: IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
              ),
            )
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const Center(
              child: TestWrapper(
                dataTestId: "welcome-text",
                child: Text(
                  'Hoşgeldiniz!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              children: [
                if (selectedCity != null)
                  Chip(
                    avatar: const Icon(Icons.location_city),
                    label: Text('Seçilen İl: $selectedCity'),
                  ),
                Chip(
                  avatar: Icon(
                    isPremium ? Icons.star : Icons.person,
                    color: isPremium ? Colors.amber : Colors.grey,
                  ),
                  label: Text('Üyelik: ${isPremium ? "Premium" : "Standart"}'),
                  backgroundColor: isPremium ? Colors.amber.shade100 : Colors.grey.shade200,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Chaos modu: rastgele gecikme, hata ve sıralama
            TestWrapper(
              dataTestId: "chaos-toggle",
              child: ValueListenableBuilder<bool>(
                valueListenable: chaosMode,
                builder: (context, enabled, _) => SwitchListTile(
                  title: const Text('Chaos Modu', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(enabled
                      ? 'Açık: rastgele gecikme, hata ve sıralama'
                      : 'Kapalı: davranış deterministik'),
                  secondary: Icon(Icons.bolt, color: enabled ? Colors.red : Colors.grey),
                  value: enabled,
                  onChanged: (value) => chaosMode.value = value,
                ),
              ),
            ),
            const Divider(),

            _featureTile(context, 'nav-records', Icons.list, 'Kayıtlar',
                'Sağa kaydır: düzenle/sil, sola kaydır: sil, uzun bas: sırala, 200 kayıt', const RecordsScreen()),
            _featureTile(context, 'nav-record-actions', Icons.swipe_left, 'Kayıtlar 2',
                'Sola kaydır: Düzenle ve Sil butonları yan yana açılır', const RecordActionsScreen()),
            _featureTile(context, 'nav-drag-drop', Icons.open_with, 'Sürükle & Bırak',
                'Görevleri kutular arasında taşı', const DragDropScreen()),
            _featureTile(context, 'nav-date-pickers', Icons.calendar_month, 'Tarih Seçiciler',
                'Material takvim ve iOS (Cupertino) tekerlek', const DatePickersScreen()),
            _featureTile(context, 'nav-timing', Icons.timer, 'Zamanlama',
                'Asenkron yükleme, bitmeyen animasyon, kısa süreli öğeler', const TimingScreen()),
            _featureTile(context, 'nav-locator-traps', Icons.visibility_off, 'Locator Tuzakları',
                'Gizli öğeler, aynı metinler, testId olmayan öğeler', const LocatorTrapsScreen()),
            _featureTile(context, 'nav-otp', Icons.keyboard, 'Klavye & OTP',
                'Maskeli telefon, 6 haneli kod, klavyenin kapattığı buton', const OtpScreen()),
            _featureTile(context, 'nav-permissions', Icons.location_on, 'Native İzinler',
                'Konum ve bildirim izin pencereleri (Flutter dışı)', const PermissionsScreen()),
          ],
        ),
      ),
    );
  }

  Widget _featureTile(BuildContext context, String testId, IconData icon, String title,
      String subtitle, Widget screen) {
    return TestWrapper(
      dataTestId: testId,
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
      ),
    );
  }
}
