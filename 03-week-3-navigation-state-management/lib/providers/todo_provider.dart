import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo.dart';

/// Enum filter untuk memfilter tugas pada daftar ToDo
enum TodoFilter { all, active, completed }

/// Notifier untuk mengelola list ToDo secara immutable
class TodoListNotifier extends Notifier<List<Todo>> {
  @override
  List<Todo> build() => const [];

  /// Menambah tugas baru ke dalam list state
  void add(String title) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;
    state = [...state, Todo(trimmed)];
  }

  /// Mengubah status selesai/belum selesai dari tugas pada indeks tertentu
  void toggle(int index) {
    if (index < 0 || index >= state.length) return;
    final todos = [...state];
    todos[index] = todos[index].copyWith(done: !todos[index].done);
    state = todos;
  }

  /// Menghapus tugas pada indeks tertentu
  void remove(int index) {
    if (index < 0 || index >= state.length) return;
    final todos = [...state]..removeAt(index);
    state = todos;
  }
}

/// Provider global untuk daftar ToDo
final todoListProvider =
    NotifierProvider<TodoListNotifier, List<Todo>>(TodoListNotifier.new);

/// Notifier untuk mengelola filter aktif
class TodoFilterNotifier extends Notifier<TodoFilter> {
  @override
  TodoFilter build() => TodoFilter.all;

  void setFilter(TodoFilter filter) => state = filter;
}

/// Provider untuk state filter
final todoFilterProvider =
    NotifierProvider<TodoFilterNotifier, TodoFilter>(TodoFilterNotifier.new);

/// Provider turunan untuk menghasilkan list ToDo yang telah difilter (Refactoring Challenge #2)
final filteredTodoListProvider = Provider<List<Todo>>((ref) {
  final todos = ref.watch(todoListProvider);
  final filter = ref.watch(todoFilterProvider);

  switch (filter) {
    case TodoFilter.all:
      return todos;
    case TodoFilter.active:
      return todos.where((todo) => !todo.done).toList();
    case TodoFilter.completed:
      return todos.where((todo) => todo.done).toList();
  }
});
