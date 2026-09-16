# Week 3 — Navigation & State Management

**Mata Kuliah:** Pemrograman Mobile  
**Minggu:** 03  
**Topik:** Declarative Navigation (GoRouter), State Management (Riverpod), AsyncValue, dan Testing  

---

## 👤 Identitas Mahasiswa
- **Nama:** Muhammad Faiq Nabil Saputra  
- **NIM:** 244107020025  
- **Kelas / Program Studi:** TI-3D / D4 Teknik Informatika  
- **Jurusan:** Jurusan Teknologi Informasi — Politeknik Negeri Malang  

---

## 🎯 Tujuan Pembelajaran
Setelah menyelesaikan modul jobsheet Minggu 3 ini, mahasiswa mampu:
1. Menjelaskan konsep navigasi, route, dan perbedaan mendasar antara **Navigator 1.0 (imperatif)** dengan **GoRouter (deklaratif)**.
2. Menerapkan navigasi multi-page dengan **GoRouter**, termasuk parsing path parameter (`/detail/:id`), deep linking, dan tab navigasi dengan `StatefulShellRoute`.
3. Menjelaskan mengapa state management diperlukan dan cara kerja **Riverpod** (`ProviderScope`, `Provider`, `Notifier`, `NotifierProvider`, serta `ConsumerWidget`).
4. Menggunakan **`AsyncValue`** (`AsyncLoading`, `AsyncError`, `AsyncData`) untuk menangani state asinkron secara aman dan komprehensif pada antarmuka pengguna.
5. Membangun aplikasi ToDo terintegrasi dengan navigasi dan Riverpod, serta memverifikasi logika bisnis maupun UI menggunakan *unit test* dan *widget test*.

---

## 📚 Ringkasan Teori & Konsep

### 1. Navigasi Imperatif (Navigator 1.0) vs Deklaratif (GoRouter)
- **Navigator 1.0 (Imperatif):** Perpindahan layar dilakukan secara manual dengan memanipulasi tumpukan stack (`Navigator.push()`, `Navigator.pop()`). Pendekatan ini sulit dipelihara pada aplikasi berskala menengah ke atas, menyulitkan penanganan deep linking, dan membuat mekanisme *route guard* (seperti redirect autentikasi) tersebar di banyak tempat.
- **GoRouter (Deklaratif):** Router resmi yang direkomendasikan Flutter di mana seluruh rute didefinisikan secara terpusat. State URL/path menentukan layar yang aktif ($\text{Route} = f(\text{Location})$).
  - `context.go()`: Mengganti stack navigasi menuju path target (sangat cocok untuk redirect login atau berpindah tab utama).
  - `context.push()`: Menumpuk route baru di atas stack (cocok untuk membuka halaman detail dengan tombol *back*).
  - `state.pathParameters`: Mengambil parameter dinamis dari URL (contoh: `/detail/:id`).

### 2. State Management & Riverpod
Ketika state harus dibagikan lintas halaman (misalnya daftar tugas yang ditampilkan di Home dan dimutasi di halaman lain), menaikkan state ke atas widget tree (*lifting state up*) menyebabkan *prop drilling*. State management memisahkan state dari siklus hidup UI:
- **`ProviderScope`**: Wadah root global yang menyimpan dan mengelola seluruh siklus hidup provider.
- **`Notifier<T>` & `NotifierProvider`**: Mengelola state sinkron yang dapat berubah melalui method terstruktur. Pembaruan state harus bersifat **immutable** (`state = [...state, newItem]`).
- **`ConsumerWidget` & `WidgetRef`**:
  - `ref.watch(provider)`: Digunakan di dalam method `build()` untuk berlangganan perubahan state (memicu rebuild otomatis saat state berubah).
  - `ref.read(provider.notifier)`: Digunakan di dalam *event handler* / callback untuk memanggil method tanpa berlangganan perubahan.

### 3. Penanganan State Asinkron dengan `AsyncValue`
Proses asinkron (seperti request API atau pembacaan database) memiliki tiga status fundamental:
1. **Loading** (proses sedang berjalan)
2. **Error** (proses gagal, membawa exception & stack trace)
3. **Data / Success** (data berhasil diterima)

Mengelola ketiga kondisi menggunakan variabel boolean terpisah (`bool isLoading`, `bool hasError`) rentan menyebabkan inkonsistensi state (misal `isLoading == true` dan `hasError == true` secara bersamaan). `AsyncValue<T>` memodelkan ketiga kondisi tersebut dalam satu tipe data union yang aman (*compile-safe*) dan dapat diproses menggunakan pattern matching `.when(loading: ..., error: ..., data: ...)`.

---

## 🛠️ Implementasi Praktikum & Refactoring

