import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/prefs.dart';
import 'pages/settings_page.dart';
import 'router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefsRepo = PrefsRepository();
  await prefsRepo.markOpenedNow();

  runApp(
    const ProviderScope(
      child: MainApp(),
    ),
  );
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkModeAsync = ref.watch(darkModeProvider);
    final isDarkMode = darkModeAsync.value ?? false;

    return MaterialApp.router(
      title: 'Week 5 Offline Notes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
    );
  }
}
