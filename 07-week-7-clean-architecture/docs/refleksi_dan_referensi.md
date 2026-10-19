# Refleksi & Referensi — Week 7: Clean Architecture

## 💬 Jawaban Refleksi

### 1. Mengapa interface repository harus tinggal di domain, bukan di data? Apa yang rusak bila dibalik?
> **Jawaban:**  
> Interface repository merepresentasikan **kontrak kebutuhan bisnis** yang ditentukan oleh domain, bukan kemampuan teknis yang disediakan oleh sumber data eksternal.  
> **Konsekuensi bila dibalik (Dependency Inversion terlanggar):**  
> Jika interface berada di layer `data`, maka layer `domain` harus mengimpor layer `data`. Akibatnya, dependensi mengarah ke luar (*domain bergantung pada data*). Hal ini merusak aturan utama Clean Architecture (*Dependency Rule*): domain menjadi rentan rusak setiap kali implementasi data driver berubah (misal migrasi dari SQLite ke Hive/REST API), serta menyulitkan pembuatan unit test murni karena domain tidak lagi terisolasi.

---

### 2. Kapan use case benar-benar dibutuhkan, dan kapan repository langsung ke notifier sudah cukup?
> **Jawaban:**  
> - **Use Case Dibutuhkan Saat:** Operasi bisnis memiliki logika validasi tersendiri (misal: validasi input sebelum login), memerlukan penggabungan (*orchestration*) lebih dari satu repository (misal: sinkronisasi catatan lokal dengan cloud API), atau memiliki aturan bisnis transformasi/pemfilteran data yang kompleks dan perlu diuji secara terisolasi.  
> - **Repository Langsung ke Notifier Cukup Saat:** Operasi hanya berupa query pasif atau CRUD satu-baris sederhana (misal membaca detail data berdasarkan ID tanpa modifikasi apa pun). Memaksakan use case untuk operasi satu baris tersebut hanya akan menambah *boilerplate* tanpa nilai tambah arsitektur.

---

### 3. Apa biaya over-engineering (use case per CRUD satu-baris) bagi tim kecil? Kapan biayanya sepadan?
> **Jawaban:**  
> - **Biaya Over-Engineering bagi Tim Kecil:**  
>   - *Class Explosion*: Jumlah file bertambah drastis untuk logika yang sebenarnya hanya meneruskan satu fungsi (`repo.fetch()`).
>   - *Cognitive Overhead & Maintenance Cost*: Memperlambat kecepatan pengembangan (*velocity*) karena setiap perubahan kecil mengharuskan developer mengedit 4-5 layer file sekaligus (entity, contract, impl, use case, provider).
> - **Kapan Biayanya Sepadan:**  
>   Biaya arsitektur formal sepadan saat aplikasi memiliki skala besar (*enterprise*), tim developer berjumlah banyak dan bekerja secara paralel, atau domain bisnis memiliki aturan kompleks yang sering berganti dan memerlukan jaminan uji unit 100% tanpa menyentuh layer framework/UI.

---

### 4. Bagian mana dari usulan AI yang Anda tolak atau sederhanakan, dan mengapa?
> **Jawaban:**  
> 1. **Penolakan Sub-layer Data Source Ekstrem:** AI sempat menyarankan pembagian `remote_data_source` dan `local_data_source` untuk setiap tabel kecil. Kami menyederhanakannya dengan menyatukan akses data langsung di dalam `RepositoryImpl` karena fitur masih bersifat lokal SQLite sederhana.
> 2. **Penyederhanaan Use Case Satu-Baris:** Kami menolak usulan pembuatan kelas use case terpisah untuk setiap query CRUD sederhana (seperti `GetAnnouncementDetailUseCase`), dan hanya mempertahankan use case penting seperti `GetNotes` dan `Login` yang memiliki logika pemrosesan error atau aturan bisnis.
> 3. **Penyelarasan Tipe Kembalian Record Dart:** AI awalnya menyarankan pelemparan exception tak tertangkap ke UI. Kami menyelaraskannya dengan pola record `({List<Note> notes, Failure? failure})` sesuai standar codelab agar penanganan kegagalan bersifat eksplisit dan tipe-aman.

---

## 📚 Referensi Pendukung
- [Flutter App Architecture Guide (Official Flutter Docs)](https://docs.flutter.dev/app-architecture)
- [The Clean Architecture by Robert C. Martin (Uncle Bob)](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Riverpod Providers & Dependency Injection Guide](https://riverpod.dev/docs/concepts/providers)
- [Dart Records & Patterns Documentation](https://dart.dev/language/records)
- [Package `fpdart` & Functional Error Handling](https://pub.dev/packages/fpdart)
- [Package `sqflite` (SQLite plugin for Flutter)](https://pub.dev/packages/sqflite)
- [GoRouter Declarative Routing & Deep Linking](https://pub.dev/packages/go_router)
