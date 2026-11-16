import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notify/features/notes/domain/usecases/is_valid_task_title.dart';

void main() {
  group('isValidTaskTitle (Unit Test)', () {
    test('menerima judul yang berisi teks', () {
      // Arrange
      const title = 'Belajar Flutter';

      // Act
      final result = isValidTaskTitle(title);

      // Assert
      expect(result, isTrue);
    });

    test('menolak teks kosong atau hanya spasi (Kasus Tepi)', () {
      // Arrange & Act & Assert
      expect(isValidTaskTitle(''), isFalse);
      expect(isValidTaskTitle('   '), isFalse);
      expect(isValidTaskTitle('\t\n'), isFalse);
    });

    test('menerima judul dengan spasi di awal dan akhir selama ada teks', () {
      // Arrange
      const titleWithPadding = '   Kerjakan Modul 12   ';

      // Act
      final result = isValidTaskTitle(titleWithPadding);

      // Assert
      expect(result, isTrue);
    });
  });
}
