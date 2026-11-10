import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notify/features/notes/domain/entities/note.dart';
import 'package:campus_notify/features/notes/domain/usecases/filter_notes.dart';
import 'package:campus_notify/features/notes/presentation/pages/notes_page.dart';
import 'package:campus_notify/features/notes/presentation/providers/notes_providers.dart';

void main() {
  final sampleNotes = [
    Note(
      id: 1,
      title: 'Belanja bulanan',
      body: 'Beli susu, telur, dan roti',
      updatedAt: DateTime(2026, 10, 1),
    ),
    Note(
      id: 2,
      title: 'Tugas Mobile Week 9',
      body: 'Mengerjakan Clean Architecture & AI',
      updatedAt: DateTime(2026, 10, 2),
    ),
    Note(
      id: 3,
      title: 'Daftar Belanja ATK',
      body: 'Kertas A4 dan pena',
      updatedAt: DateTime(2026, 10, 3),
    ),
  ];

  group('Unit Test filterNotes (Pure Domain Use Case)', () {
    test('mengembalikan semua catatan jika query kosong atau hanya spasi', () {
      expect(filterNotes(sampleNotes, ''), hasLength(3));
      expect(filterNotes(sampleNotes, '   '), hasLength(3));
    });

    test('filter mengabaikan huruf besar/kecil (case-insensitive)', () {
      final result = filterNotes(sampleNotes, 'belanja');
      expect(result, hasLength(2));
      expect(result[0].title, 'Belanja bulanan');
      expect(result[1].title, 'Daftar Belanja ATK');
    });

    test('query sebagian kata (substring) berhasil dicocokkan', () {
      final result = filterNotes(sampleNotes, 'Week 9');
      expect(result, hasLength(1));
      expect(result.first.title, 'Tugas Mobile Week 9');
    });

    test('query tidak cocok mengembalikan daftar kosong', () {
      final result = filterNotes(sampleNotes, 'zzz-tak-ada');
      expect(result, isEmpty);
    });
  });

  group('Widget Test NotesPage (Presentation Layer)', () {
    testWidgets(
      'menampilkan TextField pencarian dan seluruh daftar catatan saat query kosong',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              notesProvider.overrideWith((ref) => Future.value(sampleNotes)),
            ],
            child: const MaterialApp(home: NotesPage()),
          ),
        );

        // Tunggu FutureProvider selesai resolve
        await tester.pumpAndSettle();

        expect(find.text('Catatan'), findsOneWidget);
        expect(find.byType(TextField), findsOneWidget);
        expect(find.text('Cari judul catatan'), findsOneWidget);
        expect(find.text('Belanja bulanan'), findsOneWidget);
        expect(find.text('Tugas Mobile Week 9'), findsOneWidget);
        expect(find.text('Daftar Belanja ATK'), findsOneWidget);
      },
    );

    testWidgets('memfilter catatan saat mengetik kata kunci pada TextField', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notesProvider.overrideWith((ref) => Future.value(sampleNotes)),
          ],
          child: const MaterialApp(home: NotesPage()),
        ),
      );
      await tester.pumpAndSettle();

      // Ketik 'Tugas' ke input pencarian
      await tester.enterText(find.byType(TextField), 'Tugas');
      await tester.pump();

      expect(find.text('Tugas Mobile Week 9'), findsOneWidget);
      expect(find.text('Belanja bulanan'), findsNothing);
      expect(find.text('Daftar Belanja ATK'), findsNothing);
    });

    testWidgets(
      'menampilkan Empty State saat hasil pencarian tidak ditemukan',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              notesProvider.overrideWith((ref) => Future.value(sampleNotes)),
            ],
            child: const MaterialApp(home: NotesPage()),
          ),
        );
        await tester.pumpAndSettle();

        // Ketik query yang tidak ada
        await tester.enterText(find.byType(TextField), 'tidak-ditemukan');
        await tester.pump();

        expect(find.text('Tidak ada catatan.'), findsOneWidget);
        expect(find.byType(ListTile), findsNothing);
      },
    );

    testWidgets('menampilkan ErrorView ketika repository gagal memuat data', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notesProvider.overrideWith(
              (ref) => Future.error(Exception('Database error')),
            ),
          ],
          child: const MaterialApp(home: NotesPage()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Exception: Database error'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);
    });
  });
}
