# Skenario Pengujian Fitur Tugas (Praktikum Minggu 12)

Dokumen ini mencatat rancangan skenario pengujian untuk fitur tugas sesuai dengan **Langkah 1: Catat perilaku** pada praktikum Minggu 12.

---

## 1. Perilaku yang Diuji

Pengujian difokuskan pada fitur pengelolaan tugas (`NotesPage`, `AddNote`, dan `isValidTaskTitle`). Pengujian mencakup alur positif, validasi batas (kasus tepi), dan penanganan error sistem.

---

## 2. Rincian Skenario Pengujian

### Skenario 1: Validasi Masukan Judul Tugas (Kasus Tepi)
- **Kategori:** Unit Testing (`test/is_valid_task_title_test.dart` & `test/task_dependency_test.dart`).
- **Deskripsi:** Sistem harus memastikan judul tugas berisi teks yang bermakna dan bukan sekadar spasi kosong atau whitespace.
- **Langkah Pengujian:**
  1. Masukkan string kosong `""`.
  2. Masukkan string yang hanya berisi spasi `"   "` atau karakter newline/tab `"\t\n"`.
  3. Masukkan string yang diawali dan diakhiri spasi namun memiliki karakter `"   Kerjakan Modul 12   "`.
- **Hasil yang Diharapkan:**
  - Input kosong dan spasi ditolak (`false` / melempar `LocalFailure`).
  - Input dengan teks valid diterima (`true`).

### Skenario 2: Penanganan Kegagalan Akses Sumber Data (Kasus Kegagalan)
- **Kategori:** Dependency Testing dengan Fake Repository (`test/task_dependency_test.dart` & `test/task_ui_test.dart`).
- **Deskripsi:** Ketika sumber data (database lokal atau API) gagal membaca atau menyimpan data, aplikasi tidak boleh mengalami force close / unhandled exception.
- **Langkah Pengujian:**
  1. Konfigurasikan `FakeNoteRepository` dengan `Failure` (misal: `"Database disk error"`).
  2. Panggil fungsi `getNotes()` atau render antarmuka `NotesPage`.
- **Hasil yang Diharapkan:**
  - Layer domain use case mengembalikan failure secara aman.
  - Layer UI menampilkan pesan error yang ramah pengguna beserta tombol **"Coba Lagi"**.

### Skenario 3: Penambahan Tugas Baru Berhasil (Alur Utama / Kasus Sukses)
- **Kategori:** Widget Test & Integration Test (`test/task_ui_test.dart` & `integration_test/app_test.dart`).
- **Deskripsi:** Pengguna membuka dialog penambahan tugas, memasukkan judul tugas yang valid, menekan tombol simpan, dan melihat tugas baru muncul di daftar tugas.
- **Langkah Pengujian:**
  1. Render halaman `NotesPage` (verifikasi empty state `"Tidak ada catatan."`).
  2. Tekan FloatingActionButton dengan key `add-task-fab`.
  3. Masukkan teks `"Selesaikan modul praktikum 12"` pada field dengan key `task-title-field`.
  4. Tekan tombol Simpan dengan key `save-task-button`.
- **Hasil yang Diharapkan:**
  - Dialog tertutup secara otomatis.
  - Item dengan teks `"Selesaikan modul praktikum 12"` ter-render dengan benar pada daftar tugas di UI.
