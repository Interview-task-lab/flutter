import 'package:flutter/material.dart';
import 'test_wrapper.dart';

/// Görevler (`Draggable`) iki kutu (`DragTarget`) arasında taşınır.
/// Kayıtlar ekranındaki uzun bas + sırala hareketinden farklı olarak burada
/// sürükleme dokunur dokunmaz başlar.
class DragDropScreen extends StatefulWidget {
  const DragDropScreen({super.key});

  @override
  State<DragDropScreen> createState() => _DragDropScreenState();
}

class _DragDropScreenState extends State<DragDropScreen> {
  // Görev numarası -> tamamlandı mı
  final Map<int, bool> _done = {for (var i = 1; i <= 5; i++) i: false};

  @override
  Widget build(BuildContext context) {
    return TestWrapper(
      dataTestId: 'drag-drop-scaffold',
      child: Scaffold(
        appBar: AppBar(title: const Text('Sürükle & Bırak')),
        body: Column(
          children: [
            Expanded(child: _zone('todo', 'Yapılacak', false, Colors.orange)),
            Expanded(child: _zone('done', 'Tamamlandı', true, Colors.green)),
          ],
        ),
      ),
    );
  }

  Widget _zone(String id, String title, bool done, Color color) {
    final tasks = _done.keys.where((t) => _done[t] == done).toList();
    return TestWrapper(
      dataTestId: 'drop-zone-$id',
      child: DragTarget<int>(
        onAcceptWithDetails: (details) => setState(() => _done[details.data] = done),
        builder: (context, candidates, _) => Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: candidates.isNotEmpty ? color.withValues(alpha: 0.25) : color.withValues(alpha: 0.08),
            border: Border.all(color: color, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TestWrapper(
                dataTestId: 'drop-zone-$id-count',
                child: Text('$title (${tasks.length})',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: tasks.map(_task).toList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _task(int task) {
    final chip = Chip(label: Text('Görev $task'), avatar: const Icon(Icons.drag_indicator, size: 18));
    return TestWrapper(
      dataTestId: 'drag-task-$task',
      child: Draggable<int>(
        data: task,
        feedback: Material(color: Colors.transparent, child: chip),
        childWhenDragging: Opacity(opacity: 0.3, child: chip),
        child: chip,
      ),
    );
  }
}
