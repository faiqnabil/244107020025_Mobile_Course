import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notify/core/format.dart';

void main() {
  group('Format pure functions', () {
    test('formatDate memformat DateTime ke format YYYY-MM-DD HH:mm', () {
      final dt = DateTime(2026, 10, 11, 14, 30);
      expect(formatDate(dt), '2026-10-11 14:30');
    });

    test('truncateToken memotong token yang lebih panjang dari limit', () {
      expect(truncateToken(null), 'Belum tersedia');
      expect(truncateToken(''), 'Belum tersedia');
      expect(truncateToken('short-token'), 'short-token');
      expect(truncateToken('very-long-fcm-device-registration-token'), 'very-long-fc...');
    });

    test('routeFromMessage menambahkan slash awal bila rute belum memilikinya', () {
      expect(routeFromMessage({}), '/');
      expect(routeFromMessage({'route': 'pengumuman/1'}), '/pengumuman/1');
      expect(routeFromMessage({'route': '/pengumuman/1'}), '/pengumuman/1');
    });
  });
}
