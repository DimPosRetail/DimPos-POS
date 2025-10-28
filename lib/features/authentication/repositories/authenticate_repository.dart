import 'package:dimpos_store/enums/api_url.dart';
import 'package:dimpos_store/features/authentication/models/user.dart';
import 'package:dimpos_store/features/common/models/base_response.dart';
import 'package:dimpos_store/utils/exception.dart';
import 'package:dimpos_store/utils/request.dart';
import 'package:dimpos_store/utils/share_pref.dart';
import 'package:dimpos_store/utils/utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'authenticate_repository.g.dart';

@riverpod
AuthenticateRepository authenticateRepository(Ref ref) {
  return const AuthenticateRepository();
}

class AuthenticateRepository {
  const AuthenticateRepository();

  Future<User?> login({
    required String username,
    required String password,
  }) async {
    final response = await apiClient.getClient(ApiUrl.identity).post(
      '/authentication/login',
      data: {
        'username': username,
        'password': password,
      },
    );
    final user = BaseResponse<User>.fromJson(response.data,
        (json) => User.fromJson(json as Map<String, dynamic>)).data;
    final role = JwtDecoder.decode(user?.accessToken ?? '')['role'];
    // providerLogger.i('Role: $role');
    if (!Utils.isValidStoreRole(role)) {
      final errorResponse = {
        "code": 403,
        "data": "Tài khoản không có quyền truy cập vào hệ thống cửa hàng.",
        "message": "Forbidden"
      };
      throw createDioException(
        "Tài khoản không có quyền truy cập.",
        DioExceptionType.badResponse,
        Response(
          data: errorResponse,
          statusCode: 403,
          requestOptions: RequestOptions(path: '/authentication/login'),
        ),
      );
    }
    return user;
  }

  Future<bool> isLogin() async {
    return await getAccessToken() != null && await getRefreshToken() != null;
  }

  Future<void> setToken({
    required String accessToken,
    required String refreshToken,
  }) async {
    await setAccessToken(accessToken);
    await setRefreshToken(refreshToken);
  }

  Future<void> removeToken() async {
    await removeAccessToken();
    await removeRefreshToken();
  }
}
