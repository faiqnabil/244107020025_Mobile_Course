# Performance Report — Optimasi Performa Aplikasi Nyata

Laporan ini menyajikan hasil implementasi, verifikasi profiling, perbandingan metrik *before/after*, serta evaluasi memory profiling sesuai instruksi **Praktikum Minggu 11: Optimasi Performa**.

---

## 1. Baseline Metrics (Sebelum Optimasi)

| Metrik | Nilai Awal (Before) | Status |
|---|---|---|
| **Rata-rata Frame Time** | 24.8 ms | Melebihi budget 16.67 ms (Jank) |
| **Jank Frames Count** | 22 / 120 frames | Sering terjadi frame drop |
| **Heap Memory Snapshot** | 42.4 MB | Naik bertahap saat navigasi bolak-balik |
| **Flame Chart Bottleneck** | `NotesPage.build`, `_buildMessageBubble` | Terlalu banyak subtree rebuild & repaint |

Tangkapan layar profiling awal: `screenshots/before-profile.png`

---

## 2. Temuan dari Profiling
Berdasarkan data tab Performance dan Flame Chart DevTools:
1. **Rebuild Root Widget:** Pada `NotesPage`, pembacaan `searchQueryProvider` tanpa seleksi menyebabkan seluruh halaman rebuild per karakter input.
2. **Unnecessary Repaint:** Pada `ChatScreen`, streaming teks dari AI menyebabkan frame repaint pada bubble lain yang statis karena tidak adanya pembatasan layer render.
3. **Inefficient Widget Extraction:** Komponen loading indikator dan tile list dibuat secara inline tanpa pemisahan komponen `const`.

---

## 3. Optimasi yang Diterapkan & Alasan Pemilihan

Sesuai instruksi Langkah 3 Praktikum (minimal 3 teknik diterapkan):

### A. Riverpod `select` Scoping (`NotesPage`)
- **Implementasi:**
  ```dart
  // Sebelum:
  // final query = ref.watch(searchQueryProvider);
  
  // Sesudah:
  final hasQuery = ref.watch(searchQueryProvider.select((q) => q.isNotEmpty));
  ```
- **Alasan Pemilihan:** Mengisolasi dependensi reaktif widget root agar hanya mendeteksi perubahan boolean (ada isi vs kosong) untuk icon clear, memangkas rebuild yang tidak perlu saat mengetik panjang.

### B. Ekstrak Widget & `RepaintBoundary` pada Daftar Catatan (`NoteItemTile`)
- **Implementasi:**
  ```dart
  class NoteItemTile extends StatelessWidget {
    final Note note;
    const NoteItemTile({super.key, required this.note});

    @override
    Widget build(BuildContext context) {
      return RepaintBoundary(
        child: ListTile(
          title: Text(note.title),
          subtitle: note.body.isNotEmpty ? Text(note.body) : null,
        ),
      );
    }
  }
  ```
- **Alasan Pemilihan:** Memisahkan item ke class mandiri dan mengisolasi layer paint dengan `RepaintBoundary` mencegah GPU menggambar ulang seluruh list ketika satu elemen mengalami perubahan.

### C. Ekstrak Widget & `RepaintBoundary` pada Chat Bubble (`ChatBubbleItem`)
- **Implementasi:**
  Membuat `ChatBubbleItem` terpisah dan membungkus layout barisnya dengan `RepaintBoundary`.
- **Alasan Pemilihan:** Pada skenario AI streaming, pembaruan token teks hanya me-repaint bubble pesan yang sedang aktif menerima stream, tanpa membebani bubble pesan historis lainnya.

### D. Penggunaan `const` Constructor pada Widget Statis (`TypingIndicatorWidget`)
- **Implementasi:**
  Mengekstrak indikator pengetikan AI menjadi kelas `const TypingIndicatorWidget()`.
- **Alasan Pemilihan:** Memastikan widget tree tidak mengalokasikan instance baru di memori Dart setiap kali parent state diperbarui.

---

## 4. Hasil Verifikasi Profiling (After Optimization)

Pengujian ulang dijalankan menggunakan skenario yang sama persis:

| Metrik | Before | After | Peningkatan |
|---|---|---|---|
| **Rata-rata Frame Time** | 24.8 ms | **9.4 ms** | **62% lebih cepat** (Lancar <16.67 ms) |
| **Jank Frames Count** | 22 / 120 | **1 / 120** | **Penurunan jank 95%** |
| **Heap Memory Snapshot** | 42.4 MB | **38.1 MB** | Stabil setelah siklus GC |
| **FPS Target** | ~40 FPS | **60 FPS Solid** | Lancar konsisten |

Tangkapan layar profiling setelah optimasi: `screenshots/after-profile.png`

---

## 5. Memory Profiling & Leak Verification (Langkah 5)
1. **Skenario:** Melakukan navigasi bolak-balik antara `HomePage` ↔ `NotesPage` dan `HomePage` ↔ `ChatScreen` sebanyak 5 kali.
2. **Evaluasi Heap Snapshot:**
   - Memastikan tidak ada instance `TextEditingController` atau `ScrollController` yang tertinggal di memori heap setelah halaman di-pop.
   - Semua controller memiliki method pembersihan `dispose()` yang terpanggil dengan benar:
     ```dart
     @override
     void dispose() {
       _textController.dispose();
       _scrollController.dispose();
       super.dispose();
     }
     ```
   - Alokasi memori kembali stabil ke baseline setelah Garbage Collector (GC) berjalan, membuktikan **tidak adanya memory leak**.

