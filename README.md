# 📱 Portofolio Pemrograman Mobile (Flutter & Dart)

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Riverpod](https://img.shields.io/badge/Riverpod-2.x%20%2F%203.x-blueviolet?style=for-the-badge)](https://riverpod.dev)
[![Clean Architecture](https://img.shields.io/badge/Architecture-Clean%20(Feature--First)-success?style=for-the-badge)](#-arsitektur--prinsip-desain)
[![CI/CD](https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-2088FF?style=for-the-badge&logo=github-actions&logoColor=white)](.github/workflows/ci.yml)

Repositori ini merupakan portofolio komprehensif perkuliahan **Pemrograman Mobile** (Semester 5) Program Studi **D4 Teknik Informatika**, Jurusan Teknologi Informasi, **Politeknik Negeri Malang**. Berisi rangkaian praktikum, jobsheet, tugas proyek mandiri, pengujian otomatis, serta implementasi arsitektur perangkat lunak skala produksi dari Minggu 1 hingga Minggu 16.

---

## 👤 Identitas Mahasiswa

* **Nama Lengkap:** Muhammad Faiq Nabil Saputra
* **NIM:** 244107020025
* **Program Studi:** D4 Teknik Informatika
* **Jurusan:** Jurusan Teknologi Informasi
* **Institusi:** Politeknik Negeri Malang (Polinema)
* **Repositori GitHub:** [244107020025_Mobile_Course](https://github.com/faiqnabil/244107020025_Mobile_Course)

---

## 🧭 Ikhtisar & Roadmap Portofolio (16 Minggu)

Struktur repositori menggunakan pendekatan **monorepo modular per minggu** (`XX-week-XX-*`), di mana setiap modul memiliki kode sumber, suite pengujian (*unit/widget test*), dokumentasi arsitektur, dan bukti eksekusi (*screenshots*).

| Minggu | Topik & Fokus Utama | Status | Tautan Modul | Artefak & Sorotan Utama |
| :---: | :--- | :---: | :--- | :--- |
| **01** | **Mobile Ecosystem & Flutter Refresh** | ✅ Selesai | [01-week-1/...](01-week-1-mobile-development-ecosystem-flutter-refresh/) | Refresh sintaks Dart, Null Safety, Profil Mahasiswa, Widget Tree dasar. |
| **02** | **Declarative UI & Responsive Design** | ✅ Selesai | [02-week-2/...](02-week-2-declarative-ui-responsive-design/) | `MediaQuery`, `LayoutBuilder`, Breakpoint adaptif HP/Tablet, Flex layout. |
| **03** | **Navigation & State Management** | ✅ Selesai | [03-week-3/...](03-week-3-navigation-state-management/) | Declarative Routing (`go_router`), Riverpod provider, StateNotifier. |
| **04** | **Networking & REST API** | ✅ Selesai | [04-week-4/...](04-week-4-networking-rest-api/) | HTTP Client `Dio`, JSON serialization/deserialization, interceptor, async handling. |
| **05** | **Local Storage & Offline-First** | ✅ Selesai | [05-week-5/...](05-week-5-local-storage-offline-first/) | Database SQLite lokal (`sqflite`), persistent caching, offline-first sync. |
| **06** | **Authentication, Security & FCM** | ✅ Selesai | [06-week-6/...](06-week-6-authentication-security-fcm/) | `FlutterSecureStorage` (Keystore/Keychain), Firebase Cloud Messaging, Push Notifications. |
| **07** | **Clean Architecture (Feature-First)** | ✅ Selesai | [07-week-7/...](07-week-7-clean-architecture/) | Pemisahan 3 layer (Domain, Data, Presentation), SOLID, Dependency Rule, Mock tests. |
| **08** | **Mid-Project Review & Code Review** | ✅ Selesai | [08-week-8/...](08-week-8-mid-project-review/) | Konsolidasi UTS, Issue tracking, Peer Code Review, otomatisasi CI via GitHub Actions. |
| **09** | **AI-Assisted Development / Vibe Coding** | ✅ Selesai | [09-week-9/...](09-week-9-ai-assisted-development/) | Workflow AI (Prompt 5-slot, Verify, Refactor), Search & Empty State, AI Log audit. |
| **10** | **AI Feature Integration** | ⏳ Mendatang | [10-week-10/...](10-week-10-ai-feature-integration/) | Integrasi model AI/ML on-device atau cloud API ke dalam alur aplikasi mobile. |
| **11** | **Performance Optimization** | ⏳ Mendatang | [11-week-11/...](11-week-11-performance-optimization/) | Frame profiling, memory leak detection, const widgets, optimasi rendering list. |
| **12** | **Testing & Quality Assurance** | ⏳ Mendatang | [12-week-12/...](12-week-12-testing-quality-assurance/) | Integration test end-to-end, code coverage, golden test, accessibility audit. |
| **13** | **CI/CD Automation** | ⏳ Mendatang | [13-week-13/...](13-week-13-ci-cd-automation/) | Pipeline build APK/AAB otomatis, testing gate otomatis, automated semantic release. |
| **14** | **Deployment & Monitoring** | ⏳ Mendatang | [14-week-14/...](14-week-14-deployment-monitoring/) | Distribusi aplikasi, setup Firebase Crashlytics & Analytics, remote config. |
| **15** | **Secure Mobile Development** | ⏳ Mendatang | [15-week-15/...](15-week-15-secure-mobile-development/) | Code obfuscation, certificate pinning, anti-tampering, security hardening. |
| **16** | **Final Project Expo** | ⏳ Mendatang | [16-week-16/...](16-week-16-final-project-expo/) | Presentasi produk akhir aplikasi mobile terintegrasi secara profesional. |

---

## 🏗️ Arsitektur & Prinsip Desain

Pada proyek utama (`campus_notify` & `notes`), arsitektur yang diterapkan adalah **Feature-First Clean Architecture** yang mematuhi secara ketat **Dependency Rule** dan prinsip **SOLID**:

```text
       ┌────────────────────────────────────────────────────────┐
       │                   PRESENTATION LAYER                   │
       │   (Stateless/Consumer Widgets, Notifier, Pages, UI)    │
       └──────────────────────────┬─────────────────────────────┘
                                  │ bergantung ke (imports)
                                  ▼
       ┌────────────────────────────────────────────────────────┐
       │                      DOMAIN LAYER                      │
       │  (Pure Dart: Entities, Repository Interfaces, UseCases)│
       └──────────────────────────▲─────────────────────────────┘
                                  │ diimplementasikan oleh
       ┌──────────────────────────┴─────────────────────────────┐
       │                       DATA LAYER                       │
       │ (Models, Repository Impl, SQLite, Dio, Secure Storage) │
       └────────────────────────────────────────────────────────┘
```

### 3 Aturan Sterilitas Dependensi:
1. **Domain Layer Steril:** Berisi kode Dart murni (*Pure Dart*). Bebas dari `import 'package:flutter/...'`, framework UI, SQLite, maupun pustaka jaringan eksternal.
2. **Presentation Layer Steril dari Data Mentah:** Widget UI tidak boleh menginstansiasi client HTTP (`Dio`), database lokal (`openDatabase`), atau storage secara langsung. Semua data diakses melalui Use Case dan State Provider Riverpod.
3. **Dependency Injection Terpusat:** Menggunakan `flutter_riverpod` untuk memutus keterikatan langsung antar layer (*loose coupling*), memungkinkan pengujian murni tanpa database nyata (*mocking/faking*).

---

## 🛠️ Stack Teknologi & Library Utama

* **Core Framework:** [Flutter SDK](https://flutter.dev) (Channel Stable, Dart 3.x)
* **State Management & DI:** [Flutter Riverpod](https://riverpod.dev) (`Notifier`, `AsyncNotifier`, `FutureProvider`)
* **Routing & Deep Linking:** [GoRouter](https://pub.dev/packages/go_router)
* **Local Persistence:** [sqflite](https://pub.dev/packages/sqflite) & [path](https://pub.dev/packages/path)
* **Secure Storage:** [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage) (Hardware Keystore / Keychain)
* **Networking / REST API:** [Dio](https://pub.dev/packages/dio)
* **Push Notifications:** [firebase_messaging](https://pub.dev/packages/firebase_messaging) & [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)
* **Quality & Linter:** [flutter_lints](https://pub.dev/packages/flutter_lints) & `dart format`
* **Automated Testing:** `flutter_test` (Unit Testing, Widget Testing, Mocking)
* **DevOps / CI:** GitHub Actions Workflow (`.github/workflows/ci.yml`)

---

## 🚀 Panduan Menjalankan Proyek

### 1. Prasyarat Sistem
* Flutter SDK (versi `>= 3.13.0`)
* Dart SDK (versi `>= 3.0.0`)
* Android Studio / VS Code dengan ekstensi Flutter & Dart
* Git CLI

### 2. Kloning Repositori
```bash
git clone https://github.com/faiqnabil/244107020025_Mobile_Course.git
cd 244107020025_Mobile_Course
```

### 3. Menjalankan Modul Tertentu (Contoh: Week 9)
Setiap folder minggu merupakan proyek atau modul mandiri. Masuk ke direktori minggu yang diinginkan:

```bash
# Pindah ke modul yang dituju
cd 09-week-9-ai-assisted-development

# Mengunduh dependensi
flutter pub get

# Menjalankan static analysis (wajib 0 warning)
flutter analyze

# Menjalankan seluruh unit & widget tests
flutter test

# Menjalankan aplikasi pada perangkat/emulator yang terhubung
flutter run
```

---

## 🧪 Verifikasi & Kedisiplinan Pengujian

Setiap modul praktikum diverifikasi dengan pengujian berlapis sebelum di-commit dan di-push:

* **Static Analysis:** Memastikan kode bersih dari *dead code*, *unused imports*, dan potensi bug runtime:
  ```bash
  flutter analyze
  ```
* **Pure Unit Testing:** Menguji logika bisnis murni (*use case*, format token, parsing tanggal, rumus filter) tanpa memerlukan emulator.
* **Widget Testing:** Menguji interaksi komponen UI, simulasi ketikan pencarian, kondisi *empty state*, dan penanganan *error view*.
* **Code Formatting:** Menjaga kepatuhan gaya kode resmi Dart:
  ```bash
  dart format --set-exit-if-changed .
  ```

---

## 📄 Ringkasan Artefak Penting

* 📑 **Portofolio Singkat Mahasiswa:** [`portfolio-summary.md`](portfolio-summary.md)
* 🛡️ **Workflow Otomasi CI:** [`.github/workflows/ci.yml`](.github/workflows/ci.yml)
* 📝 **Audit & Review Paruh Semester (UTS):** [`08-week-8-mid-project-review/`](08-week-8-mid-project-review/)
* 🤖 **AI Engineering Log & Decision Matrix:** [`09-week-9-ai-assisted-development/docs/ai-log.md`](09-week-9-ai-assisted-development/docs/ai-log.md)

---

## 📜 Lisensi & Etika Akademis

Proyek dan materi di dalam repositori ini dikembangkan untuk tujuan akademis pada mata kuliah **Pemrograman Mobile** di **Politeknik Negeri Malang**. Kode sumber terbuka di bawah lisensi [MIT](LICENSE) atau ketentuan akademis yang berlaku di Politeknik Negeri Malang.
