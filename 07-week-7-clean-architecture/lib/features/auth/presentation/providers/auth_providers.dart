import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/failures.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/token_store.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login.dart';

final tokenStoreProvider = Provider<TokenStore>((ref) => TokenStore());

final authRepositoryProvider =
    Provider<AuthRepository>((ref) => const AuthRepositoryImpl());

final loginUseCaseProvider = Provider<Login>((ref) {
  return Login(ref.watch(authRepositoryProvider));
});

final authStateProvider =
    AsyncNotifierProvider<AuthNotifier, bool>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final token = await ref.watch(tokenStoreProvider).readAccess();
    return token != null;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      try {
        final session = await ref
            .read(loginUseCaseProvider)
            .call(email: email, password: password);
        await ref
            .read(tokenStoreProvider)
            .save(access: session.access, refresh: session.refresh);
        return true;
      } on Failure catch (f) {
        throw Exception(f.message);
      } catch (e) {
        throw Exception('Terjadi kesalahan autentikasi: $e');
      }
    });
  }

  Future<void> logout() async {
    await ref.read(tokenStoreProvider).clear();
    ref.invalidateSelf();
  }
}
