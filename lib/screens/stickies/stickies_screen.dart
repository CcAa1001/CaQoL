import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/sticky.dart';
import '../../providers/stickies_provider.dart';


class StickiesScreen extends ConsumerWidget {
  const StickiesScreen({super.key});

  static const _colorOptions = [
    Colors.yellow,
    Colors.lightGreen,
    Colors.lightBlue,
    Colors.pink,
    Colors.orange,
    Colors.purple,
  ];

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController();
    Color picked = Colors.yellow;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('New sticky'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ctrl,
                maxLines: 4,
                autofocus: true,
                decoration: const InputDecoration(hintText: 'Write something...'),
              ),
              const SizedBox(height: 12),
              Row(
                children: _colorOptions.map((c) => GestureDetector(
                  onTap: () => setState(() => picked = c),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: picked == c
                          ? Border.all(width: 2.5, color: Colors.black54)
                          : null,
                    ),
                  ),
                )).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (ctrl.text.isNotEmpty) {
                  ref.read(stickiesProvider.notifier).add(
                    body: ctrl.text,
                    color: picked,
                  );
                }
                Navigator.pop(ctx);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, Sticky sticky) {
    final ctrl = TextEditingController(text: sticky.body);
    Color picked = sticky.color;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Edit sticky'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ctrl,
                maxLines: 4,
                autofocus: true,
              ),
              const SizedBox(height: 12),
              Row(
                children: _colorOptions.map((c) => GestureDetector(
                  onTap: () => setState(() => picked = c),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: picked == c
                          ? Border.all(width: 2.5, color: Colors.black54)
                          : null,
                    ),
                  ),
                )).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                ref.read(stickiesProvider.notifier).delete(sticky.id);
                Navigator.pop(ctx);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
            FilledButton(
              onPressed: () {
                ref.read(stickiesProvider.notifier).update(
                  sticky.copyWith(body: ctrl.text, color: picked),
                );
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stickies = ref.watch(stickiesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Sticky Notes')),
      body: stickies.isEmpty
          ? const Center(child: Text('No stickies yet. Tap + to add one.'))
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: stickies.length,
              itemBuilder: (context, i) {
                final sticky = stickies[i];
                return GestureDetector(
                  onTap: () => _showEditDialog(context, ref, sticky),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: sticky.color,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      sticky.body,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.fade,
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}