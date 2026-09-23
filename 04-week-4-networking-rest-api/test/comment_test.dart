import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week4_api/data/comment_providers.dart';
import 'package:week4_api/data/models/comment.dart';
import 'package:week4_api/data/repositories/comment_repository.dart';

class FakeCommentRepository extends CommentRepository {
  FakeCommentRepository({this.items, this.throwError = false})
      : super(Dio());
  final List<Comment>? items;
  final bool throwError;

  @override
  Future<List<Comment>> fetchComments(int postId) async {
    if (throwError) {
      throw DioException(
        requestOptions: RequestOptions(path: '/comments'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/comments'),
          statusCode: 404,
        ),
      );
    }
    return items ?? const [];
  }
}

void main() {
  group('Comment Model Tests', () {
    test('Comment.fromJson aman saat semua field ada', () {
      final json = {
        'postId': 1,
        'id': 10,
        'name': 'id labore ex et quam laborum',
        'email': 'Eliseo@gardner.biz',
        'body': 'laudantium enim quasi est quidem magnam voluptate ipsam eos',
      };
      final comment = Comment.fromJson(json);
      expect(comment.postId, 1);
      expect(comment.id, 10);
      expect(comment.name, 'id labore ex et quam laborum');
      expect(comment.email, 'Eliseo@gardner.biz');
      expect(comment.body, contains('laudantium'));
    });

    test('Comment.fromJson aman terhadap field yang hilang / null', () {
      final json = {'id': 5};
      final comment = Comment.fromJson(json);
      expect(comment.id, 5);
      expect(comment.postId, 0);
      expect(comment.name, '');
      expect(comment.email, '');
      expect(comment.body, '');
    });

    test('Comment.fromJson edge case: menangani string ID dan data tipe tidak terduga', () {
      final json = {
        'postId': 12.0, // float
        'id': 99,
        'name': null,
        'email': null,
        'body': null,
      };
      final comment = Comment.fromJson(json);
      expect(comment.postId, 12);
      expect(comment.id, 99);
      expect(comment.name, '');
      expect(comment.email, '');
      expect(comment.body, '');
    });

    test('Comment.toJson menghasilkan map yang sesuai', () {
      const comment = Comment(
        postId: 2,
        id: 20,
        name: 'Test Name',
        email: 'test@example.com',
        body: 'Test Body',
      );
      final json = comment.toJson();
      expect(json['postId'], 2);
      expect(json['id'], 20);
      expect(json['name'], 'Test Name');
      expect(json['email'], 'test@example.com');
      expect(json['body'], 'Test Body');
    });
  });

  group('Network Errors Mapping Tests', () {
    test('friendlyErrorMessage memetakan status 404', () {
      final err = DioException(
        requestOptions: RequestOptions(path: '/comments'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/comments'),
          statusCode: 404,
        ),
      );
      expect(friendlyErrorMessage(err), contains('404'));
    });

    test('friendlyErrorMessage memetakan status 401 dan 403', () {
      final err = DioException(
        requestOptions: RequestOptions(path: '/comments'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/comments'),
          statusCode: 401,
        ),
      );
      expect(friendlyErrorMessage(err), contains('Akses ditolak'));
    });

    test('friendlyErrorMessage memetakan status 500', () {
      final err = DioException(
        requestOptions: RequestOptions(path: '/comments'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/comments'),
          statusCode: 500,
        ),
      );
      expect(friendlyErrorMessage(err), contains('Server bermasalah'));
    });

    test('friendlyErrorMessage memetakan timeout', () {
      final err = DioException(
        requestOptions: RequestOptions(path: '/comments'),
        type: DioExceptionType.connectionTimeout,
      );
      expect(friendlyErrorMessage(err), contains('timeout'));
    });
  });

  group('Comment Provider Tests', () {
    test('commentsByPostProvider mengembalikan data dengan FakeCommentRepository',
        () async {
      final container = ProviderContainer(
        overrides: [
          commentRepositoryProvider.overrideWithValue(
            FakeCommentRepository(items: [
              const Comment(
                postId: 1,
                id: 1,
                name: 'Commenter',
                email: 'commenter@test.com',
                body: 'Great post!',
              ),
            ]),
          ),
        ],
      );
      addTearDown(container.dispose);

      final comments = await container.read(commentsByPostProvider(1).future);
      expect(comments.length, 1);
      expect(comments.first.name, 'Commenter');
      expect(comments.first.body, 'Great post!');
    });

    test('CommentNotifier fetchComments memuat data ke AsyncData', () async {
      final container = ProviderContainer(
        overrides: [
          commentRepositoryProvider.overrideWithValue(
            FakeCommentRepository(items: [
              const Comment(
                postId: 1,
                id: 2,
                name: 'User 2',
                email: 'user2@test.com',
                body: 'Very insightful!',
              ),
            ]),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(commentListProvider.notifier);
      await notifier.fetchComments(1);

      final state = container.read(commentListProvider);
      expect(state.hasValue, true);
      expect(state.value!.first.name, 'User 2');
    });

    test('CommentNotifier fetchComments menangkap error menjadi AsyncError', () async {
      final container = ProviderContainer(
        overrides: [
          commentRepositoryProvider.overrideWithValue(
            FakeCommentRepository(throwError: true),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(commentListProvider.notifier);
      await notifier.fetchComments(1);

      final state = container.read(commentListProvider);
      expect(state.hasError, true);
      expect(state.error, isA<DioException>());
    });
  });
}
