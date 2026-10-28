import 'package:flutter/material.dart';
import 'chaos.dart';
import 'test_wrapper.dart';

class Record {
  final int id;
  String title;
  String note;

  Record(this.id, this.title, this.note);
}

/// 200 kayıtlık lazy liste. `ListView.builder` sadece ekranda görünenleri
/// oluşturur; uzaktaki bir kayda ulaşmak için kaydırmak gerekir.
/// - Sağa kaydır: düzenleme/silme ekranı açılır
/// - Sola kaydır: onay penceresi ile silinir, "Geri al" SnackBar'ı çıkar
/// - Uzun bas + sürükle: sıralama değişir
class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  List<Record>? _records;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final records = await _loadRecords();
    if (mounted) setState(() => _records = records);
  }

  Future<bool> _confirmDismiss(Record record, DismissDirection direction) async {
    if (direction == DismissDirection.startToEnd) {
      final deleted = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => RecordDetailScreen(record: record)),
      );
      setState(() {}); // Düzenlenen başlık/not listeye yansısın
      return deleted ?? false;
    }
    return await _askDelete(context, record) ?? false;
  }

  void _onDismissed(Record record, int index) {
    setState(() => _records!.removeAt(index));
    _showUndo(context, record, () => setState(() => _records!.insert(index, record)));
  }

  @override
  Widget build(BuildContext context) {
    final records = _records;
    return TestWrapper(
      dataTestId: 'records-scaffold',
      child: Scaffold(
        appBar: AppBar(title: Text('Kayıtlar${records == null ? '' : ' (${records.length})'}')),
        body: records == null
            ? const Center(
                child: TestWrapper(dataTestId: 'records-loading', child: CircularProgressIndicator()),
              )
            : ReorderableListView.builder(
                itemCount: records.length,
                onReorderItem: (oldIndex, newIndex) =>
                    setState(() => records.insert(newIndex, records.removeAt(oldIndex))),
                itemBuilder: (context, index) {
                  final record = records[index];
                  return TestWrapper(
                    key: ValueKey(record.id),
                    dataTestId: 'record-item-${record.id}',
                    child: Dismissible(
                      key: ValueKey('dismiss-${record.id}'),
                      background: _swipeBackground(
                          Colors.blue, Icons.edit, 'Düzenle / Sil', Alignment.centerLeft),
                      secondaryBackground:
                          _swipeBackground(Colors.red, Icons.delete, 'Sil', Alignment.centerRight),
                      confirmDismiss: (direction) => _confirmDismiss(record, direction),
                      onDismissed: (_) => _onDismissed(record, index),
                      child: ListTile(
                        leading: CircleAvatar(child: Text('${record.id}')),
                        title: Text(record.title),
                        subtitle: Text(record.note),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _swipeBackground(Color color, IconData icon, String label, Alignment alignment) {
    return Container(
      color: color,
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

/// Kayıtlar ekranının ikinci versiyonu: sola kaydırınca satırın arkasından
/// "Düzenle" ve "Sil" butonları yan yana açılır (iOS Mail tarzı).
/// Butonlar sadece satır açıkken ağaçta vardır; önce kaydırmak gerekir.
class RecordActionsScreen extends StatefulWidget {
  const RecordActionsScreen({super.key});

  @override
  State<RecordActionsScreen> createState() => _RecordActionsScreenState();
}

class _RecordActionsScreenState extends State<RecordActionsScreen> {
  List<Record>? _records;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final records = await _loadRecords();
    if (mounted) setState(() => _records = records);
  }

  Future<void> _edit(Record record) async {
    final deleted = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => RecordDetailScreen(record: record)),
    );
    if (!mounted) return;
    if (deleted == true) {
      _remove(record);
    } else {
      setState(() {}); // Düzenlenen başlık/not listeye yansısın
    }
  }

  Future<void> _delete(Record record) async {
    if (await _askDelete(context, record) == true && mounted) _remove(record);
  }

  void _remove(Record record) {
    final index = _records!.indexOf(record);
    setState(() => _records!.removeAt(index));
    _showUndo(context, record, () => setState(() => _records!.insert(index, record)));
  }

  @override
  Widget build(BuildContext context) {
    final records = _records;
    return TestWrapper(
      dataTestId: 'record-actions-scaffold',
      child: Scaffold(
        appBar: AppBar(title: Text('Kayıtlar 2${records == null ? '' : ' (${records.length})'}')),
        body: records == null
            ? const Center(
                child: TestWrapper(dataTestId: 'records-loading', child: CircularProgressIndicator()),
              )
            : ListView.builder(
                itemCount: records.length,
                itemBuilder: (context, index) {
                  final record = records[index];
                  return TestWrapper(
                    key: ValueKey(record.id),
                    dataTestId: 'record-item-${record.id}',
                    child: _SwipeActionsTile(
                      record: record,
                      onEdit: () => _edit(record),
                      onDelete: () => _delete(record),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _SwipeActionsTile extends StatefulWidget {
  final Record record;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SwipeActionsTile({required this.record, required this.onEdit, required this.onDelete});

  @override
  State<_SwipeActionsTile> createState() => _SwipeActionsTileState();
}

class _SwipeActionsTileState extends State<_SwipeActionsTile> {
  static const _actionWidth = 80.0;
  static const _openOffset = -2 * _actionWidth;
  double _offset = 0;
  bool _dragging = false;

  void _close() => setState(() => _offset = 0);

  @override
  Widget build(BuildContext context) {
    final id = widget.record.id;
    return ClipRect(
      child: Stack(
        children: [
          if (_offset < 0)
            Positioned.fill(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _action('record-edit-$id', Colors.blue, Icons.edit, 'Düzenle', widget.onEdit),
                  _action('record-delete-$id', Colors.red, Icons.delete, 'Sil', widget.onDelete),
                ],
              ),
            ),
          GestureDetector(
            onHorizontalDragStart: (_) => setState(() => _dragging = true),
            onHorizontalDragUpdate: (d) =>
                setState(() => _offset = (_offset + d.delta.dx).clamp(_openOffset, 0)),
            onHorizontalDragEnd: (_) => setState(() {
              _dragging = false;
              _offset = _offset < _openOffset / 2 ? _openOffset : 0;
            }),
            child: AnimatedContainer(
              duration: _dragging ? Duration.zero : const Duration(milliseconds: 200),
              transform: Matrix4.translationValues(_offset, 0, 0),
              // Opak Material: arkadaki butonları kapatır, ListTile efektleri görünür
              child: Material(
                child: ListTile(
                  leading: CircleAvatar(child: Text('$id')),
                  title: Text(widget.record.title),
                  subtitle: Text(widget.record.note),
                  trailing: const Icon(Icons.chevron_left, color: Colors.grey),
                  onTap: _offset < 0 ? _close : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _action(String testId, Color color, IconData icon, String label, VoidCallback onTap) {
    return TestWrapper(
      dataTestId: testId,
      child: SizedBox(
        width: _actionWidth,
        child: Material(
          color: color,
          child: InkWell(
            onTap: () {
              _close();
              onTap();
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(height: 4),
                Text(label, style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<List<Record>> _loadRecords() async {
  await chaosDelay();
  return chaosShuffle(List.generate(200, (i) => Record(i + 1, 'Kayıt ${i + 1}', 'Not ${i + 1}')));
}

void _showUndo(BuildContext context, Record record, VoidCallback onUndo) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: TestWrapper(dataTestId: 'undo-snackbar', child: Text('${record.title} silindi')),
      duration: const Duration(seconds: 3),
      persist: false,
      action: SnackBarAction(label: 'Geri al', onPressed: onUndo),
    ));
}

Future<bool?> _askDelete(BuildContext context, Record record) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => TestWrapper(
      dataTestId: 'delete-confirm-dialog',
      child: AlertDialog(
        title: const Text('Kaydı sil'),
        content: Text('"${record.title}" silinsin mi?'),
        actions: [
          TestWrapper(
            dataTestId: 'delete-confirm-no',
            child: TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Vazgeç')),
          ),
          TestWrapper(
            dataTestId: 'delete-confirm-yes',
            child: TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sil')),
          ),
        ],
      ),
    ),
  );
}

/// Sağa kaydırınca açılan ekran. `true` ile kapanırsa kayıt silinir.
class RecordDetailScreen extends StatefulWidget {
  final Record record;

  const RecordDetailScreen({super.key, required this.record});

  @override
  State<RecordDetailScreen> createState() => _RecordDetailScreenState();
}

class _RecordDetailScreenState extends State<RecordDetailScreen> {
  late final _title = TextEditingController(text: widget.record.title);
  late final _note = TextEditingController(text: widget.record.note);
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await chaosDelay(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _saving = false);
    if (chaosShouldFail()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: TestWrapper(dataTestId: 'save-error-snackbar', child: Text('Kaydetme başarısız, tekrar deneyin')),
      ));
      return;
    }
    widget.record
      ..title = _title.text
      ..note = _note.text;
    Navigator.pop(context, false);
  }

  Future<void> _delete() async {
    if (await _askDelete(context, widget.record) == true && mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TestWrapper(
      dataTestId: 'record-detail-scaffold',
      child: Scaffold(
        appBar: AppBar(title: Text('Kayıt #${widget.record.id}')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TestWrapper(
              dataTestId: 'record-title-input',
              child: TextField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Başlık', border: OutlineInputBorder()),
              ),
            ),
            const SizedBox(height: 16),
            TestWrapper(
              dataTestId: 'record-note-input',
              child: TextField(
                controller: _note,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Not', border: OutlineInputBorder()),
              ),
            ),
            const SizedBox(height: 24),
            TestWrapper(
              dataTestId: 'record-save-button',
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.save),
                label: const Text('Kaydet'),
              ),
            ),
            const SizedBox(height: 12),
            TestWrapper(
              dataTestId: 'record-delete-button',
              child: OutlinedButton.icon(
                onPressed: _saving ? null : _delete,
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                icon: const Icon(Icons.delete),
                label: const Text('Sil'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
