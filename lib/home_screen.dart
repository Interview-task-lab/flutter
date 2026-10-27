import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'test_wrapper.dart';

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
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const TestWrapper(
                  dataTestId: "welcome-text",
                  child: Text(
                    'Hoşgeldiniz!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                if (selectedCity != null) ...[
                  Chip(
                    avatar: const Icon(Icons.location_city),
                    label: Text('Seçilen İl: $selectedCity'),
                  ),
                  const SizedBox(height: 8),
                ],
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
          ),
        ),
      ),
    );
  }
}
