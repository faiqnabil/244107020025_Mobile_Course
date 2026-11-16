# Log Interaksi AI & Prompt Design - Week 10

Modul: **Integrasi Fitur AI (Praktikum: Chat Interface dengan AI)**  
Proyek: **Campus Notify (`10-week-10-ai-feature-integration`)**  
Waktu Pelaksanaan: November 2026  

---

## 1. Prompt Design

| Komponen | Spesifikasi / Isi | Tujuan |
|---|---|---|
| **System Prompt** | "Kamu adalah asisten kampus cerdas dan ramah untuk aplikasi Campus Notify. Jawab pertanyaan mahasiswa seputar jadwal, perkuliahan, dan pengumuman dalam Bahasa Indonesia secara ringkas, jelas, dan santun. Jangan meminta atau memproses data pribadi sensitif seperti NIK, nomor telepon, atau kata sandi." | Menetapkan persona asisten, batasan domain kampus, serta regulasi privasi. |
| **User Prompt (Contoh 1)** | "Halo, kapan jadwal perkuliahan semester ganjil dimulai?" | Mengajukan pertanyaan terkait jadwal akademik kampus. |
| **User Prompt (Contoh 2)** | "Bagaimana alur pengajuan surat izin praktikum?" | Menanyakan prosedur administrasi perkuliahan. |
| **Batas & Keamanan** | Validasi input sisi klien (Regex untuk NIK 16 digit dan Nomor Telepon). Pesan diblokir sebelum dikirim ke API jika mengandung data sensitif. | Mencegah kebocoran data pengguna (*privacy leak*) ke layanan cloud pihak ketiga. |

---

## 2. Output Awal AI & Evaluasi

### Percakapan Uji Coba:
- **Input Pengguna:**  
  `"Halo, kapan jadwal perkuliahan semester ganjil dimulai?"`
- **Output Awal AI:**  
  `"Halo! Jadwal perkuliahan semester ganjil biasanya dimulai pada minggu pertama atau kedua bulan September sesuai kalender akademik kampus. Silakan cek menu Pengumuman untuk jadwal resmi dari program studi Anda."`
- **Evaluasi Respons:**  
  Respons relevan, sopan, ringkas, dan mengarahkan kembali ke modul aplikasi kampus tanpa berhalusinasi atau memberikan informasi palsu.

---

## 3. Catatan Keputusan Teknis & Verifikasi

1. **Penyimpanan Kunci API (`AiService`)**:
   - Menggunakan `flutter_secure_storage` dengan key `'ai_api_key'` agar API Key Google Gemini tidak tersimpan *hardcoded* di source code.
2. **Streaming Response & UX (`ChatScreen`)**:
   - Menggunakan `StreamBuilder<String>` untuk menampilkan teks secara mengalir (streaming) seperti respons LLM modern.
   - Dilengkapi indikator pemuatan (*loading indicator* / `"AI sedang mengetik..."`) saat menunggu respons dari `AiService.ask(question)`.
   - Dilengkapi penanganan fallback dengan dialog ramah (`"Layanan AI Sibuk: Coba lagi nanti atau gunakan mode offline"`).
3. **Penyaringan Data Sensitif**:
   - Deteksi Regex otomatis pada input teks pengguna terhadap pola NIK 16 digit dan nomor HP Indonesia untuk menjamin kepatuhan regulasi privasi data.
