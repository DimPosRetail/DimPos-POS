import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.g.dart';
part 'user.freezed.dart';

@freezed
class User with _$User {
  const factory User({
    required String accountId,
    required String username,
    required String accessToken,
    required String refreshToken,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
