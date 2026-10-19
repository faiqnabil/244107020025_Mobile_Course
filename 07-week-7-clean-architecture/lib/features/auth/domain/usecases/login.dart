// lib/features/auth/domain/usecases/login.dart

import '../../../../core/failures.dart';
import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class Login {
  final AuthRepository _repository;
  const Login(this._repository);

  Future<AuthSession> call({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || !email.contains('@')) {
      throw const NetworkFailure('Email tidak valid');
    }
    if (password.length < 6) {
      throw const NetworkFailure('Kata sandi minimal 6 karakter');
    }
    try {
      return await _repository.login(email: email, password: password);
    } catch (e) {
      throw NetworkFailure(e.toString());
    }
  }
}
