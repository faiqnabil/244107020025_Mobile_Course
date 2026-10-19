# Review Checklist & Git Hygiene Audit

Dokumen ini memuat catatan audit riwayat Git, perbaikan commit, dan checklist review untuk proyek tengah semester (Minggu 8).

---

## Praktikum 1: Hygiene Branch dan Commit

### 1. Audit Riwayat Git

Berdasarkan pemeriksaan riwayat pada repositori proyek Minggu 5–7:

#### A. Perintah Audit yang Dijalankan
```bash
git log --oneline -15
git branch -a
git status
```

#### B. Hasil Output Audit
* **15 Commit Terakhir (`git log --oneline -15`):**
  ```text
  1f4dd8b (HEAD -> feat/notes-validation, origin/feat/notes-validation) feat(notes): validasi judul kosong + test
  0289497 (origin/main, origin/develop, main, develop) docs: update week 6 reflections and portfolio summary
  440bb30 feat(week7): complete clean architecture implementation and tests
  a62a3d4 docs: complete Praktikum 1 layer audit and target architecture setup
  8b86ca3 chore: snapshot before clean architecture
  1f9cc79 Praktikum Pertemuan 6
  7f8dbd2 Pertemuan 5B
  08e0c5f Pertemuan 5
  998afa2 Pertemuan 5
  5e1f289 Menambahkan Dokumentasi
  4c504de Praktikum Pertemuan 5
  ac54d79 Praktikum Pertemuan 4
  2e97311 Praktikum Pertemuan 16
  902a171 Praktikum Pertemuan 15
  1a0ea26 Praktikum Pertemuan 14
  ```

* **Daftar Branch Awal (`git branch -a`):**
  ```text
  * main
    remotes/origin/main
  ```

* **Status Working Directory (`git status`):**
  Terdapat file tak terlacak (`untracked files`) seperti `devtools_options.yaml` di subfolder yang belum dimasukkan ke `.gitignore`.

#### C. Masalah yang Teridentifikasi
1. **Commit Langsung ke `main`:** Semua riwayat commit sebelumnya (Minggu 1 s.d. 7) langsung di-*push* ke branch `main` tanpa isolasi branch `develop` maupun `feature/*`.
2. **Pesan Commit Buruk / Non-Konvensional:** Sebagian besar commit terdahulu menggunakan pesan non-deskriptif seperti `Praktikum Pertemuan 6`, `Pertemuan 5B`, `Pertemuan 5`, `Menambahkan Dokumentasi`. Pesan tersebut tidak menjelaskan *apa* yang diubah, *di modul mana* perubahannya, dan *tipe perubahan* apa yang dilakukan (`feat`, `fix`, `docs`, `refactor`).
3. **Absennya Git Flow Branching:** Tidak terdapat branch `develop` sebagai cabang integrasi fitur sebelum masuk ke `main`.
4. **File Tak Terlacak:** File konfigurasi lokal seperti `devtools_options.yaml` belum terkelola oleh `.gitignore`.

---

### 2. Pembuatan Branch Kerja yang Benar

