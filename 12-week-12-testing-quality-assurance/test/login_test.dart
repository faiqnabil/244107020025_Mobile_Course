import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notify/core/failures.dart';
import 'package:campus_notify/features/auth/domain/entities/auth_session.dart';
import 'package:campus_notify/features/auth/domain/repositories/auth_repository.dart';
import 'package:campus_notify/features/auth/domain/usecases/login.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.fail = false});

  final bool fail;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    if (fail) {
      throw const NetworkFailure('Koneksi server gagal');
    }
    return const AuthSession(
      access: 'fake-access-token',
      refresh: 'fake-refresh-token',
    );
  }

  @override
  Future<String> refresh(String refreshToken) async {
    if (fail) {
      throw const NetworkFailure('Refresh gagal');
    }
    return 'fake-refreshed-token';
  }
}

void main() {
  group('Login UseCase', () {
    test(
      'Login berhasil mengembalikan AuthSession ketika input valid',
      () async {
        final repo = FakeAuthRepository();
        final loginUseCase = Login(repo);

        final session = await loginUseCase.call(
          email: 'user@polinema.ac.id',
          password: 'password123',
        );

        expect(session.access, 'fake-access-token');
        expect(session.refresh, 'fake-refresh-token');
      },
    );

    test('Login melempar NetworkFailure ketika email tidak valid', () async {
      final repo = FakeAuthRepository();
      final loginUseCase = Login(repo);

      expect(
        () =>
            loginUseCase.call(email: 'invalid-email', password: 'password123'),
        throwsA(isA<NetworkFailure>()),
      );
    });

    test(
      'Login melempar NetworkFailure ketika password kurang dari 6 karakter',
      () async {
        final repo = FakeAuthRepository();
        final loginUseCase = Login(repo);

        expect(
          () =>
              loginUseCase.call(email: 'user@polinema.ac.id', password: '123'),
          throwsA(isA<NetworkFailure>()),
        );
      },
    );
  });
}
