# Refleksi dan Referensi — Minggu 8: Mid Project Review & Code Review

Dokumen ini memuat refleksi kritis mengenai kolaborasi tim, tanggung jawab code review, evaluasi AI assistant, serta daftar referensi pendukung untuk pembelajaran tengah semester.

---

## 💡 Refleksi Kritis

### 1. Apa beda "LGTM buta" dengan "approve" yang bertanggung jawab? Apa risikonya bagi tim?
* **LGTM Buta (*Blind LGTM*):**
  Pemberian persetujuan (*approval*) secara instan tanpa melakukan penelaahan mendalam terhadap kode yang diajukan—hanya melihat judul atau diff sekilas tanpa menarik (*pull*) branch ke mesin lokal, tanpa memeriksa *edge case*, dan tanpa menjalankan pengujian (`flutter test`).
* **Approve yang Bertanggung Jawab:**
  Reviewer secara aktif memeriksa kepatuhan arsitektur (*Dependency Rule*), menguji skenario batas (*nullability, error path, boundary value*), memverifikasi bahwa pemeriksaan mesin hijau (`flutter analyze` dan `dart format`), serta mereproduksi pengujian secara manual. Memberikan `approve` berarti reviewer ikut memikul tanggung jawab moral dan teknis bila terjadi kegagalan di *production*.
* **Risiko bagi Tim:**
  - **Akumulasi Hutang Teknis (*Technical Debt*):** Kode kotor, *memory leak*, dan pelanggaran arsitektur menyusup ke branch `develop`/`main`.
  - **Regresi Sistem & Bug di Production:** Perilaku lama aplikasi berpotensi rusak tanpa disadari karena ketiadaan tes pendukung.
  - **Kerusakan Budaya Rekayasa:** Anggota tim kehilangan standar kualitas dan menganggap review sekadar formalitas birokrasi, bukan sarana saling belajar (*knowledge sharing*).

---

### 2. Kapan komentar wajib berstatus *Request changes*, dan kapan cukup saran (*Nitpick/Suggestion*)?
* **Wajib Berstatus *Request Changes*:**
  - **Cacat Kebenaran Logika (*Bug / Edge Case Failure*):** Adanya potensi *null pointer exception*, kebocoran memori (*unhandled stream/controller dispose*), atau *crash* pada skenario tertentu.
  - **Pelanggaran Arsitektur Fatal:** Layer Domain mengimpor framework eksternal (`package:flutter`, `dio`, `sqflite`) yang merusak *Dependency Rule*.
  - **Regresi Pengujian:** PR menghapus atau membuat unit test yang sudah ada menjadi gagal (*broken build*), atau fitur baru sama sekali tidak memiliki unit test.
  - **Kerentanan Keamanan:** Hardcoded API key, penyimpanan token sensitif tanpa enkripsi, atau bypass validasi input.
* **Cukup Berstatus Saran (*Suggestion / Nitpick*):**
  - **Keterbacaan & Naming:** Penamaan variabel atau komentar yang bisa dibuat lebih deskriptif namun tidak mengubah logika bisnis.
  - **Micro-Optimization Non-Kritis:** Penggunaan konstruktor `const` tambahan atau refaktor kecil yang tidak berdampak signifikan pada performa.
  - **Preferensi Gaya Penulisan:** Usulan alternatif penulisan logika yang setara (misalnya `ternary` vs `if-else`) di mana kode saat ini sudah benar dan lolos `dart format`. Komentar semacam ini tidak boleh menghambat (*block*) merge.

---

### 3. Bagian mana dari review AI yang Anda tolak atau sederhanakan, dan mengapa?
* **Bagian yang Ditolak Keras:**
  AI mengusulkan untuk memanggil `ScaffoldMessenger.of(context).showSnackBar()` langsung dari dalam Domain Use Case `AddNote` agar kode presentation lebih ringkas.