Mengikuti standar Git Flow dan aturan kebersihan branch:
1. **Inisialisasi `develop`:** Dibuat branch `develop` dari `main` dan dipush ke remote origin (`git checkout -b develop && git push -u origin develop`). Setelah ini `main` dilindungi dan tidak menerima commit langsung.
2. **Pembuatan Feature Branch:** Dibuat branch fitur pendek dari `develop`:
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b feat/notes-validation
   ```
3. **Implementasi Perubahan Kecil (Satu Perubahan Logis):**
   - Menambahkan validasi judul kosong pada use case `AddNote` (`07-week-7-clean-architecture/lib/features/notes/domain/usecases/add_note.dart`).
   - Menyediakan provider `addNoteProvider` di `notes_providers.dart`.
   - Mengintegrasikan dialog input catatan pada UI `notes_page.dart` dengan feedback SnackBar merah jika judul kosong.
   - Menyusun unit test validasi pada `07-week-7-clean-architecture/test/validate_note_test.dart`.
4. **Commit Atomik dan Push:**
   ```bash
   git add <file-terkait>
   git commit -m "feat(notes): validasi judul kosong + test"
   git push -u origin feat/notes-validation
   ```

---

### 3. Simulasi Perbaikan Commit Buruk

Tabel berikut menunjukkan penulisan ulang 3 pesan commit lama dari riwayat proyek ke format konvensional (`tipe(scope): deskripsi singkat`) beserta alasan perbaikannya:

| Hash Commit | Pesan Lama (Sebelum) | Format Konvensional (Sesudah) | Alasan Perbaikan |
|:---|:---|:---|:---|
| `1f9cc79` | `Praktikum Pertemuan 6` | `feat(auth): implementasi otentikasi token store dan fcm push notification + test` | Pesan lama hanya menyebutkan nama pertemuan perkuliahan tanpa konteks teknis. Format baru menjelaskan tipe `feat`, scope modul `auth`, penambahan token store aman, integrasi notifikasi FCM, dan kelengkapan pengujian. |
| `4c504de` | `Praktikum Pertemuan 5` | `feat(notes): implementasi penyimpanan lokal sqflite dan sinkronisasi offline-first + test` | Pesan lama sangat umum dan tidak menunjukkan fitur yang ditambahkan. Format baru menegaskan penambahan SQLite untuk persistensi lokal dan queue sinkronisasi offline-first pada modul catatan. |
| `5e1f289` | `Menambahkan Dokumentasi` | `docs(notes): lengkapi panduan pengujian dan screenshot modul offline-first` | Pesan lama tidak menjelaskan dokumentasi apa dan untuk modul mana yang diperbarui. Format baru memperjelas tipe `docs`, scope `notes`, serta isi pembaruan pada README. |

---

## Praktikum 2: PR dan Peer Review

### 1. Template Pull Request

Pull Request dibuat dari branch `feat/notes-validation` menuju branch target `develop` dengan spesifikasi berikut:

* **Judul:** `feat(notes): validasi judul kosong + test`
* **Target Branch:** `develop` &larr; `feat/notes-validation`
* **Deskripsi PR:**
  ```markdown
  ### Masalah
  Pengguna sebelumnya dapat menyimpan catatan tanpa judul, atau dengan judul yang hanya berisi spasi kosong, sehingga menyebabkan data kosong pada tampilan list catatan.

  ### Solusi
  1. Validasi string kosong (`isEmpty`) dan pemangkasan whitespace (`trim()`) pada Domain Use Case `AddNote`.
  2. Menyediakan state provider `addNoteProvider` untuk dependency injection yang rapi.
  3. Menampilkan dialog form input catatan terisolasi (`AddNoteDialog`) dengan visual feedback pesan error via SnackBar jika judul kosong.
  4. Penyusunan unit test komprehensif pada `validate_note_test.dart`.

  ### Cara Uji
  1. Jalankan aplikasi, buka halaman Catatan, tekan tombol FAB `+`.
  2. Biarkan judul kosong dan tekan Simpan &rarr; Muncul SnackBar error: "Judul catatan tidak boleh kosong".
  3. Masukkan judul valid dan tekan Simpan &rarr; Dialog tertutup dan catatan baru tampil di daftar.
  4. Jalankan pengujian otomatis:
     ```bash
     flutter test test/validate_note_test.dart
     ```

  Closes #12
  ```

---

### 2. Peer Code Review (Putaran 1)

* **Reviewer:** Peer Reviewer (Pair Programming Partner)
* **Status Keputusan Awal:** ⚠️ **Request changes**

Setiap komentar review dirumuskan menggunakan pola standar industri: **Observasi &rarr; Dampak &rarr; Usulan Konkret**.

#### Tabel Temuan Peer Review
| No | Kategori | Observasi | Dampak | Usulan Konkret | Status |
|:---|:---|:---|:---|:---|:---|
| 1 | **Kebenaran (Edge Case)** | `AddNote` usecase memvalidasi `title.trim().isEmpty`, namun data yang diteruskan ke `_repository.addNote` masih berupa raw string `title` dan `body`. | Judul yang diawali/diakhiri banyak spasi (`"   Catatan   "`) tetap tersimpan kotor ke database SQLite. | Lakukan normalisasi string dengan `final cleanTitle = title.trim();` dan teruskan `cleanTitle` serta `body.trim()` ke repository. | ✅ Resolved |
| 2 | **Kebenaran (Memory Leak)** | Controller `titleController` dan `bodyController` diinisialisasi lokal di dalam helper method tanpa pemanggilan `dispose()`. | Terjadi kebocoran memori (*memory leak*) setiap kali pengguna membuka dan menutup dialog tambah catatan. | Ekstraksi dialog menjadi `ConsumerStatefulWidget` terpisah (`AddNoteDialog`) dan override method `dispose()` untuk membersihkan controller. | ✅ Resolved |
| 3 | **Arsitektur (Separation of Concerns)** | UI dialog input terpasang langsung di dalam `notes_page.dart` yang seharusnya hanya fokus menampilkan daftar catatan. | Melanggar *Single Responsibility Principle* dan menyulitkan pengujian widget dialog secara terisolasi. | Pisahkan widget dialog form ke kelas komponen tersendiri (`AddNoteDialog`) agar stateless/stateful terisolasi dan mudah di-maintain. | ✅ Resolved |
| 4 | **Test (Coverage & Failure Path)** | Berkas `validate_note_test.dart` baru menguji skenario sukses dan validasi judul kosong lokal, belum menguji skenario ketika repository mengembalikan `LocalFailure`. | Jika terjadi error pada layer data/database, penanganan failure di usecase tidak terverifikasi oleh test runner. | Tambahkan test case `meneruskan failure dari repository tanpa melempar exception` menggunakan stub repository dengan `fail: true`. | ✅ Resolved |
| 5 | **Keterbacaan & UI/UX** | Notifikasi SnackBar error menggunakan warna hardcoded `Colors.red` dan menutupi navigasi bawah. | Tampilan tidak adaptif dengan tema aplikasi (*Dark Mode / Light Mode*) dan kurang ergonomis. | Gunakan `Theme.of(context).colorScheme.error` untuk warna background dan tambahkan `behavior: SnackBarBehavior.floating`. | ✅ Resolved |

---

### 3. Tindak Lanjut dan Perbaikan oleh Author

Author melakukan perbaikan menyeluruh berdasarkan 5 catatan peer review:
1. **Refactor Use Case (`AddNote`):**
   - Menambahkan sanitasi string dengan `cleanTitle = title.trim()` dan `body.trim()` sebelum memanggil repository.
2. **Refactor Dialog Widget (`AddNoteDialog`):**
   - Mengubah dialog menjadi `ConsumerStatefulWidget`.
   - Mengelola lifecycle `_titleController` dan `_bodyController` dengan benar melalui `initState()` dan `dispose()`.
   - Menerapkan error feedback menggunakan `Theme.of(context).colorScheme.error` dan `SnackBarBehavior.floating`.
3. **Penyempurnaan Unit Test (`validate_note_test.dart`):**
   - Menambahkan pengujian pemangkasan leading & trailing whitespace.
   - Menambahkan pengujian failure propagation dari repository tiruan.
4. **Commit Tindak Lanjut:**
   ```bash
   git commit -m "fix(notes): terapkan saran peer review untuk sanitasi input, lifecycle controller, dan failure test"
   git push origin feat/notes-validation
   ```

---

### 4. Re-Review & Keputusan Akhir

* **Reviewer:** Peer Reviewer
* **Hasil Verifikasi:**
  - Seluruh 5 poin perbaikan telah diverifikasi langsung pada kode.
  - Perintah `flutter test test/validate_note_test.dart` dijalankan: **4 of 4 tests passed**.
  - Perintah `flutter analyze` dijalankan: **No issues found**.
* **Keputusan Akhir:** ✅ **Approve**

---

### 5. Prosedur Merge dan Penutupan Issue

Setelah status PR berubah menjadi **Approved** dan lolos verifikasi otomatis:
1. Merge branch `feat/notes-validation` ke `develop`.
2. Issue `#12` tertutup secara otomatis melalui kata kunci `Closes #12`.
3. Branch `feat/notes-validation` dihapus setelah di-merge untuk menjaga kebersihan daftar branch.

