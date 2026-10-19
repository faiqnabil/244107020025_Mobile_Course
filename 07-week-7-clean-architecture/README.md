# Week 7 — Clean Architecture

Implementasi arsitektur perangkat lunak berbasis **Clean Architecture (Feature-First)** dan **SOLID Principles** pada project Flutter (`campus_notify` & `notes`).

---

## 🎯 Tujuan Pembelajaran
1. Menerapkan prinsip SOLID dan Separation of Concerns dalam ekosistem Flutter.
2. Membangun struktur **Feature-First Clean Architecture** dengan 3 layer utama: `domain`, `data`, dan `presentation`.
3. Mematuhi **Dependency Rule** (dependensi hanya mengarah ke dalam; layer domain murni tanpa ketergantungan framework/external library).
4. Memisahkan objek `Entity` (bisnis murni) dengan `Model` (data/serialisasi).
5. Menerapkan *Dependency Injection* menggunakan **Flutter Riverpod**.
6. Melakukan *pure unit testing* pada Use Case dengan Repository tiruan (*fake*) tanpa database atau jaringan nyata.

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

### Struktur Folder Project (Feature-First)
```text
lib/
├── core/
│   ├── failures.dart                        # Failure domain (sealed class, murni Dart)
│   └── format.dart                          # Fungsi murni formatting tanggal, token & route
├── features/
│   ├── auth/
│   │   ├── domain/
│   │   │   ├── entities/auth_session.dart   # Pure business entity
│   │   │   ├── repositories/auth_repository.dart # Interface repository
│   │   │   └── usecases/login.dart          # Business use case
│   │   ├── data/
│   │   │   ├── models/auth_session_model.dart  # Data model + mapping toEntity
│   │   │   ├── token_store.dart             # Storage akses token terenkripsi
│   │   │   └── repositories/auth_repository_impl.dart # Implementasi repository konkret
│   │   └── presentation/
│   │       ├── providers/auth_providers.dart # Riverpod Notifier & DI wiring
│   │       └── pages/login_page.dart        # Halaman Login
│   └── notes/
│       ├── domain/
│       │   ├── entities/note.dart           # Pure business entity
│       │   ├── repositories/note_repository.dart # Interface repository
│       │   ├── usecases/get_notes.dart      # Business use case
│       │   └── usecases/add_note.dart       # Business use case
│       ├── data/
│       │   ├── open_notes_db.dart           # Database opener provider
│       │   ├── models/note_model.dart       # Model + mapping toMap, fromMap, toEntity
│       │   └── repositories/note_repository_impl.dart # Implementasi repository konkret (sqflite)
│       └── presentation/
│           ├── providers/notes_providers.dart # Riverpod Notifier & DI wiring
│           └── pages/notes_page.dart        # Stateless/Consumer widget UI murni
└── ...
```

---

## 📑 Rangkuman Praktikum

### Praktikum 1: Audit Layer Project Lama
- Mengidentifikasi pemetaan layer lama pada `campus_notify` dan 3 pelanggaran klasik:
  1. *Presentation* menyentuh storage/jaringan langsung (`Dio`, `FlutterSecureStorage`).
  2. Logika manipulasi/formatting data di dalam `build()`.
  3. Instansiasi manual (DI bocor).
- Dokumentasi lengkap audit: [`docs/praktikum_1_audit.md`](docs/praktikum_1_audit.md).

### Praktikum 2: Domain dan Data per Fitur
- Membuat layer **Domain murni (Pure Dart)**:
  - `Failure`, `LocalFailure`, `NetworkFailure` di [`lib/core/failures.dart`](lib/core/failures.dart).
  - Entitas bisnis `Note` di [`lib/features/notes/domain/entities/note.dart`](lib/features/notes/domain/entities/note.dart).
  - Kontrak repository `NoteRepository` dengan kembalian Record Dart `({List<Note> notes, Failure? failure})`.
  - Use case `GetNotes` di [`lib/features/notes/domain/usecases/get_notes.dart`](lib/features/notes/domain/usecases/get_notes.dart).
