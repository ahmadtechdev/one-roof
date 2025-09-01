// ignore_for_file: non_constant_identifier_names, unused_local_variable

import 'dart:convert';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class GroupTicketingController extends GetxController {
  final dio1 = dio.Dio();

  // Base URLs for different services
  static const String travelNetworkBaseUrl = 'https://travelnetwork.pk/api';
  static const String alhaiderBaseUrl = 'https://alhaidertravel.pk/api';

  // Store the selected region
  final RxString selectedRegion = ''.obs;
  final RxString selectedRegion2 = ''.obs;

  // Margin variables
  var travelnetworkmargin = 0.0;

  var al_haidermargin = 0.0;

  // Store tokens separately
  final String travelNetworkAuthToken =
      'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiI1IiwianRpIjoiNzI0N2Y4MTVkMjRjZTIwMGRlMTY4MTI3ZDFhNzczOWI3YjY2NGU1NDZhYTIwYjJmNmFlNzU4OTc0YzRkNzE4NmY3ZjIxZjgzNDA1MzYwYTEiLCJpYXQiOjE3NTYyNzcwNDYuNjgyMzUsIm5iZiI6MTc1NjI3NzA0Ni42ODIzNTQsImV4cCI6MTc4NzgxMzA0Ni40OTMxMzMsInN1YiI6IjM5Iiwic2NvcGVzIjpbXX0.L-q3NAFoteQpfiG6Ct3LyDMJtUsGPVscJCZwE-9_VMXuetUzbov9UHfLcmqkWnvYj9Alku-tMQzaAsoroasoOsaEy2sBOxYnfZoDOce_8H4l1IAroJQVUXTR9w0-5PZa5cJnAWdgaLSJAMKxzRjq5xoON5IFYnhtq8VOGkrRcSk7n2peOe7inruPbOmyGGnp42AaGDTenA-Z4DT_SMIZaFveaBw3rPm2PxoBCyTzwzqSkZExGo-xF1IvexORuIpDYtYfPVt0waVRXSDtncAKt1v8UxcVKt_4BBpyUPLWxS6Tw-eMUWE1NuuyyuR-YIwH3PIPxbNpBFpLdJontPSTu6Vi7ndxITebHNKqlfm2Blh6TQrXl6YmGTAhXMxgt2B6sv9IPiBwZkoUQpAB61fe7NhoVj_sd7VX5217OieQUHmm2PFUVvWJgVerrcoiq0isNSwOta4JDhJ5RUqSN5q8YZ48fJEpgaNbblDr1poYxBkkw1BK_HvbHPK6M_8F1ouq_F66S7cPm1rA4VeRM-GyLn7PxXnNTkhZ9iVT238CiorW_-7jvtFWubPiQoKKze2EoAAKL0URMpbUF28hmZMHHtBJ4wQ3-dlC2S6caNwUUiknfx_iCONqDjPx3PfGUNv7ytuRg9OQEhRl5LRoLdxFkHTZg38YoFet4dlodPVxkRU';

  final String alhaiderAuthToken =
      'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiI5ZTc4OTIxMS0zZjc0LTQ1ZTUtOWE3NC03YzZhYzNmMWVjZGQiLCJqdGkiOiIxNDE0NDE2YmNlNjE5OTk3YTJkNzE4MWYzYWY3YTRkMTA1YzZmZGUxNDYwNDFhZTJjYjVjZDA5ZTlhYTVhYjQ1Y2Q2M2EyNDI2MzBhZjdiZiIsImlhdCI6MTc0MzA3MjA1NC4yMDk1MTgsIm5iZiI6MTc0MzA3MjA1NC4yMDk1MjMsImV4cCI6MTc3NDYwODA1NC4xOTM4MzYsInN1YiI6Ijc0Iiwic2NvcGVzIjpbXX0.mv6GXni4w0wCJAUKWAtFOcfnH9fmI5bWTSIddDzkS3H3UUgk-0CcehU86U_m_91XRUwljgO_X06VtS3VQs29m3wwjBcNxZcL74gkmWk5zSzgjezhoaMSSuYsF_yHb3-XXODLFe6yq0-6yQ8nydhr57ifa1CLvRZRfVYdfPTCnkZqb6Y6pH_FXex4EjC5vHWHPPUOU9n6jrIvL1TM4sSs7Ie4PznkazOLdJME1XZqwrge1gdVhA7MYSVvEbPZBw7nuRdNAuA1xUHWgS2PC-qvrO_4atWEeWA__2jI6_0_Hr1nE1vUqVbRmtg3eiudmZgqo2Zfb2xjhwNfPdNgVqveFSZDiN2HmweWylN-7oGM6yKZyfa8RMSR1OH1-ubyr2TEcggUiv7Dew0gUGgq5J-kjUTWMIKpWJ_o_yZUXMCrMaBheKqDMXTZQ2w3C4CNqKf96Ky2YIU3kuQHtfgTOwhzysZSzU1Fpd9fCPo6UGbsPbzFut2vTj413dlvu1NdXWT6n-ZGhhbGxoi3JVUuOvWksKP-W1XugsbAUIeh5hyp_tr8iiORpf5DGiGjphD2PEksIxE7n9NTp1iR4TQZlSY_nUXyuW1TNd3KmdWb7eZFhP_lWc2Ycfkmt8Kq9ii_DbtTlrjtimTn24Nud33szwK19mFOfkXN55wA1DXAKA4anDs';

  @override
  void onInit() {
    super.onInit();
    // Initialize margins on controller creation
    fetchGroupTicketingMargins();
  }

  /// Fetch group ticketing margins
  Future<void> fetchGroupTicketingMargins() async {
    var data = '';

    try {
      var response = await dio1.request(
        'https://onerooftravel.net/api/groupTicketingMargins',
        options: dio.Options(method: 'POST'),
        data: data,
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print(
            'Group Ticketing Margins Response: ${json.encode(response.data)}',
          );
        }

        // Handle both String and Map responses
        Map<String, dynamic> responseData;

        if (response.data is String) {
          // Parse JSON string
          responseData = json.decode(response.data) as Map<String, dynamic>;
        } else if (response.data is Map<String, dynamic>) {
          // Already a Map
          responseData = response.data as Map<String, dynamic>;
        } else {
          if (kDebugMode) {
            print('Unexpected response type: ${response.data.runtimeType}');
          }
          return;
        }

        if (responseData['success'] == true && responseData['data'] != null) {
          final data = responseData['data'] as List;
          if (data.isNotEmpty) {
            final marginData = data[0] as Map<String, dynamic>;

            // Store travel network margin (B2C)
            travelnetworkmargin =
                double.tryParse(
                  marginData['travel_network_margin_b2c']?.toString() ?? '0',
                ) ??
                0.0;

            // Store Al Haider margin (B2C)
            al_haidermargin =
                double.tryParse(
                  marginData['ah_b2cmargin']?.toString() ?? '0',
                ) ??
                0.0;

            if (kDebugMode) {
              print(
                'Travel Network Margin (B2C) updated: $travelnetworkmargin',
              );
              print('Al Haider Margin (B2C) updated: $al_haidermargin');
            }
          }
        }
      } else {
        if (kDebugMode) {
          print('Group Ticketing Margins API Error: ${response.statusMessage}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching group ticketing margins: $e');
      }
    }
  }

  /// Apply margin to flight price based on source
  double applyMarginToPrice(double originalPrice, String source) {
    double margin = 0.0;

    // Determine which margin to apply based on source
    if (source.toLowerCase().contains('travel') ||
        source.toLowerCase().contains('network')) {
      margin = travelnetworkmargin;
    } else if (source.toLowerCase().contains('alhaider') ||
        source.toLowerCase().contains('haider')) {
      margin = al_haidermargin;
    }

    // Add margin to original price (margin is already in PKR)
    double finalPrice = originalPrice + margin;

    if (kDebugMode) {
      print(
        'Original Price: $originalPrice, Margin: $margin, Final Price: $finalPrice',
      );
    }

    return finalPrice;
  }

  // Helper methods to get headers for different services
  Map<String, String> getTravelNetworkHeaders() {
    return {
      'Accept': 'application/json',
      'Authorization': 'Bearer $travelNetworkAuthToken',
    };
  }

  Map<String, String> getAlhaiderHeaders() {
    return {
      'Accept': 'application/json',
      'Authorization': 'Bearer $alhaiderAuthToken',
      'Cookie':
          'XSRF-TOKEN=your_xsrf_token_here; al_haider_international_travels_tours_session=your_session_token_here',
    };
  }

  // TRAVEL NETWORK API METHODS

  // Fetch Airlines from Travel Network
  Future<List<dynamic>> fetchtravelnetworkAirlines() async {
    try {
      var response = await dio1.get(
        '$travelNetworkBaseUrl/available/airlines',
        options: dio.Options(headers: getTravelNetworkHeaders()),
      );

      if (response.statusCode == 200) {
        return response.data['airlines'] as List<dynamic>;
      } else {
        if (kDebugMode) {
          print("Error: ${response.statusMessage}");
        }
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print("Exception in fetchAirlines: $e");
      }
      return [];
    }
  }

  // Fetch Sectors from Travel Network
  Future<List<dynamic>> fetchSectors() async {
    try {
      var response = await dio1.get(
        '$travelNetworkBaseUrl/available/sectors',
        options: dio.Options(headers: getTravelNetworkHeaders()),
      );

      if (response.statusCode == 200) {
        return response.data['sectors'] as List<dynamic>;
      } else {
        if (kDebugMode) {
          print("Error: ${response.statusMessage}");
        }
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print("Exception in fetchSectors: $e");
      }
      return [];
    }
  }

  // Fetch Groups from Travel Network
  Future<List<dynamic>> fetchGroups(String type) async {
    selectedRegion.value = type;

    try {
      String url = '$travelNetworkBaseUrl/available/groups';

      if (type.isNotEmpty) {
        url += '?type=$type';
      } else {
        url += '?type=';
      }

      var response = await dio1.get(
        url,
        options: dio.Options(headers: getTravelNetworkHeaders()),
      );

      if (response.statusCode == 200) {
        // Print summary of response

        // Print the first 3 groups (or fewer if there aren't 3)
        final groups = response.data['groups'] as List;
        final sampleSize = groups.length > 3 ? 3 : groups.length;

        for (int i = 0; i < sampleSize; i++) {}

        // Print available keys in the response data
        for (var key in (response.data as Map).keys) {}

        // Apply margin to each group's price
        final processedGroups =
            groups.map((group) {
              if (group['price'] != null) {
                final originalPrice =
                    double.tryParse(group['price'].toString()) ?? 0.0;
                final finalPrice = applyMarginToPrice(
                  originalPrice,
                  'travel_network',
                );
                group['price'] = finalPrice.toInt();
              }
              return group;
            }).toList();

        return processedGroups;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // Save Booking to Travel Network
  // Save Booking to Travel Network with Enhanced Error Handling
  Future<Map<String, dynamic>> saveBooking({
    required int groupId,
    required String agentName,
    required String agencyName,
    required String email,
    required String mobile,
    required int adults,
    int? children,
    int? infants,
    String? agentNotes,
    required List<Map<String, dynamic>> passengers,
    required int groupPriceDetailId,
  }) async {
    try {
      // Enhanced passenger validation
      if (passengers.isEmpty) {
        return {
          'success': false,
          'message': 'No passengers provided',
          'data': null,
        };
      }

      // Validate passenger counts match
      final expectedTotal = adults + (children ?? 0) + (infants ?? 0);
      if (passengers.length != expectedTotal) {
        return {
          'success': false,
          'message':
              'Passenger count mismatch: Expected $expectedTotal, got ${passengers.length}',
          'data': null,
        };
      }

      // Validate passengers data before creating the request
      for (int i = 0; i < passengers.length; i++) {
        var passenger = passengers[i];

        // Check required fields
        if (passenger['firstName'] == null ||
            passenger['firstName'].toString().trim().isEmpty) {
          return {
            'success': false,
            'message': 'Passenger ${i + 1}: First name is required',
            'data': null,
          };
        }

        if (passenger['lastName'] == null ||
            passenger['lastName'].toString().trim().isEmpty) {
          return {
            'success': false,
            'message': 'Passenger ${i + 1}: Last name is required',
            'data': null,
          };
        }

        if (passenger['title'] == null ||
            passenger['title'].toString().trim().isEmpty) {
          return {
            'success': false,
            'message': 'Passenger ${i + 1}: Title is required',
            'data': null,
          };
        }

        // Handle potential null dates safely
        String? dob = passenger['dateOfBirth'];
        String? doe = passenger['passportExpiry'];

        // Format dates only if they exist and are valid
        if (dob != null && dob.length >= 10) {
          try {
            // Validate date format
            DateTime.parse(dob);
            passenger['dateOfBirth'] = dob.substring(0, 10);
          } catch (e) {
            return {
              'success': false,
              'message': 'Passenger ${i + 1}: Invalid date of birth format',
              'data': null,
            };
          }
        }

        if (doe != null && doe.length >= 10) {
          try {
            // Validate date format
            DateTime.parse(doe);
            passenger['passportExpiry'] = doe.substring(0, 10);
          } catch (e) {
            return {
              'success': false,
              'message': 'Passenger ${i + 1}: Invalid passport expiry format',
              'data': null,
            };
          }
        }
      }

      final data = {
        "group_id": groupId,
        "agency_info": {
          "group_id": groupId,
          "agent_name": agentName,
          "agency_name": agencyName,
          "email": email,
          "mobile": mobile,
          "adults": adults,
          "child": children ?? 0,
          "infant": infants ?? 0,
          "agent_notes": agentNotes ?? "",
        },
        "booking_details":
            passengers
                .map(
                  (passenger) => {
                    "surname": passenger['lastName']?.toString().trim() ?? "",
                    "given_name":
                        passenger['firstName']?.toString().trim() ?? "",
                    "title": passenger['title']?.toString().trim() ?? "",
                    "passport_no":
                        passenger['passportNumber']?.toString().trim() ?? "",
                    "dob": passenger['dateOfBirth']?.toString() ?? "",
                    "doe": passenger['passportExpiry']?.toString() ?? "",
                  },
                )
                .toList(),
        "group_price_detail_id": groupPriceDetailId,
      };

      // Log the complete request data for debugging
      if (kDebugMode) {
        print('=== BOOKING REQUEST DATA ===');
        // print('URL: $travelNetworkBaseUrl/create/booking');
        // print('Headers: ${getTravelNetworkHeaders()}');
        print('Payload: ${jsonEncode(data)}');
        print('========================');
      }

      // Add timeout to avoid hanging requests
      var response = await dio1.post(
        '$travelNetworkBaseUrl/create/booking',
        data: data,
        options: dio.Options(
          headers: getTravelNetworkHeaders(),
          contentType: 'application/json',
          receiveTimeout: const Duration(seconds: 45),
          sendTimeout: const Duration(seconds: 45),
        ),
      );

      // Log the complete response for debugging
      if (kDebugMode) {
        print('=== BOOKING RESPONSE ===');
        print('Status Code: ${response.statusCode}');
        print('Response Data: ${jsonEncode(response.data)}');
        print('========================');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Check if the response has the nested data structure
        var responseData = response.data;

        // Enhanced response validation
        if (responseData == null) {
          return {
            'success': false,
            'message': 'Empty response from server',
            'data': null,
          };
        }

        // Check for business logic success/failure in nested data
        if (responseData is Map<String, dynamic>) {
          // Check for explicit error flags
          if (responseData.containsKey('error') &&
              responseData['error'] == true) {
            return {
              'success': false,
              'message':
                  responseData['message']?.toString() ?? 'Booking failed',
              'error_details': responseData.toString(),
              'data': null,
            };
          }

          if (responseData.containsKey('success') &&
              responseData['success'] == false) {
            return {
              'success': false,
              'message':
                  responseData['message']?.toString() ?? 'Booking failed',
              'error_details': responseData.toString(),
              'data': null,
            };
          }

          // Check nested data structure
          if (responseData.containsKey('data')) {
            var innerData = responseData['data'];

            if (innerData is Map<String, dynamic>) {
              // Check for explicit error flag or success flag in nested data
              if (innerData.containsKey('error') &&
                  innerData['error'] == true) {
                return {
                  'success': false,
                  'message':
                      innerData['message']?.toString() ??
                      'Booking creation failed',
                  'error_details': innerData.toString(),
                  'data': null,
                };
              }

              if (innerData.containsKey('success') &&
                  innerData['success'] == false) {
                return {
                  'success': false,
                  'message':
                      innerData['message']?.toString() ??
                      'Booking creation failed',
                  'error_details': innerData.toString(),
                  'data': null,
                };
              }

              // Check if data array is empty (booking not created)
              if (innerData.containsKey('data') &&
                  innerData['data'] is List &&
                  (innerData['data'] as List).isEmpty) {
                return {
                  'success': false,
                  'message':
                      innerData['message']?.toString() ??
                      'Booking could not be created - no booking data returned',
                  'error_details': innerData.toString(),
                  'data': null,
                };
              }
            }
          }

          // Check for specific error messages in the response
          String? responseMessage = responseData['message']?.toString();
          if (responseMessage != null) {
            if (responseMessage.toLowerCase().contains('server error') ||
                responseMessage.toLowerCase().contains('internal error') ||
                responseMessage.toLowerCase().contains('database error')) {
              return {
                'success': false,
                'message':
                    'Server encountered an error. Please try again or contact support.',
                'error_details': responseData.toString(),
                'data': null,
              };
            }
          }
        }

        // If we reach here, the booking was successful
        return {
          'success': true,
          'message':
              responseData['message']?.toString() ??
              'Booking saved successfully',
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'message':
              'HTTP Error: ${response.statusCode} - ${response.statusMessage}',
          'error_details': response.data?.toString() ?? 'No error details',
          'status_code': response.statusCode,
          'data': null,
        };
      }
    } on dio.DioException catch (e) {
      // Enhanced DioException handling
      String errorMessage = 'Network error occurred';
      String? errorDetails = e.message;

      if (kDebugMode) {
        print('=== DIO EXCEPTION ===');
        print('Type: ${e.type}');
        print('Message: ${e.message}');
        print('Response: ${e.response?.data}');
        print('Status Code: ${e.response?.statusCode}');
        print('=====================');
      }

      // Check for specific error types
      switch (e.type) {
        case dio.DioExceptionType.connectionTimeout:
          errorMessage =
              'Connection timed out. Please check your internet connection.';
          break;
        case dio.DioExceptionType.sendTimeout:
          errorMessage =
              'Request timed out while sending data. Please try again.';
          break;
        case dio.DioExceptionType.receiveTimeout:
          errorMessage =
              'Request timed out while receiving response. Please try again.';
          break;
        case dio.DioExceptionType.badResponse:
          // Try to parse error response for more details
          final errorData = e.response?.data;
          if (errorData is Map<String, dynamic>) {
            errorMessage =
                errorData['message']?.toString() ??
                'Server returned error code ${e.response?.statusCode}';
            errorDetails = errorData.toString();
          } else if (errorData is String) {
            errorMessage =
                errorData.isNotEmpty
                    ? errorData
                    : 'Server returned error code ${e.response?.statusCode}';
          } else {
            errorMessage =
                'Server returned error code ${e.response?.statusCode}';
          }
          break;
        case dio.DioExceptionType.cancel:
          errorMessage = 'Request was cancelled.';
          break;
        case dio.DioExceptionType.unknown:
          errorMessage = 'Unknown network error occurred.';
          break;
        default:
          errorMessage = 'Network error: ${e.message ?? 'Unknown error'}';
      }

      return {
        'success': false,
        'message': errorMessage,
        'error_details': errorDetails,
        'status_code': e.response?.statusCode,
        'data': null,
      };
    } catch (e) {
      if (kDebugMode) {
        print('=== UNEXPECTED ERROR ===');
        print('Error: $e');
        print('Type: ${e.runtimeType}');
        print('========================');
      }

      return {
        'success': false,
        'message': 'An unexpected error occurred while processing your booking',
        'error_details': e.toString(),
        'data': null,
      };
    }
  } // ALHAIDER API METHODS

  // Fetch Groups from Alhaider
  Future<List<dynamic>> fetchAlhaiderGroups(String type) async {
    selectedRegion2.value = type;

    try {
      final response = await dio1.request(
        '$alhaiderBaseUrl/available/groups?type=$type',
        options: dio.Options(method: 'GET', headers: getAlhaiderHeaders()),
      );

      if (response.statusCode == 200) {
        final groups = response.data['groups'] as List;
        final sampleSize = groups.length > 3 ? 3 : groups.length;

        for (int i = 0; i < sampleSize; i++) {}

        // Print available keys in the response data
        for (var key in (response.data as Map).keys) {}

        // Apply margin to each group's price
        final processedGroups =
            groups.map((group) {
              if (group['price'] != null) {
                final originalPrice =
                    double.tryParse(group['price'].toString()) ?? 0.0;
                final finalPrice = applyMarginToPrice(
                  originalPrice,
                  'alhaider',
                );
                group['price'] = finalPrice.toInt();
              }
              return group;
            }).toList();

        return processedGroups;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // Fetch Airlines from Alhaider
  Future<List<dynamic>> fetchAlhaiderAirlines() async {
    try {
      final response = await dio1.request(
        '$alhaiderBaseUrl/available/airlines',
        options: dio.Options(method: 'GET', headers: getAlhaiderHeaders()),
      );

      if (response.statusCode == 200) {
        return response.data['airlines'] as List<dynamic>;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // COMBINED API METHODS

  // Fetch combined groups from both services
  Future<List<dynamic>> fetchCombinedGroups(String type, String type2) async {
    selectedRegion.value = type;

    try {
      // Fetch groups from both APIs concurrently
      final travelNetworkFuture = fetchGroups(type);
      final alhaiderFuture = fetchAlhaiderGroups(type2);

      // Wait for both to complete
      final travelNetworkGroups = await travelNetworkFuture;
      final alhaiderGroups = await alhaiderFuture;

      // Combine the results (margins are already applied in individual methods)
      final combinedGroups = [...travelNetworkGroups, ...alhaiderGroups];
      print(combinedGroups);

      return combinedGroups;
    } catch (e) {
      return [];
    }
  }

  // Fetch all airlines from both services
  Future<List<dynamic>> fetchCombinedAirlinesLogos() async {
    try {
      // Fetch airlines from both APIs concurrently
      final travelNetworkFuture = fetchtravelnetworkAirlines();
      final alhaiderFuture = fetchAlhaiderAirlines();

      // Wait for both to complete
      final travelNetworkAirlines = await travelNetworkFuture;
      final alhaiderAirlines = await alhaiderFuture;

      // Combine the results
      final combinedAirlines = [...travelNetworkAirlines, ...alhaiderAirlines];

      return combinedAirlines;
    } catch (e) {
      return [];
    }
  }

  // savebooking into database
  // Updated saveBooking_into_database function
  // Updated saveBooking_into_database function to match Postman request structure
  // Updated saveBooking_into_database function to match Postman request structure
  // Updated saveBooking_into_database function
  Future<Map<String, dynamic>> saveBooking_into_database({
    required String bookername,
    required String bookername_num,
    required String booker_email,
    required int groupId,
    required int adults,
    int? children,
    int? infants,
    String? agentNotes,
    required List<Map<String, dynamic>> passengers,
    required int groupPriceDetailId,
    // Additional parameters
    int? noOfSeats,
    double? fares,
    String? airlineName,
    // Required parameter for saveBooking response data
    Map<String, dynamic>? saveBookingResponse,
  }) async {
    try {
      // Validate passengers data before creating the request
      if (passengers.isEmpty) {
        return {
          'success': false,
          'message': 'No passengers provided',
          'data': null,
        };
      }

      // Extract data from saveBooking response if available
      String? pnrValue;
      String? apiBookingId;
      String? apiGroupId;
      String? apiSector;
      String? type;

      String? apiAirline;
      String? apiDeptDate;
      double? apiFare;

      if (saveBookingResponse != null && saveBookingResponse['data'] != null) {
        var responseData = saveBookingResponse['data']['data'];
        if (responseData != null) {
          // Extract PNR from group data
          pnrValue = responseData['group']?['pnr']?.toString();
          apiBookingId = responseData['id']?.toString();
          apiGroupId = responseData['group_id']?.toString();
          apiSector = responseData['group']?['sector']?.toString();
          type = responseData['group']?['type']?.toString();

          apiAirline =
              responseData['group']?['airline']?['airline_code']?.toString();
          apiDeptDate = responseData['group']?['dept_date']?.toString();
          apiFare =
              double.tryParse(responseData['fares']?.toString() ?? '0') ?? 0.0;
        }
      }

      // Helper function to map passenger type to human_type number
      int getHumanTypeNumber(String title) {
        String lowerTitle = title.toLowerCase();
        if (['mr', 'mrs', 'ms'].contains(lowerTitle)) {
          return 1; // adult
        } else if (['mstr', 'miss'].contains(lowerTitle)) {
          return 2; // child
        } else if (['inf'].contains(lowerTitle)) {
          return 3; // infant
        }
        return 1; // default to adult
      }

      // Helper function to determine gender from title
      String getGenderFromTitle(String title) {
        String lowerTitle = title.toLowerCase();
        if (['mr', 'mstr'].contains(lowerTitle)) {
          return 'male';
        } else if (['mrs', 'ms', 'miss'].contains(lowerTitle)) {
          return 'female';
        }
        return 'male'; // default
      }

      // Get current date for various fields
      final currentDate = DateTime.now();
      final formattedDate = currentDate.toIso8601String().substring(0, 10);

      // Calculate exchange rate (example: PKR to USD)
      const double exchangeRate = 280.0; // PKR per USD (adjust as needed)

      // Process passengers data according to API structure
      List<Map<String, dynamic>> processedPassengers =
          passengers.map((passenger) {
            // Extract price information
            double buying = apiFare ?? fares ?? 45000.0;
            double selling = buying + travelnetworkmargin;

            // Format dates safely
            String dobFormatted = '';
            String doeFormatted = '';
            String doiFormatted = '';

            if (passenger['dateOfBirth'] != null) {
              try {
                DateTime dob = DateTime.parse(passenger['dateOfBirth']);
                dobFormatted =
                    "${dob.year.toString().padLeft(4, '0')}-${dob.month.toString().padLeft(2, '0')}-${dob.day.toString().padLeft(2, '0')}";
              } catch (e) {
                dobFormatted = formattedDate; // fallback
              }
            }

            if (passenger['passportExpiry'] != null) {
              try {
                DateTime doe = DateTime.parse(passenger['passportExpiry']);
                doeFormatted =
                    "${doe.year.toString().padLeft(4, '0')}-${doe.month.toString().padLeft(2, '0')}-${doe.day.toString().padLeft(2, '0')}";
              } catch (e) {
                doeFormatted = formattedDate; // fallback
              }
            }

            // Default DOI to current date - 2 years (passport issue date approximation)
            DateTime doiDate = currentDate.subtract(const Duration(days: 730));
            doiFormatted =
                "${doiDate.year.toString().padLeft(4, '0')}-${doiDate.month.toString().padLeft(2, '0')}-${doiDate.day.toString().padLeft(2, '0')}";

            return {
              "buying": buying.round(),

              "selling": selling.round(),
              "reo": exchangeRate,
              "human_type": getHumanTypeNumber(
                passenger['title']?.toString() ?? 'Mr',
              ),
              "type": getGenderFromTitle(
                passenger['title']?.toString() ?? 'Mr',
              ),
              "sur_name": passenger['lastName']?.toString().trim() ?? '',
              "given_name": passenger['firstName']?.toString().trim() ?? '',
              "dob": dobFormatted,
              "pass_no": passenger['passportNumber']?.toString().trim() ?? '',
              "doe": doeFormatted,
              "doi": doiFormatted,
              "pnr_1":
                  pnrValue ?? "PNR${DateTime.now().millisecondsSinceEpoch}",
            };
          }).toList();

      // Construct the request data according to the Postman structure
      final data = {
        "booker_details": {
          "name": bookername.isNotEmpty ? bookername : "OneRoofTravel",
          "email":
              booker_email.isNotEmpty ? booker_email : "resOneroof@gmail.com",
          "phone": bookername_num.isNotEmpty ? bookername_num : "03001232412",
        },
        "group_data": {
          "group_id": apiGroupId ?? groupId.toString(),
          "group_type": "international", // You might want to make this dynamic
          "no_of_seats":
              noOfSeats ?? (adults + (children ?? 0) + (infants ?? 0)),
          "status": "confirmed",
          "date_created": "${currentDate.toIso8601String().substring(0, 19)}Z",
          "api_fares": (apiFare ?? fares ?? 45000.0).round(),
          "api_booking_id":
              apiBookingId ?? "APIBK${DateTime.now().millisecondsSinceEpoch}",
          "api_group_id": apiGroupId ?? groupId.toString(),
          "api_status": "active",
          "api_booking_date": formattedDate,
          "api_fare": (apiFare ?? fares ?? 45000.0).round(),
          "api_dept_date": apiDeptDate ?? formattedDate,
          "api_group_type": "GIT",
          "api_sector": apiSector ?? "LHE-DXB",
          "api_ailrine": apiAirline ?? (airlineName ?? "EK"),
        },
        "passengers_data": processedPassengers,
      };

      // Log the complete request data for debugging
      if (kDebugMode) {
        print('=== DATABASE BOOKING REQUEST DATA ===');
        print('URL: https://onerooftravel.net/api/save-group-ticketing');
        print('Payload: ${jsonEncode(data)}');
        print('====================================');
      }

      // Make the API request
      var response = await dio1.post(
        'https://onerooftravel.net/api/save-group-ticketing',
        data: data,
        options: dio.Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          receiveTimeout: const Duration(seconds: 45),
          sendTimeout: const Duration(seconds: 45),
        ),
      );

      // Log the response for debugging
      if (kDebugMode) {
        print('=== DATABASE BOOKING RESPONSE ===');
        print('Status Code: ${response.statusCode}');
        print('Response Data: ${jsonEncode(response.data)}');
        print('=================================');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Booking saved to database successfully',
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message':
              'Failed to save booking to database. Status: ${response.statusCode}',
          'error_details': response.data?.toString() ?? 'No error details',
          'data': null,
        };
      }
    } on dio.DioException catch (e) {
      String errorMessage = 'Database network error occurred';
      String? errorDetails = e.message;

      if (kDebugMode) {
        print('=== DATABASE DIO EXCEPTION ===');
        print('Type: ${e.type}');
        print('Message: ${e.message}');
        print('Response: ${e.response?.data}');
        print('Status Code: ${e.response?.statusCode}');
        print('==============================');
      }

      switch (e.type) {
        case dio.DioExceptionType.connectionTimeout:
          errorMessage =
              'Database connection timed out. Please check your internet connection.';
          break;
        case dio.DioExceptionType.sendTimeout:
          errorMessage =
              'Database request timed out while sending data. Please try again.';
          break;
        case dio.DioExceptionType.receiveTimeout:
          errorMessage =
              'Database request timed out while receiving response. Please try again.';
          break;
        case dio.DioExceptionType.badResponse:
          final errorData = e.response?.data;
          if (errorData is Map<String, dynamic>) {
            errorMessage =
                errorData['message']?.toString() ??
                'Database server returned error code ${e.response?.statusCode}';
            errorDetails = errorData.toString();
          } else if (errorData is String) {
            errorMessage =
                errorData.isNotEmpty
                    ? errorData
                    : 'Database server returned error code ${e.response?.statusCode}';
          } else {
            errorMessage =
                'Database server returned error code ${e.response?.statusCode}';
          }
          break;
        case dio.DioExceptionType.cancel:
          errorMessage = 'Database request was cancelled.';
          break;
        case dio.DioExceptionType.unknown:
          errorMessage = 'Unknown database error occurred.';
          break;
        default:
          errorMessage =
              'Database network error: ${e.message ?? 'Unknown error'}';
      }

      return {
        'success': false,
        'message': errorMessage,
        'error_details': errorDetails,
        'status_code': e.response?.statusCode,
        'data': null,
      };
    } catch (e) {
      if (kDebugMode) {
        print('=== DATABASE UNEXPECTED ERROR ===');
        print('Error: $e');
        print('Type: ${e.runtimeType}');
        print('=================================');
      }

      return {
        'success': false,
        'message': 'An unexpected database error occurred',
        'error_details': e.toString(),
        'data': null,
      };
    }
  }

  /// Method to manually refresh margins
  Future<void> refreshMargins() async {
    await fetchGroupTicketingMargins();
  }
}
