# Refactoring, Testing, dan Error Umum

Dokumen ini memuat catatan penyelesaian tantangan refactoring, disiplin pengujian, mitigasi error umum dalam kolaborasi tim, serta checklist verifikasi mandiri untuk proyek tengah semester (Minggu 8).

---

## 1. Refactoring Challenge

### A. Tindak Lanjut Komentar "Request Changes" Hingga Approved
* **Aturan Utama:** Tidak diperbolehkan me-merge Pull Request yang masih berstatus *Request changes*.
* **Penerapan Nyata:**
  Pada PR fitur validasi catatan (`feat/notes-validation`), reviewer sejawat memberikan 5 catatan review (2 kebenaran, 1 arsitektur, 1 test, 1 keterbacaan). Author telah menindaklanjuti seluruh temuan:
  1. *Edge case trimming:* Ditambahkan sanitasi `cleanTitle = title.trim()` pada `AddNote` usecase.
  2. *Memory leak:* Controller `_titleController` dan `_bodyController` dipindahkan ke `ConsumerStatefulWidget` (`AddNoteDialog`) dan dibersihkan via `dispose()`.
  3. *Arsitektur:* Form dialog dipisahkan dari `NotesPage` ke widget terisolasi.
  4. *Test coverage:* Ditambahkan test kegagalan repository dan batas panjang karakter.
  5. *Keterbacaan:* Warna SnackBar disesuaikan dengan tema `Theme.of(context).colorScheme.error`.
  Setelah diverifikasi ulang, status review dinaikkan menjadi **Approved** sebelum merge dilakukan.

### B. Otomatisasi Pemeriksaan Gaya Kode (Style Enforcement via CI)
* Debat spasi dan formatting tidak boleh menyita waktu code review manusia.
* Seluruh aturan perapian kode didelegasikan ke mesin otomatis:
  ```bash
  dart format --set-exit-if-changed .
  ```
* Workflow CI pada [.github/workflows/ci.yml](../../.github/workflows/ci.yml) telah diaktifkan dengan gerbang otomatis:
  ```yaml
  - run: dart format --set-exit-if-changed .
  - run: flutter analyze
  - run: flutter test
  ```
  Setiap Pull Request yang memiliki kode tidak rapi (*unformatted*) atau menghasilkan analisis linter error otomatis ditolak (*fail*) oleh CI runner sebelum dibaca reviewer.

### C. Strategi Pemecahan PR Besar (> 300 Baris) Menjadi PR Kecil
* **Prinsip:** PR berukuran > 300 baris menakutkan bagi reviewer, memperlambat proses review, dan meningkatkan risiko *merge conflict*.
* **Strategi Dekomposisi:**
  1. **PR 1 (Domain & Contracts - < 100 baris):** Penambahan usecase baru, interface repository, dan unit test logika bisnis murni.
  2. **PR 2 (Presentation & UI - < 150 baris):** Pembuatan widget form dialog, integrasi Notifier Riverpod, dan error feedback UI.
  3. **PR 3 (Automation & Docs - < 80 baris):** Konfigurasi CI workflow, dokumentasi panduan pengujian, dan screenshot.
* Masing-masing PR dapat direview secara tuntas dalam waktu < 15 menit tanpa membebani reviewer.

---

## 2. Testing: Review Tanpa Dijalankan Tidak Sah

Setiap Pull Request yang mengubah perilaku aplikasi wajib menyertakan bukti uji mesin dan langkah uji manual.

### A. Bukti Pemeriksaan Tiga Mesin (Status Hijau)
1. **Analisis Statis:**
   ```bash
   flutter analyze
   # Output: No issues found! (ran in 9.5s)
   ```
2. **Format Standar Dart:**
   ```bash
   dart format --set-exit-if-changed .
   # Output: Formatted 34 files (0 changed) in 0.36 seconds.
   ```
3. **Pengujian Otomatis (Unit & Widget Test):**
   ```bash
   flutter test
   # Output: All 17 tests passed!
   ```

### B. Panduan Pengujian Manual 5 Menit (Reproduksi & Verifikasi)
Reviewer wajib melakukan checkout ke branch terkait dan menjalankan uji manual berikut:

