# Week 6 — Authentication, Security & Firebase Cloud Messaging (FCM)

Aplikasi **Campus Notify** — Implementasi alur autentikasi aman, token refresh otomatis dengan Dio & Secure Storage, serta FCM Push Notifications yang mendukung 3 state aplikasi (*Foreground*, *Background*, dan *Terminated*) dengan deep linking GoRouter.

---

## 🚀 Fitur Utama
1. **Penyimpanan Token Aman (`FlutterSecureStorage`):**
   - Access token dan refresh token disimpan di storage terenkripsi (Android KeyStore / iOS Keychain).
   - Tidak pernah menggunakan `SharedPreferences` untuk menyimpan token rahasia.

2. **Dio Interceptor & Automatic Token Refresh:**
   - Menyisipkan header `Authorization: Bearer <access_token>` secara otomatis pada setiap API request.
   - Menangani HTTP 401 Unauthorized dengan melakukan refresh token otomatis (1x retry).
   - Jika refresh token expired/invalid, storage dibersihkan dan pengguna diarahkan kembali ke `/login`.

3. **Routing Guard (`GoRouter`):**
   - Mengamankan rute aplikasi (`AppRoutes`). Pengguna yang belum login otomatis dialihkan ke `/login`, sedangkan pengguna yang sudah login dialihkan dari `/login` ke `/`.

4. **Firebase Cloud Messaging (FCM) & Topic Messaging:**
   - Izin notifikasi runtime (*runtime permission*) untuk Android 13+ & iOS.
   - Pengelolaan *Token Lifecycle* (`getToken` & `onTokenRefresh`).
   - Berlangganan topik `pengumuman-kampus`.

5. **Penanganan 3 App State Notifikasi:**
   - **Foreground:** Banner lokal ditampilkan secara manual via `flutter_local_notifications`.
   - **Background:** Banner sistem OS otomatis + handler klik `onMessageOpenedApp`.
   - **Terminated:** Handler peluncuran awal via `getInitialMessage()`.

---

## 🛠️ Stack Teknologi
- **Flutter SDK**
- **Flutter Riverpod** (State Management & Dependency Injection)
- **GoRouter** (Declarative Routing & Deep Linking)
- **Dio** (HTTP Client & Interceptors)
- **flutter_secure_storage** (Secure Token Storage)
- **firebase_core** & **firebase_messaging** (FCM Services)
- **flutter_local_notifications** (Foreground Notification Display)

---

## 📂 Struktur Project
```text
06-week-6-authentication-security-fcm/
├── android/
├── ios/
├── lib/
│   ├── main.dart
│   ├── routes.dart
│   ├── data/
│   │   ├── api_client.dart
│   │   ├── api_errors.dart
│   │   ├── auth_repository.dart
│   │   └── token_store.dart
│   ├── messaging/
│   │   └── push_service.dart
│   ├── providers/
│   │   └── auth_provider.dart
│   └── pages/
│       ├── login_page.dart
│       ├── home_page.dart
│       └── announcement_page.dart
├── test/
│   └── auth_push_test.dart
├── docs/
│   ├── ai_challenge.md
│   ├── app_state_testing.md
│   └── refleksi_dan_referensi.md
├── screenshots/
├── pubspec.yaml
└── README.md
```

---

## 📸 Tangkapan Layar (Screenshots)

| Halaman Login | Halaman Utama (Home) | Halaman Detail Pengumuman |
| :---: | :---: | :---: |
| <img src="screenshots/WhatsApp%20Image%202026-10-04%20at%2015.57.18.jpeg" width="240" alt="Halaman Login"> | <img src="screenshots/WhatsApp%20Image%202026-10-04%20at%2015.57.18%20(1).jpeg" width="240" alt="Halaman Home"> | <img src="screenshots/WhatsApp%20Image%202026-10-04%20at%2015.57.18%20(2).jpeg" width="240" alt="Halaman Pengumuman"> |

### 📝 Penjelasan Singkat:
1. **Halaman Login (`/login`)**:
   - Tampilan form autentikasi pengguna (email & password).
   - Diatur oleh *Routing Guard* (`GoRouter`), sehingga pengguna yang belum terautentikasi dialihkan otomatis ke halaman ini.

2. **Halaman Utama (`/`)**:
   - Dashboard aplikasi **Campus Notify** setelah berhasil masuk.
   - Menampilkan status **Debug Info FCM** (status izin notifikasi dan ketersediaan FCM Token).
   - Menyediakan tombol navigasi ke sampel pengumuman dan opsi **Logout**.

3. **Halaman Pengumuman (`/pengumuman/:id`)**:
   - Halaman rincian pengumuman kampus.
   - Dapat diakses dari aplikasi maupun secara langsung via *Deep Linking* saat pengguna mengetuk Notifikasi Push FCM (*Foreground*, *Background*, atau *Terminated* state).

---

## 📊 Hasil Pengujian 3 App State

| App State | Kondisi Aplikasi | Tampilan Notifikasi | Navigasi Klik | Status |
| :--- | :--- | :--- | :--- | :---: |
| **Foreground** | Aplikasi Terbuka | Local Notification Banner | Menuju `/pengumuman/:id` | **PASS** |
| **Background** | App di Background | System Notification Banner | Menuju `/pengumuman/:id` | **PASS** |
| **Terminated** | App Dimatikan | System Notification Banner | Menuju `/pengumuman/:id` | **PASS** |

---

## 🧪 Unit Testing & Analisis Kode
Dapat diverifikasi dengan perintah berikut:

```bash
# Analisis Kode (harus bersih tanpa issue)
flutter analyze

# Unit Test (semua test lulus)
flutter test
```

---

## 📑 Dokumentasi Terkait
- [Dokumentasi AI Challenge & Log Perbaikan (docs/ai_challenge.md)](docs/ai_challenge.md)
- [Tabel & Detail Pengujian 3 App State (docs/app_state_testing.md)](docs/app_state_testing.md)
- [Jawaban Refleksi & Referensi (docs/refleksi_dan_referensi.md)](docs/refleksi_dan_referensi.md)
