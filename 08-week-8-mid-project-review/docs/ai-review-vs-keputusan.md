# AI Review vs. Keputusan Final

Dokumen ini mencatat proses **AI Challenge** pada Pull Request fitur validasi catatan (`feat/notes-validation`), membandingkan output review awal AI dengan verifikasi teknis manusia serta keputusan final tim pengembang.

---

## 1. AI Prompt Challenge

Prompt yang diberikan kepada AI Coding Assistant (Senior Flutter Reviewer Persona):

```text
Review PR Flutter ini sebagai senior Flutter dev.
Konteks: feature-first Clean Architecture (presentation -> domain <- data),
Riverpod, GoRouter, SQLite + Dio.
Fokus: kebenaran, arsitektur, dan test. Abaikan style.
Berikan 5 temuan teratas + level (blocker/saran)
+ alasan + usulan potongan kode perbaikan.
```

---

## 2. Output Awal AI Reviewer

Berikut adalah respons awal dari AI Reviewer terhadap kode Pull Request:

### Temuan 1 (Level: Blocker)
* **Deskripsi:** Usecase `AddNote` tidak memiliki batas maksimal panjang karakter untuk judul catatan (`title`).
* **Alasan:** Pengguna dapat memasukkan atau menempel (*paste*) teks ribuan karakter ke kolom judul. Hal ini berisiko menyebabkan *buffer overflow*, konsumsi memori berlebih pada SQLite, atau *layout overflow rendering* pada widget `ListTile` di halaman daftar catatan.
* **Potongan Kode Usulan AI:**
  ```dart
  if (cleanTitle.length > 100) {
    return Future.value((
      note: null,
      failure: const LocalFailure('Judul catatan maksimal 100 karakter'),
    ));
  }
  ```

### Temuan 2 (Level: Saran)
* **Deskripsi:** Pembuatan objek tiruan `FakeNoteRepository` pada `validate_note_test.dart` menggunakan `DateTime.now()` yang bersifat *nondeterministik*.
* **Alasan:** Pengujian yang mengandalkan waktu sistem (*system clock*) berisiko menghasilkan *flaky test* ketika dilakukan assertion timestamp spesifik atau saat pengujian dijalankan lintas zona waktu.
* **Potongan Kode Usulan AI:**
  ```dart
  updatedAt: DateTime(2026, 10, 19, 12, 0), // Nilai fixed deterministik
  ```

### Temuan 3 (Level: Blocker)
* **Deskripsi:** Logika penanganan error validasi lebih efisien jika langsung menampilkan Toast / SnackBar dari dalam Use Case `AddNote`.
* **Alasan:** Mempersingkat kode di layer presentation (`notes_page.dart`) sehingga UI tidak perlu memeriksa tuple `result.failure`.
* **Potongan Kode Usulan AI:**
  ```dart
  import 'package:flutter/material.dart'; // Import framework ke Domain

  Future<Note?> call(BuildContext context, {required String title}) async {
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(...);
      return null;
    }
    ...
  }
  ```

### Temuan 4 (Level: Saran)
* **Deskripsi:** Parameter `String body = ''` pada method `call()` use case sebaiknya diubah menjadi `String? body` dengan null checking manual di dalam blok fungsi, serta penambahan trailing comma pada setiap baris parameter.
* **Alasan:** Pola nullable lebih eksplisit untuk field opsional dalam gaya penulisan tertentu.
* **Potongan Kode Usulan AI:**
  ```dart
  Future<({Note? note, Failure? failure})> call({
    required String title,
    String? body,
  }) {
    final effectiveBody = body ?? '';
    ...
  ```

### Temuan 5 (Level: Saran)
* **Deskripsi:** Invalidation provider `ref.invalidate(notesProvider)` setelah simpan catatan menyebabkan re-fetch data penuh dari SQLite.
* **Alasan:** Disarankan menggunakan manipulasi state list secara optimistik (*optimistic local state update*) agar UI tidak memicu query database ulang.
* **Potongan Kode Usulan AI:**
  ```dart
  ref.read(notesProvider.notifier).addLocal(savedNote);
  ```

---

## 3. AI Verification Checklist

Setiap usulan AI wajib diuji dan diverifikasi sebelum diadopsi:

