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

