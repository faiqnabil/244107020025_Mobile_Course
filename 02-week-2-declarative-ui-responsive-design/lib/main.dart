import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Breakpoint layar lebar untuk tata letak responsif (mobile < 700 <= tablet/desktop)
const double kWideBreakpoint = 700.0;

void main() {
  runApp(const DashboardApp());
}

/// Root Widget aplikasi Dashboard Mahasiswa dengan dukungan Light & Dark theme
class DashboardApp extends StatefulWidget {
  const DashboardApp({super.key});

  @override
  State<DashboardApp> createState() => _DashboardAppState();
}

class _DashboardAppState extends State<DashboardApp> {
  bool isDark = false;

  void toggleTheme(bool value) {
    setState(() {
      isDark = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Academic Overview Dashboard',
      debugShowCheckedModeBanner: false,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
      ),
      home: DashboardPage(isDark: isDark, onDarkChanged: toggleTheme),
    );
  }
}

/// Halaman utama Academic Overview yang menampilkan header profil dan kartu informasi responsif
class DashboardPage extends StatelessWidget {
  const DashboardPage({
    required this.isDark,
    required this.onDarkChanged,
    super.key,
  });

  final bool isDark;
  final ValueChanged<bool> onDarkChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Academic Overview',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Semantics(
            label: isDark ? 'Beralih ke mode terang' : 'Beralih ke mode gelap',
            button: true,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isDark ? Icons.dark_mode : Icons.light_mode,
                  semanticLabel: isDark
                      ? 'Ikon Mode Gelap'
                      : 'Ikon Mode Terang',
                ),
                const SizedBox(width: 6),
                CupertinoSwitch(value: isDark, onChanged: onDarkChanged),
                const SizedBox(width: 16),
              ],
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= kWideBreakpoint;
          final columns = isWide ? 2 : 1;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Profil Mahasiswa
                const ProfileHeaderCard(
                  name: 'Muhammad Faiq Nabil Saputra',
                  nim: '244107020025',
                  studyProgram: 'D4 Teknik Informatika',
                  classGroup: 'TI-3D',
                ),
                const SizedBox(height: 20),

                // Judul Bagian Ringkasan
                Text(
                  'Ringkasan Akademik',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                // Grid Kartu Informasi Responsif
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: columns,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: isWide ? 3.0 : 2.4,
                  children: const [
                    InfoCard(
                      title: 'Assignments',
                      value: '8 Selesai',
                      icon: Icons.assignment_turned_in,
                      semanticDescription: '8 tugas telah diselesaikan',
                    ),
                    InfoCard(
                      title: 'Attendance',
                      value: '92%',
                      icon: Icons.calendar_month,
                      semanticDescription: 'Tingkat kehadiran 92 persen',
                    ),
                    InfoCard(
                      title: 'IPK Semester',
                      value: '3.88',
                      icon: Icons.school,
                      semanticDescription: 'Indeks Prestasi Kumulatif 3.88',
                    ),
                    InfoCard(
                      title: 'Current Week',
                      value: 'Week 02',
                      icon: Icons.view_week,
                      semanticDescription: 'Minggu perkuliahan saat ini ke 2',
                    ),
                    InfoCard(
                      title: 'SKS Selesai',
                      value: '42 / 144 SKS',
                      icon: Icons.account_balance_wallet,
                      semanticDescription: '42 dari 144 SKS telah diselesaikan',
                    ),
                    InfoCard(
                      title: 'Portfolio Status',
                      value: 'Ready',
                      icon: Icons.auto_awesome,
                      semanticDescription:
                          'Status portofolio siap dipublikasikan',
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Widget Profil Header yang menggunakan Container, Row, Column, Expanded
class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({
    required this.name,
    required this.nim,
    required this.studyProgram,
    required this.classGroup,
    super.key,
  });

  final String name;
  final String nim;
  final String studyProgram;
  final String classGroup;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      label: 'Kartu Profil Mahasiswa $name, NIM $nim, Kelas $classGroup',
      container: true,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: colorScheme.outlineVariant, width: 1.0),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              child: const Icon(Icons.person, size: 40),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'NIM: $nim',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Text(
                        'Kelas: $classGroup',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Program Studi: $studyProgram',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget Kartu Informasi Reusable dengan dukungan Theme dinamis dan Semantics
class InfoCard extends StatelessWidget {
  const InfoCard({
    required this.title,
    required this.value,
    this.icon,
    this.semanticDescription,
    super.key,
  });

  final String title;
  final String value;
  final IconData? icon;
  final String? semanticDescription;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      label: semanticDescription ?? '$title: $value',
      container: true,
      child: Card(
        elevation: 1.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.6),
            width: 1.0,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
          child: Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 24,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 14),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