### 1. Praktikum 1 — Aplikasi Multi-Page dengan GoRouter
- Membangun konfigurasi rute deklaratif pada `lib/router.dart` dengan path `/` dan dynamic sub-route `/detail/:id`.
- Implementasi `HomePage` dan `DetailPage` yang menerima path parameter `id` melalui `state.pathParameters['id']!`.

### 2. Praktikum 2 — Aplikasi ToDo dengan Riverpod
- Membangun model immutable `Todo` dengan method `copyWith`.
- Membuat `TodoListNotifier` turunan `Notifier<List<Todo>>` yang menyediakan fungsi `add()`, `toggle()`, dan `remove()`.
- Menyusun `TodoPage` berbasis `ConsumerWidget` yang memanfaatkan `ref.watch` untuk menampilkan daftar tugas dan dialog input tugas baru.

### 3. Praktikum 3 — Uji Ketiga State AsyncValue
- Mengembangkan `StatsNotifier` turunan `AsyncNotifier<List<String>>` yang mensimulasikan delay jaringan (2 detik) dan kegagalan acak.
- Menggunakan `AsyncValue.when` pada `StatsPage` untuk menampilkan indikator loading (`CircularProgressIndicator`), tampilan error dengan tombol retry (`ref.invalidate`), serta daftar data sukses.

### 4. Refactoring Challenge
1. **Pemisahan Widget Modular (`TodoTile`):**  
   Mengekstrak baris item ToDo menjadi widget mandiri di `lib/widgets/todo_tile.dart` dengan checkbox, coretan teks ketika selesai, dan tombol hapus.
2. **Ekstraksi Filter Provider:**  
   Menambahkan `TodoFilterNotifier` (`enum TodoFilter { all, active, completed }`) dan derived provider `filteredTodoListProvider` yang otomatis menyaring item berdasarkan filter aktif.
3. **Integrasi GoRouter & Bottom NavigationBar:**  
   Mengimplementasikan `StatefulShellRoute.indexedStack` bersama `ShellScaffold` yang menyediakan `NavigationBar` Material 3 untuk navigasi mulus antara tab **Daftar ToDo** (`/`) dan **Statistik** (`/stats`).

---

## 📂 Struktur Proyek
```text
03-week-3-navigation-state-management/
├── lib/
│   ├── models/
│   │   └── todo.dart                 # Model data Todo (title, done, copyWith)
│   ├── pages/
│   │   ├── detail_page.dart          # Halaman detail berparameter /detail/:id
│   │   ├── shell_scaffold.dart       # Shell Scaffold dengan NavigationBar tab
│   │   ├── stats_page.dart           # Halaman statistik dengan AsyncValue (AI Challenge)
│   │   └── todo_page.dart            # Halaman utama ToDo dengan Segmented Filter
│   ├── providers/
│   │   ├── stats_provider.dart       # AsyncNotifier & AsyncNotifierProvider
│   │   └── todo_provider.dart        # TodoListNotifier, FilterNotifier & Derived Provider
│   ├── widgets/
│   │   └── todo_tile.dart            # Widget baris TodoTile modular
│   ├── main.dart                     # Entrypoint dibungkus ProviderScope & MaterialApp.router
│   └── router.dart                   # Konfigurasi GoRouter StatefulShellRoute
├── test/
│   ├── stats_provider_test.dart      # Unit test AsyncNotifier (success & failure cases)
│   ├── todo_provider_test.dart       # Unit test TodoListNotifier & filter logic
│   └── widget_test.dart              # Automated widget test (add task, toggle, navigation)
├── docs/
│   └── ai_challenge.md               # Dokumentasi prompt AI, verification checklist & perbaikan
├── screenshots/                      # Direktori artefak visual pengujian aplikasi
├── pubspec.yaml                      # Dependensi: flutter_riverpod, go_router
└── README.md                         # Laporan lengkap Jobsheet Minggu 3
```

---

## 🧪 Hasil Pengujian & Verifikasi

### 1. Static Analysis (`flutter analyze`)
```bash
flutter analyze
```
**Hasil:**
```text
Analyzing 03-week-3-navigation-state-management...
No issues found! (ran in 10.4s)
```

### 2. Automated Test Suite (`flutter test`)
```bash
flutter test
```
**Hasil:**
```text
00:00 +0: StatsNotifier Unit Tests StatsNotifier mengembalikan data statistik yang sesuai saat sukses
00:02 +6: StatsNotifier Unit Tests StatsNotifier menghasilkan AsyncError ketika terjadi kegagalan jaringan
00:05 +7: menambah tugas baru
00:09 +8: toggle status checkbox tugas
00:09 +9: navigasi antar tab NavigationBar
00:10 +10: All tests passed!
```

---

