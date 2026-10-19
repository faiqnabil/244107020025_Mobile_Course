# Week 8 — Mid Project Review & Code Review

Repository portofolio tengah semester untuk modul **Mid Project Review & Code Review** pada mata kuliah Pemrograman Mobile.

---

## 📌 Ringkasan Status Paruh Semester

* **Mahasiswa:** Muhammad Faiq Nabil Saputra
* **NIM:** 244107020025
* **Kelas:** D4 Teknik Informatika — JTI Polinema
* **Status Kesiapan:** ✅ **Siap untuk Paruh Kedua Semester (100% Lolos Mid-Review)**

Proyek ini merupakan konsolidasi dan penyempurnaan dari implementasi Minggu 1 s.d. 7, mengadopsi **Feature-First Clean Architecture**, **SOLID Principles**, **Riverpod**, serta kedisiplinan kolaborasi profesional berbasis **Git Flow**, **Automated Static Analysis**, dan **Peer Code Review**.

---

## 🛠️ Stack Teknologi

* **Framework:** Flutter SDK (Channel Stable) & Dart 3
* **State Management & DI:** `flutter_riverpod` (v2.6)
* **Routing & Deep Linking:** `go_router` (v14)
* **Local Persistence:** `sqflite` (SQLite) & `path`
* **Secure Storage:** `flutter_secure_storage` (Keystore / Keychain)
* **Networking & HTTP:** `dio`
* **Cloud Messaging:** `firebase_messaging` & `flutter_local_notifications`
* **Continuous Integration:** GitHub Actions (`.github/workflows/ci.yml`)

---

## 🗺️ Peta Issue & Pull Request

| ID | Tipe | Judul / Deskripsi | Branch | Status | Tautan / Referensi |
|:---|:---|:---|:---|:---|:---|
| `#12` | **Issue** | Bug: Pengguna dapat menyimpan catatan tanpa judul atau hanya berisi spasi kosong | `fix/12-notes-empty-title` | Closed via PR | Issue tracking validasi catatan |
| `#PR-1` | **Pull Request** | `feat(notes): validasi judul kosong + test` | `feat/notes-validation` &rarr; `develop` | Merged | [review-checklist.md](docs/review-checklist.md) |
| `#PR-CI` | **Pull Request** | `ci: setup penolakan otomatis PR kotor via GitHub Actions` | `ci/setup-automation` &rarr; `develop` | Merged | [.github/workflows/ci.yml](../../.github/workflows/ci.yml) |

---

## 🎯 Fitur Utama Aplikasi

1. **Autentikasi & Penyimpanan Token Aman (`features/auth`):**
   - Otentikasi sesi berbasis JWT token.
   - Akses token dan refresh token disimpan terenkripsi via `FlutterSecureStorage`.
   - Interceptor Dio untuk auto-refresh token 1x saat status `401 Unauthorized`.
2. **Push Notifications & Deep Linking (`messaging`):**
   - Integrasi Firebase Cloud Messaging (FCM) topik `pengumuman-kampus`.
   - Local notifications handler untuk kondisi *foreground*, *background*, dan *terminated*.
   - Deep linking otomatis ke halaman pengumuman detail melalui `GoRouter`.
3. **Catatan Offline-First & Validasi Input (`features/notes`):**
   - Persistensi data lokal berbasis SQLite (`sqflite`).
   - Validasi ketat judul kosong (`isEmpty`) dan pemangkasan whitespace (`trim()`) pada layer Domain use case `AddNote`.
   - UI input dialog interaktif (`AddNoteDialog`) dengan visual feedback error SnackBar.
4. **Sterilitas Arsitektur & Dependency Rule:**
   - Layer `domain` sepenuhnya steril dari framework eksternal (0 dependencies pihak ketiga).
   - Layer `presentation` sepenuhnya terisolasi dari SQL / database driver mentah.

---

## 🧪 Bukti Pemeriksaan Mesin (Status Hijau)

Tiga gerbang mesin (*machine checks*) wajib hijau sebelum kode diintegrasikan ke `develop`:

```text
1. flutter analyze
   Analyzing 08-week-8-mid-project-review...                       
   No issues found! (ran in 9.7s)

2. dart format --set-exit-if-changed .
   Formatted 34 files (0 changed) in 0.36 seconds.

3. flutter test
   All tests passed! (16 passed in 8.0s)
```

### Rincian 16 Unit & Widget Test yang Lolos:
* `auth_push_test.dart` (4 tests): Navigasi payload FCM, deep linking, login state, auto refresh error handling.
* `format_test.dart` (3 tests): Pure function date format, token truncation, route formatting.
* `get_notes_test.dart` (2 tests): Usecase fetching notes, failure propagation.
* `login_test.dart` (3 tests): Usecase valid auth session, invalid email failure, password length validation.
* `validate_note_test.dart` (4 tests): Validasi judul kosong, judul valid, whitespace trimming, repository failure handling.

---

## 🚀 Cara Menjalankan Project

### 1. Prasyarat
* Flutter SDK (>= 3.3.0)
* Android Studio / VS Code dengan ekstensi Dart & Flutter

### 2. Langkah Menjalankan
```bash
# Pindah ke direktori minggu 8
cd 08-week-8-mid-project-review

# Unduh dependensi
flutter pub get

# Jalankan analisis statis
flutter analyze

# Jalankan seluruh pengujian otomatis
flutter test

# Jalankan aplikasi (pilih emulator atau peranti fisik)
flutter run
```

---

## 📂 Struktur Direktori

```text
08-week-8-mid-project-review/
├── .github/workflows/ci.yml       # Konfigurasi CI otomatis
├── docs/
│   └── review-checklist.md       # Audit Git, tabel sebelum/sesudah, checklist peer review & mid-review
├── lib/
│   ├── core/                      # Failures domain & pure format utilities
│   ├── data/                      # Legacy data sources & client
│   ├── features/
│   │   ├── auth/                  # Clean Architecture modul Auth
│   │   └── notes/                 # Clean Architecture modul Notes (AddNote + AddNoteDialog)
│   ├── messaging/                 # Push service FCM & local notification
│   ├── pages/                     # Application pages
│   └── main.dart                  # Entry point aplikasi
├── test/                          # 16 unit tests komprehensif
└── README.md                      # Dokumentasi status paruh semester
```
