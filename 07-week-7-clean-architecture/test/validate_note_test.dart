import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notify/core/failures.dart';
import 'package:campus_notify/features/notes/domain/entities/note.dart';
import 'package:campus_notify/features/notes/domain/repositories/note_repository.dart';
import 'package:campus_notify/features/notes/domain/usecases/add_note.dart';

class FakeNoteRepository implements NoteRepository {
  FakeNoteRepository({this.fail = false});

  final bool fail;
  Note? savedNote;

  @override
  Future<({List<Note> notes, Failure? failure})> fetchNotes() {
    throw UnimplementedError();
  }

  @override
  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
  }) async {
    if (fail) {
      return (
        note: null,
        failure: const LocalFailure('Gagal menyimpan ke database'),
      );
    }
    savedNote = Note(
      id: 1,
      title: title,
      body: body,
      updatedAt: DateTime.now(),
    );
    return (note: savedNote, failure: null);
  }
}

void main() {
  group('AddNote Validation', () {
    test(
      'judul kosong mengembalikan LocalFailure dan tidak memanggil repository',
      () async {
        final repo = FakeNoteRepository();
        final useCase = AddNote(repo);

        final resultEmpty = await useCase.call(title: '');
        expect(resultEmpty.failure, isA<LocalFailure>());
        expect(
          resultEmpty.failure?.message,
          'Judul catatan tidak boleh kosong',
        );
        expect(resultEmpty.note, isNull);
        expect(repo.savedNote, isNull);

        final resultWhitespace = await useCase.call(title: '   ');
        expect(resultWhitespace.failure, isA<LocalFailure>());
        expect(
          resultWhitespace.failure?.message,
          'Judul catatan tidak boleh kosong',
        );
        expect(resultWhitespace.note, isNull);
        expect(repo.savedNote, isNull);
      },
    );

    test('judul valid berhasil menyimpan catatan via repository', () async {
      final repo = FakeNoteRepository();
      final useCase = AddNote(repo);

      final result = await useCase.call(
        title: 'Rencana Belajar',
        body: 'Belajar Flutter Clean Architecture',
      );
      expect(result.failure, isNull);
      expect(result.note, isNotNull);
      expect(result.note?.title, 'Rencana Belajar');
      expect(repo.savedNote?.title, 'Rencana Belajar');
    });

    test(
      'judul dan isi dipangkas (trim) sebelum dikirim ke repository',
      () async {
        final repo = FakeNoteRepository();
        final useCase = AddNote(repo);

        final result = await useCase.call(
          title: '   Catatan Penting   ',
          body: '  Deskripsi materi kuliah  ',
        );
        expect(result.failure, isNull);
        expect(repo.savedNote?.title, 'Catatan Penting');
        expect(repo.savedNote?.body, 'Deskripsi materi kuliah');
      },
    );

    test(
      'meneruskan failure dari repository tanpa melempar exception',
      () async {
        final repo = FakeNoteRepository(fail: true);
        final useCase = AddNote(repo);

        final result = await useCase.call(title: 'Catatan Baru');
        expect(result.failure, isA<LocalFailure>());
        expect(result.failure?.message, 'Gagal menyimpan ke database');
        expect(result.note, isNull);
      },
    );
  });
}
