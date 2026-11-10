# Performance Findings — Baseline Profiling

Dokumen ini mencatat temuan masalah performa pada aplikasi sebelum dilakukan langkah optimasi sesuai dengan **Langkah 2: Identifikasi Masalah** pada Praktikum Minggu 11.

---

## 1. Baseline Profiling (Sebelum Optimasi)

- **Mode Eksekusi:** `flutter run --profile`
- **Skenario Pengujian:** 
  1. Membuka halaman Catatan (`NotesPage`).
  2. Mengetik query pencarian cepat dan membersihkan query via tombol clear.
  3. Membuka halaman AI Assistant (`ChatScreen`).
  4. Menerima streaming teks AI yang memicu pembaruan state per karakter/kata secara dinamis.
  5. Melakukan scrolling pada daftar percakapan dan daftar catatan.
- **Hasil Metrik Awal:**
  - **Rata-rata Frame Time:** 24.8 ms (melebihi target 16.67 ms untuk 60 FPS).
  - **Jank Frames (Merah/Kuning):** 22 dari 120 frame uji.
  - **Top Function di Flame Chart:** `NotesPage.build` (18.2 ms), `_buildMessageBubble` (14.5 ms).
  - **Tangkapan Layar:** Tersimpan pada `screenshots/before-profile.png`.

---

## 2. Temuan Masalah Performa (Minimal 3 Masalah)

### Temuan 1: Widget Rebuild Berlebih pada Halaman Catatan (`NotesPage`)
- **Gejala:** Setiap kali pengguna mengetik satu karakter pada `TextField` pencarian, seluruh tree widget `NotesPage` dibangun ulang (rebuild) secara menyeluruh.
- **Penyebab:** Pada `NotesPage`, pembacaan provider dilakukan dengan `final query = ref.watch(searchQueryProvider);` di bagian atas method `build`. Meskipun suffix icon hanya membutuhkan informasi apakah query kosong atau tidak (`query.isNotEmpty`), seluruh widget ikut ter-rebuild pada setiap perubahan string.
- **Dampak:** Terjadi lonjakan frame time (frame kuning dan merah) saat pencarian cepat dilakukan, menyebabkan UI terasa tersendat (*lag*).

### Temuan 2: Repaint Berulang pada Subtree Chat Bubble (`ChatScreen`)
- **Gejala:** Saat pesan AI sedang streaming (menghasilkan kata demi kata secara real-time), seluruh `ListView.builder` dan elemen UI lain di sekitarnya ikut ter-repaint di thread Raster GPU.
- **Penyebab:** Chat bubble tidak diisolasi dalam layer rendering terpisah (`RepaintBoundary`) dan tidak diekstrak menjadi widget mandiri dengan *const constructor*.
- **Dampak:** Raster thread mengalami beban tinggi karena harus merasterisasi ulang seluruh canvas bubble lain yang sebenarnya tidak mengalami perubahan teks.

### Temuan 3: Rebuild Widget Indikator Loading Tanpa Isolasi (`ChatScreen`)
- **Gejala:** Widget indikator *"AI sedang mengetik..."* dibangun ulang bersamaan dengan tree utama halaman chat.
- **Penyebab:** Indikator loading ditulis langsung sebagai baris kode widget di dalam method `build` utama tanpa pemisahan kelas `const` (`StatelessWidget`).
- **Dampak:** Closure dan elemen widget baru dibuat ulang di setiap siklus frame saat state `_isLoading` diperbarui.

---

## 3. Rencana Tindakan Optimasi
1. Mengubah pembacaan query menjadi terseleksi menggunakan `ref.watch(searchQueryProvider.select((q) => q.isNotEmpty))` untuk membatasi rebuild root widget.
2. Mengekstrak `NoteItemTile` dan membungkusnya dengan `RepaintBoundary` agar repaint hanya terbatas pada item terkait.
3. Mengekstrak `ChatBubbleItem` dan membungkusnya dengan `RepaintBoundary`.
4. Mengekstrak `TypingIndicatorWidget` menjadi `const StatelessWidget`.
5. Memverifikasi pembuangan resource controller (`dispose`) pada setiap controller agar bebas memory leak.
