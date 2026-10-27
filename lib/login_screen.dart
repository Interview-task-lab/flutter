import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'test_wrapper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final List<String> _cities = [
    'İstanbul',
    'Ankara',
    'İzmir',
    'Bursa',
    'Antalya',
    'Adana',
    'Trabzon',
    'Eskişehir',
    'Gaziantep',
    'Konya',
  ];

  String? _selectedCity;
  bool _isPremium = false;

  @override
  void initState() {
    super.initState();
    _selectedCity = _cities.first;
  }

  @override
  Widget build(BuildContext context) {
    return TestWrapper(
      dataTestId: "login-scaffold",
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Giriş Yap'),
        ),
        body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Hoş Geldiniz',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Lütfen şehir ve üyelik tipinizi seçiniz. Giriş yap butonuna ulaşmak için aşağı kaydırın.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                // 1. İl Seçimi Dropdown
                TestWrapper(
                  dataTestId: "city-dropdown",
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedCity,
                    decoration: const InputDecoration(
                      labelText: 'İl Seçiniz',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_city),
                    ),
                    items: _cities.map((String city) {
                      return DropdownMenuItem<String>(
                        value: city,
                        child: Text(city),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCity = newValue;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Premium Switch / Toggle
                TestWrapper(
                  dataTestId: "premium-toggle",
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: SwitchListTile(
                      title: const Text(
                        'Premium Üyelik',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(_isPremium ? 'Premium Mod Aktif' : 'Standart Mod Aktif'),
                      secondary: Icon(
                        _isPremium ? Icons.star : Icons.star_border,
                        color: _isPremium ? Colors.amber : Colors.grey,
                      ),
                      value: _isPremium,
                      onChanged: (bool value) {
                        setState(() {
                          _isPremium = value;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Scroll Mesafesini 2 Scroll Seviyesine Ulaştıran İçerik Blokları
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                              'Uygulama Özellikleri',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Uygulamamız hem Android hem de iOS cihazlarda akıcı kaydırma (scroll) performansı sunmaktadır. İstediğiniz ili seçerek bölgesel içeriklere erişebilir, Premium switch ile özel avantajlardan yararlanabilirsiniz.',
                          style: TextStyle(fontSize: 14, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.verified_user, color: Colors.green),
                            SizedBox(width: 8),
                            Text(
                              'Güvenli Giriş',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Giriş alanına erişmek için sayfada 2 defa aşağı kaydırınız (scroll yapınız). Kullanıcı adınız ve şifreniz ile güvenli oturum açabilirsiniz.',
                          style: TextStyle(fontSize: 14, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ),

                // Dikey Kaydırma Mesafesi (2 Scroll için Yükseklik)
                const SizedBox(height: 450),

                // 3. Giriş Formu ve Butonu (2 Scroll Sonrası Ulaşılan Bölüm)
                const Text(
                  'Oturum Açın',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const TestWrapper(
                  dataTestId: "username-input",
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Kullanıcı Adı',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const TestWrapper(
                  dataTestId: "password-input",
                  child: TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Şifre',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                TestWrapper(
                  dataTestId: "login-button",
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeScreen(
                            selectedCity: _selectedCity,
                            isPremium: _isPremium,
                          ),
                        ),
                      );
                    },
                    child: const Text('Giriş Yap', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