---

## Praktikum 3: Static Analysis dan Mid Review

### 1. Pembersihan dengan Tiga Perintah Mesin

Tiga perintah analisis statis dan pengujian otomatis dijalankan pada proyek `08-week-8-mid-project-review`. Seluruhnya menghasilkan status **HIJAU (Lolos)**:

#### A. Static Analysis (`flutter analyze`)
```bash
flutter analyze
```
* **Output:**
  ```text
  Analyzing 08-week-8-mid-project-review...                       
  No issues found! (ran in 9.7s)
  ```
* **Keterangan:** Bebas dari error, warning, linter info (`unused_import`, `prefer_const`, `must_be_immutable`).

#### B. Code Formatter (`dart format --set-exit-if-changed .`)
```bash
dart format --set-exit-if-changed .
```
* **Output:**
  ```text
  Formatted 34 files (0 changed) in 0.36 seconds.
  ```
* **Keterangan:** Seluruh berkas Dart pada `lib/` dan `test/` telah rapi sesuai konvensi gaya resmi Dart. Kode exit bernilai 0 (bersih).

#### C. Unit & Widget Testing (`flutter test`)
```bash
flutter test
```
* **Output:**
  ```text
  00:00 +0: loading D:/mobile/08-week-8-mid-project-review/test/auth_push_test.dart
  00:00 +0: D:/mobile/08-week-8-mid-project-review/test/auth_push_test.dart: routeFromMessage menangani route kosong dan tanpa slash
  00:00 +1: D:/mobile/08-week-8-mid-project-review/test/auth_push_test.dart: data payload membawa id pengumuman
  00:00 +2: D:/mobile/08-week-8-mid-project-review/test/auth_push_test.dart: provider auth membaca status login dari token
  00:01 +3: D:/mobile/08-week-8-mid-project-review/test/auth_push_test.dart: refresh gagal -> sesi dibersihkan (paksa login ulang)
  00:03 +4: D:/mobile/08-week-8-mid-project-review/test/format_test.dart: Format pure functions formatDate memformat DateTime ke format YYYY-MM-DD HH:mm
  00:03 +5: D:/mobile/08-week-8-mid-project-review/test/format_test.dart: Format pure functions truncateToken memotong token yang lebih panjang dari limit
  00:03 +6: D:/mobile/08-week-8-mid-project-review/test/format_test.dart: Format pure functions routeFromMessage menambahkan slash awal bila rute belum memilikinya
  00:05 +7: D:/mobile/08-week-8-mid-project-review/test/get_notes_test.dart: GetNotes meneruskan daftar dari repository
  00:06 +8: D:/mobile/08-week-8-mid-project-review/test/get_notes_test.dart: GetNotes meneruskan failure tanpa melempar
  00:06 +9: D:/mobile/08-week-8-mid-project-review/test/login_test.dart: Login UseCase Login berhasil mengembalikan AuthSession ketika input valid
  00:06 +10: D:/mobile/08-week-8-mid-project-review/test/login_test.dart: Login UseCase Login melempar NetworkFailure ketika email tidak valid
  00:06 +11: D:/mobile/08-week-8-mid-project-review/test/login_test.dart: Login UseCase Login melempar NetworkFailure ketika password kurang dari 6 karakter
  00:08 +12: D:/mobile/08-week-8-mid-project-review/test/validate_note_test.dart: AddNote Validation judul kosong mengembalikan LocalFailure dan tidak memanggil repository
  00:08 +13: D:/mobile/08-week-8-mid-project-review/test/validate_note_test.dart: AddNote Validation judul valid berhasil menyimpan catatan via repository
  00:08 +14: D:/mobile/08-week-8-mid-project-review/test/validate_note_test.dart: AddNote Validation judul dan isi dipangkas (trim) sebelum dikirim ke repository
  00:08 +15: D:/mobile/08-week-8-mid-project-review/test/validate_note_test.dart: AddNote Validation meneruskan failure dari repository tanpa melempar exception
  00:08 +16: All tests passed!
  ```
