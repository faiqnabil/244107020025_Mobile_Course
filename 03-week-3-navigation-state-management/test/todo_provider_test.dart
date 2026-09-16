import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week3_app/providers/todo_provider.dart';

void main() {
  group('TodoListNotifier Unit Tests', () {
    test('State awal harus berupa list kosong', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final todos = container.read(todoListProvider);
      expect(todos, isEmpty);
    });

    test('Method add() harus menambahkan tugas baru secara immutable', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(todoListProvider.notifier).add('Belajar Riverpod');

      final todos = container.read(todoListProvider);
      expect(todos.length, 1);
      expect(todos.first.title, 'Belajar Riverpod');
      expect(todos.first.done, isFalse);
    });

    test('Method toggle() harus mengubah status done', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(todoListProvider.notifier).add('Tugas 1');
      expect(container.read(todoListProvider)[0].done, isFalse);

      container.read(todoListProvider.notifier).toggle(0);
      expect(container.read(todoListProvider)[0].done, isTrue);

      container.read(todoListProvider.notifier).toggle(0);
      expect(container.read(todoListProvider)[0].done, isFalse);
    });

    test('Method remove() harus menghapus tugas berdasarkan index', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(todoListProvider.notifier).add('Tugas 1');
      container.read(todoListProvider.notifier).add('Tugas 2');
      expect(container.read(todoListProvider).length, 2);

      container.read(todoListProvider.notifier).remove(0);
      final todos = container.read(todoListProvider);
      expect(todos.length, 1);
      expect(todos.first.title, 'Tugas 2');
    });

    test('Filter Provider harus menyaring tugas aktif dan selesai dengan benar', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(todoListProvider.notifier).add('Tugas Aktif');
      container.read(todoListProvider.notifier).add('Tugas Selesai');
      container.read(todoListProvider.notifier).toggle(1);

      // Default: All
      expect(container.read(filteredTodoListProvider).length, 2);

      // Filter: Active
      container
          .read(todoFilterProvider.notifier)
          .setFilter(TodoFilter.active);
      expect(container.read(filteredTodoListProvider).length, 1);
      expect(container.read(filteredTodoListProvider).first.title, 'Tugas Aktif');

      // Filter: Completed
      container
          .read(todoFilterProvider.notifier)
          .setFilter(TodoFilter.completed);
      expect(container.read(filteredTodoListProvider).length, 1);
      expect(container.read(filteredTodoListProvider).first.title, 'Tugas Selesai');
    });
  });
}
