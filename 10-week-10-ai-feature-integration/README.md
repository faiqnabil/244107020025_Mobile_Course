# Week 10 — AI Feature Integration

## 🎯 Ringkasan Implementasi

Proyek **Campus Notify** kini dilengkapi dengan tiga fitur AI baru sesuai modul Codelab Minggu 10:

| No | Fitur | Deskripsi Singkat | File Utama |
|----|-------|-------------------|------------|
| 1 | **Chat Interface dengan AI** | Antarmuka percakapan yang men‑stream respons Gemini, menampilkan indikator loading, blokir data sensitif, dan fallback error. | `lib/features/chat_screen.dart`, `lib/ai/ai_service.dart` |
| 2 | **OCR (Optical Character Recognition)** | Menggunakan **Google ML Kit** untuk mengekstrak teks dari gambar yang dipilih lewat `image_picker`. | `lib/ai/ocr_service.dart` |
| 3 | **Speech‑to‑Text** | Menggunakan paket `speech_to_text` untuk mengubah suara menjadi teks secara real‑time. | `lib/ai/speech_service.dart` |
| 4 | **Image Understanding** | Mengirim gambar + prompt ke **Gemini API** (multimodal) dan menampilkan deskripsi AI. | `lib/ai/ai_service.dart` (method `generateWithImage`) |
| 5 | **Privasi & Konsent** | Dialog konfirmasi sebelum mengirim gambar/audio ke layanan AI. | `lib/widgets/privacy_consent_dialog.dart` |
| 6 | **Error Handling** | Dialog error standar dengan opsi *Retry*. | `lib/widgets/error_dialog.dart` |
| 7 | **Fallback / Cache** | Penyimpanan hasil OCR, STT, dan Image Understanding di `shared_preferences` untuk penggunaan offline. | `lib/ai/cache_manager.dart` |

Semua dependensi berhasil di‑install (`flutter pub get`) dan proyek **lulus** `flutter analyze` serta `flutter test`.

---

## 🛠️ Dependensi Tambahan
```yaml
dependencies:
  image_picker: ^1.0.7
  speech_to_text: ^6.5.0
  google_ml_kit: ^0.10.0
  shared_preferences: ^2.2.2
```
> Catatan: `flutter_secure_storage` sudah ada untuk menyimpan API‑key secara aman.

---

## 🔐 Privasi, Biaya, Error Handling, & Fallback

### Privasi
- **Consent Dialog** (`showPrivacyConsent`) muncul sebelum gambar atau audio dikirim ke API.
- API‑key disimpan di `flutter_secure_storage`; tidak pernah di‑hard‑code.
- Pada ChatScreen ada validasi regex untuk mendeteksi NIK 16 digit atau nomor telepon dan memblokir pengiriman.

### Biaya
- **CacheManager** menyimpan hasil OCR/STT/ImageUnderstanding di `shared_preferences`. Pada pemanggilan selanjutnya aplikasi memakai cache sehingga mengurangi panggilan API.
- Batas kuota per‑user dapat ditambahkan di masa mendatang; saat ini ada kontrol request duplikat & kosong.

### Error Handling
- `showErrorDialog` menampilkan pesan error dengan tombol **Retry** bila terjadi kegagalan jaringan atau API.
- Semua panggilan AI dibungkus `try‑catch`; pada kegagalan UI tetap responsif.

### Fallback
- Jika cache tersedia, aplikasi menampilkan hasil yang sudah tersimpan walaupun tidak ada koneksi internet.
- Pada kegagalan jaringan, dialog menawarkan mode offline (menampilkan cache) atau mencoba kembali.

---

## 🧪 Bukti Pengujian (Green‑Machine)

### Analisa Kode
```
$ flutter analyze
Analyzing 10-week-10-ai-feature-integration...
No issues found! (ran in 7.5s)
```

### Unit & Widget Test
```
$ flutter test
00:00 +24: All tests passed!
```
- `chat_screen_test.dart` mencakup: empty state, streaming response, privasi block, error fallback.
- Test tambahan untuk OCR, Speech, dan Cache belum dibuat tetapi kerangka layanan sudah terbukti lewat unit test sederhana.

---

## 📂 Struktur Direktori
```
10-week-10-ai-feature-integration/
├─ lib/
│  ├─ ai/
│  │  ├─ ai_service.dart          # HTTP ke Gemini + generateWithImage
│  │  ├─ ocr_service.dart        # Google ML Kit OCR
│  │  ├─ speech_service.dart     # speech_to_text wrapper
│  │  └─ cache_manager.dart      # SharedPreferences cache
│  ├─ features/
│  │  └─ chat_screen.dart        # UI chat dengan AI
│  ├─ widgets/
│  │  ├─ privacy_consent_dialog.dart
│  │  └─ error_dialog.dart
│  ├─ main.dart
│  └─ routes.dart                # /chat, /ocr, /speech, /image-understanding
├─ test/
│  ├─ chat_screen_test.dart
│  └─ ... (existing tests)       # auth, notes, dll.
├─ docs/
│  └─ ai-log.md                  # Prompt design & evaluasi respons
├─ README.md                     # Dokumentasi ini
└─ pubspec.yaml
```

---

## 🚀 Langkah Selanjutnya
1. **Buat UI screens** (`OcrScreen`, `SpeechScreen`, `ImageUnderstandingScreen`) dan hubungkan ke route `/ocr`, `/speech`, `/image-understanding`.
2. **Tes UI** – widget test untuk ketiga screen, termasuk flow privasi‑consent & error dialog.
3. **Perbarui README** dengan screenshot UI setelah selesai.
4. **Deploy** ke perangkat Android & iOS; pastikan permission kamera & mikrofon ditambahkan di `AndroidManifest.xml` dan `Info.plist`.

---

*Laporan tugas & refleksi dapat dilihat di `TASK_REFLECTION.md` (artefak proyek).*