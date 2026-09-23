# Dokumentasi AI Challenge — Minggu 4: Networking & REST API

**Mata Kuliah:** Pemrograman Mobile  
**Topik:** Integrasi AI Assistant untuk Pembuatan Repository Layer, Model Null-Safe, Provider, dan Testing  
**Tanggal:** 16 September 2026  
**Penulis / Mahasiswa:** Muhammad Faiq Nabil Saputra (NIM: 244107020025)

---

## 1. Prompt yang Digunakan

Prompt berikut diberikan kepada AI Coding Assistant sesuai arahan jobsheet Codelab Minggu 4:

```text
Buatkan repository layer Flutter untuk endpoint GET /comments?postId={id}
dari JSONPlaceholder menggunakan Dio + flutter_riverpod.
Requirements:
- Model Comment dengan fromJson aman null (postId, id, name, email, body).
- CommentRepository dengan method fetchComments(postId) + timeout 10 detik.
- AsyncNotifierProvider dengan penanganan error otomatis (AsyncError)
  dan fungsi pesan error ramah pengguna untuk timeout, connection error, 404, dan 500.
- Satu unit test untuk fromJson dengan field yang hilang.
Jelaskan setiap bagian kode dalam komentar.
```

---

## 2. Output Awal AI

Output awal yang dihasilkan AI mencakup:
1. **Model `Comment`:**
   ```dart
   class Comment {
     final int postId;
     final int id;
     final String name;
     final String email;
     final String body;

     Comment({
       required this.postId,
       required this.id,
       required this.name,
       required this.email,
       required this.body,
     });

     factory Comment.fromJson(Map<String, dynamic> json) {
       return Comment(
         postId: json['postId'] as int? ?? 0, // potensi isu jika format JSON berupa num/double
         id: json['id'] as int? ?? 0,
         name: json['name'] as String? ?? '',
         email: json['email'] as String? ?? '',
         body: json['body'] as String? ?? '',
       );
     }
   }
   ```
2. **Repository `CommentRepository`:**
   Membuat instance `Dio` baru di dalam method secara independen dengan timeout lokal, bukan memanfaatkan `dioProvider` yang sudah dikonfigurasi secara terpusat.
3. **Provider & Error Handling:**
   Mendefinisikan fungsi `friendlyErrorMessage` yang terduplikasi dari modul `providers.dart`, serta belum memiliki guard retry Riverpod untuk pengujian test runner.
4. **Unit Test:**
   Hanya menyediakan 1 test happy-path sederhana tanpa menguji skenario edge case tipe data atau pengujian state provider menggunakan fake repository.

---

## 3. AI Verification Checklist & Analisis Kritis

Sesuai checklist evaluasi teknis pada Codelab Minggu 4, berikut adalah hasil verifikasi:

| Kriteria Checklist | Status | Catatan Analisis & Tindakan |
|---|:---:|---|
| **1. UI tidak memanggil Dio langsung** | ✅ **Lolos** | Akses data dibatasi melalui `CommentRepository` dan provider (`commentListProvider` & `commentsByPostProvider`). UI tidak memiliki referensi langsung ke `Dio`. |
| **2. `fromJson` aman terhadap null** | ⚠️ **Perlu Perbaikan** | Output awal memakai `json['postId'] as int?`. Jika API mengembalikan nilai floating-point (misal `1.0`), cast ini akan melempar exception `type 'double' is not a subtype of type 'int?'`. Diperbaiki menjadi `(json['postId'] as num?)?.toInt() ?? 0`. |
| **3. Pemetaan `DioExceptionType` lengkap** | ✅ **Lolos** | Semua tipe error umum (`connectionTimeout`, `sendTimeout`, `receiveTimeout`, `connectionError`, `badResponse` status 401, 403, 404, 500) dipetakan ke pesan ramah bahasa Indonesia. |
| **4. Base URL & Timeout terpusat** | ⚠️ **Perlu Perbaikan** | Output awal membuat `Dio()` baru di dalam repositori. Diperbaiki dengan menginjeksi `ref.watch(dioProvider)` agar mewarisi `baseUrl`, `connectTimeout`, `receiveTimeout`, dan `LogInterceptor` dari `api_client.dart`. |
| **5. Pengujian edge case field hilang & tipe data** | ⚠️ **Perlu Perbaikan** | Ditambahkan pengujian khusus untuk field yang sepenuhnya `null`/absen, serta ditambahkan edge case pengujian nilai numerik float (`num`). Ditambahkan pula unit test provider menggunakan `FakeCommentRepository`. |
| **6. `flutter analyze` & `flutter test` lolos tanpa warning** | ✅ **Lolos** | Seluruh kode di-refactor hingga bersih dari *lint errors* dan semua test lulus 100%. |

