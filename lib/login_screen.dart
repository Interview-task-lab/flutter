import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'test_wrapper.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TestWrapper(
      dataTestId: "login-scaffold",
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Giriş Yap'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const TestWrapper(
                dataTestId: "username-input",
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Kullanıcı Adı',
                    border: OutlineInputBorder(),
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
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TestWrapper(
                dataTestId: "login-button",
                child: ElevatedButton(
                  onPressed: () {
                    // Db bağlantısı olmadan direkt ana sayfaya geçiş
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                    );
                  },
                  child: const Text('Giriş'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
