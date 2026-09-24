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
