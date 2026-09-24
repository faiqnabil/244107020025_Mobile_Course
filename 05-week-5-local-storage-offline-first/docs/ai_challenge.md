# AI Challenge & Dokumen Keputusan Arsitektur Storage

**Mata Kuliah:** Pemrograman Mobile  
**Topik:** Minggu 5 - Local Storage & Offline-First  
**Project:** `week5_offline_notes`

---

## 1. Prompt AI yang Digunakan
```text
Aplikasi Flutter Offline Notes: CRUD catatan + preferensi tema.
Bandingkan SharedPreferences, Hive, sqflite (SQLite), dan Drift
untuk dua kebutuhan ini. Requirements:
- Kriteria: kompleksitas query, kebutuhan relasi, reaktivitas (stream),
  type-safety, ukuran boilerplate, dan kemudahan testing.
- Beri rekomendasi final: mana untuk preferensi, mana untuk catatan,
  beserta alasannya dalam 1 tabel.
- Tunjukkan skema tabel/kotak untuk 1000+ catatan.
Jelaskan trade-off setiap pilihan.
```

---

## 2. Output Awal AI (Raw Initial Output Summary)
AI Coding Assistant memberikan respon ringkas sebagai berikut:
- **SharedPreferences**: Sangat bagus untuk preferensi tema/pengaturan key-value, tetapi TIDAK direkomendasikan untuk daftar catatan koleksi.
- **Hive**: Cepat untuk data NoSQL key-value/box, namun tidak memiliki SQL query bawaan untuk pencarian relasional kompleks.
- **sqflite (SQLite)**: Sangat direkomendasikan untuk koleksi catatan yang memerlukan transaksi ACID, query SQL terstruktur, dan performa stabil untuk 1000+ data tanpa overhead code generation.
- **Drift**: Pilihan yang sangat powerful dengan tipe data reaktif (*Stream/watch*) dan *type-safety* tinggi via *code generation*, namun memiliki ukuran *boilerplate* dan setup terbanyak.

---

## 3. Tabel Perbandingan Opsi Storage

| Kriteria | SharedPreferences | Hive | sqflite (SQLite) | Drift |
| :--- | :--- | :--- | :--- | :--- |
| **Tipe Data & Struktur** | Key-Value Sederhana | NoSQL Key-Value / Box | Relasional SQL | Relasional SQL (Type-safe) |
| **Kompleksitas Query** | Sangat Rendah (Key lookup) | Rendah (Map lookup / Filter manual) | Tinggi (SQL Query: JOIN, WHERE, ORDER) | Tinggi (Dart Fluent API + SQL) |
| **Kebutuhan Relasi** | Tidak Ada | Tidak Ada | Sangat Baik (Foreign Key, Index) | Sangat Baik (Foreign Key, Type-safe JOIN) |
| **Reaktivitas (Stream)** | Tidak Ada | Tersedia (`watch()`) | Manual via Riverpod / StreamController | Native Stream (`watch()`) |
| **Type-Safety** | Rendah (Cast Object) | Sedang (TypeAdapter) | Sedang (Map<String, Object?>) | Sangat Tinggi (Code Generation) |
| **Ukuran Boilerplate** | Sangat Kecil | Kecil-Sedang | Sedang | Tinggi (Code Generation `build_runner`) |
| **Kemudahan Testing** | Sangat Mudah (`setMockInitialValues`) | Mudah (`Hive.init()`) | Mudah (In-Memory Database / Mock Injection) | Mudah (Native In-Memory Database) |

---

## 4. Skema Data untuk 1000+ Catatan

### SQLite (`sqflite`) Schema (Pilihan Terpilih)
```sql
CREATE TABLE notes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  body TEXT NOT NULL DEFAULT '',
  updated_at TEXT NOT NULL,
  dirty INTEGER NOT NULL DEFAULT 0
);

-- Indeks untuk pengurutan cepat dan filter status sync
CREATE INDEX idx_notes_updated_at ON notes(updated_at DESC);
CREATE INDEX idx_notes_dirty ON notes(dirty);
```

### Hive Box Schema (Alternatif NoSQL)
```dart
@HiveType(typeId: 0)
class NoteHive extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String body;

  @HiveField(3)
  DateTime updatedAt;

  @HiveField(4)
  bool dirty;
}
```

---

## 5. AI Verification Checklist & Temuan Evaluasi

1. **Penolakan Menyimpan Koleksi di SharedPreferences**:
   - **Hasil Verifikasi:** Menolak penggunaan SharedPreferences untuk daftar catatan. SharedPreferences menyimpan data dalam format file XML/plist berbasis key-value. Menyimpan 1000+ catatan sebagai single JSON string akan menyebabkan overhead parsing I/O yang besar, tidak mendukung query/sorting parsial, dan berisiko corrupt saat update bersamaan.

