# Refleksi & Referensi — Week 6

## 💬 Jawaban Refleksi

### 1. Mengapa refresh token tidak boleh disimpan di SharedPreferences? Apa risikonya bila bocor?
> **Jawaban:**  
> `SharedPreferences` menyimpan data dalam bentuk file teks polos (XML di Android, plist di iOS) tanpa enkripsi bawaan. Jika perangkat di-*root* / *jailbreak*, atau jika terdapat celah malware/backup eksfiltrasi, file ini dapat dibaca secara langsung oleh pihak ketiga.  
> **Risiko Kebocoran:** Refresh token adalah kredensial berumur panjang (misal 7-30 hari). Apabila refresh token bocor, penyerang (*attacker*) dapat meminta *access token* baru ke server kapan saja tanpa memerlukan kata sandi pengguna, sehingga akun dapat diambil alih secara permanen sampai sesi dicabut oleh server (OWASP Mobile M2: Insecure Data Storage).

---

### 2. Apa yang rusak bila `onTokenRefresh` diabaikan selama satu semester perkuliahan?
> **Jawaban:**  
> Registration token FCM pada perangkat tidak bersifat permanen; token tersebut dapat berganti secara otomatis ketika aplikasi di-update, data dihapus (*clear data*), aplikasi di-reinstal, atau saat Firebase melakukan rotasi kunci keamanan.  
> **Dampak:** Apabila `onTokenRefresh` tidak dipasang, backend kampus akan terus menyimpan token lama (*stale token*). Ketika backend mengirim notifikasi push penting (seperti perubahan jadwal ujian atau batas pembayaran UKT), server FCM akan menolak pengiriman (*Unregistered / Invalid Registration Token*). Akibatnya, mahasiswa tidak akan lagi menerima notifikasi push selama semester tersebut.

---

### 3. Kapan memakai topik dan kapan memakai token perangkat? Beri contoh pesan kampus untuk masing-masing.
> **Jawaban:**  
> - **Topik Messaging (`subscribeToTopic`):** Dipakai untuk siaran (*broadcast*) publik ke sekelompok pengguna yang memiliki preferensi/peran yang sama tanpa perlu menyimpan daftar token di database server.  
>   *Contoh Pesan Kampus:*  
>   - Topik `pengumuman-kampus`: "Pengumuman: Dies Natalis Kampus akan dilaksanakan besok."  
>   - Topik `angkatan-2024`: "Penting: Pengisian KRS Semester Ganjil dibuka hari ini."  
> - **Token Perangkat (Device Token / Direct Messaging):** Dipakai untuk pesan terarah (*targeted notification*) khusus bagi satu individu pengguna tertentu.  
>   *Contoh Pesan Kampus:*  
>   - Notifikasi Personal: "Pembayaran UKT atas nama NIM 244107020025 berhasil diproses."  
>   - Notifikasi Tugas/Bimbingan: "Dosen Pembimbing telah memberikan catatan revisi pada proposal skripsi Anda."

---

### 4. Bagian mana dari draf AI yang Anda tolak atau perbaiki, dan mengapa?
> **Jawaban:**  
> 1. **Sintaks API `flutter_local_notifications` v22:** Draf awal AI menggunakan positional argument lama pada metode `initialize` dan `_local.show`. Kami menolak dan menggantinya dengan *named parameters* (`settings:`, `id:`, `title:`, `body:`, `notificationDetails:`, `payload:`) agar kompatibel dengan versi terbaru dan lolos `flutter analyze`.  
> 2. **Struktur Background Message Handler:** Draf AI sempat menempatkan handler `onBackgroundMessage` di dalam metode kelas instans. Kami memperbaikinya menjadi fungsi top-level bertanda `@pragma('vm:entry-point')` karena Flutter Engine mengeksekusi handler background pada isolate terpisah tanpa instance UI.  
> 3. **Sensitivitas Tampilan Token di UI:** AI secara default menampilkan seluruh string token. Kami mengubahnya agar token selalu di-truncate (`substring(0, 12) + '...'`) untuk mencegah kebocoran kredensial pada screenshot laporan.

---

