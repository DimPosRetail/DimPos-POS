import 'package:freezed_annotation/freezed_annotation.dart';

part 'entity_error_response.freezed.dart';
part 'entity_error_response.g.dart';

@Freezed(genericArgumentFactories: true)
class EntityErrorResponse with _$EntityErrorResponse {
  const factory EntityErrorResponse({
    required String propertyName,
    required String errorMessage,
  }) = _EntityErrorResponse;

  factory EntityErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$EntityErrorResponseFromJson(json);
}
