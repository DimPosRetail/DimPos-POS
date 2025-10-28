import 'package:dimpos_store/features/common/models/base_response.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

void handleApiError({
  required DioException error,
}) {
  String title = "Lỗi";
  String errorMessage = "Đã xảy ra lỗi gì đó!";

  try {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        errorMessage = "Kết nối đã hết thời gian!";
        break;
      case DioExceptionType.receiveTimeout:
        errorMessage = "Thời gian nhận dữ liệu đã hết!";
        break;
      case DioExceptionType.sendTimeout:
        errorMessage = "Thời gian gửi dữ liệu đã hết!";
        break;
      case DioExceptionType.badResponse:
        final response = error.response;
        if (response != null) {
          try {
            errorMessage = BaseResponse<String>.fromJson(
                error.response!.data as Map<String, dynamic>,
                (json) => json.toString()).data.toString();
            title = BaseResponse<String>.fromJson(
                error.response!.data as Map<String, dynamic>,
                (json) => json.toString()).message.toString();
          } catch (e) {
            // If parsing fails, use default message
            // errorMessage = "Đã xảy ra lỗi từ máy chủ!";
          }
        }
        break;
      default:
        // Use the default error message
        break;
    }
  } catch (e) {
    // Use the default error message if any exceptions occur
  }

  // Show the error dialog at the top of the screen
  toastification.show(
    type: ToastificationType.error,
    style: ToastificationStyle.fillColored,
    title: Text(title),
    description: Text(errorMessage),
    autoCloseDuration: const Duration(seconds: 3),
    alignment: Alignment.topRight,
  );
}

void showTopErrorDialog(BuildContext context, String message) {
  // Show the dialog
  showDialog(
    context: context,
    barrierColor: Colors.transparent, // Make the barrier transparent
    builder: (BuildContext context) {
      // Use a positioned dialog that appears at the top
      return Dialog(
        // Remove default padding and margins
        insetPadding: const EdgeInsets.only(top: 10, left: 10, right: 10),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Stack(
          children: [
            // Use Positioned to place the dialog at the top
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade700,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              message,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );

  // Automatically dismiss the dialog after 3 seconds
  Future.delayed(const Duration(seconds: 2), () {
    // Check if the dialog is still showing before dismissing
    if (ModalRoute.of(context)?.isCurrent != true) {
      Navigator.of(context).pop();
    }
  });
}

DioException createDioException(
  String message,
  DioExceptionType type,
  Response? response,
) {
  // For badResponse type, create a structured error response if not provided
  if (type == DioExceptionType.badResponse &&
      (response?.data is! Map ||
          !(response!.data as Map).containsKey('data'))) {
    final errorResponse = {
      "code": response?.statusCode ?? 400,
      "data": message,
      "message": "Error"
    };

    return DioException(
      response: Response(
        data: errorResponse,
        statusCode: response?.statusCode ?? 400,
        requestOptions: response?.requestOptions ?? RequestOptions(path: ''),
      ),
      type: type,
      requestOptions: response?.requestOptions ?? RequestOptions(path: ''),
      message: message,
    );
  }

  // Return DioException with the existing response
  return DioException(
    response: response,
    type: type,
    requestOptions: response?.requestOptions ?? RequestOptions(path: ''),
    message: message,
  );
}
