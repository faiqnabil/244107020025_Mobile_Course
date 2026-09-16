# Week 2 — Declarative UI & Responsive Design

**Mata Kuliah:** Pemrograman Mobile  
**Minggu:** 02  
**Topik:** Declarative UI, Responsive Design, Theming & Accessibility  

---

## 👤 Identitas Mahasiswa
- **Nama:** Muhammad Faiq Nabil Saputra  
- **NIM:** 244107020025  
- **Kelas / Program Studi:** TI-3D / D4 Teknik Informatika  
- **Jurusan:** Jurusan Teknologi Informasi — Politeknik Negeri Malang  

---

## 🎯 Tujuan Pembelajaran
Setelah menyelesaikan modul jobsheet Minggu 2 ini, mahasiswa mampu:
1. Menjelaskan prinsip **Declarative UI** dan hubungan antara widget, konfigurasi (*properties*), serta *state* ($\text{UI} = f(\text{state})$).
2. Menggunakan widget dasar Flutter: `StatelessWidget`, `StatefulWidget`, `Container`, `Row`, `Column`, dan `Expanded`.
3. Membedakan dan mengintegrasikan komponen **Material 3** dan **Cupertino** (misalnya `CupertinoSwitch` dan `Switch.adaptive`) untuk kebutuhan multi-platform.
4. Membangun tata letak responsif (*responsive layout*) yang beradaptasi secara dinamis untuk ukuran layar mobile (< 700px, 1 kolom) dan tablet/desktop (≥ 700px, 2 kolom) menggunakan `LayoutBuilder`.
5. Menerapkan sistem tema terpusat (*ThemeData*, *Light & Dark Mode*), styling kontekstual dengan `Theme.of(context)`, serta aksesibilitas dasar (*Accessibility & Semantics*).

---

## 📚 Ringkasan Teori & Konsep

### 1. Declarative UI vs Imperative UI
- **Imperative UI (Tradisional):** Pengembang memanipulasi elemen UI secara manual langkah demi langkah saat data berubah (misal: `view.setText(...)`, `view.setVisibility(GONE)`).
- **Declarative UI (Flutter):** Pengembang mendeskripsikan bagaimana tampilan antarmuka seharusnya terlihat pada state tertentu. Ketika state berubah (melalui pemanggilan `setState()`), Flutter merekonstruksi dan merender ulang sub-tree widget yang relevan secara otomatis.

$$\text{UI} = f(\text{state})$$

### 2. Widget Dasar Layout
- `StatelessWidget`: Widget yang bersifat *immutable* (tampilannya statis dan hanya bergantung pada konfigurasi awal dari parent).
- `StatefulWidget`: Widget yang memiliki objek `State` terpisah untuk mengelola data yang dapat berubah selama *lifecycle* aplikasi.
- `Container`: Widget serbaguna yang menggabungkan ukuran (*width/height*), *padding*, *margin*, *decoration* (*border*, *background color*, *border radius*), dan child widget.
- `Row` & `Column`: Widget tata letak fleksibel yang menyusun child widget secara horizontal (`Row`) atau vertikal (`Column`).
- `Expanded`: Widget yang membungkus child di dalam `Row`/`Column` untuk membagi sisa ruang kosong yang tersedia secara proporsional menggunakan properti `flex`.

### 3. Material 3 dan Komponen Cupertino
- **Material 3 (M3):** Bahasa desain standar Google untuk Android dan web, menyediakan `MaterialApp`, `Card`, `AppBar`, `ThemeData`, dan `ColorScheme`.
- **Cupertino:** Widget yang mengikuti *Human Interface Guidelines* dari Apple iOS.
- Pada jobsheet ini, widget `CupertinoSwitch` dari `package:flutter/cupertino.dart` diintegrasikan pada `AppBar` Material 3 untuk mendemonstrasikan fleksibilitas penggabungan ekosistem Material dan Cupertino.

### 4. Responsive Layout & Breakpoints
- Menggunakan `LayoutBuilder` untuk mengukur *constraints* ruang yang tersedia secara real-time.
- Menetapkan konstanta breakpoint bernama `const double kWideBreakpoint = 700.0;` untuk memisahkan layout layar sempit (1 kolom) dan layar lebar (2 kolom).

