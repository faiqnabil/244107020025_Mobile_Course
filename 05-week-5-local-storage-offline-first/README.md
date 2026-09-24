# Week 5: Local Storage & Offline-First Notes App

Aplikasi Flutter **Offline-First Notes** yang dibangun menggunakan **Riverpod**, **SharedPreferences**, **SQLite (`sqflite`)**, **Dio**, dan **GoRouter**.

---

## 🎯 Tujuan Pembelajaran & Fitur Utama
1. **Preferensi Pengguna (`SharedPreferences`)**:
   - Pengaturan mode gelap/terang (*Dark Mode*).
   - Pencatatan waktu terakhir aplikasi dibuka (*Last Opened At*).

2. **Catatan Lokal Persisten (`SQLite` via `sqflite`)**:
   - Operasi CRUD (Create, Read, Delete) catatan tersimpan lokal.
   - Halaman Detail Catatan berbasis GoRouter (`/note/:id`).
   - Pengurutan catatan berdasarkan `updated_at` terbaru.

3. **Pola Offline-First & Antrean Sinkronisasi**:
   - Indikator catatan belum tersinkron (*dirty flag*).
   - Aturan resolusi konflik *Last-Write-Wins (LWW)*.
   - Fitur simulasi sinkronisasi data (`syncNotes`) saat koneksi online kembali.
   - *Cache-first read* untuk data publik (Posts JSONPlaceholder) menggunakan SQLite + Dio.
   - Toggle *Force Offline Mode* untuk pengujian mode offline deterministik.

4. **Pengujian Unit & Komponen**:
   - Pengujian unit model dan provider dengan repository palsu (`FakeNoteRepository`).
   - Widget test untuk perenderan UI.

---

## 🛠️ Stack Teknologi
- **Flutter SDK**
- **flutter_riverpod**: State Management (`AsyncNotifier`, `NotifierProvider`, `FutureProvider`)
- **shared_preferences**: Penyimpanan key-value preferensi kecil
- **sqflite** & **path**: Penyimpanan relasional SQLite lokal
- **dio**: HTTP client dengan kemampuan background fetch
- **go_router**: Navigasi deklaratif berbasi rute (`/`, `/note/:id`, `/settings`)

---

## 💡 Ringkasan Keputusan Storage (AI Challenge)

| Kebutuhan Data | Pilihan Storage | Alasan Utama |
| :--- | :--- | :--- |
| **Preferensi (Tema, Waktu Buka)** | `SharedPreferences` | Data berukuran kecil, berbentuk key-value primitif, dan membutuhkan pembacaan instan saat startup. |
| **Koleksi Catatan & Cache Posts** | `sqflite` (SQLite) | Data terstruktur relasional, mendukung pengurutan query, indeks, dan field `dirty` untuk antrean sync offline-first. |

> - Dokumentasi lengkap AI Challenge & perbandingan storage tersedia di [`docs/ai_challenge.md`](docs/ai_challenge.md).
> - Dokumen Jawaban Refleksi & Referensi Pendukung tersedia di [`docs/refleksi_dan_referensi.md`](docs/refleksi_dan_referensi.md).

---

## 🚀 Cara Menjalankan Project

1. **Clone repository dan buka folder project**:
   ```bash
   cd 05-week-5-local-storage-offline-first
   ```

2. **Install dependensi**:
   ```bash
   flutter pub get
   ```

3. **Jalankan analisis kode dan pengujian unit**:
   ```bash
   flutter analyze
   flutter test
   ```

4. **Jalankan aplikasi**:
   ```bash
   flutter run
   ```

---

## 🧪 Hasil Pengujian
- **`flutter analyze`**: `No issues found!`
- **`flutter test`**: `7/7 tests passed!`

---

## 📸 Tangkapan Layar Aplikasi (Screenshots)

Berikut adalah dokumentasi tampilan antarmuka dan pengujian fitur-fitur aplikasi:

| Tangkapan Layar | Penjelasan & Deskripsi Fitur |
| :--- | :--- |
| ![Catatan Mode Terang Kosong](screenshots/WhatsApp%20Image%202026-09-24%20at%2021.53.44.jpeg) | **1. Halaman Utama Catatan (Mode Terang - Kosong)**<br>Tampilan utama tab *Catatan* pada Tema Terang saat belum ada data. Menampilkan banner "Semua catatan telah tersinkron", tempat kosong (*empty state*), tombol Floating Action Button (`+`), serta ikon Pengaturan di sudut kanan atas. |
| ![Tambah Catatan Baru](screenshots/WhatsApp%20Image%202026-09-24%20at%2021.53.45.jpeg) | **2. Modal Form Tambah Catatan Baru**<br>Dialog input modal pada Mode Gelap untuk menambah catatan baru (Judul dan Isi Catatan). Data yang dimasukkan akan disimpan secara lokal ke dalam database SQLite (`sqflite`). |
| ![Catatan Belum Tersinkron](screenshots/WhatsApp%20Image%202026-09-24%20at%2021.53.45%20\(1\).jpeg) | **3. Indikator Belum Tersinkron (Dirty Flag)**<br>Tampilan daftar catatan setelah dibuat. Banner indikator berwarna ungu menampilkan pesan *"1 catatan belum tersinkron (dirty)"* lengkap dengan tombol **Sync** dan badge status warna oranye *"Belum Sync"* pada item catatan. |
| ![Sinkronisasi Catatan Selesai](screenshots/WhatsApp%20Image%202026-09-24%20at%2021.53.45%20\(2\).jpeg) | **4. Hasil Sinkronisasi Catatan (Sync Success)**<br>Tampilan setelah tombol **Sync** ditekan. Flag `dirty` di-reset menjadi clean, status berubah menjadi *"Semua catatan telah tersinkron"*, dan badge *"Belum Sync"* pada item hilang. |
| ![Posts Cache List](screenshots/WhatsApp%20Image%202026-09-24%20at%2021.53.46.jpeg) | **5. Tab Posts Cache (Cache-First Read)**<br>Menampilkan daftar post dari REST API (JSONPlaceholder) yang telah disimpan ke dalam cache lokal SQLite via **Dio** & **sqflite** untuk akses cepat tanpa membebankan network. |
| ![Force Offline Mode Active](screenshots/WhatsApp%20Image%202026-09-24%20at%2021.53.46%20\(1\).jpeg) | **6. Simulasi Force Offline Mode**<br>Pengujian saklar *Force Offline Mode* (posisi aktif/ON). Digunakan untuk mensimulasikan kondisi aplikasi tanpa internet untuk menguji keandalan strategi *Offline-First*. |
| ![Pengaturan Mode Terang](screenshots/WhatsApp%20Image%202026-09-24%20at%2021.53.46%20\(2\).jpeg) | **7. Halaman Pengaturan (Mode Terang)**<br>Tampilan menu Pengaturan (*Settings*) menggunakan **SharedPreferences** untuk menyimpan preferensi tema (Mode Gelap: Non-aktif) dan mencatat timestamp waktu terakhir kali aplikasi dibuka (*Last Opened At*). |
| ![Pengaturan Mode Gelap](screenshots/WhatsApp%20Image%202026-09-24%20at%2021.53.44%20\(1\).jpeg) | **8. Halaman Pengaturan (Mode Gelap)**<br>Tampilan menu Pengaturan saat saklar *Mode Gelap* diaktifkan. Preferensi langsung tersimpan di `SharedPreferences` dan mengubah tema seluruh aplikasi secara instan. |
