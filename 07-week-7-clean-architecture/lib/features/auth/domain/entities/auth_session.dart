// lib/features/auth/domain/entities/auth_session.dart

class AuthSession {
  final String access;
  final String refresh;

  const AuthSession({required this.access, required this.refresh});
}
