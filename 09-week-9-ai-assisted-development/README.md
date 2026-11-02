# Week 9 — AI-Assisted Development / Vibe Coding

Implementasi alur kerja **AI-Assisted Development** berbasis disiplin rekayasa perangkat lunak (*Prompt → Generate → Verify → Test → Refactor → Explain*) pada arsitektur **Feature-First Clean Architecture** dan **SOLID Principles** di Flutter.

Fitur utama yang ditambahkan pada modul ini adalah **Pencarian Catatan (Search & Filter Notes)** dengan dukungan tampilan status kosong (**Empty State**) dan penanganan status pemuatan data yang andal.

---

## 🎯 Tujuan Pembelajaran
1. Menjelaskan dan mempraktikkan workflow *AI-assisted development* secara disiplin dan terverifikasi.
2. Menyusun formula prompt 5-slot yang efektif dan berkonteks tinggi tanpa membocorkan kredensial/rahasia.
3. Mengenali berbagai pola halusinasi dan kelemahan kode AI (versi dependensi kadaluarsa, *dead code*, jalur relatif salah).
4. Melakukan *debugging*, verifikasi silang (*grep/test*), dan *refactoring* kode hasil AI ke standar *Clean Architecture*.
5. Menguji kode secara komprehensif menggunakan `flutter analyze` dan kombinasi *unit & widget testing*.
6. Mendokumentasikan log interaksi, analisis keputusan, serta bukti pengujian di [`docs/ai-log.md`](docs/ai-log.md).

---

## 🏗️ Struktur Arsitektur & Dependency Rule

```text
presentation (widget, notifier, router)
      │
      ▼  bergantung ke
domain (entity, repository interface, use case, failure)
      ▲
      │  diimplementasikan oleh
data (model, repository impl, SQLite/sqflite, secure storage, Dio)
```

### Struktur Berkas Fitur Notes (Feature-First)
```text
lib/features/notes/
├── domain/
│   ├── entities/
│   │   └── note.dart                    # Entitas bisnis murni (Pure Dart)
│   ├── repositories/
│   │   └── note_repository.dart         # Kontrak interface repository
│   └── usecases/
│       ├── get_notes.dart               # Use case pengambilan data catatan
│       ├── add_note.dart                # Use case penambahan catatan
│       └── filter_notes.dart            # [Week 9] Pure use case filter/search
├── data/
│   ├── models/note_model.dart           # Model serialisasi data SQLite
│   ├── open_notes_db.dart               # Provider koneksi database
│   └── repositories/
│       └── note_repository_impl.dart   # Implementasi konkret repository
└── presentation/
    ├── providers/
    │   ├── notes_providers.dart         # State list catatan (FutureProvider)
    │   └── search_query_provider.dart   # [Week 9] Notifier pencarian (Riverpod 3)
    └── pages/
        └── notes_page.dart              # [Week 9] UI pencarian + list + empty state
```

---

## 🤖 AI Workflow & Engineering Log

Setiap baris kode yang disarankan oleh asisten AI wajib melewati proses verifikasi, pengujian ketat, dan pertanggungjawaban teknis.

### Formula Prompt 5-Slot
```text
1. Peran   : Senior Flutter Developer & Clean Architecture Specialist
2. Konteks : Proyek Flutter Clean Architecture Feature-First, Riverpod 3.4.3, SQLite.
3. Tugas   : Tambah pencarian judul catatan (case-insensitive) + empty state.
4. Batas   : Pertahankan sterilitas domain, fungsi filter murni, jangan panggil DB dari widget.
5. Output  : File usecase, provider, widget modifikasi, serta unit & widget tests.
```

Dokumentasi lengkap mengenai prompt mentah, analisis kelemahan kode AI, dan investigasi halusinasi dapat dilihat pada:  
👉 [`docs/ai-log.md`](docs/ai-log.md).

---

## ⚖️ Evaluasi Usulan AI vs Keputusan Developer

| No | Usulan AI | Evaluasi & Fakta Mesin | Keputusan | Tindakan Pengembang |
|:---|:---|:---|:---:|:---|
| 1 | `filterNotes(notes, query)` di layer domain | Logika murni Dart tanpa import framework | **TERIMA** | Diadopsi sebagai pure use case di `lib/features/notes/domain/usecases/filter_notes.dart` dan ditambahkan `.trim()`. |
| 2 | `StateProvider<String>` untuk query pencarian | **Error kompilasi**: Riverpod 3.4.3 telah menghapus `StateProvider` | **TOLAK** | Direfaktor menggunakan `Notifier` dan `NotifierProvider` modern sesuai standar Riverpod 3. |
| 3 | Mengembalikan list kosong pada `loading` & `error` di `notes_page.dart` | **Pelanggaran UX & Dead Code**: `ErrorView` tidak pernah muncul dan loading tertutup teks empty state | **TOLAK & REFACTOR** | Memetakan `state.when` secara tepat: menampilkan `CircularProgressIndicator` saat loading, `ErrorView` saat gagal, dan empty state hanya saat data valid kosong. |
| 4 | Import `../../entities/note.dart` pada use case | **Error kompilasi**: Salah perhitungan kedalaman direktori relatif | **TOLAK & REFACTOR** | Dikoreksi menjadi `import '../entities/note.dart'`. |

