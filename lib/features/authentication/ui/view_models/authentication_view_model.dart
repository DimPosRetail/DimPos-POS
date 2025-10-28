import 'package:dimpos_store/features/authentication/models/user.dart';
import 'package:dimpos_store/features/authentication/repositories/authenticate_repository.dart';
import 'package:dimpos_store/features/authentication/ui/state/authentication_state.dart';
import 'package:dimpos_store/utils/request.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'authentication_view_model.g.dart';

@Riverpod(keepAlive: true)
class AuthenticationViewModel extends _$AuthenticationViewModel {
  @override
  FutureOr<AuthenticationState> build() {
    return const AuthenticationState();
  }

  Future<User?> login({
    required String username,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await ref
          .read(authenticateRepositoryProvider)
          .login(username: username, password: password);

      if (user != null) {
        await ref.read(authenticateRepositoryProvider).setToken(
              accessToken: user.accessToken,
              refreshToken: user.refreshToken,
            );
        apiClient.setToken(user.accessToken);
        state = AsyncData(
          AuthenticationState(user: user),
        );
      } else {
        state = AsyncData(
          const AuthenticationState(),
        );
      }
      return user;
    } catch (error, _) {
      state = AsyncData(
        const AuthenticationState(),
      );
      rethrow;
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      await ref.read(authenticateRepositoryProvider).removeToken();
      apiClient.setToken(null);
      state = const AsyncData(
        AuthenticationState(),
      );
    } catch (error, _) {
      state = const AsyncData(
        AuthenticationState(),
      );
      rethrow;
    }
  }
}
