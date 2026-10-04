import 'package:dio/dio.dart';

String friendlyErrorMessage(Object error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi internet lambat / RTO.';
      case DioExceptionType.badResponse:
        if (error.response?.statusCode == 401) {
          return 'Sesi habis, silakan login kembali.';
        }
        return 'Terjadi kesalahan pada server (${error.response?.statusCode}).';
      case DioExceptionType.cancel:
        return 'Permintaan dibatalkan.';
      default:
        return 'Gagal terhubung ke jaringan.';
    }
  }
  return error.toString();
}
