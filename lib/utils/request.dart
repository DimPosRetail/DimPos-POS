import 'dart:io';

import 'package:dimpos_store/enums/api_url.dart';
import 'package:dimpos_store/environment/env.dart';
import 'package:dimpos_store/utils/logger_config.dart';
import 'package:dimpos_store/utils/share_pref.dart';
import 'package:dio/dio.dart';

// Helper function to convert parameters to query string format
Map<String, dynamic> convertToQueryParams(
    [Map<String, dynamic> params = const {}]) {
  Map<String, dynamic> queryParams = {};

  params.forEach((key, value) {
    // Skip null values entirely - don't include them in the result
    if (value != null) {
      if (value is List) {
        // Convert list items to strings
        queryParams[key] = value.map<String>((e) => e.toString()).toList();
      } else {
        // Convert other values to strings
        queryParams[key] = value.toString();
      }
    }
  });

  return queryParams;
}

// Base exception class for all API-related errors
class AppException implements Exception {
  final String? message;
  final String prefix;

  AppException([this.message, this.prefix = ""]);

  @override
  String toString() {
    return "$prefix$message";
  }
}

// Specific exception types
class FetchDataException extends AppException {
  FetchDataException([String? message])
      : super(message, "Error During Communication: ");
}

class BadRequestException extends AppException {
  BadRequestException([String? message]) : super(message, "Invalid Request: ");
}

class UnauthorizedException extends AppException {
  UnauthorizedException([String? message]) : super(message, "Unauthorized: ");
}

class InvalidInputException extends AppException {
  InvalidInputException([String? message]) : super(message, "Invalid Input: ");
}

class ExpiredException extends AppException {
  ExpiredException([String? message]) : super(message, "Token Expired: ");
}

class NotFoundException extends AppException {
  NotFoundException([String? message]) : super(message, "Not Found: ");
}

class ServerException extends AppException {
  ServerException([String? message]) : super(message, "Server Error: ");
}

class NetworkException extends AppException {
  NetworkException([String? message]) : super(message, "Network Error: ");
}

// Logging interceptor for debugging API requests and responses
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    if (!options.headers.containsKey("Authorization")) {
      final token = await getAccessToken();
      if (token != null) {
        options.headers["Authorization"] = "Bearer $token";
        providerLogger.d('Added access token to request headers');
      }
    }
    final requestLog = {
      'METHOD': options.method,
      'PATH': options.path,
      'BASE_URL': options.baseUrl,
      'HEADERS': options.headers,
      'DATA': options.data is FormData ? 'FormData' : options.data,
      'QUERY_PARAMS': options.queryParameters,
    };

    providerLogger.i('➡️ REQUEST\n${_formatLogData(requestLog)}');

    if (options.data is FormData) {
      options.headers[Headers.contentTypeHeader] =
          Headers.multipartFormDataContentType;
    }

    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final responseLog = {
      'STATUS_CODE': response.statusCode,
      'PATH': response.requestOptions.path,
      'BASE_URL': response.requestOptions.baseUrl,
      'DATA': response.data,
    };

    providerLogger.i('⬅️ RESPONSE\n${_formatLogData(responseLog)}');
    return super.onResponse(response, handler);
  }

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    final errorLog = {
      'STATUS_CODE': err.response?.statusCode,
      'PATH': err.requestOptions.path,
      'BASE_URL': err.requestOptions.baseUrl,
      'ERROR': err.error,
      'MESSAGE': err.message,
      'RESPONSE_DATA': err.response?.data,
    };

    providerLogger.e('❌ ERROR\n${_formatLogData(errorLog)}');
    return super.onError(err, handler);
  }

  // Helper function to format log data for better readability
  String _formatLogData(Map<dynamic, dynamic> data) {
    StringBuffer buffer = StringBuffer();
    data.forEach((key, value) {
      buffer.write('$key: $value\n');
    });
    return buffer.toString();
  }
}

