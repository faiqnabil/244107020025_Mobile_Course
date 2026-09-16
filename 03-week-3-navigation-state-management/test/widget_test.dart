import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week3_app/main.dart';

void main() {
  testWidgets('menambah tugas baru', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    expect(find.text('Belum ada tugas'), findsOneWidget);

    // Buka modal dialog tambah tugas
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Isi teks pada input dialog
    await tester.enterText(find.byType(TextField), 'Kerjakan PR minggu 3');
    await tester.tap(find.text('Tambah'));
    await tester.pumpAndSettle();

    // Verifikasi tugas berhasil muncul di UI
    expect(find.text('Kerjakan PR minggu 3'), findsOneWidget);
  });

  testWidgets('toggle status checkbox tugas', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    // Tambahkan tugas
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Tugas Checkbox');
    await tester.tap(find.text('Tambah'));
    await tester.pumpAndSettle();

    // Cari checkbox
    final checkboxFinder = find.byType(Checkbox);
    expect(checkboxFinder, findsOneWidget);

    // Toggle status
    await tester.tap(checkboxFinder);
    await tester.pumpAndSettle();

    final checkbox = tester.widget<Checkbox>(checkboxFinder);
    expect(checkbox.value, isTrue);
  });

  testWidgets('navigasi antar tab NavigationBar', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    // Memastikan berada di tab ToDo
    expect(find.text('ToDo Riverpod'), findsOneWidget);

    // Klik tab Statistik pada NavigationBar
    await tester.tap(find.byIcon(Icons.bar_chart_outlined));
    await tester.pump();

    // Verifikasi navigasi ke halaman Statistik
    expect(find.text('Statistik ToDo'), findsOneWidget);

    // Memajukan clock pengujian agar timer asinkron pada StatsNotifier selesai
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });
}
