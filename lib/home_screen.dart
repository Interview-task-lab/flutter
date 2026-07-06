import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'test_wrapper.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

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
        body: const Center(
          child: TestWrapper(
            dataTestId: "welcome-text",
            child: Text(
              'Hoşgeldiniz!',
              style: TextStyle(fontSize: 24),
            ),
          ),
        ),
      ),
    );
  }
}