### 5. Theming & Accessibility
- Mendefinisikan `theme` (Light Mode) dan `darkTheme` (Dark Mode) berbasis `ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo)`.
- Menggunakan `Theme.of(context)` agar warna, teks, dan border menyesuaikan tema aktif secara otomatis.
- Menambahkan widget `Semantics` dan atribut `semanticLabel` pada ikon serta tombol sakelar tema guna mendukung pembaca layar (*screen reader* / TalkBack).

---

## 🛠️ Implementasi Source Code

### 1. Struktur Proyek
```text
02-week-2-declarative-ui-responsive-design/
├── lib/
│   └── main.dart                     # Kode utama aplikasi Academic Overview Dashboard
├── test/
│   ├── widget_test.dart              # Automated widget tests (responsive, theme toggle, profile)
│   └── generate_screenshots_test.dart# Script otomatis capture visual screenshot
├── screenshots/
│   ├── mobile_light.png              # Tampilan mobile mode terang
│   ├── mobile_dark.png               # Tampilan mobile mode gelap
│   ├── tablet_light.png              # Tampilan tablet mode terang
│   └── tablet_dark.png               # Tampilan tablet mode gelap
├── pubspec.yaml                      # Konfigurasi dependensi project responsive_dashboard
└── README.md                         # Laporan lengkap jobsheet Minggu 2
```

### 2. Kode Sumber Utama (`lib/main.dart`)
Aplikasi Academic Overview Dashboard mengimplementasikan seluruh ketentuan tugas utama dan refactoring challenge:

