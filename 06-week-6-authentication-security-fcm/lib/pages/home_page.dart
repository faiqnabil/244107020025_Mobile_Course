import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../messaging/push_service.dart';
import '../providers/auth_provider.dart';
import '../routes.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String? _fcmToken;
  bool _permissionGranted = false;

  @override
  void initState() {
    super.initState();
    _initFcm();
  }

  Future<void> _initFcm() async {
    final granted = await requestNotificationPermission();
    if (mounted) {
      setState(() {
        _permissionGranted = granted;
      });
    }

    if (granted) {
      await initLocalNotifications();
      await initFcmToken(onToken: (token) async {
        if (mounted) {
          setState(() {
            _fcmToken = token;
          });
        }
      });
    }
  }

  String _truncateToken(String? token) {
    if (token == null || token.isEmpty) return 'Belum tersedia';
    if (token.length <= 12) return token;
    return '${token.substring(0, 12)}...';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Campus Notify'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authStateProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Selamat datang di Campus Notify!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Debug Info FCM',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('Izin Notifikasi: ${_permissionGranted ? "Diizinkan" : "Ditolak/Belum"}'),
                      const SizedBox(height: 4),
                      Text('FCM Token (Truncated): ${_truncateToken(_fcmToken)}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  context.go(AppRoutes.announcementDetail('1'));
                },
                child: const Text('Lihat Pengumuman Sample'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  ref.read(authStateProvider.notifier).logout();
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Logout', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
