# Week 7 — Clean Architecture (Praktikum 1: Audit Layer Project Lama)

Project **Campus Notify** — Implementasi Refactoring Arsitektur Perangkat Lunak berbasis **Clean Architecture** (Feature-First) dan **SOLID Principles**.

---

## 📑 Praktikum 1: Audit Layer Project Lama

### 1. Pemetaan File ke Layer & Identifikasi Masalah

Berikut adalah tabel hasil audit struktur project `campus_notify` sebelum dilakukan refactoring ke Clean Architecture:

| File | Layer saat ini | Masalah / Temuan Audit |
| :--- | :--- | :--- |
| `lib/pages/home_page.dart` | `presentation` | Memanggil fungsi push service FCM secara langsung di `initState()`; mencampur UI dengan logika notifikasi & manipulasi string token (`_truncateToken`). |
| `lib/pages/login_page.dart` | `presentation` | Form login memanggil notifier secara langsung; pesan exception mentah belum dibungkus ke dalam domain `Failure`. |
| `lib/pages/announcement_page.dart` | `presentation` | Widget presentation membaca parameter rute secara langsung tanpa layer domain/use case. |
| `lib/data/api_client.dart` | `data` | Instansiasi `Dio(BaseOptions(...))` hardcoded langsung di file data tanpa abstraksi config atau DI. |
| `lib/data/api_errors.dart` | `data` | Custom exception Dio belum dipetakan ke domain `Failure` sehingga penanganan error berpotensi bocor ke UI. |
| `lib/data/auth_repository.dart` | `data` (+kontrak tercampur) | Interface (kontrak) dan implementasi masih menjadi satu kelas konkret di layer data. Tidak ada abstraksi di domain. |
| `lib/data/token_store.dart` | `data` | Instansiasi default `FlutterSecureStorage()` dilakukan langsung pada constructor tanpa penyuntikan dependensi (DI). |
| `lib/providers/auth_provider.dart` | `presentation` / `data` mix | Instansiasi `AuthRepository()` dan `TokenStore()` dilakukan secara manual di dalam provider (`authRepositoryProvider`, `tokenStoreProvider`), menyebabkan DI bocor. |
| `lib/messaging/push_service.dart` | `infrastructure` / `data` | Service messaging FCM berada di luar struktur layer Clean Architecture standar (perlu direstrukturisasi). |

---

### 2. Audit Tiga Pelanggaran Klasik (Grep Analysis)

Pemeriksaan otomatis menggunakan grep (`rg`) dilakukan untuk menandai titik-titik pelanggaran aturan dependensi dan DI:

#### 🔍 Audit 1: Widget / Presentation yang menyentuh Jaringan / Storage / Database secara langsung
```bash
rg "Dio\(|http\.|openDatabase|SharedPreferences\.getInstance|FlutterSecureStorage" lib/pages lib/widgets
```
- **Hasil Audit**:
  - `lib/data/token_store.dart`: `const FlutterSecureStorage()` (Instansiasi langsung storage)
  - `lib/data/api_client.dart`: `Dio(BaseOptions(...))` (Instansiasi langsung HTTP Client)
  - *Target Refactor*: Pastikan tidak ada widget/presentation yang menginstansiasi atau mengakses driver storage/network secara langsung.

#### 🔍 Audit 2: Logika Bisnis & Formatting di dalam build() / Presentation
```bash
rg "DateFormat|jsonDecode|\.toIso8601String" lib/pages lib/widgets
```
- **Hasil Audit**: 0 temuan langsung untuk `DateFormat`/`jsonDecode`, namun ditemukan logika manipulasi/formatting string token FCM di `HomePage._truncateToken()` yang berada di presentation layer.
- *Target Refactor*: Pindahkan seluruh formatting dan transformasi data ke domain/use case atau presenter helper murni.

#### 🔍 Audit 3: Instansiasi Manual (Dependency Injection Bocor)
```bash
rg "Repository\(|Dio\(BaseOptions" lib/pages lib/providers
```
- **Hasil Audit**:
  - `lib/providers/auth_provider.dart:7`: `Provider<AuthRepository>((ref) => AuthRepository());` (Instansiasi kelas konkret tanpa abstraksi interface)
  - `lib/data/api_client.dart:6`: `final dio = Dio(BaseOptions(...));` (Instansiasi manual `Dio`)
- *Target Refactor*: Seluruh instansiasi repository harus menggunakan kontrak *abstract class* di domain layer dan disuntikkan via Riverpod Provider.

> 🎯 **Target Akhir Audit**: Setelah Praktikum 3, ketiga perintah grep di atas harus menghasilkan **0 temuan (NOL HASIL)** pada folder presentation dan domain!

---

### 3. Gambaran Struktur Target Clean Architecture (Feature-First)

Berikut adalah struktur target yang dirancang untuk merefactor project ini ke dalam arsitektur **Feature-First Clean Architecture**:

```text
lib/
├── core/
│   ├── failures.dart                        # Failure domain murni Dart (seperti LocalFailure, NetworkFailure)
│   └── providers.dart                       # Provider global / lintas fitur (misal: shared preferences, secure storage)
├── features/
│   ├── auth/
│   │   ├── domain/
│   │   │   ├── entities/auth_session.dart   # Entity bisnis murni (tanpa JSON mapping)
│   │   │   ├── repositories/auth_repository.dart # Interface / Contract repository
│   │   │   └── usecases/login.dart          # Single business operation use case
│   │   ├── data/
│   │   │   ├── models/auth_session_model.dart  # Model data + mapping toEntity() / toMap()
│   │   │   └── repositories/auth_repository_impl.dart # Implementasi repository konkret
│   │   └── presentation/
│   │       ├── providers/auth_providers.dart # Riverpod Notifier + Wiring DI
│   │       └── pages/login_page.dart        # Page UI murni
│   └── announcements/
│       ├── domain/
│       │   ├── entities/announcement.dart   # Entity pengumuman
│       │   ├── repositories/announcement_repository.dart # Interface repository
│       │   └── usecases/get_announcements.dart # Use case membaca pengumuman
│       ├── data/
│       │   ├── models/announcement_model.dart # Model pengumuman + JSON parser
│       │   └── repositories/announcement_repository_impl.dart # Implementasi
│       └── presentation/
│           ├── providers/announcement_providers.dart # Provider state UI
│           └── pages/
│               ├── home_page.dart
│               └── announcement_page.dart
└── routes.dart                              # Declarative routing (GoRouter)
```

---

## 🛠️ Stack Teknologi
- **Flutter SDK**
- **Flutter Riverpod** (State Management & Dependency Injection)
- **GoRouter** (Declarative Routing & Deep Linking)
- **Dio** (HTTP Client & Interceptors)
- **flutter_secure_storage** (Secure Token Storage)
- **firebase_core** & **firebase_messaging** (FCM Services)

---

## 🧪 Verifikasi Status Snapshot Project
Snapshot project sebelum refactoring telah dibuat dan dapat diverifikasi melalui perintah:

```bash
# Snapshot Git Commit
git log -n 1

# Analisis Static Code
flutter analyze

# Running Unit Tests
flutter test
```
