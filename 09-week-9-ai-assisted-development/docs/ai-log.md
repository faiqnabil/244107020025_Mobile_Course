# AI Development Log (Week 9 — AI-Assisted Development / Vibe Coding)

Dokumen ini mencatat seluruh rekam jejak siklus *AI-Assisted Development* (*Prompt → Generate → Verify → Test → Refactor → Explain*) untuk penambahan fitur **Pencarian Catatan (Search & Filter Notes)** serta penanganan status kosong (*Empty State*) pada proyek Flutter berbasis *Feature-First Clean Architecture* dan Riverpod.

---

## 1. Siklus Workflow

```text
1. Prompt   -> Peran, Konteks, Tugas, Batas, Output (Formula 5 Slot)
2. Generate -> AI mengusulkan kode awal (domain use case, provider, widget)
3. Verify   -> Baca baris demi baris, verifikasi import, cek kompatibilitas API Riverpod 3 & Flutter SDK
4. Test     -> flutter analyze & flutter test (Unit Test pure function + Widget Test UI)
5. Refactor -> Perbaiki halusinasi import, migrasikan StateProvider ke Notifier, pulihkan ErrorView & Loading state
6. Explain  -> Pertanggungjawaban keputusan teknis tanpa bergantung pada AI
```

---

## 2. Prompt Engineering (Formula 5 Slot)

Berikut adalah prompt berstruktur yang digunakan untuk meminta AI mengusulkan fitur pencarian:

```text
Peran: Senior Flutter Developer & Clean Architecture Specialist
Konteks: 
  - Proyek Flutter menggunakan arsitektur Feature-First (Domain <- Data, Presentation -> Domain).
  - State Management: flutter_riverpod versi ^3.4.3.
  - Fitur saat ini: notes dengan entitas Note (id, title, body, updatedAt, dirty) dan NotesPage (ConsumerWidget).
Tugas: 
  - Tambahkan fitur pencarian judul catatan (search/filter) secara case-insensitive.
  - Tampilkan Empty State ramah pengguna ("Tidak ada catatan.") ketika hasil filter kosong.
Batas: 
  - Jangan ubah kontrak arsitektur dasar.
  - Jangan memanggil SQLite atau filter langsung di dalam widget build method tanpa use case.
  - Layer domain harus murni Dart tanpa import Flutter/Dio/SQLite.
Output: 
  - File use case filter domain
  - Provider search query
  - Modifikasi NotesPage
  - Unit test dan Widget test
```

---

## 3. Output Awal AI & Analisis Kritis

### Usulan Awal AI:
1. **Domain Use Case (`filter_notes.dart`)**:
   ```dart
   import '../../entities/note.dart'; // ⚠️ BUG IMPORT

   List<Note> filterNotes(List<Note> notes, String query) {
     if (query.isEmpty) return notes;
     final lower = query.toLowerCase();
     return notes.where((note) => note.title.toLowerCase().contains(lower)).toList();
   }
   ```
2. **Presentation Provider (`search_query_provider.dart`)**:
   ```dart
   import 'package:flutter_riverpod/flutter_riverpod.dart';

   // ⚠️ HALUSINASI API: StateProvider sudah usang/dihapus di Riverpod 3.x
   final searchQueryProvider = StateProvider<String>((ref) => '');
   ```
3. **Presentation Page (`notes_page.dart`)**:
   ```dart
   final filteredNotes = state.when(
     loading: () => const <Note>[],      // ⚠️ BUG UX: Loading tertutup empty state
     error: (_, __) => const <Note>[],   // ⚠️ BUG LOGIKA: ErrorView jadi dead code
     data: (notes) => filterNotes(notes, query),
   );
   ```

---

## 4. Temuan Bug & Halusinasi AI (Bukti Mesin)

### Temuan 1: Halusinasi Package/API Kadaluarsa (`StateProvider` pada Riverpod 3.x)
- **Gejala / Error**:
  Saat dijalankan dengan `flutter test test/search_filter_test.dart`:
  ```text
  lib/features/notes/presentation/providers/search_query_provider.dart:5:29: Error: Method not found: 'StateProvider'.
  final searchQueryProvider = StateProvider<String>((ref) => '');
                              ^^^^^^^^^^^^^
  ```
- **Penyebab**: AI menggunakan pengetahuannya tentang Riverpod v1/v2 lama. Pada `flutter_riverpod: 3.4.3` (`riverpod 3`), `StateProvider` telah dihilangkan dan digantikan dengan class `Notifier` / `NotifierProvider`.
- **Solusi & Refactor**:
  Mengubah provider menjadi modern Riverpod 3 Notifier:
  ```dart
  class SearchQueryNotifier extends Notifier<String> {
    @override
    String build() => '';

    void setQuery(String query) => state = query;
    void clear() => state = '';
  }

  final searchQueryProvider =
      NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);
  ```

