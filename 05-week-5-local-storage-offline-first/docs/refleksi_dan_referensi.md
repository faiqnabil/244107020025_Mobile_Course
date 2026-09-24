# Laporan Tugas, Refleksi, dan Referensi (Minggu 5)

## 1. Aturan Konflik Sinkronisasi (Conflict Resolution Policy)
Pada arsitektur *offline-first*, konflik dapat terjadi ketika data yang sama diubah di dua perangkat yang berbeda saat offline.
- **Aturan Konflik yang Diterapkan:** *Last-Write-Wins (LWW)* berbasis stempel waktu `updated_at`.
- **Mekanisme:**
  1. Setiap perubahan lokal mencatat stempel waktu `updated_at` (ISO 8601 UTC).
  2. Saat fungsi `syncNotes` membandingkan catatan lokal dan data server, catatan dengan timestamp `updated_at` paling baru akan memenangkan konflik dan memperbarui catatan yang lebih lama.
  3. Setelah sukses diunggah ke server, status `dirty` diubah dari `1` menjadi `0`.

---

## 2. Refleksi Pembelajaran

### Q1: Mengapa daftar catatan tidak boleh disimpan di SharedPreferences? Apa yang rusak jika aturan ini dilanggar?
> **Jawaban:** SharedPreferences didesain murni untuk key-value preferensi kecil (seperti boolean `dark_mode` atau string `language`). Menyimpan daftar catatan koleksi di SharedPreferences melanggar prinsip *data persistence*:
> - **Performa I/O:** Setiap penambahan 1 catatan mengharuskan aplikasi me-load seluruh array catatan, mengonversinya ke JSON String, dan menulis ulang file fisik disk. Hal ini menyebabkan lag I/O dan memblokir *UI main thread*.
> - **Tidak Ada Query/Filter:** SharedPreferences tidak mendukung query SQL (`WHERE`, `ORDER BY`, `LIMIT`). Pencarian catatan harus me-load seluruh data ke RAM memori.
> - **Risiko Data Corrupt:** Jika aplikasi tertutup mendadak saat proses pemformatan JSON string, seluruh file preferensi berisiko rusak (*corrupt*) dan kehilangan semua catatan pengguna.

### Q2: Kapan cache-first cukup, dan kapan Anda membutuhkan strategi lain (misalnya network-first untuk data harga real-time)?
> **Jawaban:**
> - **Cache-First (Cache-First Read):** Cukup dan ideal untuk data yang jarang berubah atau data personal di mana kecepatan *load UI* adalah prioritas utama (seperti catatan pribadi, artikel berita, feed media sosial). UI langsung terbuka 0ms tanpa menunggu jaringan.
> - **Network-First / Network-Only:** Sangat dibutuhkan untuk data kritis yang cepat berubah di mana menyajikan data usang (*stale data*) berbahaya atau berdampak finansial. Contohnya: harga saham/kripto, saldo dompet digital, ketersediaan tiket penerbangan, atau pemesanan tempat duduk.

### Q3: Bagaimana dirty flag berubah menjadi antrean sync tanpa memblokir UI? Kapan antrean terpisah (tabel outbox) menjadi perlu?
> **Jawaban:**
> - **Tanpa Memblokir UI:** Penandaan `dirty = 1` dilakukan secara instan di SQLite lokal saat pengguna menekan tombol simpan (operasi lokal < 2 ms). Operasi penyinkronan jaringan (`syncNotes`) dilakukan secara asynchronous (*non-blocking Future/background worker*), sehingga pengguna dapat terus menggunakan UI tanpa hambatan.
> - **Kapan Tabel Outbox Terpisah Dibutuhkan:** Tabel outbox terpisah menjadi perlu ketika mutasi aplikasi memiliki urutan ketergantungan yang kompleks (seperti `CREATE_NOTE -> UPLOAD_ATTACHMENT -> UPDATE_TAGS`), memerlukan penanganan status *retry* per-payload, atau saat transaksi mutasi melibatkan banyak entity yang saling berhubungan.

### Q4: Bagian mana dari rekomendasi AI yang Anda tolak, dan mengapa?
> **Jawaban:** Kami menolak rekomendasi awal AI yang menyarankan penggunaan library **Drift** untuk reaktivitas stream.
> - **Alasan:** Drift memerlukan konfigurasi `build_runner` dan *code generation* yang menambah waktu kompilasi (*build time*) dan ukuran project. Sebagai gantinya, kami menggunakan SQLite murni via `sqflite` yang dipadukan dengan **Riverpod** (`FutureProvider` + `ref.invalidate()`) yang jauh lebih ringan, tetap reaktif, dan sangat mudah diuji tanpa dependensi *code generator*.

---

## 3. Referensi Pendukung
1. [Slide Materi Week 5: Local Storage & Offline First](https://drive.google.com/file/d/1Yd0sypJO85c-sWK_HRg4enjRHiA-NWfu/view)
2. [Flutter Cookbook: Store key-value data](https://docs.flutter.dev/cookbook/persistence/key-value)
3. [Pub.dev: shared_preferences package](https://pub.dev/packages/shared_preferences)
4. [Pub.dev: sqflite package](https://pub.dev/packages/sqflite)
5. [Riverpod Documentation: AsyncNotifier and AsyncValue](https://riverpod.dev/docs/concepts/async_notifiers)
6. [Learn Dart in Y Minutes](https://learnxinyminutes.com/dart/)