* **Keterangan:** Seluruh 16 unit test dari modul auth, navigasi push, formatting, dan catatan berhasil lolos 100%.

---

### 2. Konfigurasi Otomatisasi CI (`.github/workflows/ci.yml`)

Workflow Continuous Integration (CI) dikonfigurasi pada [.github/workflows/ci.yml](file:///d:/mobile/.github/workflows/ci.yml) untuk memeriksa setiap Pull Request secara otomatis sebelum diizinkan untuk di-merge:

```yaml
name: ci
on: [pull_request]
jobs:
  verify:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: 08-week-8-mid-project-review
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: 'stable'
      - run: flutter analyze
      - run: flutter test
```

---

### 3. Pembuktian Struktur Feature-First (Tiga Grep Sterilitas)

Verifikasi arsitektural Clean Architecture dijalankan untuk membuktikan kepatuhan terhadap *Dependency Rule*:

| No | Uji Sterilitas Arsitektur | Perintah Grep | Hasil | Evaluasi |
|:---|:---|:---|:---|:---|
| 1 | **Presentation Steril dari Data Driver & Parser Mentah** | `git grep -E "Dio\(|openDatabase|getDatabasesPath|FlutterSecureStorage|SharedPreferences\.getInstance|jsonDecode" -- "08-week-8-mid-project-review/lib/features/*/presentation"` | **0 temuan** | ✅ LULUS: UI hanya berinteraksi melalui Notifier/Provider Riverpod dan Domain Entity. |
| 2 | **Domain Steril dari Framework & Library Pihak Ketiga** | `git grep -E "import 'package:(flutter|dio|sqflite|firebase)" -- "08-week-8-mid-project-review/lib/features/*/domain" "08-week-8-mid-project-review/lib/core"` | **0 temuan** | ✅ LULUS: Domain murni bahasa Dart tanpa dependensi framework UI atau jaringan/database. |
| 3 | **Domain Tidak Bergantung pada Data Layer** | `git grep -E "import '.*data/" -- "08-week-8-mid-project-review/lib/features/*/domain"` | **0 temuan** | ✅ LULUS: Arah dependensi benar (Data bergantung ke Domain via repository implementation). |

---

### 4. Matriks Penilaian Kesiapan Tengah Semester (Mid-Review Readiness)

| Komponen Penilaian | Kondisi Target | Status Aktual | Catatan Verifikasi |
|:---|:---|:---|:---|
| **Fondasi Arsitektur** | Feature-First Clean Architecture terbukti steril | ✅ **Lulus (100%)** | 3/3 grep sterilitas nol temuan; pemisahan layer presentation, domain, dan data terisolasi. |
| **Pemeriksaan Mesin** | Tiga perintah hijau (analyze, format, test) | ✅ **Lulus (100%)** | `flutter analyze` 0 issues, `dart format` exit 0, `flutter test` 16/16 passed. |
| **CI Automation** | Otomasi penolakan PR kotor via GitHub Actions | ✅ **Aktif** | Berkas `.github/workflows/ci.yml` terkonfigurasi untuk memicu verifikasi pada setiap PR. |
| **Git Hygiene & Flow** | Branch pendek, PR terarah ke `develop`, commit konvensional | ✅ **Lulus (100%)** | Branch `feat/notes-validation` dibuat dari `develop`, PR terstruktur, dan di-merge dengan aman. |
| **Tindak Lanjut Review** | Seluruh komentar peer review diselesaikan | ✅ **Lulus (100%)** | 5 catatan review (2 kebenaran, 1 arsitektur, 1 test, 1 saran) telah diperbaiki dan diapprove. |
| **Kelengkapan Dokumen** | `README.md`, `docs/`, `screenshots/`, panduan cara uji | ✅ **Lengkap** | Tersedia di `08-week-8-mid-project-review/`. |