```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Breakpoint layar lebar untuk tata letak responsif (mobile < 700 <= tablet/desktop)
const double kWideBreakpoint = 700.0;

void main() {
  runApp(const DashboardApp());
}

/// Root Widget aplikasi Dashboard Mahasiswa dengan dukungan Light & Dark theme
class DashboardApp extends StatefulWidget {
  const DashboardApp({super.key});

  @override
  State<DashboardApp> createState() => _DashboardAppState();
}

class _DashboardAppState extends State<DashboardApp> {
  bool isDark = false;

  void toggleTheme(bool value) {
    setState(() {
      isDark = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Academic Overview Dashboard',
      debugShowCheckedModeBanner: false,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
      ),
      home: DashboardPage(
        isDark: isDark,
        onDarkChanged: toggleTheme,
      ),
    );
  }
}

/// Halaman utama Academic Overview yang menampilkan header profil dan kartu informasi responsif
class DashboardPage extends StatelessWidget {
  const DashboardPage({
    required this.isDark,
    required this.onDarkChanged,
    super.key,
  });

  final bool isDark;
  final ValueChanged<bool> onDarkChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Academic Overview',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Semantics(
            label: isDark ? 'Beralih ke mode terang' : 'Beralih ke mode gelap',
            button: true,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isDark ? Icons.dark_mode : Icons.light_mode,
                  semanticLabel: isDark ? 'Ikon Mode Gelap' : 'Ikon Mode Terang',
                ),
                const SizedBox(width: 6),
                CupertinoSwitch(
                  value: isDark,
                  onChanged: onDarkChanged,
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= kWideBreakpoint;
          final columns = isWide ? 2 : 1;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Profil Mahasiswa
                const ProfileHeaderCard(
                  name: 'Muhammad Faiq Nabil Saputra',
                  nim: '244107020025',
                  studyProgram: 'D4 Teknik Informatika',
                  classGroup: 'TI-3D',
                ),
                const SizedBox(height: 20),

                // Judul Bagian Ringkasan
                Text(
                  'Ringkasan Akademik',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),

                // Grid Kartu Informasi Responsif
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: columns,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: isWide ? 3.0 : 2.4,
                  children: const [
                    InfoCard(
                      title: 'Assignments',
                      value: '8 Selesai',
                      icon: Icons.assignment_turned_in,
                      semanticDescription: '8 tugas telah diselesaikan',
                    ),
                    InfoCard(
                      title: 'Attendance',
                      value: '92%',
                      icon: Icons.calendar_month,
                      semanticDescription: 'Tingkat kehadiran 92 persen',
                    ),
                    InfoCard(
                      title: 'IPK Semester',
                      value: '3.88',
                      icon: Icons.school,
                      semanticDescription: 'Indeks Prestasi Kumulatif 3.88',
                    ),
                    InfoCard(
                      title: 'Current Week',
                      value: 'Week 02',
                      icon: Icons.view_week,
                      semanticDescription: 'Minggu perkuliahan saat ini ke 2',
                    ),
                    InfoCard(
                      title: 'SKS Selesai',
                      value: '42 / 144 SKS',
                      icon: Icons.account_balance_wallet,
                      semanticDescription: '42 dari 144 SKS telah diselesaikan',
                    ),
                    InfoCard(
                      title: 'Portfolio Status',
                      value: 'Ready',
                      icon: Icons.auto_awesome,
                      semanticDescription: 'Status portofolio siap dipublikasikan',
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Widget Profil Header yang menggunakan Container, Row, Column, Expanded
class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({
    required this.name,
    required this.nim,
    required this.studyProgram,
    required this.classGroup,
    super.key,
  });

  final String name;
  final String nim;
  final String studyProgram;
  final String classGroup;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      label: 'Kartu Profil Mahasiswa $name, NIM $nim, Kelas $classGroup',
      container: true,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: colorScheme.outlineVariant,
            width: 1.0,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              child: const Icon(
                Icons.person,
                size: 40,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'NIM: $nim',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Text(
                        'Kelas: $classGroup',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Program Studi: $studyProgram',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget Kartu Informasi Reusable dengan dukungan Theme dinamis dan Semantics
class InfoCard extends StatelessWidget {
  const InfoCard({
    required this.title,
    required this.value,
    this.icon,
    this.semanticDescription,
    super.key,
  });

  final String title;
  final String value;
  final IconData? icon;
  final String? semanticDescription;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      label: semanticDescription ?? '$title: $value',
      container: true,
      child: Card(
        elevation: 1.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.6),
            width: 1.0,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
          child: Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 24,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 14),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
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

## 📸 Dokumentasi & Hasil Tangkapan Layar

Berikut adalah hasil tangkapan layar antarmuka dashboard pada berbagai konfigurasi perangkat dan tema:

| Konfigurasi Layar | Mode Terang (Light Mode) | Mode Gelap (Dark Mode) |
| :--- | :---: | :---: |
| **Mobile (< 700px, 1 Kolom)** | ![Mobile Light](<screenshots/WhatsApp Image 2026-09-08 at 18.24.06.jpeg>) | ![Mobile Dark](<screenshots/WhatsApp Image 2026-09-08 at 18.24.07 (1).jpeg>) |
| **Tablet / Landscape (≥ 700px, 2 Kolom)** | ![Tablet Light](<screenshots/WhatsApp Image 2026-09-08 at 18.24.07.jpeg>) | ![Tablet Dark](<screenshots/WhatsApp Image 2026-09-08 at 18.24.07 (2).jpeg>) |

---

## 🤖 AI Prompt Challenge

Sesuai dengan instruksi codelab, berikut dokumentasi interaksi prompt eksplorasi desain, analisis konsep, dan verifikasi AI:

### 1. Prompt Desain
> **Prompt:**  
> *"Bandingkan dua tata letak dashboard akademik untuk Flutter: versi GridView dan versi LayoutBuilder + Column. Jelaskan trade-off responsif dan aksesibilitasnya."*

**Ringkasan Output AI:**
- **Versi GridView (`GridView.count`):**
  - *Kelebihan:* Sangat mudah mengatur rasio aspek kartu (`childAspectRatio`), spacing antar kolom/baris, dan pembagian kolom otomatis via `crossAxisCount`.
  - *Kelemahan:* Perlu penanganan `shrinkWrap: true` dan `NeverScrollableScrollPhysics` jika diletakkan di dalam `SingleChildScrollView` agar tidak terjadi konflik scroll ganda.
- **Versi LayoutBuilder + Column (dengan Row bersarang):**
  - *Kelebihan:* Fleksibilitas tinggi pada tinggi kartu yang dinamis (*auto-height* berdasarkan konten teks tanpa batas rasio tetap).
  - *Kelemahan:* Pengembang harus menulis logika pembagian pasangan child manual menggunakan `Row` dan `Expanded`.
- **Aksesibilitas & Responsivitas:**
  Kedua pendekatan sama-sama mendukung aksesibilitas pembaca layar jika dibungkus `Semantics`. Namun `GridView` lebih konsisten dalam menjaga keseragaman ukuran kartu di berbagai densitas piksel.

### 2. Prompt Penguatan Konsep (Expanded vs Overflow)
> **Prompt:**  
> *"Jelaskan kapan penggunaan Expanded justru menyebabkan overflow di dalam Row, beri contoh kode yang gagal dan perbaikannya."*

**Ringkasan Output AI:**
- **Penyebab Gagal (*Unbounded Constraints*):**  
  `Expanded` menuntut batasan lebar yang terbatas (*bounded constraint*). Jika sebuah `Row` dengan `Expanded` diletakkan di dalam kontainer yang lebar horizontalnya tidak terbatas (misalnya di dalam `SingleChildScrollView` horizontal tanpa batasan lebar, atau `ListView` horizontal), Flutter akan melempar *RenderFlex children have non-zero flex but incoming width constraints are unbounded error*.
- **Contoh Kode Gagal:**
  ```dart
  // ERROR: Row horizontal di dalam scrollview horizontal tidak memiliki bounded width
  SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        Expanded(child: Text('Teks Panjang Mahasiswa')), // CRASH / Overflow Error
      ],
    ),
  )
  ```
- **Perbaikan:**
  Hapus `Expanded` dan gunakan lebar tetap/konten asli (`IntrinsicWidth` / `SizedBox(width: ...)`), atau batasi lebar kontainer menggunakan `SizedBox(width: MediaQuery.of(context).size.width)`.

### 3. Verification Prompt (Audit Diri Sendiri)
> **Prompt:**  
> *"Periksa kembali rekomendasi layout di atas: apakah tetap responsif di bawah 600px, apakah mengurangi aksesibilitas, dan apakah ada widget yang tidak tersedia di Flutter stabil saat ini?"*

**Ringkasan Audit AI:**
- **Responsif di bawah 600px:** Terbukti aman karena di bawah 700px, layout beralih menjadi 1 kolom penuh dengan *aspect ratio* yang cukup lega (`2.4`), dan dibungkus `SingleChildScrollView` vertikal sehingga tidak akan terjadi overflow tinggi pada layar sangat kecil (misal: 320px).
- **Aksesibilitas:** Terjaga sepenuhnya dengan `Semantics(label: ..., container: true)` pada setiap kartu dan pembaca layar dapat membaca data secara linier.
- **Stabilitas Widget:** Seluruh widget (`LayoutBuilder`, `SingleChildScrollView`, `GridView`, `Card`, `CupertinoSwitch`, `ThemeData`) merupakan widget stabil di Flutter 3.x. Penggunaan `withValues(alpha: ...)` menggantikan `withOpacity` yang telah deprecated di Flutter versi modern.

### 4. Keputusan yang Dipilih & Alasan Teknis
- Memilih kombinasi **`LayoutBuilder` + `SingleChildScrollView` + `GridView.count`** dengan `shrinkWrap: true` dan `NeverScrollableScrollPhysics()`.
- **Alasan Teknis:** Memungkinkan header profil dan grid kartu digulir bersamaan sebagai satu kesatuan halaman yang mulus (*seamless single-scroll*), sekaligus mempertahankan presisi layout multi-kolom saat layar melebar.

---

## 🧪 Verifikasi & Pengujian

### 1. Pengujian Widget (`flutter test`)
Pengujian otomatis pada file [`test/widget_test.dart`](test/widget_test.dart) mencakup 4 skenario verifikasi:
1. **Layout 1 Kolom di Layar Sempit:** Memastikan lebar kartu beradaptasi pada viewport mobile (< 700px).
2. **Layout 2 Kolom di Layar Lebar:** Memastikan lebar kartu terbagi 2 kolom pada viewport tablet/desktop (≥ 700px).
3. **Interaktivitas Switch Tema:** Memastikan `CupertinoSwitch` dapat di-tap dan mengubah ikon mode menjadi `Icons.dark_mode`.
4. **Verifikasi Konten:** Memastikan informasi profil dan kartu akademik tampil dengan benar.

**Hasil Eksekusi:**
```text
00:00 +0: loading D:/mobile/02-week-2-declarative-ui-responsive-design/test/widget_test.dart
00:00 +0: Dashboard satu kolom di layar sempit
00:01 +1: Dashboard dua kolom di layar lebar
00:02 +2: Toggle theme mengubah mode terang ke gelap
00:02 +3: Menampilkan informasi profil dan kartu akademik
00:02 +4: All tests passed!
```

### 2. Analisis Statis Kode (`flutter analyze`)
Memastikan kode bersih dari peringatan linting, deprecation, maupun error tipe data:

```text
Analyzing 02-week-2-declarative-ui-responsive-design...
No issues found! (ran in 3.1s)
```

---

## 💡 Jawaban Pertanyaan Refleksi

### 1. Apa perbedaan cara berpikir imperative dan declarative saat membangun UI?
> **Jawaban:**  
> Pada paradigma **imperative**, developer bertindak seperti memberikan instruksi langkah-demi-langkah kepada sistem untuk mengubah elemen antarmuka yang sudah ada (misalnya: *cari tombol X, ubah warnanya jadi merah, sembunyikan teks Y*).  
> Sebaliknya, pada paradigma **declarative**, developer hanya mendefinisikan aturan pemetaan tampilan antarmuka berdasarkan state yang sedang aktif ($\text{UI} = f(\text{state})$). Ketika state berubah, kita tidak perlu memodifikasi widget lama, melainkan cukup memperbarui state dan membiarkan framework membangun ulang (*rebuild*) tampilan yang sesuai secara deklaratif.

### 2. Kapan Expanded membantu dan kapan penggunaannya justru menghasilkan layout error?
> **Jawaban:**  
> - **Membantu:** Saat kita ingin elemen di dalam `Row` atau `Column` mengisi seluruh sisa ruang kosong yang tersedia secara proporsional, mencegah teks panjang meluap (*overflow*), atau membuat tata letak kolom yang seimbang.
> - **Menghasilkan Error:** Ketika `Expanded` ditempatkan di dalam kontainer yang memiliki dimensi *unbounded* (tanpa batas), seperti di dalam `SingleChildScrollView` dengan arah scroll yang sama atau `Row` di dalam `Row` horizontal tanpa batas lebar. Hal ini menyebabkan Flutter tidak dapat menghitung sisa ruang yang harus diisi dan menghasilkan exception layout.

### 3. Bagaimana breakpoint dan theme memengaruhi pengalaman pengguna?
> **Jawaban:**  
> - **Breakpoint:** Menjamin aplikasi tetap nyaman digunakan di berbagai ukuran layar (dari ponsel kecil 4 inci hingga tablet 12 inci atau layar monitor). Di layar sempit, layout 1 kolom menjaga keterbacaan teks tanpa terpotong; di layar lebar, layout multi-kolom memanfaatkan ruang kosong secara optimal tanpa membuat elemen terlalu renggang.
> - **Theme:** Memberikan kenyamanan visual sesuai preferensi pengguna dan kondisi pencahayaan lingkungan (mengurangi kelelahan mata dengan *Dark Mode* pada malam hari), sekaligus mempertahankan konsistensi identitas visual dan kontras warna yang ramah aksesibilitas.

### 4. Apa yang Anda verifikasi dari rekomendasi AI setelah tugas inti selesai?
> **Jawaban:**  
> Setelah tugas utama diimplementasikan secara mandiri, saran AI diverifikasi terhadap:
> 1. **Kesesuaian dengan Flutter Versi Stabil Terbaru:** Menolak penggunaan API yang sudah usang/deprecated (seperti mengganti `withOpacity` dengan `withValues`).
> 2. **Perilaku Responsif Nyata:** Menguji layout pada ukuran ekstrem (< 400px dan > 1000px) untuk memastikan tidak muncul error *RenderFlex overflow*.
> 3. **Standar Aksesibilitas:** Memverifikasi bahwa saran layout tidak menghilangkan *semantics tree* atau kontras warna teks terhadap latar belakang.

---

## 🚀 Cara Menjalankan Proyek

1. **Jalankan Aplikasi Flutter:**
   ```bash
   # Di Chrome browser
   flutter run -d chrome

   # Di Windows desktop
   flutter run -d windows
   ```

2. **Jalankan Automated Tests:**
   ```bash
   flutter test
   ```

3. **Jalankan Code Analyzer:**
   ```bash
   flutter analyze
   ```
