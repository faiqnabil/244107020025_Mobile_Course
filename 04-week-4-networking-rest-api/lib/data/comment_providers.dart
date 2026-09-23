import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/comment.dart';
import 'providers.dart';
import 'repositories/comment_repository.dart';

export 'network_errors.dart';

/// Provider untuk CommentRepository yang memanfaatkan dioProvider terpusat
final commentRepositoryProvider = Provider<CommentRepository>(
  (ref) => CommentRepository(ref.watch(dioProvider)),
);

/// AsyncNotifier untuk mengelola daftar komentar dengan penanganan status error/loading otomatis
class CommentNotifier extends AsyncNotifier<List<Comment>> {
  @override
  Future<List<Comment>> build() async {
    // State awal kosong sebelum postId dipanggil
    return [];
  }

  /// Mengambil komentar berdasarkan postId dan mengubah error jaringan menjadi AsyncError
  Future<void> fetchComments(int postId) async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(commentRepositoryProvider);
      final comments = await repository.fetchComments(postId);
      state = AsyncData(comments);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

/// AsyncNotifierProvider untuk komentar dengan retry dinonaktifkan untuk testing
final commentListProvider =
    AsyncNotifierProvider<CommentNotifier, List<Comment>>(
  CommentNotifier.new,
  retry: (retryCount, error) => null,
);

/// Family FutureProvider untuk memuat komentar otomatis berdasarkan ID post
final commentsByPostProvider =
    FutureProvider.autoDispose.family<List<Comment>, int>((ref, postId) async {
  final repository = ref.watch(commentRepositoryProvider);
  return repository.fetchComments(postId);
});
