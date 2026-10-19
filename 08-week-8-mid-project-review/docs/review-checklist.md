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