| Skenario Uji | Langkah Pengujian | Hasil yang Diharapkan | Status |
|:---|:---|:---|:---:|
| **1. Judul Kosong** | Buka halaman Catatan, tekan tombol `+`, biarkan judul kosong, tekan "Simpan". | Muncul SnackBar error: *"Judul catatan tidak boleh kosong"* berwarna merah tema; dialog tetap terbuka. | ✅ Lulus |
| **2. Judul Spasi Saja** | Masukkan string spasi `"     "`, tekan "Simpan". | Muncul SnackBar error: *"Judul catatan tidak boleh kosong"*; database tidak menyimpan record kosong. | ✅ Lulus |
| **3. Judul > 100 Karakter** | Masukkan teks lebih dari 100 karakter, tekan "Simpan". | Muncul SnackBar error: *"Judul catatan maksimal 100 karakter"*; data ditolak di layer use case. | ✅ Lulus |
| **4. Judul Valid & Trim** | Masukkan `"   Tugas Mobile Minggu 8   "`, tekan "Simpan". | Dialog tertutup, indikator loading selesai, catatan baru tampil rapi di ListView tanpa spasi awal/akhir. | ✅ Lulus |

Bukti tangkapan layar antarmuka tersimpan pada direktori [screenshots/](../screenshots/).

---

## 3. Error Umum dan Solusinya dalam Kolaborasi Tim

Berdasarkan pengalaman praktik dan kurikulum industri, berikut adalah 5 gejala masalah umum dalam kolaborasi pengembangan perangkat lunak serta solusinya:

| Gejala Masalah | Penyebab Umum | Solusi Nyata yang Diterapkan |
|:---|:---|:---|
| **PR 800 baris tak kunjung direview** | Banyak fitur berbeda digabungkan dalam satu Pull Request besar. | Pecah per fitur menjadi PR atomik; targetkan ukuran satu PR < 300 baris dan estimasi review < 15 menit. |
| **Konflik merge berulang (*frequent merge conflicts*)** | Branch kerja berumur panjang (> 1 minggu) dan jarang disinkronkan dengan branch utama. | Terapkan *short-lived branches* (< 3 hari) dan lakukan rebase/pull harian dari branch `develop`. |
| **Review hanya menjadi perdebatan spasi / format** | Tidak ada standarisasi formatter otomatis dan tidak ada pipeline CI. | Wajibkan eksekusi `dart format` lokal serta aktifkan CI untuk menolak PR kotor secara otomatis. |
| **PR berstatus `Approved` tetapi bug lolos ke production** | Reviewer hanya membaca kode secara visual (LGTM buta) tanpa melakukan checkout dan testing langsung. | Reviewer wajib melakukan pull branch, menjalankan `flutter test`, dan menguji langkah manual 5 menit. |
| **Saran AI merusak arsitektur aplikasi** | Rekomendasi AI coding assistant diterima mentah-mentah tanpa verifikasi arsitektural. | Terapkan verifikasi manual: tolak saran AI yang melanggar *Dependency Rule* Clean Architecture dengan argumen teknis tertulis dan bukti grep. |

---

## 4. Checklist Verifikasi Mandiri Kesiapan Proyek

Checklist akhir sebelum menyelesaikan evaluasi tengah semester:

- [x] **Branching Model:** Seluruh pekerjaan fitur berasal dari branch `develop`, menggunakan branch pendek satu tujuan (`feat/*`), dan issue ditutup otomatis via PR (`Closes #12`).
- [x] **Disiplin Peer Review:** Minimal 3 komentar review bermakna (2 kebenaran, 1 arsitektur, 1 test, 1 keterbacaan) telah ditindaklanjuti hingga status *Approved*.
- [x] **Kerapian Mesin:** `flutter analyze` bersih (0 error/warning), `dart format` rapi (exit code 0), dan `flutter test` hijau (17/17 passed).
- [x] **Dokumentasi AI:** Tabel prompt, output awal, dan usulan AI vs keputusan final terdokumentasi di [docs/ai-review-vs-keputusan.md](ai-review-vs-keputusan.md).
- [x] **Kelengkapan Portofolio:** Tersedia berkas `README.md`, folder `docs/`, `screenshots/`, dan workflow `.github/workflows/ci.yml`.
