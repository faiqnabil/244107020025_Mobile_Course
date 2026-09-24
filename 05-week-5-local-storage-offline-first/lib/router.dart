import 'package:go_router/go_router.dart';
import 'pages/notes_page.dart';
import 'pages/note_detail_page.dart';
import 'pages/settings_page.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const NotesPage(),
    ),
    GoRoute(
      path: '/note/:id',
      builder: (context, state) {
        final idStr = state.pathParameters['id'] ?? '0';
        final id = int.tryParse(idStr) ?? 0;
        return NoteDetailPage(noteId: id);
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
  ],
);