2. **Dukungan Antrean Sync (Dirty Flag & Timestamp)**:
   - **Hasil Verifikasi:** Skema yang dirancang menyertakan field `dirty INTEGER DEFAULT 0` dan `updated_at TEXT`. Hal ini krusial untuk mendukung pola *offline-first*, di mana setiap pembuatan/perubahan lokal ditandai `dirty = 1` agar dapat di-sync ke server saat koneksi internet kembali.

3. **Reaktivitas Stream vs Future-based Updates**:
   - **Hasil Verifikasi:** `sqflite` tidak menyediakan reaktivitas stream secara native. Namun, dengan mengombinasikannya dengan **Riverpod** (`FutureProvider` + `ref.invalidate()`), state UI dapat diperbarui secara reaktif tanpa perlu menambah kompleksitas code generation.

4. **Analisis Boilerplate & Setup**:
   - **Hasil Verifikasi:** Drift membutuhkan `build_runner` dan file `.g.dart` tambahan yang menambah waktu kompilasi dan kompleksitas project. `sqflite` memberikan keseimbangan ideal antara kontrol penuh query SQL dan kemudahan setup tanpa peranti code generator tambahan.

5. **Keputusan Final & Argumentasi Teknikal**:
   - **Preferensi (`dark_mode`, `last_opened_at`)**: Menggunakan `SharedPreferences`.
   - **Koleksi Catatan & Cache Posts**: Menggunakan `sqflite` + Riverpod.

---

## 6. Jawab Pertanyaan Refleksi Codelab

1. **Mengapa daftar catatan tidak boleh disimpan di SharedPreferences? Apa yang rusak jika aturan ini dilanggar?**
   - **Jawaban:** SharedPreferences tidak didesain untuk data koleksi atau data yang dinamis. Jika 1000+ catatan disimpan sebagai satu string JSON besar di SharedPreferences:
     - **Performa:** Setiap penambahan/perubahan kecil mengharuskan pemformatan ulang dan penulisan ulang seluruh string JSON ke disk, menyebabkan lag I/O (*UI thread blocking*).
     - **Query & Filter:** Tidak ada fitur indeks atau filter SQL. Pencarian kata kunci atau pengurutan harus me-load seluruh array ke memori RAM terlebih dahulu.
     - **Integritas Data:** Berisiko tinggi mengalami kebocoran memori dan kerusakan file (*file corruption*) jika aplikasi ditutup paksa saat proses *serialize* JSON sedang berjalan.

2. **Kapan cache-first cukup, dan kapan Anda membutuhkan strategi lain (misalnya network-first untuk data harga real-time)?**
   - **Jawaban:** 
     - **Cache-first** sangat tepat untuk data yang jarang berubah dan mengutamakan kecepatan respon UI, seperti daftar catatan pribadi, artikel berita, atau profil pengguna. UI menampilkan cache lokal seketika (0 ms delay), lalu pembaruan dilakukan di background.
     - **Network-first** (atau *network-only*) dibutuhkan saat keakuratan dan aktualitas data bersifat kritis, seperti harga saham, transaksi keuangan, ketersediaan kursi bioskop, atau tiket penerbangan real-time. Menampilkan data cache usang pada kasus ini dapat menyebabkan kerugian finansial atau kegagalan transaksi.

3. **Bagaimana dirty flag berubah menjadi antrean sync tanpa memblokir UI? Kapan antrean terpisah (tabel outbox) menjadi perlu?**
   - **Jawaban:**
     - *Dirty flag* (`dirty = 1`) ditandai secara cepat di SQLite saat pengguna menambah/mengedit catatan secara lokal. Proses sinkronisasi (`syncNotes`) dijalankan di background asynchronous task tanpa menahan *main thread* (UI tetap mulus).
     - **Tabel Outbox Terpisah** menjadi perlu saat operasi sinkronisasi membutuhkan urutan yang sangat spesifik (misal: *order of operations* seperti `CREATE -> UPDATE -> DELETE`), menyertakan payload multipart file (seperti unggah foto catatan), atau ketika terdapat berbagai jenis aksi mutasi yang kompleks yang membutuhkan *retry-policy* dan penanganan status error per item.

4. **Bagian mana dari rekomendasi AI yang Anda tolak, dan mengapa?**
   - **Jawaban:** Kami menolak rekomendasi awal AI yang menyarankan penggunaan library **Drift** untuk reaktivitas reaktif. Alasan penolakan: Drift memerlukan *code generation* via `build_runner` yang menambah ukuran *build time*, menambah dependensi berlebih untuk aplikasi skala menengah, dan memperrumit *unit testing*. Sebagai gantinya, kami menggunakan `sqflite` murni yang dikombinasikan dengan **Riverpod StateNotifier/FutureProvider** untuk mencapai reaktivitas UI yang sama bersihnya namun jauh lebih ringan.

---

## 7. Hasil Pengujian Unit & Analisis Kode
- **Status `flutter analyze`**: `No issues found!` (0 errors, 0 warnings).
- **Status `flutter test`**: `7/7 tests passed!` (100% lulus).