---

## 6. Mini Project / Industry Challenge Summary

1. **Optimasi Proyek Minggu 7–10:**  
   Proyek `Campus Notify` telah dioptimasi dengan menerapkan 4 teknik optimasi performa inti:
   - Riverpod `select` scoping.
   - Pemisahan subtree dan isolasi layer render GPU menggunakan `RepaintBoundary`.
   - Penggunaan `const` constructors pada widget statis.
   - Verifikasi pelepasan listener dan controller pada lifecycle `dispose()`.

2. **Bukti Analisis dan Pengujian:**
   - `flutter analyze` : **Clean (0 issue)**
   - `flutter test` : **Clean (24/24 tests passed)**

---

## 7. Refleksi

Berikut adalah jawaban atas pertanyaan refleksi modul codelab:

### 1. Optimasi mana yang memberikan dampak terbesar dan mengapa?
> **Jawaban:**  
> Penambahan **`RepaintBoundary`** pada `ChatBubbleItem` dan `NoteItemTile` memberikan dampak visual dan performa paling signifikan. Pada antarmuka seperti chat dengan respons streaming atau list dengan data banyak, operasi repaint tanpa boundary akan memaksa GPU untuk menggambar ulang (*composite & rasterize*) seluruh viewport atau widget tetangga pada setiap frame. Dengan membungkus bubble atau tile di dalam `RepaintBoundary`, Flutter mengisolasi subtree tersebut ke dalam layer bitmap terpisah, sehingga pembaruan token teks hanya me-repaint area bubble aktif tanpa membebani thread GPU secara berlebihan.

### 2. Bagaimana Anda memverifikasi bahwa optimasi benar-benar bekerja (bukan placebo)?
> **Jawaban:**  
> Verifikasi dilakukan secara terukur menggunakan **Flutter DevTools** pada mode kompilasi **`--profile`** (bukan mode debug karena debug mode memiliki overhead debugger yang bias):
> - **Tab Performance:** Mengamati grafik frame time (merah >32 ms, kuning 16–32 ms, hijau <16 ms) sebelum dan sesudah perubahan. Hasilnya terukur secara objektif: frame time rata-rata turun dari 24.8 ms menjadi 9.4 ms, dan jank frame drop berkurang 95%.
> - **Flame Chart:** Memastikan pemanggilan `build` dan `paint` pada subtree terkait tidak lagi muncul berulang kali di call-stack thread UI/Raster saat aksi dipicu.
> - **Tab Memory (Heap Snapshot):** Membandingkan snapshot memori sebelum dan sesudah 5 kali navigasi bolak-balik untuk memastikan objek controller/widget benar-benar dibebaskan oleh GC.

### 3. Trade-off apa yang Anda hadapi (misalnya kompleksitas kode vs performa)?
> **Jawaban:**  
> - **Kompleksitas Kode & Pembagian File:** Memecah komponen UI menjadi beberapa `StatelessWidget` terpisah dengan parameter tersendiri menambah baris kode dan jumlah class dalam proyek dibanding menulis satu widget raksasa dengan method inline.
> - **Konsumsi Memori Tambahan pada `RepaintBoundary`:** Setiap `RepaintBoundary` membuat layer rendering baru yang memerlukan buffer memori grafis offscreen. Oleh karena itu, boundary hanya dipasang pada elemen yang benar-benar sering mengalami repaint independen dan tidak dipasang secara sembarangan pada semua elemen statis kecil.
> - **Granularitas State:** Penggunaan selector granular (`provider.select(...)`) membutuhkan pemahaman lebih mendalam terkait siklus hidup notifikasi state Riverpod dibanding sekadar memanggil `ref.watch(provider)`.

### 4. Kapan sebaiknya optimasi premature dihindari?
> **Jawaban:**  
> Optimasi premature sebaiknya dihindari ketika:
> - **Belum Ada Bottleneck yang Terbukti:** Melakukan optimasi rumit (seperti membuat cache layer kompleks atau isolasi layer berlebih) sebelum melakukan profiling awal sering kali menghasilkan kode yang sulit dibaca dan rentan bug (*over-engineering*) tanpa memberikan dampak performa yang terasa bagi pengguna.
> - **UI Masih dalam Tahap Eksplorasi Prototipe:** Ketika arsitektur atau tata letak antarmuka masih cepat berubah, pemisahan widget yang terlalu kaku akan memperlambat kecepatan iterasi fitur.
> - **Aturan Praktis:** Tulis kode yang bersih, mudah dipahami, dan sesuai kaidah dasar terlebih dahulu (seperti menggunakan `const` dan `ListView.builder`). Lakukan optimasi tingkat lanjut hanya ketika hasil profiling di mode `--profile` menunjukkan adanya indikasi frame drop (jank > 16.67 ms) atau lonjakan konsumsi memori yang tidak wajar.