---

## 4. Perbaikan & Refactoring yang Dilakukan

Berdasarkan temuan di atas, dilakukan sejumlah perbaikan arsitektural:

1. **Sentralisasi Penanganan Pesan Error (`lib/data/network_errors.dart`):**
   Memisahkan `friendlyErrorMessage` ke file mandiri agar dapat digunakan ulang secara bersih oleh `providers.dart`, `comment_providers.dart`, dan halaman UI tanpa duplikasi kode.
2. **Injeksi Dependency Terpusat:**
   `CommentRepository` kini menerima `Dio` melalui constructor (`CommentRepository(this._dio)`), dan di-provide melalui `commentRepositoryProvider`:
   ```dart
   final commentRepositoryProvider = Provider<CommentRepository>(
     (ref) => CommentRepository(ref.watch(dioProvider)),
   );
   ```
3. **Penyempurnaan Model Null-Safe:**
   Menggunakan `(json['...'] as num?)?.toInt() ?? 0` dan menambahkan constructor `const` serta method `toJson()`.
4. **Penyediaan `FutureProvider.family` Tambahan:**
   Menambahkan `commentsByPostProvider` yang mempermudah pemanggilan komentar berdasarkan `postId` langsung dari UI widget secara deklaratif.
5. **Ekspansi Test Suite (`test/comment_test.dart`):**
   Menyusun 8 skenario pengujian komprehensif:
   - Deserialization lengkap & field hilang.
   - Edge case tipe `double` to `int` dan nilai `null`.
   - Serialization `toJson()`.
   - Pemetaan error status HTTP 401, 403, 404, 500, dan timeout.
   - Provider test sukses & error menggunakan `FakeCommentRepository`.

---

## 5. Hasil Pengujian (Test Results)

Pengujian dijalankan melalui Flutter Test Runner:

```bash
flutter test test/comment_test.dart
```

**Output Terminal:**
```text
00:00 +0: loading test/comment_test.dart
00:00 +0: Comment Model Tests Comment.fromJson aman saat semua field ada
00:00 +1: Comment Model Tests Comment.fromJson aman terhadap field yang hilang / null
00:00 +2: Comment Model Tests Comment.fromJson edge case: menangani string ID dan data tipe tidak terduga
00:00 +3: Comment Model Tests Comment.toJson menghasilkan map yang sesuai
00:00 +4: Network Errors Mapping Tests friendlyErrorMessage memetakan status 404
00:00 +5: Network Errors Mapping Tests friendlyErrorMessage memetakan status 401 dan 403
00:00 +6: Network Errors Mapping Tests friendlyErrorMessage memetakan status 500
00:00 +7: Network Errors Mapping Tests friendlyErrorMessage memetakan timeout
00:00 +8: Comment Provider Tests commentsByPostProvider mengembalikan data dengan FakeCommentRepository
00:00 +9: Comment Provider Tests CommentNotifier fetchComments memuat data ke AsyncData
00:00 +10: Comment Provider Tests CommentNotifier fetchComments menangkap error menjadi AsyncError
00:01 +11: All tests passed!
```

---

## 6. Kesimpulan & Refleksi

Integrasi AI coding assistant sangat mempercepat pembuatan kode *boilerplate* (model serialization, repository class, dan provider setup). Namun, campur tangan *engineer* tetap krusial untuk:
- Memastikan arsitektur tetap bersih (*Clean / Repository Pattern* tidak dilanggar).
- Memastikan *edge cases* seperti konversi numerik JSON dan ketiadaan field tidak memicu *runtime crash*.
- Menjamin konsistensi konfigurasi jaringan (timeout & interceptor terpusat).
- Merancang *mock / fake repository* agar unit test tidak melakukan panggilan HTTP sungguhan yang rentan *flaky*.
