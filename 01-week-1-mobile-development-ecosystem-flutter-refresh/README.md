# Week 1 — Mobile Development Ecosystem & Flutter Refresh

**Mata Kuliah:** Pemrograman Mobile  
**Minggu:** 01  
**Topik:** Mobile Development Ecosystem & Flutter Refresh  

---

## 👤 Identitas Mahasiswa
- **Nama:** Muhammad Faiq Nabil Saputra  
- **NIM:** 244107020025  
- **Kelas / Program Studi:** D4 Teknik Informatika  
- **Jurusan:** Jurusan Teknologi Informasi — Politeknik Negeri Malang  

---

## 🎯 Tujuan Pembelajaran
Setelah menyelesaikan modul jobsheet Minggu 1 ini, mahasiswa diharapkan mampu:
1. Menjelaskan evolusi pengembangan aplikasi mobile serta perbedaan mendasar antara pendekatan **Native**, **Hybrid**, dan **Cross-Platform**.
2. Memahami arsitektur Flutter (Framework, Engine, Embedder), peran bahasa pemrograman Dart, struktur direktori proyek, dan konsep dasar *Widget Tree*.
3. Menguasai dasar-dasar pemrograman Dart: variabel, tipe data, fungsi, class/objek, dan implementasi *Null Safety*.
4. Menyiapkan environment Flutter, Android SDK, emulator/perangkat fisik, dan memverifikasinya melalui `flutter doctor` dan `flutter devices`.
5. Membangun aplikasi Flutter pertama, memodifikasi UI (Profil Mahasiswa), memahami konsep *Hot Reload* vs *Hot Restart*, serta mengelola source code pada portofolio Git.

---

## 📚 Ringkasan Teori

### 1. Evolusi Pengembangan Mobile
Pengembangan aplikasi mobile terus berkembang untuk menjawab kebutuhan efisiensi pengembangan di berbagai sistem operasi (Android dan iOS).

| Pendekatan | Ciri Utama | Kelebihan | Kekurangan | Contoh Teknologi |
| :--- | :--- | :--- | :--- | :--- |
| **Native** | Kode dan UI dibuat khusus untuk platform tertentu menggunakan SDK resmi. | Akses hardware langsung, performa paling maksimal, UX 100% konsisten dengan OS. | Butuh 2 basis kode terpisah (biaya & waktu x2), tim pengembang spesifik. | Kotlin / Java (Android), Swift / Obj-C (iOS) |
| **Hybrid** | Aplikasi web yang dibungkus (*wrapper*) dalam webview native. | Pengembangan sangat cepat menggunakan HTML/CSS/JS standar web. | Performa lebih lambat, akses API hardware terbatas melalui jembatan plugin. | Apache Cordova, Ionic |
| **Cross-Platform** | Satu basis kode (*single codebase*) dikompilasi ke aplikasi multi-platform. | Efisiensi kode, waktu rilis cepat, konsistensi UI di berbagai platform. | Ukuran binary aplikasi sedikit lebih besar, butuh pembaruan binding jika ada API OS baru. | **Flutter**, React Native |

### 2. Arsitektur Flutter dan Peran Dart
- **Framework (Dart):** Berisi fondasi widget (Material & Cupertino), rendering layer, animation, dan gestures.
- **Engine (C/C++):** Menggunakan Skia/Impeller untuk rendering grafis langsung ke kanvas, text layout, dan Dart VM.
- **Embedder:** Penghubung spesifik OS (Android, iOS, Windows, Web, macOS, Linux) untuk hosting, event loop, dan akses plugin native.
- **Peran Dart:** Mendukung kompilasi **JIT (Just-In-Time)** saat fase *development* (memungkinkan *Hot Reload*) dan **AOT (Ahead-Of-Time)** saat fase *production* menjadi kode mesin native yang cepat.

### 3. Widget Tree & Struktur Proyek Flutter
- **Widget Tree:** Struktur hierarki pohon di mana seluruh elemen UI (termasuk layout, padding, teks, dan gesture) direpresentasikan sebagai widget.
- **Struktur Folder:**
  - `lib/`: Titik awal kode aplikasi Dart (`lib/main.dart`).
  - `test/`: Berisi automated unit dan widget tests (`test/widget_test.dart`).
  - `android/`, `ios/`, `web/`, `windows/`: Konfigurasi dan wrapper untuk platform target.
  - `pubspec.yaml`: Manajemen dependency, metadata, font, dan aset aplikasi.

### 4. Hot Reload vs Hot Restart
- **Hot Reload (`r`):** Menginjeksi perubahan kode secara instan ke dalam Dart Virtual Machine tanpa menghilangkan *state* aplikasi. Cocok untuk perancangan dan tweaking UI secara cepat.
- **Hot Restart (`R`):** Mengompilasi ulang kode dan menjalankan ulang aplikasi dari `main()`, mereset seluruh *state* menjadi default. Diperlukan jika mengubah state inisialisasi, dependensi, atau struktur global.

---

## 🛠️ Langkah Praktikum & Hasil

### 1. Latihan Mandiri Dart Refresh
Mengerjakan latihan dasar Dart pada file `lib/dart_refresh.dart`:
1. Membuat fungsi `hitungLuasPersegiPanjang(double panjang, double lebar)`.
2. Membuat class `Profil` dengan atribut `nama`, `nim`, dan `email` bertipe `String?` (nullable).
3. Menguji pemanggilan fungsi dan penanganan nilai null secara aman pada fungsi `main()`.

**Kode Sumber:** [`lib/dart_refresh.dart`](lib/dart_refresh.dart)