## 💡 Refleksi Pembelajaran (Jawaban Pertanyaan Modul)

### 1. Kapan `setState` masih cukup, dan kapan state harus naik ke Riverpod?
- **`setState` masih cukup ketika:** State bersifat murni lokal di dalam satu widget tertutup, tidak perlu dibagikan ke widget/halaman lain, dan tidak memiliki dependensi logika bisnis yang rumit (contoh: status teks pada `TextEditingController`, membuka/menutup expansion tile, atau animasi lokal).
- **State harus naik ke Riverpod ketika:**
  1. State perlu diakses atau dimodifikasi oleh beberapa halaman/widget berbeda tanpa *prop drilling*.
  2. State harus tetap bertahan dalam memori meskipun widget tampilannya di-*dispose* (misal saat berpindah halaman).
  3. Logika bisnis dan manajemen data perlu diuji secara terisolasi (*unit testing*) tanpa harus me-render widget tree.

### 2. Apa perbedaan `context.go` dan `context.push`, dan kapan masing-masing tepat digunakan?
- **`context.go(path)`:** Mengubah lokasi rute secara deklaratif dan **mengganti struktur stack navigasi** sesuai hierarki rute yang ditentukan di router. Tepat digunakan untuk navigasi tingkat atas, perpindahan tab, atau *redirection* setelah login/logout di mana pengguna tidak seharusnya menekan tombol *back* untuk kembali ke halaman sebelumnya.
- **`context.push(path)`:** Menambahkan/menumpuk (*push*) rute baru **di atas stack navigasi saat ini** tanpa menghapus stack di bawahnya. Tepat digunakan untuk membuka layar detail, modal form, atau alur bertahap di mana tombol *back* sistem/AppBar diharapkan membawa pengguna kembali ke layar pemanggil.

### 3. Bagaimana `AsyncValue` mencegah bug dibanding tiga boolean terpisah?
Menggunakan 3 variabel boolean terpisah (`bool isLoading`, `bool hasError`, `Object? data`) memiliki kelemahan struktural:
- Ada kemungkinan terjadi **kondisi state tidak valid / inkonsisten**, misalnya `isLoading == true` dan `hasError == true` terjadi bersamaan akibat lupa me-reset salah satu flag.
- Rentan terhadap *developer error* seperti lupa menangani kondisi error sehingga aplikasi menampilkan layar putih (*blank screen*).
- **`AsyncValue` mencegah bug ini** dengan memanfaatkan tipe data terpadu (*sealed union*). Pada satu waktu, state hanya bisa berada di salah satu dari tiga varian: `AsyncLoading`, `AsyncError`, atau `AsyncData`. Melalui fungsi pattern matching `.when()`, compiler mewajibkan penanganan seluruh skenario, memastikan antarmuka selalu menampilkan visual yang valid dan konsisten.

### 4. Bagian mana dari hasil AI yang Anda perbaiki, dan mengapa?
Berdasarkan pengerjaan **AI Challenge** (didokumentasikan lengkap pada [`docs/ai_challenge.md`](docs/ai_challenge.md)):
1. **Penggunaan API Refresh/Invalidate:** AI awalnya menggunakan `ref.refresh` usang di dalam widget. Hal ini diperbaiki menjadi `ref.invalidate(statsProvider)` atau memanggil method pada notifier `ref.read(statsProvider.notifier).refresh()`.
2. **Duplikasi Logika Pengambilan Data:** AI menduplikasi pembuatan list data di dalam method `build()` dan `refresh()`. Kode direfaktor menjadi satu method privat `_fetchStats()` yang didelegasikan menggunakan `AsyncValue.guard`.
3. **Dukungan Pengujian Deterministik (*Testability*):** Kode awal AI menggunakan `Random()` langsung tanpa opsi injeksi, sehingga unit test sulit memverifikasi kondisi sukses dan gagal secara konsisten. Constructor diperbaiki agar dapat menerima parameter `Random` dan flag simulasi untuk pengujian unit test.
4. **Deprecation Fixes:** Memperbaiki penggunaan `.withOpacity()` menjadi `.withValues(alpha: 0.15)` sesuai standar Flutter Material 3 terbaru.

---

## 🚀 Cara Menjalankan Proyek

1. **Pastikan Flutter SDK terpasang:**
   ```bash
   flutter --version
   ```

2. **Masuk ke direktori minggu 3 dan instal dependensi:**
   ```bash
   cd 03-week-3-navigation-state-management
   flutter pub get
   ```

3. **Menjalankan analisis kode statis:**
   ```bash
   flutter analyze
   ```

4. **Menjalankan seluruh unit test dan widget test:**
   ```bash
   flutter test
   ```

5. **Menjalankan aplikasi di emulator atau browser:**
   ```bash
   flutter run
   ```