---

## 🧪 Hasil Verifikasi & Testing Mesin

Semua pengujian dijalankan dan diverifikasi melalui CLI Flutter:

| Verifikasi | Perintah | Hasil | Status |
| :--- | :--- | :---: | :---: |
| **1. Sterilitas Presentation** | `git grep -E "Dio\(|openDatabase|getDatabasesPath" lib/features/notes/presentation` | **0 temuan** | ✅ LULUS |
| **2. Sterilitas Domain** | `git grep -E "import 'package:(flutter|dio|sqflite)" lib/features/notes/domain` | **0 temuan** | ✅ LULUS |
| **3. Static Analysis** | `flutter analyze` | **No issues found!** | ✅ LULUS |
| **4. Unit & Widget Testing** | `flutter test` | **20 / 20 tests passed!** | ✅ LULUS |

### Rincian Test Suite Week 9 (`test/search_filter_test.dart`)
1. `Unit Test filterNotes`: mengembalikan seluruh catatan bila query kosong / spasi.
2. `Unit Test filterNotes`: menyaring catatan secara *case-insensitive*.
3. `Unit Test filterNotes`: pencocokan substring parsial kata kunci.
4. `Unit Test filterNotes`: mengembalikan daftar kosong bila tidak ada yang cocok.
5. `Widget Test NotesPage`: merender `TextField` pencarian dan daftar penuh saat query kosong.
6. `Widget Test NotesPage`: memfilter catatan secara interaktif saat teks diketikkan.
7. `Widget Test NotesPage`: menampilkan **Empty State** (`"Tidak ada catatan."`) saat hasil pencarian nihil.
8. `Widget Test NotesPage`: merender `ErrorView` dengan tombol retry saat database gagal dimuat.

---

## 💬 Refleksi Pembelajaran

### 1. Satu halusinasi AI apa yang Anda temukan dan bagaimana membuktikannya?
**Temuan:** AI mengusulkan pembuatan state pencarian menggunakan sintaksis `StateProvider<String>((ref) => '')`.  
**Pembuktian:** Terbukti gagal kompilasi saat dieksekusi melalui `flutter test` dengan pesan kesalahan:  
`Error: Method not found: 'StateProvider'`.  
Hal ini terjadi karena AI berasumsi proyek menggunakan Flutter Riverpod v1/v2, padahal `pubspec.lock` telah menggunakan `flutter_riverpod: 3.4.3` yang mewajibkan penggunaan `NotifierProvider`.

### 2. Prompt mana yang paling membantu dan apa yang Anda ubah?
Prompt yang menggunakan **Formula 5-Slot** adalah yang paling efektif karena secara tegas membatasi cakupan (*constraints*) dan arsitektur (*context*). Modifikasi krusial yang ditambahkan adalah klausul larangan memfilter data langsung di dalam widget `build()`, sehingga AI dipaksa memisahkan logika ke usecase domain murni yang mudah diuji secara independen.

### 3. Satu refactor apa yang Anda lakukan pada kode AI?
Refactoring pada penanganan `AsyncValue` di [`notes_page.dart`](lib/features/notes/presentation/pages/notes_page.dart). AI awalnya memotong logika dengan mengembalikan `const <Note>[]` untuk status `loading` dan `error`, yang mengakibatkan widget `ErrorView` menjadi *dead code* dan teks *"Tidak ada catatan"* muncul prematur. Kami merefaktornya agar status `loading` menampilkan `CircularProgressIndicator`, status `error` menampilkan `ErrorView` dengan mekanisme retry, dan penyaringan hanya terjadi pada status `data`.

### 4. Keputusan terima/tolak mana yang paling sulit?
Keputusan menentukan apakah fungsi `filterNotes` memerlukan usecase class penuh berbasis OOP (`class FilterNotes { List<Note> call(...) }`) atau cukup fungsi murni top-level Dart. Kami memutuskan **menerima fungsi murni top-level** karena tidak memiliki state maupun dependensi eksternal, sehingga menghindari *over-engineering* tanpa melanggar prinsip *Clean Architecture*.

---

## 📸 Tangkapan Layar Uji Antarmuka
Bukti eksekusi antarmuka dan visualisasi verifikasi tersimpan pada folder [`screenshots/`](screenshots/):
- Tampilan daftar catatan lengkap dengan input pencarian.
- Tampilan hasil filter interaktif berdasarkan kata kunci judul.
- Tampilan **Empty State** (*"Tidak ada catatan."*) ketika kata kunci tidak ditemukan.

---

## 🚀 Cara Menjalankan

1. **Jalankan Static Analysis**:
   ```bash
   flutter analyze
   ```

2. **Jalankan Pengujian Unit & Widget**:
   ```bash
   flutter test test/search_filter_test.dart
   ```

3. **Jalankan Seluruh Suite Pengujian Proyek**:
   ```bash
   flutter test
   ```
