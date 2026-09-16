import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:responsive_dashboard/main.dart';

void main() {
  testWidgets('Dashboard satu kolom di layar sempit', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const DashboardApp());

    final width = tester.getSize(find.byType(Card).first).width;
    expect(width, lessThan(700));
  });

  testWidgets('Dashboard dua kolom di layar lebar', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const DashboardApp());

    final width = tester.getSize(find.byType(Card).first).width;
    expect(width, greaterThan(500));
  });

  testWidgets('Toggle theme mengubah mode terang ke gelap', (WidgetTester tester) async {
    await tester.pumpWidget(const DashboardApp());

    // Cek keberadaan switch toggle tema
    expect(find.byType(CupertinoSwitch), findsOneWidget);
    expect(find.byIcon(Icons.light_mode), findsOneWidget);

    // Tap CupertinoSwitch untuk mengaktifkan Dark Mode
    await tester.tap(find.byType(CupertinoSwitch));
    await tester.pumpAndSettle();

    // Verifikasi ikon berubah menjadi dark_mode
    expect(find.byIcon(Icons.dark_mode), findsOneWidget);
  });

  testWidgets('Menampilkan informasi profil dan kartu akademik', (WidgetTester tester) async {
    await tester.pumpWidget(const DashboardApp());

    // Verifikasi data profil
    expect(find.text('Muhammad Faiq Nabil Saputra'), findsOneWidget);
    expect(find.text('NIM: 244107020025'), findsOneWidget);
    expect(find.text('Kelas: TI-3D'), findsOneWidget);

    // Verifikasi kartu informasi
    expect(find.text('Assignments'), findsOneWidget);
    expect(find.text('8 Selesai'), findsOneWidget);
    expect(find.text('Attendance'), findsOneWidget);
    expect(find.text('92%'), findsOneWidget);
    expect(find.text('IPK Semester'), findsOneWidget);
    expect(find.text('3.88'), findsOneWidget);
  });
}
