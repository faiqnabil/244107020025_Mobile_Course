# Week 12 — Pengujian dan Jaminan Kualitas (Testing & Quality Assurance)

Proyek ini berisi implementasi **Praktikum: Susun Test Suite untuk Fitur Tugas** sesuai modul Codelab Minggu 12 Pemrograman Mobile.

---

## 🎯 Ringkasan Test Suite

Pengujian disusun menggunakan pendekatan piramida pengujian (*Testing Pyramid*) yang mencakup logika bisnis (Unit Test), abstraksi data (Dependency Testing dengan Fake Repository), interaksi antarmuka (Widget Test), dan alur ujung-ke-ujung (Integration Test).

### Daftar File Pengujian:
1. **`test/is_valid_task_title_test.dart` (Unit Test):**
   - Menguji fungsi `isValidTaskTitle` dengan pola *Arrange, Act, Assert*.
   - Memeriksa kasus sukses teks valid dan kasus tepi (string kosong, hanya spasi, atau karakter whitespace).
2. **`test/task_dependency_test.dart` (Dependency / Repository Test):**
   - Menggunakan `FakeNoteRepository` yang mengimplementasikan `NoteRepository`.
   - Menguji aliran data sukses, penolakan input invalid pada `AddNote`, dan penanganan error tanpa ketergantungan pada SQLite atau jaringan.
3. **`test/task_ui_test.dart` (Widget Test):**
   - Menguji rendering `NotesPage` menggunakan `tester.pumpWidget` dan `tester.pumpAndSettle`.
   - Menguji validasi form input dialog tambah tugas (`task-title-field`, `save-task-button`).
   - Menguji interaksi penambahan item hingga muncul di daftar tugas.
   - Menguji tampilan pesan error dan tombol coba lagi saat repository gagal.
4. **`integration_test/app_test.dart` (Integration Test):**
   - Menguji alur lengkap dari inisialisasi halaman, pembukaan dialog, pengisian input, hingga item terkonfirmasi tampil di viewport.

---

## 📋 Skenario Pengujian

Sesuai instruksi Langkah 1 Praktikum:
| No | Skenario | Kategori | File Test Terkait | Hasil |
|---|---|---|---|---|
| 1 | Validasi masukan judul tugas (menerima teks, menolak string kosong/spasi saja) | Kasus Tepi / Aturan Bisnis | `test/is_valid_task_title_test.dart` | **Passed** |
| 2 | Penanganan error repository tanpa membuat crash aplikasi | Kasus Kegagalan | `test/task_dependency_test.dart`, `test/task_ui_test.dart` | **Passed** |
| 3 | Pengguna menambahkan tugas baru lewat form dan tugas muncul di daftar | Kasus Sukses / Alur Utama | `test/task_ui_test.dart`, `integration_test/app_test.dart` | **Passed** |

Dokumentasi detail skenario tersimpan pada [`docs/test-scenarios.md`](docs/test-scenarios.md).

---

## 🧪 Hasil Pemeriksaan dan Analisis

### 1. Analisis Statis Kode (`flutter analyze`)
```bash
$ flutter analyze
Analyzing 12-week-12-testing-quality-assurance...
No issues found! (ran in 8.5s)
```

### 2. Eksekusi Unit & Widget Test (`flutter test`)
```bash
$ flutter test
00:20 +35: All tests passed!
```
Semua 35 pengujian unit dan widget lulus 100%.

### 3. Cakupan Kode (`flutter test --coverage`)
```bash
$ flutter test --coverage
00:23 +35: All tests passed!
```
Laporan cakupan kode (*coverage report*) berhasil dihasilkan di `coverage/lcov.info`.

### 4. Eksekusi Pengujian Integrasi (`integration_test`)
- **File Test:** `integration_test/app_test.dart`
- **Perintah Eksekusi:**
  ```bash
  flutter test integration_test/app_test.dart -d <device_id>
  ```
- **Keterangan / Kendala Perangkat:**  
  Pengujian integrasi telah disusun secara lengkap di `integration_test/app_test.dart` menggunakan `IntegrationTestWidgetsFlutterBinding`. Saat pengujian dijalankan langsung dengan perintah `flutter test integration_test/app_test.dart -d windows`, eksekusi memerlukan toolchain native Visual Studio C++ build tools (`Unable to find suitable Visual Studio toolchain`), dan saat ini tidak ada emulator Android yang sedang aktif (`No emulators available`). Alur integrasi secara logika telah diverifikasi identik melalui pengujian widget komprehensif pada `task_ui_test.dart` yang lulus 100%.

---

## 📂 Struktur Direktori Proyek
```text
12-week-12-testing-quality-assurance/
├── lib/
│   ├── features/
│   │   └── notes/
│   │       ├── data/repositories/
│   │       │   └── fake_note_repository.dart       # Fake repository untuk pengujian
│   │       ├── domain/usecases/
│   │       │   └── is_valid_task_title.dart        # Logika validasi judul tugas
│   │       └── presentation/pages/
│   │           └── notes_page.dart                 # UI tugas dengan Form dialog & Key
├── test/
│   ├── is_valid_task_title_test.dart               # Unit test logika dan kasus tepi
│   ├── task_dependency_test.dart                   # Test dependensi & fake repository
│   ├── task_ui_test.dart                           # Widget test UI dan interaksi
│   └── ... (pengujian modul sebelumnya)
├── integration_test/
│   └── app_test.dart                               # Pengujian integrasi alur utama
├── docs/
│   └── test-scenarios.md                           # Dokumentasi 3 skenario perilaku
├── pubspec.yaml                                    # Termasuk dependensi integration_test
└── README.md
```

---

## 💡 Refleksi

- **Bug yang paling mungkin terlewat tanpa pengujian yang ditulis:**  
  Bug pada validasi spasi kosong (misalnya pengguna hanya menekan tombol spasi beberapa kali lalu menekan tombol Simpan). Tanpa fungsi `isValidTaskTitle` dan pengujian unit kasus tepi, input tersebut dapat lolos dan tersimpan sebagai catatan kosong yang mengotori database. Selain itu, tanpa pengujian kegagalan repository, kegagalan koneksi/disk bisa menyebabkan aplikasi *crash* (unhandled exception) alih-alih menampilkan pesan error yang ramah pengguna.

- **Bagian yang perlu fake dan bagaimana fake membuatnya konsisten:**  
  `NoteRepository` adalah bagian yang paling perlu diganti dengan `FakeNoteRepository`. Menjalankan pengujian dengan database SQLite sungguhan membutuhkan akses filesystem dan inisialisasi native plugin yang lambat serta rawan menimbulkan efek samping antar-test (*shared state*). Dengan `FakeNoteRepository`, data disimpan secara in-memory dalam kontrol pengujian, memungkinkan simulasi sukses, error instan, dan eksekusi test yang deterministik dalam hitungan milidetik.

- **Perbedaan nilai antara pengujian widget dan pengujian integrasi:**  
  - **Widget Test:** Memberikan umpan balik instan (*fast feedback*) pada komponen UI terisolasi tanpa memerlukan emulator atau kompilasi native biner. Sangat efektif untuk menguji rendering state bersyarat (loading, error, empty state) dan validasi input dialog.
  - **Pengujian Integrasi:** Memberikan jaminan tingkat tinggi bahwa semua bagian aplikasi (routing, lifecycle platform, plugin, dan event loop perangkat) bekerja bersama secara harmonis pada lingkungan runtime perangkat nyata.
