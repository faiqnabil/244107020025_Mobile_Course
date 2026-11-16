import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/auth_session_model.dart';
import '../../../../core/failures.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl();

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!email.contains('@') || password.length < 6) {
      throw const LocalFailure('Email atau kata sandi tidak valid');
    }
    final model = AuthSessionModel(
      access: 'mock-access-for-$email',
      refresh: 'mock-refresh-for-$email',
    );
    return model.toEntity();
  }

  @override
  Future<String> refresh(String refreshToken) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (refreshToken.isEmpty) {
      throw const LocalFailure('Refresh token tidak ditemukan atau kadaluarsa');
    }
    return 'mock-access-renewed-${DateTime.now().millisecondsSinceEpoch}';
  }
}