* **Alasan Penolakan:**
  Usulan tersebut merupakan **pelanggaran fatal Clean Architecture**. Layer `domain` dirancang sebagai inti bisnis murni (*pure Dart*) yang independen dari platform UI. Membawa `BuildContext` dan `package:flutter/material.dart` ke domain akan merusak *Dependency Rule*, menggagalkan modularitas, dan membuat domain use case mustahil diuji secara *pure unit testing* tanpa kerangka kerja widget Flutter.
* **Bagian yang Ditolak Karena Di luar Scope (Nitpick):**
  AI memperdebatkan gaya penulisan parameter `body = ''` menjadi `String? body` serta penempatan koma (*trailing comma*). Saran ini ditolak karena perapian sintaks sudah didelegasikan sepenuhnya ke mesin `dart format` pada pipeline CI.
* **Bagian yang Disederhanakan / Diterima dengan Modifikasi:**
  AI menyarankan pembaruan state lokal secara optimistik (*optimistic local update*) daripada me-reload database. Kami menolak manipulasi state lokal buatan demi menjaga SQLite sebagai *Single Source of Truth*, namun mengadopsi usulan AI dalam menambahkan indikator loading visual (`_isLoading`) pada tombol dialog form agar transisi data tetap mulus.

---

### 4. Satu hal konkret yang Anda perbaiki setelah review sejawat — apa dampaknya?
* **Hal Konkret yang Diperbaiki:**
  Pada putaran pertama peer review, ditemukan bahwa `titleController` dan `bodyController` diinisialisasi secara lokal di dalam helper method dialog pada `notes_page.dart` tanpa pernah memanggil `.dispose()`.
* **Tindakan Perbaikan:**
  Kami mengekstraksi dialog tersebut menjadi `ConsumerStatefulWidget` tersendiri (`AddNoteDialog`) dan mengimplementasikan lifecycle `dispose()` yang secara eksplisit membersihkan kedua controller dari memori.
* **Dampak Positif:**
  - **Mencegah Memory Leak:** Mencegah penumpukan objek controller dan listener yang tidak terpakai setiap kali pengguna membuka dan menutup dialog tambah catatan.
  - **Meningkatkan Arsitektur & Modularitas:** `NotesPage` kembali mematuhi *Single Responsibility Principle* (hanya bertanggung jawab menampilkan list catatan), sementara logika input form terisolasi rapi di dalam komponennya sendiri.

---

## 📚 Referensi Pendukung

1. **Slide Week 8: Mid Project Review & Code Review**  
   Materi perkuliahan Pemrograman Mobile, Jurusan Teknologi Informasi, Politeknik Negeri Malang.
2. [Atlassian: Gitflow Workflow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow)  
   Panduan branching model industri (`main`, `develop`, `feature/*`, `fix/*`).
3. [GitHub: About Pull Request Reviews](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/reviewing-changes-in-pull-requests/about-pull-request-reviews)  
   Praktik terbaik kolaborasi peer review dan workflow approval di GitHub.
4. [Conventional Commits v1.0.0](https://www.conventionalcommits.org/en/v1.0.0/)  
   Spesifikasi format pesan commit terstruktur (`feat`, `fix`, `docs`, `refactor`, `chore`, `test`).
5. [Flutter: Static Analysis & IDE Integration](https://docs.flutter.dev/tools/using-ide)  
   Dokumentasi resmi linter dan static analyzer pada ekosistem Flutter.
6. [Dart: Linter Rules](https://dart.dev/tools/linter-rules)  
   Katalog lengkap aturan linter resmi untuk kode Dart berkualitas tinggi.
7. [GitHub Actions Documentation](https://docs.github.com/en/actions)  
   Panduan penyusunan continuous integration (CI) pipeline otomatis.
8. [Learn Dart in Y Minutes](https://learnxinyminutes.com/dart/)  
   Cheatsheet sintaksis modern dan fitur bahasa pemrograman Dart 3.
