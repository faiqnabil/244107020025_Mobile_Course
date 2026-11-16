import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notify/ai/ai_service.dart';
import 'package:campus_notify/features/chat_screen.dart';

class MockAiService extends AiService {
  final Future<String> Function(String)? onAsk;
  bool saveApiKeyCalled = false;

  MockAiService({this.onAsk});

  @override
  Future<String> ask(String question) async {
    if (onAsk != null) {
      return onAsk!(question);
    }
    return 'Halo! Saya asisten AI kampus.';
  }

  @override
  Future<void> saveApiKey(String key) async {
    saveApiKeyCalled = true;
  }
}

void main() {
  group('ChatScreen Widget Tests', () {
    testWidgets('menampilkan Empty State dan komponen input saat pertama dibuka',
        (tester) async {
      final mockAi = MockAiService();

      await tester.pumpWidget(
        MaterialApp(
          home: ChatScreen(aiService: mockAi),
        ),
      );

      expect(find.text('AI Campus Assistant'), findsOneWidget);
      expect(find.text('Tanya Asisten AI Kampus'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.send), findsOneWidget);
    });

    testWidgets('mengirim pesan pengguna dan menampilkan respons streaming AI',
        (tester) async {
      final mockAi = MockAiService(
        onAsk: (q) async => 'Jadwal kuliah hari ini jam 08.00 WIB.',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ChatScreen(aiService: mockAi),
        ),
      );

      // Ketik pertanyaan
      await tester.enterText(find.byType(TextField), 'Kapan jadwal kuliah?');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      // Memverifikasi pesan user muncul
      expect(find.text('Kapan jadwal kuliah?'), findsOneWidget);

      // Memompa hingga animasi streaming selesai
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Memverifikasi respons AI muncul
      expect(find.text('Jadwal kuliah hari ini jam 08.00 WIB.'), findsOneWidget);
    });

    testWidgets('memblokir pengiriman dan menampilkan SnackBar privasi jika NIK dikirim',
        (tester) async {
      bool askCalled = false;
      final mockAi = MockAiService(
        onAsk: (q) async {
          askCalled = true;
          return 'Jawaban';
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ChatScreen(aiService: mockAi),
        ),
      );

      // Ketik pesan yang mengandung NIK 16 digit
      await tester.enterText(
        find.byType(TextField),
        'Halo ini NIK saya 3507123456780001 tolong cek',
      );
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      expect(askCalled, isFalse);
      expect(
        find.textContaining('Peringatan Keamanan: Terdeteksi data sensitif'),
        findsOneWidget,
      );
    });

    testWidgets('menampilkan dialog error / fallback jika API gagal',
        (tester) async {
      final mockAi = MockAiService(
        onAsk: (q) async => throw Exception('Koneksi timeout'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ChatScreen(aiService: mockAi),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Test pertanyaan');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Layanan AI Sibuk'), findsOneWidget);
      expect(find.text('Coba lagi nanti atau gunakan mode offline.'), findsOneWidget);
    });
  });
}
