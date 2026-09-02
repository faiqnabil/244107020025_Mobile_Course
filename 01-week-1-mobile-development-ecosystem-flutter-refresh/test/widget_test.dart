import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:week_1_mobile_dev/main.dart';

void main() {
  testWidgets('Profil Mahasiswa UI test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify AppBar title
    expect(find.text('Profil Mahasiswa'), findsOneWidget);

    // Verify Icon
    expect(find.byIcon(Icons.school), findsOneWidget);

    // Verify Nama dan NIM
    expect(find.text('Muhammad Faiq Nabil Saputra'), findsOneWidget);
    expect(find.text('NIM: 244107020025'), findsOneWidget);

    // Verify Mata Kuliah dan Prodi
    expect(find.text('Pemrograman Mobile — Minggu 1'), findsOneWidget);
    expect(find.text('D4 Teknik Informatika - JTI Polinema'), findsOneWidget);
  });
}