// Enhanced API request class with support for multiple endpoints
class ApiClient {
  // Map of API endpoints with their base URLs
  final Map<ApiUrl, String> _apiEndpoints = {
    ApiUrl.base: Env.apiBaseUrl,
    ApiUrl.identity: Env.apiIdentityUrl,
    ApiUrl.menu: Env.apiMenuUrl,
    ApiUrl.store: Env.apiStoreUrl,
    ApiUrl.promotion: Env.apiPromotionUrl,
    ApiUrl.basket: Env.apiBasketUrl,
    ApiUrl.order: Env.apiOrderUrl,
    ApiUrl.notification: Env.apiNotificationUrl,
    ApiUrl.inventory: Env.apiInventoryUrl,
  };

  // Map to store Dio instances for each endpoint
  final Map<ApiUrl, Dio> _dioInstances = {};

  // Singleton instance
  static final ApiClient _instance = ApiClient._internal();

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    // Initialize Dio instances for all endpoints
    _apiEndpoints.forEach((key, url) {
      _dioInstances[key] = _createDioInstance(url);
    });
  }

  // Creates a new Dio instance with the given base URL
  Dio _createDioInstance(String baseUrl) {
    BaseOptions options = BaseOptions(
      baseUrl: baseUrl,
      headers: {
        Headers.contentTypeHeader: "application/json",
        Headers.acceptHeader: "text/plain",
      },
      connectTimeout: const Duration(seconds: 40),
      sendTimeout: const Duration(seconds: 40),
      receiveTimeout: const Duration(seconds: 40),
    );

    Dio dio = Dio(options);
    dio.interceptors.add(LoggingInterceptor());
    dio.interceptors.add(InterceptorsWrapper(
      onResponse: (e, handler) {
        return handler.next(e); // continue
      },
      onError: (e, handler) async {
        // Let the handleApiError method handle this
        handler.next(e);
      },
    ));
    return dio;
  }

  // Get a Dio instance for a specific endpoint
  Dio getClient([ApiUrl endpoint = ApiUrl.base]) {
    if (!_dioInstances.containsKey(endpoint)) {
      providerLogger.w('Endpoint $endpoint not found, using default');
      endpoint = ApiUrl.base;
    }
    return _dioInstances[endpoint]!;
  }

  // Set token for all endpoints or a specific one
  void setToken(String? token, [ApiUrl? specificEndpoint]) {
    if (specificEndpoint != null) {
      // Set token for a specific endpoint
      if (_dioInstances.containsKey(specificEndpoint)) {
        if (token != null) {
          _dioInstances[specificEndpoint]!.options.headers["Authorization"] =
              "Bearer $token";
          providerLogger.d('Token set for $specificEndpoint endpoint');
        } else {
          _dioInstances[specificEndpoint]!
              .options
              .headers
              .remove("Authorization");
          providerLogger.d('Token removed for $specificEndpoint endpoint');
        }
      } else {
        providerLogger
            .w('Endpoint $specificEndpoint not found for token setting');
      }
    } else {
      // Set token for all endpoints
      _dioInstances.forEach((key, dio) {
        if (token != null) {
          dio.options.headers["Authorization"] = "Bearer $token";
        } else {
          dio.options.headers.remove("Authorization");
        }
      });
      providerLogger.d(token != null
          ? 'Token set for all endpoints'
          : 'Token removed from all endpoints');
    }
  }

  // Configure base URL for a specific endpoint
  void setBaseUrl(ApiUrl endpoint, String url) {
    if (_dioInstances.containsKey(endpoint)) {
      _dioInstances[endpoint]!.options.baseUrl = url;
      _apiEndpoints[endpoint] = url;
      providerLogger.d('Base URL for $endpoint set to $url');
    } else {
      // Create a new endpoint if it doesn't exist
      _apiEndpoints[endpoint] = url;
      _dioInstances[endpoint] = _createDioInstance(url);
      providerLogger.d('New endpoint $endpoint created with URL $url');
    }
  }
}

// Create a singleton instance
final apiClient = ApiClient();

// For backward compatibility
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
