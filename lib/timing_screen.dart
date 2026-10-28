import 'dart:async';
import 'package:flutter/material.dart';
import 'chaos.dart';
import 'test_wrapper.dart';

/// Zamanlamaya bağlı zorluklar:
/// - Asenkron yükleme: 2 sn skeleton, chaos açıkken ek gecikme ve hata + "Tekrar dene"
/// - Bitmeyen animasyon: `sync-indicator` hiç durmaz (pumpAndSettle zaman aşımına düşer)
/// - Kısa süreli öğeler: 2 sn'lik SnackBar, 3 sn'de kendiliğinden kapanan dialog
class TimingScreen extends StatefulWidget {
  const TimingScreen({super.key});

  @override
  State<TimingScreen> createState() => _TimingScreenState();
}

class _TimingScreenState extends State<TimingScreen> {
  List<String>? _orders;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _orders = null;
      _error = false;
    });
    await chaosDelay(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      if (chaosShouldFail()) {
        _error = true;
      } else {
        _orders = List.generate(5, (i) => 'Sipariş #${1001 + i}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TestWrapper(
      dataTestId: 'timing-scaffold',
      child: Scaffold(
        appBar: AppBar(title: const Text('Zamanlama')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const TestWrapper(
              dataTestId: 'sync-indicator',
              child: ListTile(
                leading: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3)),
                title: Text('Canlı senkronizasyon'),
                subtitle: Text('Bu animasyon hiç bitmez'),
              ),
            ),
            const Divider(),
            const Text('Siparişler', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _ordersSection(),
            const Divider(height: 32),
            TestWrapper(
              dataTestId: 'show-snackbar-button',
              child: ElevatedButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  duration: Duration(seconds: 2),
                  content: TestWrapper(dataTestId: 'transient-snackbar', child: Text('2 saniye sonra kaybolacağım')),
                )),
                child: const Text('SnackBar göster (2 sn)'),
              ),
            ),
            const SizedBox(height: 12),
            TestWrapper(
              dataTestId: 'show-auto-dialog-button',
              child: ElevatedButton(
                onPressed: () => showDialog<void>(context: context, builder: (_) => const _AutoCloseDialog()),
                child: const Text('Kendiliğinden kapanan dialog (3 sn)'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ordersSection() {
    if (_error) {
      return TestWrapper(
        dataTestId: 'orders-error',
        child: Card(
          color: Colors.red.shade50,
          child: ListTile(
            leading: const Icon(Icons.error, color: Colors.red),
            title: const Text('Siparişler yüklenemedi'),
            trailing: TestWrapper(
              dataTestId: 'retry-button',
              child: TextButton(onPressed: _load, child: const Text('Tekrar dene')),
            ),
          ),
        ),
      );
    }
    final orders = _orders;
    if (orders == null) {
      return TestWrapper(
        dataTestId: 'orders-skeleton',
        child: Column(
          children: List.generate(
            5,
            (_) => Container(
              height: 48,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      );
    }
    return TestWrapper(
      dataTestId: 'orders-list',
      child: Column(
        children: [
          for (final order in orders)
            TestWrapper(
              dataTestId: 'order-${order.substring(order.indexOf('#') + 1)}',
              child: Card(child: ListTile(leading: const Icon(Icons.receipt), title: Text(order))),
            ),
        ],
      ),
    );
  }
}

class _AutoCloseDialog extends StatefulWidget {
  const _AutoCloseDialog();

  @override
  State<_AutoCloseDialog> createState() => _AutoCloseDialogState();
}

class _AutoCloseDialogState extends State<_AutoCloseDialog> {
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 3), () => Navigator.pop(context));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const TestWrapper(
      dataTestId: 'auto-dialog',
      child: AlertDialog(
        title: Text('Bilgi'),
        content: Text('Bu pencere 3 saniye içinde kendiliğinden kapanacak.'),
      ),
    );
  }
}
