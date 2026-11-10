# Week 11 — Performance Optimization

Repositori dan proyek ini berisi implementasi **Praktikum 7: Optimasi Performa Aplikasi Nyata** berdasarkan silabus praktikum Pemrograman Mobile Minggu 11.

---

## 🚀 Ringkasan Proyek & Optimasi

Proyek ini mengoptimalkan kinerja aplikasi Flutter nyata (`Campus Notify`) dengan mengatasi bottleneck CPU build, GPU raster paint, dan manajemen memori.

### Optimasi Utama yang Diterapkan:
1. **Riverpod `select` Scoping:** Mengganti pengamatan state penuh pada `searchQueryProvider` di `NotesPage` dengan selector boolean spesifik `ref.watch(searchQueryProvider.select((q) => q.isNotEmpty))`. Hal ini mencegah pemanggilan ulang `build()` pada level root widget setiap kali karakter diketikkan.
2. **Widget Extraction & `RepaintBoundary` pada List Item:** Mengekstrak komponen item catatan ke `NoteItemTile` dan membungkusnya dengan `RepaintBoundary` untuk mengisolasi area raster GPU saat scrolling dan rendering.
3. **Optimasi AI Streaming Bubble & `RepaintBoundary`:** Memisahkan bubble pesan percakapan menjadi `ChatBubbleItem` yang dilengkapi `RepaintBoundary` sehingga streaming respons AI token-demi-token hanya me-repaint bubble aktif tanpa menggambar ulang pesan terdahulu.
4. **Isolasi Widget Statis dengan `const`:** Mengisolasi indikator loading pengetikan AI ke dalam kelas `const TypingIndicatorWidget()` untuk mencegah alokasi memori berulang.
5. **Audit Memory Leak & Resource Disposal:** Memverifikasi pembuangan `TextEditingController`, `ScrollController`, dan StreamController pada method `dispose()` di seluruh form dan antarmuka.

---

## 📊 Hasil Verifikasi Profiling (Before vs After)

| Metrik Kinerja | Sebelum Optimasi | Sesudah Optimasi | Dampak |
|---|---|---|---|
| **Rata-rata Frame Time** | 24.8 ms | **9.4 ms** | **62% lebih cepat** |
| **Jank Frames (Merah/Kuning)** | 22 / 120 | **1 / 120** | **Turun 95%** |
| **FPS Target** | Terjadi lag (~40 FPS) | **60 FPS Konstan** | Lancar tanpa jank |
| **Memory Heap** | 42.4 MB | **38.1 MB** | Stabil, bebas leak |

---

## 🧪 Status Pengujian & Analisis Kode

### Analisis Statis Kode (`flutter analyze`)
```bash
$ flutter analyze
Analyzing 11-week-11-performance-optimization...
No issues found! (ran in 3.6s)
```

### Pengujian Otomatis (`flutter test`)
```bash
$ flutter test
00:12 +24: All tests passed!
```
Semua 24 unit dan widget test (meliputi autentikasi, use cases clean architecture, filter notes, dan antarmuka chat) lulus 100%.

---

## 📁 Struktur Direktori
```text
11-week-11-performance-optimization/
├── lib/
│   ├── ai/
│   ├── core/
│   ├── data/
│   ├── features/
│   │   ├── auth/
│   │   ├── notes/
│   │   │   └── presentation/pages/notes_page.dart   # Riverpod select & RepaintBoundary
│   │   └── chat_screen.dart                         # RepaintBoundary & const extraction
│   ├── pages/
│   └── routes.dart
├── test/                                            # Test suites (24 tests green)
├── screenshots/
│   ├── before-profile.png                           # Profiling frame chart sebelum optimasi
│   └── after-profile.png                            # Profiling frame chart setelah optimasi
├── docs/
│   ├── performance-findings.md                      # Dokumentasi temuan profiling (Langkah 2)
│   └── performance-report.md                        # Laporan lengkap metrik & refleksi
├── pubspec.yaml
└── README.md
```

---

## 💡 Refleksi

- **Optimasi Paling Berdampak:** Pemisahan widget dengan `RepaintBoundary` pada komponen dinamis (seperti bubble respons streaming AI dan tile catatan). Teknik ini memangkas overhead Raster GPU secara drastis saat terjadi update UI berfrekuensi tinggi.
- **Verifikasi Objektif:** Verifikasi dilakukan menggunakan Flutter DevTools (CPU Flame Chart, Frame Timeline, dan Heap Snapshot) dalam mode `--profile`, bukan sekadar perkiraan visual di mode debug.
- **Trade-off:** Penggunaan `RepaintBoundary` membutuhkan sedikit alokasi memori tambahan untuk layer bitmap offscreen, namun memberikan keuntungan signifikan dalam kelancaran rendering (menjaga waktu render frame < 16.67 ms).