- Membuat layer **Data**:
  - `NoteModel` turunan dari `Note` dengan mapping `toMap()`, `fromMap()`, dan `toEntity()`.
  - `NoteRepositoryImpl` yang mengimplementasikan `NoteRepository` menggunakan `sqflite`.

### Praktikum 3: Presentation, DI, dan Verifikasi
- Melakukan penyuntikan dependensi terpusat di Riverpod (`notes_providers.dart`).
- Membuat `NotesPage` yang hanya mengonsumsi state via Riverpod tanpa menyentuh database atau parser JSON langsung.
- Membuat pengujian unit use case dengan fake repository di [`test/get_notes_test.dart`](test/get_notes_test.dart).

---

## 🤖 AI Challenge (Bagian 6)
- Prompt eksplorasi arsitektur feature-first, pemetaan file lama, evaluasi over-engineering (kapan use case wajib vs repository langsung ke notifier), serta wiring DI Riverpod.
- Hasil verifikasi checklist, tabel perbandingan usulan AI vs keputusan final, dan analisis teknis didokumentasikan lengkap di:
  👉 [`docs/ai_challenge.md`](docs/ai_challenge.md).

---

## 💬 Refleksi & Referensi (Bagian 8)
- Jawaban 4 pertanyaan refleksi Clean Architecture, trade-off arsitektur bagi tim kecil, dan daftar referensi pendukung tersedia di:
  👉 [`docs/refleksi_dan_referensi.md`](docs/refleksi_dan_referensi.md).

---

## 🧪 Hasil Verifikasi 3 Sterilitas Dependensi & Testing

| Verifikasi | Perintah | Hasil | Status |
| :--- | :--- | :---: | :---: |
| **1. Presentation Steril dari Data Mentah** | `git grep -E "Dio\(|openDatabase|getDatabasesPath|FlutterSecureStorage|SharedPreferences\.getInstance|jsonDecode" lib/features/*/presentation` | **0 temuan** | ✅ LULUS |
| **2. Domain Steril dari Framework & Packages** | `git grep -E "import 'package:(flutter|dio|sqflite|firebase)" lib/features/*/domain lib/core` | **0 temuan** | ✅ LULUS |
| **3. Static Analysis** | `flutter analyze` | **No issues found!** | ✅ LULUS |
| **4. Unit Testing** | `flutter test` | **12 / 12 tests passed!** | ✅ LULUS |

### 🛠️ Refactoring Challenge (Bagian 7)
- **Fitur Kedua (`auth`)**: Mengadopsi Clean Architecture penuh (`AuthSession` entity, `AuthRepository` interface, `AuthSessionModel`, `AuthRepositoryImpl`, `Login` use case, dan `auth_providers.dart`).
- **Ekstraksi Formatting Murni**: Logika pemotongan token, formatting tanggal, dan normalisasi deep link diekstrak ke [`lib/core/format.dart`](lib/core/format.dart) tanpa ketergantungan widget.
- **Sterilisasi UI dari Raw Exception**: UI hanya menerima pesan ramah pengguna (`Failure.message`).


### 📸 Bukti Eksekusi & Screenshots
Tangkapan layar pengujian antarmuka dan bukti verifikasi before/after disimpan pada direktori [`screenshots/`](screenshots/):
- `screenshots/WhatsApp Image 2026-10-04 at 15.57.18 (1).jpeg` — Tampilan antarmuka beranda Campus Notify.
- `screenshots/WhatsApp Image 2026-10-04 at 15.57.18 (2).jpeg` — Tampilan dialog & payload pesan pengumuman.
- `screenshots/WhatsApp Image 2026-10-04 at 15.57.18.jpeg` — Tampilan form login autentikasi.

---

## 🛠️ Stack Teknologi
- **Flutter SDK**
- **Flutter Riverpod** (Dependency Injection & State Management)
- **sqflite & path** (Local Relational Storage di Layer Data)
- **GoRouter** (Declarative Routing)
- **Dio** (HTTP Client)
- **flutter_secure_storage** (Secure Token Storage)
- **flutter_test** (Unit Testing Domain & Presentation)

---

## 🚀 Cara Menjalankan

1. **Jalankan static analysis**:
   ```bash
   flutter analyze
   ```

2. **Jalankan unit tests**:
   ```bash
   flutter test
   ```
