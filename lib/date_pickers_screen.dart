import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'test_wrapper.dart';

/// Material takvim seçicileri (dialog, gün ızgarası, ay gezinme) ve iOS tarzı
/// Cupertino tekerlek seçicileri (kaydırarak değer seçme).
/// Not: Cupertino tekerlekleri Flutter tarafından çizilir, native UIDatePicker
/// değildir; XCUITest'in pickerWheel komutları çalışmaz, kaydırma gerekir.
class DatePickersScreen extends StatefulWidget {
  const DatePickersScreen({super.key});

  @override
  State<DatePickersScreen> createState() => _DatePickersScreenState();
}

class _DatePickersScreenState extends State<DatePickersScreen> {
  final _now = DateTime.now();
  final Map<String, String> _values = {};
  final Map<String, DateTime> _cupertinoValues = {};

  String _date(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  String _time(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  void _set(String id, String? value) {
    if (value != null) setState(() => _values[id] = value);
  }

  Future<void> _materialDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(_now.year - 1),
      lastDate: DateTime(_now.year + 1, 12, 31),
      // Hafta sonları seçilemez: devre dışı günler de bir test vakası
      selectableDayPredicate: (d) => d.weekday < DateTime.saturday,
      initialDate: _nextWeekday(_now),
    );
    _set('material-date', picked == null ? null : _date(picked));
  }

  Future<void> _materialRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(_now.year - 1),
      lastDate: DateTime(_now.year + 1, 12, 31),
    );
    _set('material-range', picked == null ? null : '${_date(picked.start)} - ${_date(picked.end)}');
  }

  Future<void> _materialTime() async {
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (!mounted) return;
    _set('material-time', picked?.format(context));
  }

  Future<void> _cupertino(String id, CupertinoDatePickerMode mode) async {
    var value = _cupertinoValues[id] ?? _now;
    // Sadece "Tamam" değeri kaydeder; dışarı dokunmak iptal eder (iOS davranışı)
    final picked = await showCupertinoModalPopup<DateTime>(
      context: context,
      builder: (ctx) => TestWrapper(
        dataTestId: 'cupertino-popup',
        child: Container(
          height: 300,
          color: CupertinoColors.systemBackground.resolveFrom(ctx),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TestWrapper(
                      dataTestId: 'cupertino-cancel-button',
                      child: CupertinoButton(child: const Text('Vazgeç'), onPressed: () => Navigator.pop(ctx)),
                    ),
                    TestWrapper(
                      dataTestId: 'cupertino-done-button',
                      child: CupertinoButton(
                        child: const Text('Tamam'),
                        onPressed: () => Navigator.pop(ctx, value),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: TestWrapper(
                    dataTestId: 'cupertino-picker',
                    child: CupertinoDatePicker(
                      mode: mode,
                      initialDateTime: value,
                      minimumYear: _now.year - 1,
                      maximumYear: _now.year + 1,
                      use24hFormat: true,
                      onDateTimeChanged: (d) => value = d,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (picked == null) return;
    _cupertinoValues[id] = picked;
    _set(id, switch (mode) {
      CupertinoDatePickerMode.time => _time(picked),
      CupertinoDatePickerMode.dateAndTime => '${_date(picked)} ${_time(picked)}',
      _ => _date(picked),
    });
  }

  @override
  Widget build(BuildContext context) {
    return TestWrapper(
      dataTestId: 'date-pickers-scaffold',
      child: Scaffold(
        appBar: AppBar(title: const Text('Tarih Seçiciler')),
        body: ListView(
          children: [
            _header('Material (takvim)'),
            _pickerTile('material-date', Icons.event, 'Tarih (hafta sonu kapalı)', _materialDate),
            _pickerTile('material-range', Icons.date_range, 'Tarih aralığı', _materialRange),
            _pickerTile('material-time', Icons.access_time, 'Saat', _materialTime),
            _header('iOS / Cupertino (tekerlek)'),
            _pickerTile('cupertino-date', Icons.calendar_today, 'Tarih tekerleği',
                () => _cupertino('cupertino-date', CupertinoDatePickerMode.date)),
            _pickerTile('cupertino-time', Icons.schedule, 'Saat tekerleği',
                () => _cupertino('cupertino-time', CupertinoDatePickerMode.time)),
            _pickerTile('cupertino-datetime', Icons.more_time, 'Tarih + saat tekerleği',
                () => _cupertino('cupertino-datetime', CupertinoDatePickerMode.dateAndTime)),
          ],
        ),
      ),
    );
  }

  Widget _header(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
      );

  Widget _pickerTile(String id, IconData icon, String title, VoidCallback onTap) {
    return TestWrapper(
      dataTestId: '$id-button',
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: TestWrapper(dataTestId: '$id-value', child: Text(_values[id] ?? 'Seçilmedi')),
        onTap: onTap,
      ),
    );
  }
}

DateTime _nextWeekday(DateTime d) {
  while (d.weekday >= DateTime.saturday) {
    d = d.add(const Duration(days: 1));
  }
  return d;
}
