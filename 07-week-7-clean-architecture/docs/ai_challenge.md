# AI Challenge & Engineering Log — Week 7: Clean Architecture

**Mata Kuliah:** Pemrograman Mobile  
**Topik:** Clean Architecture (Feature-First) & SOLID Principles  
**Target Project:** `campus_notify` & `notes`  

---

## 1. AI Prompt Challenge (Prompt yang Diberikan)

Sesuai panduan Codelab Minggu 7 Bagian 6, prompt berikut diberikan kepada AI coding assistant:

```text
Project Flutter saya: campus_notify (auth + FCM + daftar pengumuman).
Kondisi kini: folder lib/{data, providers, pages, messaging},
repository tercampur dengan implementasi, widget memanggil Dio langsung.
Tugas:
1. Usulkan struktur feature-first Clean Architecture
   (presentation/domain/data) untuk fitur auth + announcements.
2. Untuk tiap file lama, sebutkan tujuan barunya (pindah/pecah/hapus).
3. Tandai bagian yang over-engineering bila diterapkan ke CRUD sederhana,
   dan kapan use case benar-benar dibutuhkan vs repository langsung.
4. Tunjukkan wiring DI dengan Riverpod (tanpa package DI tambahan).
Jelaskan trade-off setiap keputusan.
```

---

## 2. Output Awal AI (Initial AI Output)

Berikut adalah usulan arsitektur awal yang diberikan oleh AI:

### 1. Usulan Struktur Direktori Feature-First
```text
lib/
├── core/
│   ├── failures.dart
│   └── network/
│       └── api_client.dart
├── features/
│   ├── auth/
│   │   ├── domain/
│   │   │   ├── entities/auth_session.dart
│   │   │   ├── repositories/auth_repository.dart
│   │   │   └── usecases/login_usecase.dart
│   │   ├── data/
│   │   │   ├── datasources/auth_remote_data_source.dart
│   │   │   ├── datasources/auth_local_data_source.dart
│   │   │   ├── models/auth_session_model.dart
│   │   │   └── repositories/auth_repository_impl.dart
│   │   └── presentation/
│   │       ├── providers/auth_providers.dart
│   │       └── pages/login_page.dart
│   └── announcements/
│       ├── domain/
│       │   ├── entities/announcement.dart
│       │   ├── repositories/announcement_repository.dart
│       │   ├── usecases/get_announcements_usecase.dart
│       │   └── usecases/get_announcement_detail_usecase.dart
│       ├── data/
│       │   ├── datasources/announcement_remote_data_source.dart
│       │   ├── models/announcement_model.dart
│       │   └── repositories/announcement_repository_impl.dart
│       └── presentation/
│           ├── providers/announcement_providers.dart
│           └── pages/
│               ├── home_page.dart
│               └── announcement_page.dart
└── routes.dart
```

### 2. Pemetaan File Lama ke Tujuan Baru
- `lib/data/api_client.dart` ➔ Dipindah ke `lib/core/network/api_client.dart`.
- `lib/data/token_store.dart` ➔ Dipecah menjadi data source lokal `lib/features/auth/data/datasources/auth_local_data_source.dart`.
- `lib/data/auth_repository.dart` ➔ Dipecah menjadi kontrak domain (`lib/features/auth/domain/repositories/auth_repository.dart`) dan implementasi (`lib/features/auth/data/repositories/auth_repository_impl.dart`).
- `lib/providers/auth_provider.dart` ➔ Dipindah ke `lib/features/auth/presentation/providers/auth_providers.dart` dengan dependency injection via Riverpod.
- `lib/pages/login_page.dart` ➔ Dipindah ke `lib/features/auth/presentation/pages/login_page.dart`.
- `lib/pages/home_page.dart` & `announcement_page.dart` ➔ Dipindah ke `lib/features/announcements/presentation/pages/`.
- `lib/messaging/push_service.dart` ➔ Dipindah ke infrastructure/core messaging service.

### 3. Analisis Over-Engineering (Use Case vs Langsung Repository)
- **Over-Engineering**: Membuat kelas `UseCase` terpisah untuk setiap operasi CRUD satu baris yang hanya meneruskan panggilan (`GetAnnouncementDetailUseCase` yang hanya memanggil `repo.getDetail(id)`) menambah *boilerplate* tanpa memberikan nilai tambah logika bisnis.
- **Kapan Use Case Wajib**:
  1. Operasi melibatkan validasi bisnis sebelum memanggil repository (misal: validasi format kredensial login).
  2. Operasi menggabungkan lebih dari satu repository (misal: sinkronisasi data lokal SQLite dengan remote API).
  3. Logika bisnis dapat digunakan kembali di beberapa tempat atau membutuhkan unit testing independen.

