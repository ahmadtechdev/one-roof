import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  var dio = Dio();
  static const String _baseUrl = 'https://onerooftravel.net/api';

  // Keys for SharedPreferences
  static const String _tokenKey = 'user_auth_token';
  static const String _tokenExpiryKey = 'user_token_expiry';
  static const String _userDataKey = 'user_data';

  // Observable values
  final RxBool isLoading = false.obs;
  final RxBool isLoggedInValue = false.obs;
  final RxMap<String, dynamic> userData = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize Dio
    dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    // Add logging interceptor in debug mode
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );
    }

    // Check login status at startup
    checkLoginStatus();
  }

  // Check login status and load user data if logged in
  Future<void> checkLoginStatus() async {
    final loginStatus = await isLoggedIn();
    isLoggedInValue.value = loginStatus;

    if (loginStatus) {
      final data = await getUserData();
      if (data != null) {
        userData.value = data;
      }
    }
  }

  // Updated getValidToken function to automatically logout on token expiry
  Future<String?> getValidToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final expiryTimestamp = prefs.getInt(_tokenExpiryKey);

    if (token == null || expiryTimestamp == null) {
      return null; // No token stored
    }

    // Check if token is expired
    final now =
        DateTime.now().millisecondsSinceEpoch ~/
        1000; // Current time in seconds
    if (now >= expiryTimestamp) {
      if (kDebugMode) {
        print('Token expired, logging out user automatically');
      }

      // Automatically logout user when token is expired
      await logout(isTokenExpired: true);
      return null; // Token expired
    }

    return token; // Valid token
  }

  // Store token with expiry and user data
  Future<void> _storeAuthData(
    String token,
    int expiryTimestamp,
    Map<String, dynamic> userData,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setInt(_tokenExpiryKey, expiryTimestamp);
    await prefs.setString(_userDataKey, jsonEncode(userData));

    if (kDebugMode) {
      final expiryDate = DateTime.fromMillisecondsSinceEpoch(
        expiryTimestamp * 1000,
      );
      print('Token stored, expires on: $expiryDate');
      print('User data stored: $userData');
    }

    // Update login status and user data
    isLoggedInValue.value = true;
    this.userData.value = userData;
  }

  // Get stored user data
  // Updated getUserData method in AuthController
  Future<Map<String, dynamic>?> getUserData() async {
    // First check if token is valid
    final token = await getValidToken();

    if (token == null) {
      // Token is invalid or expired, clear data and return null
      if (kDebugMode) {
        print("Token invalid or expired, clearing user data");
      }
      await clearAuthData();
      return null;
    }

    // Token is valid, get user data
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(_userDataKey);

    if (userDataString != null) {
      try {
        final userData = jsonDecode(userDataString);
        if (kDebugMode) {
          print("Retrieved valid user data: $userData");
        }
        return userData;
      } catch (e) {
        if (kDebugMode) {
          print("Error parsing user data: $e");
        }
        // Clear corrupted data
        await prefs.remove(_userDataKey);
        return null;
      }
    }

    if (kDebugMode) {
      print("No user data found in SharedPreferences");
    }
    return null;
  }

  // Alternative method to get user data without token validation (if needed)
  Future<Map<String, dynamic>?> getUserDataDirect() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(_userDataKey);
    if (userDataString != null) {
      try {
        return jsonDecode(userDataString);
      } catch (e) {
        if (kDebugMode) {
          print("Error parsing user data: $e");
        }
        return null;
      }
    }
    return null;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    isLoading.value = true;

    try {
      final response = await dio.post(
        '$_baseUrl/token',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200 && response.data != null) {
        // Parse token, expiry and user data
        final token = response.data['token'];
        final expiryTimestamp = response.data['expire'];
        final userData = response.data['UserData'] ?? {};

        if (token != null && expiryTimestamp != null) {
          // Store token with expiry and user data
          await _storeAuthData(token, expiryTimestamp, userData);

          isLoading.value = false;
          return {
            'success': true,
            'token': token,
            'userData': userData,
            'message': 'Login successful',
          };
        }
      }

      // Extract error message from response
      String errorMessage = 'Login failed';
      if (response.data != null && response.data is Map) {
        errorMessage =
            response.data['message'] ??
            response.data['error'] ??
            'Login failed with status code: ${response.statusCode}';
      }

      isLoading.value = false;
      return {
        'success': false,
        'message': errorMessage,
        'statusCode': response.statusCode,
      };
    } on DioException catch (e) {
      isLoading.value = false;
      return _handleDioError(e, 'Login');
    } catch (e) {
      isLoading.value = false;
      return {
        'success': false,
        'message': 'An unexpected error occurred: ${e.toString()}',
      };
    }
  }

  // Updated logout function with comprehensive cleanup
  Future<void> logout({bool isTokenExpired = false}) async {
    isLoading.value = true;

    try {
      final prefs = await SharedPreferences.getInstance();

      // Remove all authentication-related data from SharedPreferences
      await Future.wait([
        prefs.remove(_tokenKey),
        prefs.remove(_tokenExpiryKey),
        prefs.remove(_userDataKey),
      ]);

      // Reset all observable values to their initial state
      isLoggedInValue.value = false;
      userData.value = <String, dynamic>{};

      // Debug logging
      if (kDebugMode) {
        if (isTokenExpired) {
          print('User logged out due to token expiration');
        } else {
          print('User logged out manually');
        }
        print('All authentication data cleared from SharedPreferences');
        print('Observable values reset to initial state');
      }

      isLoading.value = false;

      // Optional: Navigate to login screen or show message
      // You can add navigation logic here if needed
      // Get.offAllNamed('/login'); // Uncomment if using named routes
    } catch (e) {
      if (kDebugMode) {
        print('Error during logout: ${e.toString()}');
      }

      // Even if there's an error, reset the observable values
      isLoggedInValue.value = false;
      userData.value = <String, dynamic>{};
      isLoading.value = false;
    }
  }

  // Helper method to clear all authentication data (can be called from anywhere)
  Future<void> clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Remove all auth-related keys
      await Future.wait([
        prefs.remove(_tokenKey),
        prefs.remove(_tokenExpiryKey),
        prefs.remove(_userDataKey),
      ]);

      // Reset observable values
      isLoggedInValue.value = false;
      userData.value = <String, dynamic>{};

      if (kDebugMode) {
        print('Authentication data cleared successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing authentication data: ${e.toString()}');
      }
    }
  }

  // Method to check if user is logged in with valid token
  Future<bool> isLoggedIn() async {
    final token = await getValidToken();
    return token != null;
  }

  // Helper method to handle Dio errors consistently
  Map<String, dynamic> _handleDioError(DioException e, String operation) {
    String errorMessage;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        errorMessage =
            'Connection timeout. Please check your internet connection.';
        break;
      case DioExceptionType.receiveTimeout:
        errorMessage =
            'Server took too long to respond. Please try again later.';
        break;
      case DioExceptionType.sendTimeout:
        errorMessage =
            'Request timeout. Please check your internet connection.';
        break;
      case DioExceptionType.badResponse:
        if (e.response != null) {
          // Try to extract error message from response
          if (e.response!.data is Map) {
            errorMessage =
                e.response!.data['message'] ??
                e.response!.data['error'] ??
                '$operation failed with status: ${e.response!.statusCode}';
          } else {
            errorMessage =
                '$operation failed with status: ${e.response!.statusCode}';
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
      if (e.response != null) {
        print('Response status: ${e.response!.statusCode}');
        print('Response data: ${e.response!.data}');
      }
    }

    return {'success': false, 'message': errorMessage};
  }

  Future<Map<String, dynamic>> register({
    required String agencyName,
    required String contactName,
    required String email,
    required String countryCode,
    required String cellNumber,
    required String address,
    required String city,
  }) async {
    isLoading.value = true;

    try {
      final response = await dio.post(
        '$_baseUrl/register',
        data: {
          "agency_name": agencyName,
          "contact_name": contactName,
          "email": email,
          "country_code": countryCode,
          "csphno": cellNumber,
          "full_addrss": address,
          "city": city,
        },
      );

      // Debug log the raw response
      if (kDebugMode) {
        print('Registration response: ${response.data}');
      }

      // Parse the response data
      var responseData = response.data;
      if (responseData is String) {
        try {
          responseData = jsonDecode(responseData);
        } catch (e) {
          // If JSON parsing fails, keep it as string
        }
      }

      // Check the status field in the response
      if (responseData is Map && responseData.containsKey('status')) {
        // Check if status is "error" or non-200 numeric
        if (responseData['status'] == 'error' ||
            (responseData['status'] is num && responseData['status'] != 200)) {
          isLoading.value = false;
          return {
            'success': false,
            'message': responseData['message'] ?? 'Registration failed',
            'errors': responseData['errors'] ?? {},
            'data': responseData,
          };
        }
      }

      // If we reach here and HTTP status is 200/201, consider it success
      if (response.statusCode == 200 || response.statusCode == 201) {
        isLoading.value = false;
        return {
          'success': true,
          'data': responseData,
          'message':
              responseData is Map
                  ? (responseData['message'] ?? 'Registration successful')
                  : 'Registration successful',
        };
      } else {
        // Handle other HTTP error codes
        String errorMessage =
            'Registration failed with status code: ${response.statusCode}';
        if (responseData is Map && responseData.containsKey('message')) {
          errorMessage = responseData['message'];
        }

        isLoading.value = false;
        return {
          'success': false,
          'message': errorMessage,
          'statusCode': response.statusCode,
        };
      }
    } on DioException catch (e) {
      isLoading.value = false;
      return _handleDioError(e, 'Registration');
    } catch (e) {
      if (kDebugMode) {
        print('Registration exception: ${e.toString()}');
        print('Stack trace: ${StackTrace.current}');
      }
      isLoading.value = false;
      return {
        'success': false,
        'message': 'Registration failed: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> getHotelBookings() async {
    isLoading.value = true;

    try {
      // Get the token from SharedPreferences
      final token = await getValidToken();

      if (token == null) {
        isLoading.value = false;
        return {
          'success': false,
          'message': 'Authentication token not found. Please login again.',
        };
      }

      // Set up headers with the token
      final headers = {'Authorization': 'Bearer $token'};

      // Make the API request
      final response = await dio.get(
        '$_baseUrl/hotel-booking',
        options: Options(headers: headers),
      );

      // Debug log the response
      if (kDebugMode) {
        print('Hotel bookings response: ${response.data}');
      }

      if (response.statusCode == 200) {
        isLoading.value = false;
        return {
          'success': true,
          'data': response.data,
          'message': 'Hotel bookings retrieved successfully',
        };
      } else {
        String errorMessage = 'Failed to fetch hotel bookings';
        if (response.data != null &&
            response.data is Map &&
            response.data.containsKey('message')) {
          errorMessage = response.data['message'];
        }

        isLoading.value = false;
        return {
          'success': false,
          'message': errorMessage,
          'statusCode': response.statusCode,
        };
      }
    } on DioException catch (e) {
      isLoading.value = false;
      return _handleDioError(e, 'Hotel Bookings');
    } catch (e) {
      if (kDebugMode) {
        print('Hotel bookings exception: ${e.toString()}');
        print('Stack trace: ${StackTrace.current}');
      }
      isLoading.value = false;
      return {
        'success': false,
        'message': 'Failed to fetch hotel bookings: ${e.toString()}',
      };
    }
  }

  // Updated getGroupBookings function with proper null safety handling
  Future<Map<String, dynamic>> getGroupBookings({
    required String fromDate,
    required String toDate,
  }) async {
    isLoading.value = true;

    try {
      // Get the token from SharedPreferences
      final token = await getValidToken();

      if (token == null) {
        isLoading.value = false;
        return {
          'success': false,
          'message': 'Authentication token not found. Please login again.',
        };
      }

      // Set up headers with the token
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      // Create request data with date parameters
      final Map<String, dynamic> requestData = {
        'from_date': fromDate,
        'to_date': toDate,
      };

      // Make the API request with POST method and date parameters
      final response = await dio.post(
        '$_baseUrl/group-bookings',
        options: Options(headers: headers),
        data: requestData,
      );

      // Debug log the response
      if (kDebugMode) {
        print('Group bookings response: ${response.data}');
      }

      if (response.statusCode == 200) {
        isLoading.value = false;
        return {
          'success': true,
          'data': response.data,
          'message': 'Group bookings retrieved successfully',
        };
      } else {
        String errorMessage = 'Failed to fetch Group bookings';
        if (response.data != null &&
            response.data is Map &&
            response.data.containsKey('message')) {
          errorMessage = response.data['message'];
        }

        isLoading.value = false;
        return {
          'success': false,
          'message': errorMessage,
          'statusCode': response.statusCode,
        };
      }
    } on DioException catch (e) {
      isLoading.value = false;
      return _handleDioError(e, 'Group Bookings');
    } catch (e) {
      if (kDebugMode) {
        print('Group bookings exception: ${e.toString()}');
        print('Stack trace: ${StackTrace.current}');
      }
      isLoading.value = false;
      return {
        'success': false,
        'message': 'Failed to fetch Group bookings: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> getFlightsBookings({
    required String fromDate,
    required String toDate,
  }) async {
    isLoading.value = true;

    try {
      // Get the token from SharedPreferences
      final token = await getValidToken();

      if (token == null) {
        isLoading.value = false;
        return {
          'success': false,
          'message': 'Authentication token not found. Please login again.',
        };
      }

      // Set up headers with the token
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      // Create request data with date parameters
      final Map<String, dynamic> requestData = {
        'from_date': fromDate,
        'to_date': toDate,
      };

      // Make the API request with POST method and date parameters
      final response = await dio.post(
        '$_baseUrl/all-flights',
        options: Options(headers: headers),
        data: requestData,
      );

      // Debug log the response
      if (kDebugMode) {
        print('Flights bookings response: ${response.data}');
      }

      if (response.statusCode == 200) {
        isLoading.value = false;
        return {
          'success': true,
          'data': response.data,
          'message': 'Flights bookings retrieved successfully',
        };
      } else {
        String errorMessage = 'Failed to fetch Flights bookings';
        if (response.data != null &&
            response.data is Map &&
            response.data.containsKey('message')) {
          errorMessage = response.data['message'];
        }

        isLoading.value = false;
        return {
          'success': false,
          'message': errorMessage,
          'statusCode': response.statusCode,
        };
      }
    } on DioException catch (e) {
      isLoading.value = false;
      return _handleDioError(e, 'Flights Bookings');
    } catch (e) {
      if (kDebugMode) {
        print('Flights bookings exception: ${e.toString()}');
        print('Stack trace: ${StackTrace.current}');
      }
      isLoading.value = false;
      return {
        'success': false,
        'message': 'Failed to fetch Flights bookings: ${e.toString()}',
      };
    }
  }
}
