import 'package:freezed_annotation/freezed_annotation.dart';

part 'paging_response.freezed.dart';
part 'paging_response.g.dart';

@Freezed(genericArgumentFactories: true)
class PagingResponse<T> with _$PagingResponse<T> {
  const factory PagingResponse({
    @Default(0) int? size,
    @Default(0) int? page,
    @Default(0) int? total,
    @Default(0) int? totalPages,
    List<T>? items,
  }) = _PagingResponse<T>;

  factory PagingResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) =>
      _$PagingResponseFromJson(json, fromJsonT);
}
