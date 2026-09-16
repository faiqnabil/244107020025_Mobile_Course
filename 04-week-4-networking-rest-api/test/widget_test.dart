import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week4_api/data/models/post.dart';
import 'package:week4_api/data/providers.dart';
import 'package:week4_api/data/repositories/post_repository.dart';
import 'package:week4_api/pages/post_list_page.dart';
import 'package:week4_api/widgets/post_tile.dart';

class MockPostRepository extends PostRepository {
  MockPostRepository({this.posts = const [], this.throwError = false})
      : super(Dio());
  final List<Post> posts;
  final bool throwError;

  @override
  Future<List<Post>> fetchPosts() async {
    if (throwError) {
      throw DioException(
        requestOptions: RequestOptions(path: '/posts'),
        type: DioExceptionType.connectionError,
      );
    }
    return posts;
  }
}

void main() {
  testWidgets('PostListPage menampilkan daftar post dengan PostTile saat data sukses',
      (tester) async {
    final mockRepo = MockPostRepository(
      posts: [
        const Post(
          userId: 1,
          id: 101,
          title: 'Testing Flutter Riverpod',
          body: 'Belajar networking REST API dengan Dio dan Riverpod.',
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          postRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: const MaterialApp(
          home: PostListPage(),
        ),
      ),
    );

    // Initial loading
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Wait for async provider build to complete
    await tester.pumpAndSettle();

    // Verify PostTile renders correctly
    expect(find.byType(PostTile), findsOneWidget);
    expect(find.text('Testing Flutter Riverpod'), findsOneWidget);
    expect(find.text('101'), findsOneWidget);
  });

  testWidgets('PostListPage menampilkan pesan error dan tombol Coba lagi saat gagal',
      (tester) async {
    final mockRepo = MockPostRepository(throwError: true);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          postRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: const MaterialApp(
          home: PostListPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify error UI
    expect(find.text('Coba lagi'), findsOneWidget);
    expect(find.textContaining('Tidak dapat terhubung'), findsOneWidget);
  });
}