## 📚 Referensi Pendukung
- [Slide Week 6: Authentication, Security & FCM](../00-slides/Week_06_Authentication_Security_FCM.html)
- [FCM Flutter Client Guide (Firebase Docs)](https://firebase.google.com/docs/cloud-messaging/flutter/client)
- [FCM Message Types: Notification vs Data](https://firebase.google.com/docs/cloud-messaging/concept-options)
- [Firebase Auth for Flutter Integration](https://firebase.google.com/docs/auth/flutter/start)
- [Package `flutter_secure_storage` (pub.dev)](https://pub.dev/packages/flutter_secure_storage)
- [Package `flutter_local_notifications` (pub.dev)](https://pub.dev/packages/flutter_local_notifications)
- [GoRouter Redirect & Deep Linking Guide](https://go_router.dev/)
- [OWASP Mobile Top 10 Security Risks](https://owasp.org/www-project-mobile-top-10/)
## Implementasi Autentikasi & Integrasi FCM

### 1. Token Store (`lib/data/token_store.dart`)
```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStore {
  TokenStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  Future<void> save({required String access, required String refresh}) async {
    await _storage.write(key: _accessKey, value: access);
    await _storage.write(key: _refreshKey, value: refresh);
  }

  Future<String?> readAccess() => _storage.read(key: _accessKey);
  Future<String?> readRefresh() => _storage.read(key: _refreshKey);

  Future<void> clear() => _storage.deleteAll();
}
```

### 2. Push Service (`lib/messaging/push_service.dart`)
```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final _local = FlutterLocalNotificationsPlugin();
String? pendingDeepLink;

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background handling logic (e.g., log, store minimal data)
}

void registerBackgroundHandler() {
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}

Future<bool> requestNotificationPermission() async {
  final settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  return settings.authorizationStatus == AuthorizationStatus.authorized ||
      settings.authorizationStatus == AuthorizationStatus.provisional;
}

Future<void> initLocalNotifications([void Function(String route)? onNotificationClick]) async {
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const ios = DarwinInitializationSettings();
  await _local.initialize(
    settings: const InitializationSettings(android: android, iOS: ios),
    onDidReceiveNotificationResponse: (response) {
      pendingDeepLink = response.payload;
      if (response.payload != null && response.payload!.isNotEmpty && onNotificationClick != null) {
        onNotificationClick(response.payload!);
      }
    },
  );
}

Future<void> initFcmToken({required Future<void> Function(String token) onToken}) async {
  final token = await FirebaseMessaging.instance.getToken();
  if (token != null) await onToken(token);

  FirebaseMessaging.instance.onTokenRefresh.listen(onToken);
  await FirebaseMessaging.instance.subscribeToTopic('pengumuman-kampus');
}

void listenForeground(void Function(String route) go) {
  FirebaseMessaging.onMessage.listen((message) async {
    final route = message.data['route'] ?? '/';
    const androidDetails = AndroidNotificationDetails(
      'pengumuman',
      'Pengumuman Kampus',
      importance: Importance.high,
      priority: Priority.high,
    );
    await _local.show(
      id: message.hashCode,
      title: message.notification?.title ?? 'Pengumuman',
      body: message.notification?.body ?? '',
      notificationDetails: const NotificationDetails(android: androidDetails),
      payload: route,
    );
  });
}

void listenBackgroundAndTerminated(void Function(String route) go) {
  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    final route = message.data['route'];
    if (route != null && route.isNotEmpty) {
      go(route);
    }
  });

  FirebaseMessaging.instance.getInitialMessage().then((message) {
    if (message != null) {
      final route = message.data['route'];
      if (route != null && route.isNotEmpty) {
        go(route);
      }
    }
  });
}
```

### 3. Login Page (`lib/pages/login_page.dart`)
```dart
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    ref.read(authStateProvider.notifier).login(email, password);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    ref.listen<AsyncValue<bool>>(authStateProvider, (prev, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(friendlyErrorMessage(next.error!))),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Login Campus Notify')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Kata Sandi', border: OutlineInputBorder()),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            authState.isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(onPressed: _handleLogin, child: const Text('Login')),
          ],
        ),
      ),
    );
  }
}
```

These snippets illustrate how authentication state is managed via Riverpod (`authStateProvider`), how tokens are stored securely, and how FCM messages are handled across app states.

---
*Catatan*: Pastikan `flutter_secure_storage`, `firebase_messaging`, dan `flutter_local_notifications` berada pada versi terbaru (>=22) agar API di atas kompatibel.
