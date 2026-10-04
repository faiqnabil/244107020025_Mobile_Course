# Hasil Pengujian 3 App State FCM Notification — Week 6

Tabel berikut menunjukkan hasil pengujian perilaku notifikasi gabungan (`notification` + `data`) pada tiga kondisi aplikasi (*App State*):

| App State | Kondisi Aplikasi | Handler yang Bekerja | Perilaku Tampilan Notifikasi | Perilaku Saat Banner Diklik | Status Pengujian |
| :--- | :--- | :--- | :--- | :--- | :---: |
| **Foreground** | Aplikasi sedang terbuka & aktif di layar utama | `FirebaseMessaging.onMessage` + `FlutterLocalNotificationsPlugin` | Banner sistem tidak otomatis muncul; ditampilkan **secara manual** via local notification plugin dengan channel High Priority. | Mengarahkan router aplikasi ke rute `data.route` (mis. `/pengumuman/3`). | **PASS** |
| **Background** | Aplikasi diminimize (di background / recents menu) | `FirebaseMessaging.onMessageOpenedApp` | Banner notifikasi dimunculkan **secara otomatis oleh OS Android/iOS** di tray notifikasi. | Aplikasi kembali ke layar utama dan GoRouter langsung berpindah ke `/pengumuman/3`. | **PASS** |
| **Terminated** | Aplikasi dimatikan total / *killed* | `FirebaseMessaging.instance.getInitialMessage()` | Banner notifikasi dimunculkan **secara otomatis oleh OS Android/iOS**. | Aplikasi diluncurkan dari keadaan awal (*cold boot*), `getInitialMessage()` membaca payload `data.route`, dan GoRouter langsung mengarahkan ke `/pengumuman/3`. | **PASS** |

---

## Contoh Payload Uji (FCM HTTP v1 / Console)

```json
{
  "message": {
    "topic": "pengumuman-kampus",
    "notification": {
      "title": "Jadwal Kuliah Berubah",
      "body": "Kelas Mobile Development pindah ke Ruang A2 pukul 13:00."
    },
    "data": {
      "route": "/pengumuman/3",
      "id": "3"
    }
  }
}
```