---

### Temuan 2: Salah Jalur Relatif Import (`../../entities/note.dart`)
- **Gejala / Error**:
  ```text
  lib/features/notes/domain/usecases/filter_notes.dart:1:8: Error: Error when reading 'lib/features/notes/entities/note.dart': The system cannot find the path specified
  import '../../entities/note.dart';
  ```
- **Penyebab**: File berada di `lib/features/notes/domain/usecases/`. Folder `entities` berada sejajar di `lib/features/notes/domain/entities/`. Jalur `../../` naik ke `lib/features/notes/`, sehingga mencari folder yang salah.
- **Solusi & Refactor**: Diperbaiki menjadi `import '../entities/note.dart';`.

---

### Temuan 3: *Dead Code* & Pelanggaran UX State di `NotesPage`
- **Gejala / Error**:
  AI mendefinisikan widget `ErrorView`, namun pada `state.when(...)` untuk `loading` dan `error` hanya mengembalikan `const <Note>[]`.
  Akibatnya:
  1. Saat pertama kali memuat data dari database lokal, UI langsung menampilkan *"Tidak ada catatan."* (Empty State) alih-alih `CircularProgressIndicator`.
  2. Saat terjadi error koneksi atau database locked, `ErrorView` tidak pernah dirender dan tombol `Coba Lagi` tidak bisa diakses pengguna.
- **Solusi & Refactor**:
  Memetakan `state.when` langsung pada level `Expanded`, sehingga `loading` menampilkan `CircularProgressIndicator()`, `error` menampilkan `ErrorView`, dan data diproses melalui `filterNotes(notes, query)` dengan fallback empty state.

---

### Temuan 4: Penanganan Whitespace Query pada `filterNotes`
- **Gejala**: Jika pengguna mengetikkan spasi saja (`"   "`), `query.isEmpty` bernilai `false`, menyebabkan pencarian karakter spasi dan memfilter catatan secara keliru.
- **Solusi & Refactor**: Menambahkan `query.trim()` sebelum pengecekan dan konversi huruf kecil.

---

## 5. Tabel Keputusan Review Usulan AI

| No | Usulan AI | Kategori | Keputusan | Alasan Teknis & Bukti |
|:---|:---|:---:|:---:|:---|
| 1 | Membuat fungsi `filterNotes` sebagai Use Case Domain terpisah | Arsitektur | **TERIMA** | Menjaga Dependency Rule: UI tidak memiliki logika manipulasi data, dan fungsi filter murni (*pure Dart*) sangat mudah diuji tanpa mocking widget. |
| 2 | Menggunakan `StateProvider<String>` untuk query pencarian | State Management | **TOLAK** | Gagal kompilasi pada Riverpod 3.4.3 (`Method not found: 'StateProvider'`). Diganti dengan `NotifierProvider` dan `Notifier`. |
| 3 | Mengembalikan `const <Note>[]` saat state `loading` & `error` di `notes_page.dart` | Logika UI / UX | **TOLAK & REFACTOR** | Menjadikan `ErrorView` sebagai *dead code* dan menampilkan teks "Tidak ada catatan" padahal data masih dalam proses loading. |
| 4 | Jalur import `../../entities/note.dart` | Sintaksis | **TOLAK & REFACTOR** | Gagal resolve path file. Diperbaiki ke `../entities/note.dart`. |
| 5 | Penggunaan `ListView.builder` di widget privat `NotesList` | Rendering | **TERIMA** | Efisien untuk render list berukuran dinamis tanpa lag. |

---

## 6. Hasil Verifikasi Mesin

### 1. Static Analysis (`flutter analyze`)
```bash
flutter analyze
```
Status: **No issues found!** (Semua aturan linter pada `analysis_options.yaml` terpenuhi).

### 2. Unit Testing & Widget Testing (`flutter test`)
```bash
flutter test
```
Hasil:
- `test/auth_push_test.dart` (2 passed)
- `test/format_test.dart` (6 passed)
- `test/get_notes_test.dart` (2 passed)
- `test/login_test.dart` (3 passed)
- `test/search_filter_test.dart` (7 passed):
  - Unit test: query kosong & spasi, case-insensitive, partial matching, query tidak cocok.
  - Widget test: render TextField & list utuh, filter realtime saat mengetik, render Empty State, render ErrorView saat error.
**Total: 20 / 20 tests passed!**

