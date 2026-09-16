import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'pages/detail_page.dart';
import 'pages/shell_scaffold.dart';
import 'pages/stats_page.dart';
import 'pages/todo_page.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);
final GlobalKey<NavigatorState> sectionNavKey = GlobalKey<NavigatorState>(
  debugLabel: 'section',
);

/// Konfigurasi routing deklaratif menggunakan GoRouter
final appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/',
  routes: [
    // ShellRoute dengan bottom navigation bar
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ShellScaffold(navigationShell: navigationShell);
      },
      branches: [
        // Tab 1: Daftar ToDo
        StatefulShellBranch(
          navigatorKey: sectionNavKey,
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const TodoPage(),
              routes: [
                GoRoute(
                  path: 'detail/:id',
                  builder: (context, state) {
                    final id = state.pathParameters['id'] ?? '1';
                    return DetailPage(id: id);
                  },
                ),
              ],
            ),
          ],
        ),
        // Tab 2: Statistik (AsyncNotifier)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/stats',
              builder: (context, state) => const StatsPage(),
            ),
          ],
        ),
      ],
    ),
  ],
);
