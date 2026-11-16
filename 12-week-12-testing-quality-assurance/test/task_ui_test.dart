import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notify/core/failures.dart';
import 'package:campus_notify/features/notes/data/repositories/fake_note_repository.dart';
import 'package:campus_notify/features/notes/domain/entities/note.dart';
import 'package:campus_notify/features/notes/presentation/pages/notes_page.dart';
import 'package:campus_notify/features/notes/presentation/providers/notes_providers.dart';

void main() {
  Widget createTestWidget({FakeNoteRepository? repo}) {
    final fakeRepo = repo ?? FakeNoteRepository();
    return ProviderScope(
      overrides: [
        noteRepositoryProvider.overrideWithValue(fakeRepo),
      ],
      child: const MaterialApp(
        home: NotesPage(),
      ),
    );
  }

  group('Task UI Widget Test (NotesPage)', () {
    testWidgets('menampilkan judul halaman tugas dan daftar tugas awal', (tester) async {
      final fakeRepo = FakeNoteRepository(
        initialNotes: [
          Note(
            id: 1,
            title: 'Baca materi testing',
            body: '',
            updatedAt: DateTime.now(),
          ),
        ],
      );

      await tester.pumpWidget(createTestWidget(repo: fakeRepo));
      await tester.pumpAndSettle();

      // Memeriksa judul halaman dan item yang muncul
      expect(find.text('Catatan'), findsOneWidget);
      expect(find.text('Baca materi testing'), findsOneWidget);
    });

    testWidgets('menampilkan pesan saat input tidak valid pada dialog tambah tugas', (tester) async {
      final fakeRepo = FakeNoteRepository();
      await tester.pumpWidget(createTestWidget(repo: fakeRepo));
      await tester.pumpAndSettle();

      // Buka dialog tambah tugas
      await tester.tap(find.byKey(const Key('add-task-fab')));
      await tester.pumpAndSettle();

      // Tekan tombol Simpan tanpa mengisi field judul
      await tester.tap(find.byKey(const Key('save-task-button')));
      await tester.pumpAndSettle();

      // Validasi form harus menampilkan pesan error
      expect(find.text('Judul tugas tidak boleh kosong'), findsOneWidget);
    });

    testWidgets('tindakan pengguna menambah tugas berhasil dan merender item di daftar', (tester) async {
      final fakeRepo = FakeNoteRepository();
      await tester.pumpWidget(createTestWidget(repo: fakeRepo));
      await tester.pumpAndSettle();

      // Pastikan awalnya empty state
      expect(find.text('Tidak ada catatan.'), findsOneWidget);

      // Buka dialog tambah tugas
      await tester.tap(find.byKey(const Key('add-task-fab')));
      await tester.pumpAndSettle();

      // Masukkan teks ke field
      await tester.enterText(
        find.byKey(const Key('task-title-field')),
        'Selesaikan modul praktikum 12',
      );
      await tester.pumpAndSettle();

      // Tekan tombol Simpan
      await tester.tap(find.byKey(const Key('save-task-button')));
      await tester.pumpAndSettle();

      // Verifikasi item baru muncul di UI
      expect(find.text('Selesaikan modul praktikum 12'), findsOneWidget);
      expect(fakeRepo.currentNotes.length, 1);
    });

    testWidgets('menampilkan pesan error saat repository mengalami kegagalan', (tester) async {
      final fakeRepo = FakeNoteRepository(
        failure: const LocalFailure('Gagal memuat daftar tugas dari database'),
      );
      await tester.pumpWidget(createTestWidget(repo: fakeRepo));
      await tester.pumpAndSettle();

      expect(find.text('Exception: Gagal memuat daftar tugas dari database'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);
    });
  });
}
