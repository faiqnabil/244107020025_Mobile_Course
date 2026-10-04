# AI Challenge & Engineering Log — Week 6

## 1. Prompt Awal (Initial Prompt)
> "Buatkan boilerplate Flutter untuk autentikasi menggunakan Riverpod, Dio interceptor dengan automatic token refresh (access + refresh token via FlutterSecureStorage), serta FCM push notification service yang menangani 3 app state (foreground, background, terminated) dan deep link GoRouter ke `/pengumuman/:id`."

---

## 2. Output Awal AI (Initial AI Output)
Output awal yang dihasilkan mencakup struktur file dasar `TokenStore`, `AuthRepository`, `api_client`, `push_service`, dan `main.dart`. Namun, terdapat beberapa isu sintaksis, deprecation/breaking changes API, dan ketidaksesuaian kontrak runtime:

```dart
// Draf Awal AI untuk push_service.dart (Memiliki kesalahan sintaks/API v22)
Future<void> initLocalNotifications() async {
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const ios = DarwinInitializationSettings();
  // ES-1: Menggunakan positional argument pada initialize (API lama)
  await _local.initialize(
    const InitializationSettings(android: android, iOS: ios),
    onDidReceiveNotificationResponse: (response) { ... },
  );
}

void listenForeground(void Function(String route) go) {
  FirebaseMessaging.onMessage.listen((message) async {
    // ES-2: Positional arguments pada _local.show (API v22 mewajibkan named arguments)
    await _local.show(
      message.hashCode,
      message.notification?.title ?? 'Pengumuman',
      message.notification?.body ?? '',
      const NotificationDetails(android: androidDetails),
      payload: route,
    );
  });
}
```

---

## 3. Daftar Perbaikan Manual & Alasan Teknis

| Issue / Bagian Kode | Kode Awal AI | Kode Perbaikan Manual | Alasan Teknis & Keamanan |
| :--- | :--- | :--- | :--- |
| **1. Param `initialize`** | `_local.initialize(const InitializationSettings(...))` | `_local.initialize(settings: const InitializationSettings(...))` | `flutter_local_notifications` versi 22+ mengubah signature `initialize` menjadi named argument `settings:`. |
| **2. Param `_local.show`** | `_local.show(id, title, body, details)` | `_local.show(id: id, title: title, body: body, notificationDetails: details)` | Paket v22 mewajibkan parameter bernama (`id:`, `title:`, `body:`, `notificationDetails:`) untuk menghindari ambigu tipe data. |
| **3. High-Priority Background Handler** | Dipasang sebagai method di dalam kelas | Fungsi top-level dengan `@pragma('vm:entry-point')` | Background messaging handler dipanggil oleh Flutter Engine di isolate terpisah tanpa UI context. |
| **4. Keamanan Storage Token** | Risiko penggunaan `SharedPreferences` | Menggunakan `FlutterSecureStorage` saja | Token tidak boleh disimpan di XML/plist mentah tanpa enkripsi KeyStore/Keychain (OWASP Mobile M2/M5). |
| **5. Sensor Token di Debug UI** | Menampilkan string token utuh | `token.substring(0, 12) + '...'` | Praktik keamanan membatasi paparan token di log/screenshot untuk mencegah eksfiltrasi token. |

---

## 4. Evaluasi Refactoring & Unit Test
- **Rute Sentral (`lib/routes.dart`):** Menyatukan semua konstanta rute aplikasi agar GoRouter dan deep link FCM tidak rentan *typo*.
- **Pesan Error Ramah (`lib/data/api_errors.dart`):** Mengubah `DioException` menjadi pesan bahasa Indonesia yang ramah pengguna.
- **Unit Testing (`test/auth_push_test.dart`):** Menguji pemrosesan data payload `routeFromMessage`, manipulasi parameter `id`, serta logika kebersihan token saat refresh gagal tanpa tergantung pada SDK Firebase sungguhan.
