# Dokumentasi AI Challenge — Week 3: Navigation & State Management

**Mahasiswa:** Muhammad Faiq Nabil Saputra  
**NIM:** 244107020025  
**Kelas/Prodi:** TI-3D / D4 Teknik Informatika  

---

## 1. Prompt yang Digunakan
Sesuai instruksi pada modul codelab Minggu 3, prompt yang diberikan kepada AI coding assistant adalah sebagai berikut:

```text
Buatkan halaman Flutter bernama StatsPage menggunakan flutter_riverpod.
Requirements:
- ConsumerWidget dengan satu AsyncNotifierProvider yang mensimulasikan
  pengambilan data statistik (delay 2 detik, kadang gagal 30%).
- UI harus menangani loading (spinner), error (pesan + tombol retry),
  dan success (ListView 3 item).
- Berikan unit test untuk notifier-nya.
Jelaskan setiap bagian kode dalam komentar.
```

---

## 2. Output Awal AI (Initial Draft)

```dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// AsyncNotifier untuk mengelola data statistik
class StatsNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() async {
    await Future.delayed(const Duration(seconds: 2));
    if (Random().nextDouble() < 0.3) {
      throw Exception('Koneksi terputus');
    }
    return [
      'Total Tugas: 10',
      'Tugas Selesai: 7',
      'Tugas Pending: 3',
    ];
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await Future.delayed(const Duration(seconds: 2));
      return [
        'Total Tugas: 10',
        'Tugas Selesai: 7',
        'Tugas Pending: 3',
      ];
    });
  }
}

final statsProvider = AsyncNotifierProvider<StatsNotifier, List<String>>(StatsNotifier.new);

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistik')),
      body: stats.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error: $err'),
              ElevatedButton(
                onPressed: () => ref.refresh(statsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (data) => ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, i) => ListTile(title: Text(data[i])),
        ),
      ),
    );
  }
}
```

---

## 3. AI Verification Checklist & Temuan Evaluasi

| Kriteria Verifikasi | Status | Catatan / Temuan Evaluasi |
|:---|:---:|:---|
| **Immutability State** | ✅ Lolos | State berupa list baru dan tidak dimutasi langsung (`state.add()` dihindari). |
| **Penggunaan `ref.watch` vs `ref.read`** | ⚠️ Diperbaiki | `ref.watch` dipakai di `build()`, namun tombol retry menggunakan `ref.refresh` usang alih-alih `ref.invalidate(statsProvider)` atau memanggil `ref.read(statsProvider.notifier).refresh()`. |
| **AsyncValue State Coverage** | ✅ Lolos | Seluruh 3 state (`loading`, `error`, `data`) ditangani secara eksplisit menggunakan `.when(...)`. |
| **Deklarasi Provider Eksplisit** | ✅ Lolos | Tipe dideklarasikan secara eksplisit: `AsyncNotifierProvider<StatsNotifier, List<String>>`. |
| **Riverpod Modern API Compliance** | ⚠️ Diperbaiki | Output awal mencampurkan logika delay di `refresh()` yang menduplikasi kode pemanggilan API. Pola diperbaiki dengan delegasi method `_fetchStats()` tunggal dan `AsyncValue.guard`. |
| **Clean Analysis & Testing** | ⚠️ Diperbaiki | Kode awal menghasilkan peringatan deprecation (`withOpacity` diganti `.withValues()`) dan kurang mendukung pengujian deterministik pada unit test karena `Random()` tidak dapat diinjeksi. |

---

## 4. Perbaikan & Refactoring yang Dilakukan

1. **Dependency Injection untuk Pengujian Deterministik:**
   - Menambahkan parameter opsional `Random? random` dan `bool simulateFailure = true` pada constructor `StatsNotifier`. Hal ini memungkinkan pengujian unit test mensimulasikan skenario sukses maupun gagal secara pasti tanpa *flaky test*.
2. **Penggunaan API Modern Material 3 & Riverpod:**
   - Mengganti `ElevatedButton` dengan `FilledButton.icon`.
   - Menggunakan `ref.invalidate(statsProvider)` untuk mereset dan memicu `build()` notifier secara bersih.
   - Mengganti styling transparan usang `withOpacity()` dengan `withValues(alpha: 0.15)`.
3. **Penyempurnaan Unit Test:**
   - Menyusun 2 skenario unit test terpisah menggunakan `ProviderContainer` dan `overrideWith` untuk menguji kondisi sukses (`AsyncData`) dan kondisi gagal (`AsyncError`).

---

## 5. Keputusan Teknis (*Technical Rationale*)
- **Mengapa `AsyncNotifier` dipilih dibanding `FutureProvider`?**  
  `AsyncNotifier` memungkinkan penambahan method bisnis (`refresh()`, mutasi state) langsung di dalam class notifier, menjaga kode tetap terenkapsulasi dan mudah dipelihara seiring bertambahnya fitur.
- **Mengapa `ref.invalidate` lebih disukai dibanding membuat instance baru?**  
  `ref.invalidate` menandai provider sebagai *stale* dan Riverpod secara otomatis mengeksekusi ulang fungsi `build()` pada frame berikutnya, memastikan siklus hidup widget dan listener tetap sinkron.
