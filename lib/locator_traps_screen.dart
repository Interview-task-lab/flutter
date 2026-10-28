import 'package:flutter/material.dart';
import 'test_wrapper.dart';

/// Locator tuzakları:
/// - Ağaçta olup görünmeyen öğeler: Offstage, Opacity(0), Visibility, IndexedStack
/// - Üstü başka bir katmanla kapatılmış buton
/// - Aynı metne sahip butonlar, bir kısmında testId yok
/// - Her açılışta değişen (dinamik) testId
/// Her dokunuş `trap-result` metnine yazılır, doğru öğeye basıldı mı doğrulanabilir.
class LocatorTrapsScreen extends StatefulWidget {
  const LocatorTrapsScreen({super.key});

  @override
  State<LocatorTrapsScreen> createState() => _LocatorTrapsScreenState();
}

class _LocatorTrapsScreenState extends State<LocatorTrapsScreen> {
  // Her açılışta farklı id: sabit locator ile bulunamaz
  final _dynamicId = 'promo-banner-${DateTime.now().millisecondsSinceEpoch % 100000}';
  String _result = 'Henüz dokunulmadı';
  bool _reveal = false;
  bool _overlay = true;
  int _tab = 0;

  void _tap(String what) => setState(() => _result = what);

  @override
  Widget build(BuildContext context) {
    return TestWrapper(
      dataTestId: 'locator-traps-scaffold',
      child: Scaffold(
        appBar: AppBar(title: const Text('Locator Tuzakları')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TestWrapper(
              dataTestId: 'trap-result',
              child: Text('Son dokunulan: $_result', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            TestWrapper(
              dataTestId: _dynamicId,
              child: Card(
                color: Colors.purple.shade50,
                child: ListTile(
                  leading: const Icon(Icons.campaign),
                  title: const Text('Kampanya'),
                  subtitle: Text('Dinamik id: $_dynamicId'),
                  onTap: () => _tap('Kampanya'),
                ),
              ),
            ),
            _header('Gizli öğeler'),
            TestWrapper(
              dataTestId: 'reveal-hidden-toggle',
              child: SwitchListTile(
                title: const Text('Gizli öğeleri göster'),
                value: _reveal,
                onChanged: (v) => setState(() => _reveal = v),
              ),
            ),
            Offstage(
              offstage: !_reveal,
              child: _button('offstage-button', 'Offstage buton'),
            ),
            // Opacity 0 iken görünmez ama yerini kaplar ve dokunulabilir
            Opacity(
              opacity: _reveal ? 1 : 0,
              child: _button('invisible-button', 'Opacity 0 buton'),
            ),
            Visibility(
              visible: _reveal,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: _button('visibility-button', 'Visibility buton'),
            ),
            _header('Üstü kapalı buton'),
            Stack(
              children: [
                _button('covered-button', 'Kapalı buton'),
                if (_overlay)
                  Positioned.fill(
                    child: TestWrapper(
                      dataTestId: 'covering-overlay',
                      child: GestureDetector(
                        onTap: () => _tap('Kaplama katmanı'),
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.4),
                          alignment: Alignment.center,
                          child: const Text('Bakımda', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            TestWrapper(
              dataTestId: 'remove-overlay-button',
              child: TextButton(
                onPressed: () => setState(() => _overlay = !_overlay),
                child: Text(_overlay ? 'Katmanı kaldır' : 'Katmanı geri koy'),
              ),
            ),
            _header('Aynı metinli butonlar'),
            for (final product in ['A', 'B', 'C'])
              Card(
                child: ListTile(
                  title: Text('Ürün $product'),
                  // Sadece A'nın testId'si var; B ve C metin/sıra ile bulunmalı
                  trailing: product == 'A'
                      ? TestWrapper(dataTestId: 'product-a-edit', child: _editButton(product))
                      : _editButton(product),
                ),
              ),
            _header('Sekmeler (IndexedStack)'),
            TestWrapper(
              dataTestId: 'trap-tabs',
              child: SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 0, label: Text('Profil')),
                  ButtonSegment(value: 1, label: Text('Adres')),
                  ButtonSegment(value: 2, label: Text('Kart')),
                ],
                selected: {_tab},
                onSelectionChanged: (s) => setState(() => _tab = s.first),
              ),
            ),
            const SizedBox(height: 8),
            // Üç sayfa da ağaçta, hepsinde "Kaydet" var; sadece seçili olan görünür
            IndexedStack(
              index: _tab,
              children: [
                for (final page in ['Profil', 'Adres', 'Kart'])
                  _button('tab-${page.toLowerCase()}-save', 'Kaydet', result: '$page kaydet'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(String text) => Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 8),
        child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      );

  Widget _button(String id, String label, {String? result}) => TestWrapper(
        dataTestId: id,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: ElevatedButton(onPressed: () => _tap(result ?? label), child: Text(label)),
        ),
      );

  Widget _editButton(String product) =>
      TextButton(onPressed: () => _tap('Ürün $product düzenle'), child: const Text('Düzenle'));
}
