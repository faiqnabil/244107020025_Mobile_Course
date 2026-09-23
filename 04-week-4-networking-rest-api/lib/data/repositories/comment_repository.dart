import 'package:dio/dio.dart';
import '../models/comment.dart';

/// Repository untuk mengakses endpoint komentar pada REST API
class CommentRepository {
  CommentRepository(this._dio);
  final Dio _dio;

  /// Mengambil daftar komentar berdasarkan [postId]
  /// Timeout 10 detik dikelola secara terpusat oleh konfigurasi Dio (BaseOptions)
  Future<List<Comment>> fetchComments(int postId) async {
    final response = await _dio.get<List>(
      '/comments',
      queryParameters: {'postId': postId},
    );
    final data = response.data ?? [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(Comment.fromJson)
        .toList();
  }
}
