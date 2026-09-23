import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week4_api/data/models/post.dart';
import 'package:week4_api/data/providers.dart';
import 'package:week4_api/main.dart';
import 'package:week4_api/widgets/post_tile.dart';
import 'post_test.dart';

void main() {
  testWidgets('App renders properly smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          postRepositoryProvider.overrideWithValue(
            FakePostRepository(items: const []),
          ),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pump();
    expect(find.byType(MyApp), findsOneWidget);
  });

  testWidgets('PostTile renders post title, body, and id correctly', (WidgetTester tester) async {
    const post = Post(
      userId: 1,
      id: 9,
      title: 'Sample Title',
      body: 'Sample Body',
    );
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PostTile(post: post),
        ),
      ),
    );
    expect(find.text('Sample Title'), findsOneWidget);
    expect(find.text('Sample Body'), findsOneWidget);
    expect(find.text('9'), findsOneWidget);
  });
}
