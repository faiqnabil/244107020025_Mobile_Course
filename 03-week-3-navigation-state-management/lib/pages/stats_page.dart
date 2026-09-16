import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/stats_provider.dart';

/// Halaman StatsPage menggunakan ConsumerWidget untuk menampilkan data statistik.
/// Widget ini mendengarkan statsProvider yang bertipe AsyncNotifierProvider.
class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Memantau state AsyncValue dari statsProvider di dalam method build.
    // Riverpod akan me-rebuild widget ini setiap kali status async berubah (loading, data, error).
    final statsAsync = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistik ToDo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Segarkan Data',
            // Di dalam event callback, gunakan ref.read untuk memanggil method notifier tanpa berlangganan
            onPressed: () => ref.read(statsProvider.notifier).refresh(),
          ),
        ],
      ),
      // AsyncValue.when menangani ketiga kemungkinan state: loading, error, dan success (data).
      body: statsAsync.when(
        // State 1: Loading - Menampilkan indikator progress melingkar di tengah layar.
        loading: () => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Memuat data statistik...',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),

        // State 2: Error - Menampilkan pesan error dan tombol Coba lagi (retry) menggunakan ref.invalidate.
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.redAccent,
                  size: 56,
                ),
                const SizedBox(height: 12),
                Text(
                  'Gagal memuat statistik:\n$err',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () {
                    // ref.invalidate mereset provider sehingga build() pada notifier dieksekusi ulang
                    ref.invalidate(statsProvider);
                  },
                  icon: const Icon(Icons.replay),
                  label: const Text('Coba lagi'),
                ),
              ],
            ),
          ),
        ),

        // State 3: Success - Menampilkan ListView berisi 3 item statistik ringkasan.
        data: (stats) => RefreshIndicator(
          onRefresh: () => ref.read(statsProvider.notifier).refresh(),
          child: ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: stats.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final icons = [
                Icons.assignment_outlined,
                Icons.check_circle_outline,
                Icons.hourglass_top_outlined,
              ];
              final colors = [
                Colors.indigo,
                Colors.teal,
                Colors.orange,
              ];

              return Card(
                elevation: 1,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        colors[index % colors.length].withValues(alpha: 0.15),
                    foregroundColor: colors[index % colors.length],
                    child: Icon(icons[index % icons.length]),
                  ),
                  title: Text(
                    stats[index],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('Data tersinkronisasi dengan server lokal'),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
