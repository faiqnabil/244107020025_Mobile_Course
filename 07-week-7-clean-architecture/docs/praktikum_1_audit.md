# Audit Layer Project Lama (Praktikum 1)

## 1. Tabel Pemetaan File ke Layer

| File | Layer saat ini | Masalah |
| :--- | :--- | :--- |
| `lib/pages/home_page.dart` | presentation | Memanggil fungsi push service FCM langsung di `initState()`; mencampur UI dengan logika notifikasi & string formatting token. |
| `lib/pages/login_page.dart` | presentation | Form login memanggil notifier secara langsung; pesan exception mentah belum dibungkus domain Failure. |
| `lib/pages/announcement_page.dart` | presentation | Widget presentation membaca parameter rute tanpa pemisahan layer domain. |
| `lib/data/api_client.dart` | data | Instansiasi `Dio(BaseOptions(...))` hardcoded langsung di file data tanpa abstraksi/DI. |
| `lib/data/api_errors.dart` | data | Custom exception Dio belum dipetakan ke Failure di layer domain. |
| `lib/data/auth_repository.dart` | data (+kontrak tercampur) | Interface dan implementasi masih satu kelas (belum terpisah ke domain repository interface dan data repository impl). |
| `lib/data/token_store.dart` | data | Instansiasi default `FlutterSecureStorage()` langsung di constructor tanpa abstraksi DI. |
| `lib/providers/auth_provider.dart` | presentation (state) / data mix | Instansiasi `AuthRepository()` & `TokenStore()` manual langsung di provider (`authRepositoryProvider`, `tokenStoreProvider`). |
| `lib/messaging/push_service.dart` | infrastructure / data | Service FCM berada di luar struktur Clean Architecture (perlu diintegrasikan ke data/infrastructure layer). |

---

## 2. Hasil Audit Tiga Pelanggaran Klasik (Grep Analysis)

### Audit 1: Widget / Presentation menyentuh jaringan/database/storage langsung
Command:
```bash
rg "Dio\(|http\.|openDatabase|SharedPreferences\.getInstance|FlutterSecureStorage" lib/pages lib/widgets
```
- Findings:
  - `lib/data/token_store.dart:5`: Instansiasi langsung `FlutterSecureStorage()`
  - `lib/data/api_client.dart:6`: Instansiasi langsung `Dio(...)`

### Audit 2: Logika bisnis / formatting di dalam build() atau presentation
Command:
```bash
rg "DateFormat|jsonDecode|\.toIso8601String" lib/pages lib/widgets
```
- Findings:
  - `lib/pages/home_page.dart:45-49`: Logika helper `_truncateToken(String? token)` dilakukan langsung pada widget `HomePage`.

### Audit 3: Instansiasi manual (DI bocor)
Command:
```bash
rg "Repository\(|Dio\(BaseOptions" lib/pages lib/providers
```
- Findings:
  - `lib/providers/auth_provider.dart:7`: `Provider<AuthRepository>((ref) => AuthRepository());`
  - `lib/data/api_client.dart:6`: `final dio = Dio(BaseOptions(baseUrl: '...'));`

---

## 3. Gambar Struktur Target (Feature-First Clean Architecture)

```text
lib/
├── core/
│   ├── failures.dart
│   └── providers.dart
├── features/
│   ├── auth/
│   │   ├── domain/
│   │   │   ├── entities/auth_session.dart
│   │   │   ├── repositories/auth_repository.dart
│   │   │   └── usecases/login.dart
│   │   ├── data/
│   │   │   ├── models/auth_session_model.dart
│   │   │   └── repositories/auth_repository_impl.dart
│   │   └── presentation/
│   │       ├── providers/auth_providers.dart
│   │       └── pages/login_page.dart
│   └── announcements/
│       ├── domain/
│       │   ├── entities/announcement.dart
│       │   ├── repositories/announcement_repository.dart
│       │   └── usecases/get_announcements.dart
│       ├── data/
│       │   ├── models/announcement_model.dart
│       │   └── repositories/announcement_repository_impl.dart
│       └── presentation/
│           ├── providers/announcement_providers.dart
│           └── pages/
│               ├── home_page.dart
│               └── announcement_page.dart
└── routes.dart
```
