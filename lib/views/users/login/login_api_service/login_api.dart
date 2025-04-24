import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginApiService {
  late final Dio dio;
  static const String _baseUrl = 'https://onerooftravel.net/api';
  static const String _tokenKey = 'user_auth_token';

  LoginApiService() {
    dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: Duration(seconds: 30),
        receiveTimeout: Duration(seconds: 30),
        validateStatus: (status) => true, // Accept any status code for proper error handling
        contentType: 'application/json',
      ),
    );

    // Add logging interceptor in debug mode
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ));
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        '/token',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        // Store the token
        await _storeToken(response.data['token']);
        return {
          'success': true,
          'token': response.data['token'],
          'message': 'Login successful',
        };
      } else {
        // Extract error message from response
        String errorMessage = 'Login failed';

        if (response.data != null && response.data is Map) {
          errorMessage = response.data['message'] ??
              response.data['error'] ??
              'Login failed with status code: ${response.statusCode}';
        }

        return {
          'success': false,
          'message': errorMessage,
          'statusCode': response.statusCode,
        };
      }
    } on DioException catch (e) {
      return _handleDioError(e, 'Login');
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred: ${e.toString()}',
      };
    }
  }

  // Updated registration function with improved error handling
  Future<Map<String, dynamic>> register({
    required String agencyName,
    required String contactName,
    required String email,
    required String countryCode,
    required String cellNumber,
    required String address,
    required String city,
  }) async {
    try {
      // Log registration attempt
      print('Attempting registration for $email');

      // Using the full URL and proper formatting for the API
      final response = await dio.request(
        'https://onerooftravel.net/api/register',
        options: Options(
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
        ),
        data: json.encode({
          "agency_name": agencyName,
          "contact_name": contactName,
          "email": email,
          "country_code": countryCode,
          "csphno": cellNumber,
          "full_addrss": address,
          "city": city,
        }),
      );

      // Log the full response in debug mode1
      if (kDebugMode) {
        print('Registration response status: ${response.statusCode}');
        print('Registration response data: ${json.encode(response.data)}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Check if response data indicates success
        bool isSuccess = false;
        String message = 'Registration successful';

        if (response.data is Map) {
          // Different APIs might use different success indicators
          isSuccess = response.data['success'] == true ||
              response.data['status'] == 'success' ||
              response.statusCode == 201;

          // Extract message if available
          if (response.data.containsKey('message')) {
            message = response.data['message'];
          }
        } else {
          isSuccess = true; // Assume success based on status code
        }

        return {
          'success': isSuccess,
          'data': response.data,
          'message': message,
        };
      } else {
        // Extract detailed error message
        String errorMessage = 'Registration failed';
        Map<String, dynamic> errorDetails = {};

        if (response.data != null) {
          if (response.data is Map) {
            // Handle structured error responses
            errorMessage = response.data['message'] ??
                response.data['error'] ??
                'Server returned error code: ${response.statusCode}';

            // Collect field-specific errors if available
            if (response.data.containsKey('errors') && response.data['errors'] is Map) {
              errorDetails = Map<String, dynamic>.from(response.data['errors']);
            }
          } else if (response.data is String) {
            // Handle string error responses
            errorMessage = response.data;
          }
        }

        return {
          'success': false,
          'message': errorMessage,
          'errors': errorDetails,
          'statusCode': response.statusCode,
        };
      }
    } on DioException catch (e) {
      return _handleDioError(e, 'Registration');
    } catch (e) {
      print('Registration exception: ${e.toString()}');
      return {
        'success': false,
        'message': 'Registration failed: ${e.toString()}',
      };
    }
  }

  // Helper method to handle Dio errors consistently
  Map<String, dynamic> _handleDioError(DioException e, String operation) {
    String errorMessage;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        errorMessage = 'Connection timeout. Please check your internet connection.';
        break;
      case DioExceptionType.receiveTimeout:
        errorMessage = 'Server took too long to respond. Please try again later.';
        break;
      case DioExceptionType.sendTimeout:
        errorMessage = 'Request timeout. Please check your internet connection.';
        break;
      case DioExceptionType.badResponse:
        if (e.response != null) {
          // Try to extract error message from response
          if (e.response!.data is Map) {
            errorMessage = e.response!.data['message'] ??
                e.response!.data['error'] ??
                '$operation failed with status: ${e.response!.statusCode}';
          } else {
            errorMessage = '$operation failed with status: ${e.response!.statusCode}';
          }
        } else {
          errorMessage = 'Bad server response';
        }
        break;
      case DioExceptionType.cancel:
        errorMessage = 'Request was cancelled';
        break;
      case DioExceptionType.connectionError:
        errorMessage = 'No internet connection. Please check your network.';
        break;
      case DioExceptionType.unknown:
      default:
        if (e.message != null && e.message!.contains('SocketException')) {
          errorMessage = 'No internet connection. Please check your network.';
        } else {
          errorMessage = 'An unexpected error occurred: ${e.message}';
        }
    }

    // Log the error in debug mode
    if (kDebugMode) {
      print('$operation API Error: $errorMessage');
      print('Error details: ${e.toString()}');

      if (e.response != null) {
        print('Response data: ${e.response!.data}');
        print('Response headers: ${e.response!.headers}');
        print('Response status code: ${e.response!.statusCode}');
      }
    }

    return {
      'success': false,
      'message': errorMessage,
      'error': e.toString(),
    };
  }

  Future<void> _storeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}