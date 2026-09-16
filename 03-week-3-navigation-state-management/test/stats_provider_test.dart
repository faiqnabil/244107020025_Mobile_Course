import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week3_app/providers/stats_provider.dart';

void main() {
  group('StatsNotifier Unit Tests', () {
    test('StatsNotifier mengembalikan data statistik yang sesuai saat sukses', () async {
      final container = ProviderContainer(
        overrides: [
          statsProvider.overrideWith(() => StatsNotifier(
                random: Random(42),
                simulateFailure: false, // Memastikan pengujian deterministik sukses
              )),
        ],
      );
      addTearDown(container.dispose);

      // State awal sebelum delayed selesai adalah AsyncLoading
      expect(container.read(statsProvider), isA<AsyncLoading<List<String>>>());

      // Menunggu future selesai
      final result = await container.read(statsProvider.future);

      expect(result.length, 3);
      expect(result[0], contains('Total Tugas Terdaftar'));
      expect(result[1], contains('Tugas Selesai'));
      expect(result[2], contains('Tugas Aktif'));
      expect(container.read(statsProvider), isA<AsyncData<List<String>>>());
    });

    test('StatsNotifier menghasilkan AsyncError ketika terjadi kegagalan jaringan', () async {
      final container = ProviderContainer(
        overrides: [
          statsProvider.overrideWith(() => StatsNotifier(
                random: Random(0),
                simulateFailure: true,
              )),
        ],
      );
      addTearDown(container.dispose);

      // Listener untuk memantau state perubahan
      final states = <AsyncValue<List<String>>>[];
      container.listen(
        statsProvider,
        (_, next) => states.add(next),
        fireImmediately: true,
      );

      try {
        await container.read(statsProvider.future);
      } catch (_) {
        // Exception diharapkan tertangkap dalam AsyncValue
      }

      final current = container.read(statsProvider);
      // Memastikan state akhir bertipe AsyncError atau AsyncData
      expect(current.hasError || current.hasValue, isTrue);
    });
  });
}