```dart
// Cuplikan kode Dart Refresh
double hitungLuasPersegiPanjang(double panjang, double lebar) {
  return panjang * lebar;
}

class Profil {
  final String nama;
  final String nim;
  final String? email;

  Profil({required this.nama, required this.nim, this.email});

  String status() => 'Mahasiswa: $nama | NIM: $nim';
}
```

**Output Eksekusi:**
```text
=============================================
PRAKTIKUM DART REFRESH - MINGGU 1
Nama : Muhammad Faiq Nabil Saputra
NIM  : 244107020025
=============================================

--- 1. Perhitungan Luas Persegi Panjang ---
Panjang : 12.5
Lebar   : 6.0
Luas    : 75.0

--- 2. Profil Mahasiswa (Email Terisi) ---
Mahasiswa: Muhammad Faiq Nabil Saputra | NIM: 244107020025
Email   : FAIQ.NABIL@EXAMPLE.COM

--- 3. Profil Mahasiswa (Email Kosong / Null Safety) ---
Mahasiswa: Muhammad Faiq Nabil Saputra | NIM: 244107020025
Email   : BELUM DIISI

=============================================
```

---

### 2. Aplikasi Flutter Pertama & Mini Assignment (Profil Mahasiswa)
Mengubah UI default Flutter pada `lib/main.dart` menjadi tampilan Profil Mahasiswa dengan menyertakan Nama, NIM, Mata Kuliah, dan Program Studi.

**Kode Sumber:** [`lib/main.dart`](lib/main.dart)

```dart
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Profil Mahasiswa',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Profil Mahasiswa'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        body: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.school,
                size: 72,
                color: Colors.blue,
              ),
              SizedBox(height: 16),
              Text(
                'Muhammad Faiq Nabil Saputra',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'NIM: 244107020025',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Pemrograman Mobile — Minggu 1',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'D4 Teknik Informatika - JTI Polinema',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## 🧪 Verifikasi & Pengujian

### 1. Pengujian Widget (`flutter test`)
Pengujian otomatis pada `test/widget_test.dart` memverifikasi keberadaan widget `AppBar`, `Icons.school`, `Nama Mahasiswa`, dan `NIM`.
- Hasil: `00:01 +1: All tests passed!`

### 2. Analisis Kode (`flutter analyze`)
- Hasil: `No issues found! (ran in 1.9s)`

---

## 💡 Jawaban Pertanyaan Refleksi

### 1. Kapan native lebih tepat dipilih daripada cross-platform?
> **Jawaban:**  
> Pendekatan **native** lebih tepat dipilih ketika:
> - Aplikasi memerlukan akses mendalam ke fitur hardware teranyar atau API tingkat rendah platform (seperti sensor khusus, driver kamera manual, Bluetooth Low Energy kompleks, atau API AR/VR level rendah).
> - Aplikasi menuntut performa komputasi atau rendering grafis ultra tinggi tanpa adanya lapisan abstraksi tambahan (contoh: 3D game AAA atau pengolahan video real-time resolusi tinggi).
> - Perusahaan memiliki alokasi anggaran dan tim khusus untuk masing-masing platform demi menjamin 100% kepatuhan terhadap pedoman UI/UX native (Apple Human Interface Guidelines vs Google Material Design).

### 2. Bagaimana perubahan state berhubungan dengan widget tree dan UI deklaratif?
> **Jawaban:**  
> Dalam paradigma UI deklaratif ($\text{UI} = f(\text{state})$), antarmuka adalah refleksi langsung dari *state* saat ini. Ketika state berubah (misalnya melalui pemanggilan `setState`), Flutter menandai widget yang bersangkutan sebagai *dirty* dan memanggil kembali fungsi `build()`. Flutter kemudian merekonstruksi sub-pohon widget yang terpengaruh dan secara cerdas melakukan perbandingan (*diffing/reconciliation*) pada *Element Tree* dan *RenderObject Tree* sehingga hanya bagian layar yang benar-benar mengalami perubahan data saja yang di-render ulang.

### 3. Mengapa commit kecil dengan pesan jelas bermanfaat bagi pekerjaan tim dan portfolio?
> **Jawaban:**  
> - **Bagi Tim:** Memudahkan penelusuran riwayat kode (*git log* / *git blame*), mempercepat proses *code review*, meminimalisir kemungkinan *merge conflict* yang besar, serta mempermudah isolasi bug dan rollback perubahan tertentu (*git revert*) tanpa merusak fitur lainnya.
> - **Bagi Portofolio:** Menunjukkan kedisiplinan dan profesionalisme pengembang dalam menerapkan standar industri (seperti konvensi *Conventional Commits*), serta memperlihatkan proses pemecahan masalah yang runut dan terstruktur.

---

## ⚙️ Kendala Setup & Solusi

- **Kendala:**  
  Peringatan lisensi Android SDK yang belum disetujui saat pengecekan awal `flutter doctor` (`Android license status unknown`).
- **Solusi:**  
  Menjalankan perintah `flutter doctor --android-licenses` di terminal PowerShell dan menyetujui seluruh klausul lisensi SDK yang belum terverifikasi.

---

## 🚀 Cara Menjalankan Proyek

1. **Jalankan Skrip Latihan Dart:**
   ```bash
   dart run lib/dart_refresh.dart
   ```

2. **Jalankan Aplikasi Flutter:**
   ```bash
   # Jalankan di browser Chrome
   flutter run -d chrome

   # Atau jalankan di Windows Desktop
   flutter run -d windows
   ```

3. **Jalankan Pengujian Unit & Widget:**
   ```bash
   flutter test
   ```

4. **Jalankan Analisis Kode:**
   ```bash
   flutter analyze
   ```
