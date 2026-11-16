import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notify/core/failures.dart';
import 'package:campus_notify/features/notes/data/repositories/fake_note_repository.dart';
import 'package:campus_notify/features/notes/domain/entities/note.dart';
import 'package:campus_notify/features/notes/domain/usecases/add_note.dart';
import 'package:campus_notify/features/notes/domain/usecases/get_notes.dart';

void main() {
  group('Task Repository & Service Dependency Test (Fake Repository)', () {
    test('meneruskan data sukses dari fake repository (Kasus Sukses)', () async {
      // Arrange
      final initialData = [
        Note(
          id: 1,
          title: 'Baca materi testing',
          body: 'Pelajari unit & widget test',
          updatedAt: DateTime.now(),
        ),
      ];
      final fakeRepo = FakeNoteRepository(initialNotes: initialData);
      final getNotes = GetNotes(fakeRepo);

      // Act
      final result = await getNotes();

      // Assert
      expect(result.failure, isNull);
      expect(result.notes.length, 1);
      expect(result.notes.first.title, 'Baca materi testing');
    });

    test('menangani kegagalan dari fake repository tanpa melempar crash (Kasus Kegagalan)', () async {
      // Arrange
      final fakeRepo = FakeNoteRepository(
        failure: const LocalFailure('Database disk error'),
      );
      final getNotes = GetNotes(fakeRepo);

      // Act
      final result = await getNotes();

      // Assert
      expect(result.failure, isNotNull);
      expect(result.failure!.message, 'Database disk error');
      expect(result.notes, isEmpty);
    });

    test('AddNote use case menolak judul kosong tanpa memanggil repository (Kasus Tepi Validasi)', () async {
      // Arrange
      final fakeRepo = FakeNoteRepository();
      final addNote = AddNote(fakeRepo);

      // Act
      final result = await addNote(title: '   ');

      // Assert
      expect(result.failure, isNotNull);
      expect(result.failure!.message, 'Judul catatan tidak boleh kosong');
      expect(result.note, isNull);
      expect(fakeRepo.currentNotes, isEmpty);
    });

    test('AddNote berhasil menambahkan tugas ke fake repository', () async {
      // Arrange
      final fakeRepo = FakeNoteRepository();
      final addNote = AddNote(fakeRepo);

      // Act
      final result = await addNote(title: 'Susun test suite');

      // Assert
      expect(result.failure, isNull);
      expect(result.note, isNotNull);
      expect(result.note!.title, 'Susun test suite');
      expect(fakeRepo.currentNotes.length, 1);
    });
  });
}
