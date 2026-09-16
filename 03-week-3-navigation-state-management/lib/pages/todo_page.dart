import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/todo_provider.dart';
import '../widgets/todo_tile.dart';

/// Halaman utama daftar ToDo menggunakan ConsumerWidget Riverpod
class TodoPage extends ConsumerWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Memantau state daftar ToDo yang telah difilter (watch di dalam build)
    final todos = ref.watch(filteredTodoListProvider);
    final allTodos = ref.watch(todoListProvider);
    final currentFilter = ref.watch(todoFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ToDo Riverpod'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Detail Info',
            onPressed: () => context.go('/detail/info'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Baris Filter Status (Refactoring Challenge #2)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SegmentedButton<TodoFilter>(
              segments: const [
                ButtonSegment(
                  value: TodoFilter.all,
                  label: Text('Semua'),
                  icon: Icon(Icons.list_alt),
                ),
                ButtonSegment(
                  value: TodoFilter.active,
                  label: Text('Aktif'),
                  icon: Icon(Icons.pending_actions),
                ),
                ButtonSegment(
                  value: TodoFilter.completed,
                  label: Text('Selesai'),
                  icon: Icon(Icons.check_circle_outline),
                ),
              ],
              selected: {currentFilter},
              onSelectionChanged: (Set<TodoFilter> selected) {
                ref.read(todoFilterProvider.notifier).setFilter(selected.first);
              },
            ),
          ),

          // Konten List ToDo
          Expanded(
            child: todos.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.task_alt,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Belum ada tugas',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        if (allTodos.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => ref
                                .read(todoFilterProvider.notifier)
                                .setFilter(TodoFilter.all),
                            child: const Text('Tampilkan semua tugas'),
                          ),
                        ],
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80, top: 4),
                    itemCount: todos.length,
                    itemBuilder: (context, index) {
                      final todo = todos[index];
                      // Menemukan indeks asli pada list global untuk aksi toggle/remove yang tepat
                      final originalIndex = allTodos.indexOf(todo);
                      final targetIndex =
                          originalIndex != -1 ? originalIndex : index;

                      return TodoTile(
                        todo: todo,
                        onToggle: () => ref
                            .read(todoListProvider.notifier)
                            .toggle(targetIndex),
                        onDelete: () => ref
                            .read(todoListProvider.notifier)
                            .remove(targetIndex),
                        onTap: () => context.go('/detail/${targetIndex + 1}'),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Dialog modal untuk menambahkan tugas baru
  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tugas baru'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Masukkan judul tugas...',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              ref.read(todoListProvider.notifier).add(value.trim());
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref
                    .read(todoListProvider.notifier)
                    .add(controller.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }
}