### 4. Wiring Dependency Injection dengan Riverpod
```dart
// lib/features/auth/presentation/providers/auth_providers.dart
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    apiClient: ref.watch(apiClientProvider),
    tokenStore: ref.watch(tokenStoreProvider),
  );
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

final authNotifierProvider = NotifierProvider<AuthNotifier, AsyncValue<AuthSession?>>(() {
  return AuthNotifier();
});
```

---

## 3. AI Verification Checklist & Evaluasi Kritis

Sesuai instruksi Codelab Minggu 7, seluruh usulan awal AI diverifikasi secara kritis:

| Checklist Evaluasi | Status Evaluasi | Catatan & Tindakan Kritis |
| :--- | :---: | :--- |
| **1. Repository Interface vs Impl** | ✅ Diterima | Kontrak `abstract class` diletakkan di `domain/repositories/`, sedangkan implementasi konkret ada di `data/repositories/`. Tidak dicampur dalam satu folder. |
| **2. Domain Steril dari Framework** | ✅ Diterima & Diverifikasi | Layer domain murni Dart tanpa `flutter`, `dio`, `sqflite`, atau `firebase`. Diverifikasi dengan grep 0 temuan. |
| **3. Use Case CRUD Satu-Baris** | ⚠️ Dikritisi / Ditolak | Usulan AI yang membuat `GetAnnouncementDetailUseCase` terpisah ditolak demi kesederhanaan. Untuk query baca sederhana, notifier cukup memanggil repository langsung; use case hanya dipakai pada operasi dengan logika bisnis (seperti `Login` atau `GetNotes` dengan filtering/failure mapping). |
| **4. Entitas Bebas JSON Mapping** | ✅ Diterima | `Entity` di domain hanya mendefinisikan field bisnis tanpa `toMap`/`fromMap`. Seluruh serialisasi dikapsulkan di `Model` pada layer data. |
| **5. Wiring DI Terpusat di Riverpod** | ✅ Diterima | Widget presentation tidak melakukan instansiasi `new RepositoryImpl()` sendiri, seluruh dependensi disuntikkan via Riverpod `Provider`. |

---

## 4. Tabel Usulan AI vs Keputusan Final & Trade-Off

| Aspek Arsitektur | Usulan Awal AI | Keputusan Final | Trade-Off & Alasan Teknis |
| :--- | :--- | :--- | :--- |
| **Granularitas Data Source** | Membuat `RemoteDataSource` & `LocalDataSource` terpisah untuk setiap fitur. | Menggabungkan akses data langsung di `RepositoryImpl` jika operasinya sederhana. | **Trade-off:** Menghindari lapisan indirection berlebih pada aplikasi mobile skala sedang, sambil tetap mempertahankan pemisahan kontrak domain. |
| **Granularitas Use Case** | Setiap method repository dibungkus 1 kelas `UseCase` terpisah. | Hanya membuat `UseCase` untuk operasi dengan aturan bisnis (validasi, aggregasi, error handling). | **Trade-off:** Menghindari *boilerplate class explosion* (banyak file satu baris) pada CRUD pasif tanpa mengorbankan keterujian logika bisnis. |
| **Error Handling Contract** | Melempar custom Exception lalu ditangkap di UI. | Menggunakan Dart Record `({T data, Failure? failure})` atau sealed class `Failure`. | **Trade-off:** Eksplisit dan *type-safe*, mencegah kebocoran runtime exception yang tidak tertangkap hingga ke widget layer. |
| **Pemisahan Model vs Entity** | `NoteModel extends Note` dengan mapping di `NoteModel`. | Mengadopsi pola pewarisan `NoteModel extends Note` dengan `toEntity()`. | **Trade-off:** Memudahkan interoperabilitas data lokal SQLite tanpa mengotori domain entity dengan logika serialisasi. |

---

## 5. Bukti Verifikasi 3 Sterilitas Grep (Command Verification)

Tiga pemeriksaan sterilitas dependensi telah dijalankan dan seluruhnya menghasilkan **NOL TEMUAN (LULUS)**:

### 1. Presentation Steril dari Data Driver & Parser Mentah
```bash
git grep -E "Dio\(|openDatabase|getDatabasesPath|FlutterSecureStorage|SharedPreferences\.getInstance|jsonDecode" lib/features/*/presentation
```
- **Hasil:** 0 temuan (bersih, presentation hanya berinteraksi melalui Provider Riverpod dan Entity).

### 2. Domain Steril dari Framework Eksternal
```bash
git grep -E "import 'package:(flutter|dio|sqflite|firebase)" lib/features/*/domain lib/core
```
- **Hasil:** 0 temuan (bersih, domain murni logika bahasa pemrograman Dart).

### 3. Static Code Analysis & Unit Testing
```bash
flutter analyze
flutter test
```
- **Hasil flutter analyze:** `No issues found!`
- **Hasil flutter test:** `All tests passed! (6 passed)`
