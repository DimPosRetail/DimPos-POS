import 'package:dimpos_store/features/authentication/models/user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'authentication_state.freezed.dart';
part 'authentication_state.g.dart';

@freezed
class AuthenticationState with _$AuthenticationState {
  const factory AuthenticationState({
    User? user,
  }) = _AuthenticationState;

  factory AuthenticationState.fromJson(Map<String, Object?> json) =>
      _$AuthenticationStateFromJson(json);
}
