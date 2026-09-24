import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'local/db.dart';
import 'repositories/note_repository.dart';

class Post {
  const Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
  });

  final int id;
  final int userId;
  final String title;
  final String body;

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: (json['id'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'title': title,
        'body': body,
      };
}

Future<int> syncNotes(NoteRepository repo) async {
  final dirtyCount = await repo.countDirty();
  if (dirtyCount == 0) return 0;
  // Simulasi upload ke REST API
  await Future.delayed(const Duration(seconds: 1));
  await repo.markAllSynced();
  return dirtyCount;
}

class ForceOfflineNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
  void setOffline(bool value) => state = value;
}

final forceOfflineProvider =
    NotifierProvider<ForceOfflineNotifier, bool>(ForceOfflineNotifier.new);

class PostsSyncService {
  PostsSyncService({
    Future<Database> Function()? openDb,
    Dio? dio,
  })  : _openDb = openDb ?? openNotesDb,
        _dio = dio ?? Dio();

  final Future<Database> Function() _openDb;
  final Dio _dio;

  Future<List<Post>> readCachedPosts() async {
    final db = await _openDb();
    final rows = await db.query('cached_posts', orderBy: 'id ASC');
    return rows.map((r) {
      final payloadStr = r['payload'] as String;
      return Post.fromJson(jsonDecode(payloadStr) as Map<String, dynamic>);
    }).toList();
  }

  Future<void> saveCachedPosts(List<Post> posts) async {
    final db = await _openDb();
    final batch = db.batch();
    batch.delete('cached_posts');
    final now = DateTime.now().toIso8601String();
    for (final post in posts) {
      batch.insert(
        'cached_posts',
        {
          'id': post.id,
          'payload': jsonEncode(post.toJson()),
          'cached_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Post>> loadPostsCacheFirst({
    bool forceOffline = false,
    void Function()? onBackgroundRefreshed,
  }) async {
    final cached = await readCachedPosts();

    if (!forceOffline) {
      _refreshPostsInBackground(onBackgroundRefreshed);
    }

    return cached;
  }

  void _refreshPostsInBackground(void Function()? onRefreshed) async {
    try {
      final response = await _dio.get('https://jsonplaceholder.typicode.com/posts');
      if (response.statusCode == 200 && response.data is List) {
        final list = (response.data as List)
            .map((item) => Post.fromJson(item as Map<String, dynamic>))
            .toList();
        await saveCachedPosts(list);
        if (onRefreshed != null) onRefreshed();
      }
    } catch (_) {
      // Error / offline -> diamkan agar UI menampilkan cache lokal
    }
  }
}

final postsSyncServiceProvider = Provider((ref) => PostsSyncService());

final postsProvider = FutureProvider<List<Post>>((ref) async {
  final service = ref.watch(postsSyncServiceProvider);
  final isOffline = ref.watch(forceOfflineProvider);

  return service.loadPostsCacheFirst(
    forceOffline: isOffline,
    onBackgroundRefreshed: () {
      ref.invalidateSelf();
    },
  );
});
