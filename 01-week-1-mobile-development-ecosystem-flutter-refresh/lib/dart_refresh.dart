// ignore_for_file: avoid_print

/// Latihan Mandiri Dart Refresh - Minggu 1
/// Nama: Muhammad Faiq Nabil Saputra
/// NIM: 244107020025
library;

/// 1. Fungsi hitungLuasPersegiPanjang yang menerima panjang dan lebar bertipe double.
double hitungLuasPersegiPanjang(double panjang, double lebar) {
  return panjang * lebar;
}

/// 2. Class Profil dengan properti nama, nim, dan email yang boleh kosong (nullable).
class Profil {
  final String nama;
  final String nim;
  final String? email;

  Profil({
    required this.nama,
    required this.nim,
    this.email,
  });

  String status() {
    return 'Mahasiswa: $nama | NIM: $nim';
  }
}

/// 3. Fungsi main() untuk menguji fungsi dan class dengan penanganan null safety.
void main() {
  print('=============================================');
  print('PRAKTIKUM DART REFRESH - MINGGU 1');
  print('Nama : Muhammad Faiq Nabil Saputra');
  print('NIM  : 244107020025');
  print('=============================================\n');

  // Uji 1: Fungsi hitungLuasPersegiPanjang
  print('--- 1. Perhitungan Luas Persegi Panjang ---');
  double panjang = 12.5;
  double lebar = 6.0;
  double luas = hitungLuasPersegiPanjang(panjang, lebar);
  print('Panjang : $panjang');
  print('Lebar   : $lebar');
  print('Luas    : $luas\n');

  // Uji 2: Profil dengan email terisi
  print('--- 2. Profil Mahasiswa (Email Terisi) ---');
  Profil mhs1 = Profil(
    nama: 'Muhammad Faiq Nabil Saputra',
    nim: '244107020025',
    email: 'faiq.nabil@example.com',
  );
  print(mhs1.status());
  print('Email   : ${mhs1.email?.toUpperCase() ?? 'BELUM DIISI'}\n');

  // Uji 3: Profil dengan email null (kosong) dengan penanganan aman
  print('--- 3. Profil Mahasiswa (Email Kosong / Null Safety) ---');
  Profil mhs2 = Profil(
    nama: 'Muhammad Faiq Nabil Saputra',
    nim: '244107020025',
    email: null,
  );
  print(mhs2.status());
  print('Email   : ${mhs2.email?.toUpperCase() ?? 'BELUM DIISI'}\n');
  print('=============================================');
}