| Uji Verifikasi | Pertanyaan Kunci | Hasil Pemeriksaan |
|:---|:---|:---|
| **Verifikasi Kebenaran** | Apakah temuan benar-benar ada dan berdampak nyata? | **Temuan 1 & 2 terbukti benar.** Judul panjang memang dapat merusak tata letak UI, dan `DateTime.now()` memang melanggar kaidah determinisme unit test. |
| **Uji Dependency Rule** | Apakah usulan melanggar Clean Architecture (Domain mengimpor Flutter/Dio/SQLite)? | **Temuan 3 melanggar keras Dependency Rule.** Usulan mengimpor `package:flutter/material.dart` dan `BuildContext` ke dalam Use Case Domain. |
| **Uji Ruang Lingkup (Scope)** | Apakah AI hanya nitpick style/formatting yang sudah ditangani CI/Formatter? | **Temuan 4 adalah nitpick style.** Representasi default value `body = ''` sudah aman, dan formatting koma sudah diatur oleh `dart format`. |
| **Uji Arsitektur & Realitas** | Apakah usulan peningkatan performa sesuai dengan karakteristik aplikasi? | **Temuan 5 diuji:** Database lokal SQLite membutuhkan waktu query < 5 ms. Optimistic local state berisiko inkonsisten dengan data aktual database (ID auto-increment). |

---

## 4. Tabel Usulan vs. Keputusan Final

| No | Temuan AI | Level AI | Keputusan Tim | Alasan Teknis & Arsitektural |
|:---:|:---|:---:|:---:|:---|
| **1** | Validasi batas maksimal 100 karakter judul | Blocker | ✅ **DITERIMA** | **Terbukti Benar:** Mencegah *overflow rendering* pada komponen UI list dan beban query SQLite. Logika `cleanTitle.length > 100` ditambahkan ke `AddNote` usecase dan diverifikasi dengan unit test baru. |
| **2** | Determinisme timestamp pada `FakeNoteRepository` | Saran | ✅ **DITERIMA** | **Terbukti Benar:** Prinsip pengujian F.I.R.S.T (*Repeatable*) menuntut nilai waktu yang deterministik. Atribut `updatedAt` diganti dengan `DateTime(2026, 10, 19, 12, 0)`. |
| **3** | Pemanggilan SnackBar langsung di dalam Domain Use Case | Blocker | ❌ **DITOLAK** | **Pelanggaran Fatal Arsitektur:** Domain HARUS murni Dart (*pure Dart*). Mengimpor `package:flutter/material.dart` dan membawa `BuildContext` ke domain melanggar *Dependency Rule*. Terbukti gagal pada uji sterilitas `git grep`. |
| **4** | Pengubahan parameter `body = ''` menjadi nullable + trailing comma | Saran | ❌ **DITOLAK** | **Nitpick Style:** Constructor parameter dengan default parameter `body = ''` sudah non-nullable dan aman. Penataan koma/spasi adalah tanggung jawab `dart format` di CI, bukan ranah review arsitektural. |
| **5** | Optimistic state update menggantikan `ref.invalidate` | Saran | ⚠️ **DITERIMA DENGAN MODIFIKASI** | **Keputusan Pragmatis:** Tetap menggunakan `ref.invalidate(notesProvider)` karena SQLite adalah *single source of truth*. Sebagai gantinya, ditambahkan feedback visual progress `_isLoading` pada tombol Simpan dialog agar transisi mulus tanpa flicker. |

---

## 5. Bukti Verifikasi Pengujian Pasca-Tindak Lanjut

Setelah temuan yang valid (Temuan 1 & 2) diterapkan pada kode:

### A. Static Analysis
```bash
flutter analyze
```
* **Hasil:** `No issues found! (ran in 9.5s)`

### B. Unit Testing
```bash
flutter test
```
* **Hasil:** **17 of 17 tests passed!**
* Termasuk test case baru:
  ```text
  AddNote Validation judul melebihi 100 karakter mengembalikan LocalFailure dan tidak memanggil repository
  ```

### C. Sterilitas Domain Tetap Terjaga
```bash
git grep -E "import 'package:(flutter|dio|sqflite)" -- "08-week-8-mid-project-review/lib/features/*/domain"
```
* **Hasil:** **0 temuan** (Layer domain tetap 100% murni Dart).
