import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// AsyncNotifier untuk mengelola pengambilan data statistik secara asinkron (AI Challenge)
class StatsNotifier extends AsyncNotifier<List<String>> {
  final Random _random;
  final bool _simulateFailure;

  StatsNotifier({Random? random, this._simulateFailure = true})
      : _random = random ?? Random();

  @override
  Future<List<String>> build() async {
    return _fetchStats();
  }

  /// Mensimulasikan pengambilan data statistik dengan delay 2 detik
  /// dan kemungkinan gagal 30% bila fitur simulasi kegagalan aktif.
  Future<List<String>> _fetchStats() async {
    await Future.delayed(const Duration(seconds: 2));

    if (_simulateFailure && _random.nextDouble() < 0.3) {
      throw Exception('Gagal memuat statistik dari server (koneksi terputus).');
    }

    return [
      'Total Tugas Terdaftar: 10 Tugas',
      'Tugas Selesai (Completed): 7 Tugas (70%)',
      'Tugas Aktif (Pending): 3 Tugas (30%)',
    ];
  }

  /// Method refresh untuk memuat ulang data dengan penanganan AsyncLoading & AsyncValue.guard
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchStats());
  }
}

/// Provider global untuk data statistik
final statsProvider =
    AsyncNotifierProvider<StatsNotifier, List<String>>(StatsNotifier.new);
