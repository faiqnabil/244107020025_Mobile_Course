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
