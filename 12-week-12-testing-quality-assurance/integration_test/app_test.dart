import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:campus_notify/features/notes/data/repositories/fake_note_repository.dart';
import 'package:campus_notify/features/notes/presentation/pages/notes_page.dart';
import 'package:campus_notify/features/notes/presentation/providers/notes_providers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('pengguna dapat menambahkan tugas dan melihatnya di daftar (alur utama integrasi)', (tester) async {
    final fakeRepo = FakeNoteRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          noteRepositoryProvider.overrideWithValue(fakeRepo),
        ],
        child: const MaterialApp(
          home: NotesPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verifikasi tampilan awal halaman
    expect(find.text('Catatan'), findsOneWidget);
    expect(find.text('Tidak ada catatan.'), findsOneWidget);

    // 2. Klik tombol tambah tugas
    final fabFinder = find.byKey(const Key('add-task-fab'));
    expect(fabFinder, findsOneWidget);
    await tester.tap(fabFinder);
    await tester.pumpAndSettle();

    // 3. Masukkan teks judul tugas
    final inputFinder = find.byKey(const Key('task-title-field'));
    expect(inputFinder, findsOneWidget);
    await tester.enterText(inputFinder, 'Baca materi pengujian integrasi');
    await tester.pumpAndSettle();

    // 4. Klik tombol simpan
    final saveButtonFinder = find.byKey(const Key('save-task-button'));
    expect(saveButtonFinder, findsOneWidget);
    await tester.tap(saveButtonFinder);
    await tester.pumpAndSettle();

    // 5. Verifikasi tugas berhasil muncul di list
    expect(find.text('Baca materi pengujian integrasi'), findsOneWidget);
  });
}
