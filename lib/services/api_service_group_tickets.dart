import 'dart:convert';

import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class GroupTicketingController extends GetxController {
  final dio1 = dio.Dio();

  // Store the selected region
  final RxString selectedRegion = ''.obs;

  // Store token separately
  final String authToken =
      'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiI1IiwianRpIjoiMTdmOTNjMTM2NjkwNmU1ZmZlMWYxMTRkNjFhZmJhODg3YWNjYWYxYmQyM2I0NGU5OTg5MTg5NGYyZmUwMjdlZTBlZGYwMDMyN2Q0YmYzN2IiLCJpYXQiOjE3MzgyNDQ2NDkuODI2MDc4LCJuYmYiOjE3MzgyNDQ2NDkuODI2MDgsImV4cCI6MTc2OTc4MDY0OS43OTQ4MTEsInN1YiI6IjM5Iiwic2NvcGVzIjpbXX0.g09sNMCTRD7V0Y7FKflF63seB5ri6vuwJ66TNrEy2cgQByMKveomh8IAtb2Q5bsdeGZeqQVrkvzD97wblJXVjLNTuBrC0xtLOxkN9pOd1LcPlEHU9gbXpyjUNa841ESXVuLhmabedb2d0CZxitrOb62TIQH81J6k_uapZRQsBbPissnFsZCNZndwlQC3oSFvQmqJJ_qdtliYQ39z27M7XUlVH3NEk0mgVcj34NanGi7ENWuVPjCPiSr33pCRbsAZUcU5eMk97brgpXtiZuMpy2E7EWnFlFbVCme9mffq3ISP4dNigqN09-gS2dObQ_r1HcgPLcaX3netnvDOUBrgvONjdS8YDDQ5Xpxf3gN6Ez-4lxwSFhF1bhHFYvpPEsrv-dLGgN_c3rGSIBqRowrA_JH1jCTo6-HTwB_tPn5ZJ-nN5v5732Rl0OM4Yhhwv23yEToA5q20S74gOx1wMYQbRCMQEEkouZdLabv5Jns_ADBrTnlE8IMlUu5viCYUaLzs0PZeW0IbVAFjKVICiydF7bAuxysRwAedhQcm5zbTQKnKFH65UqLwf7Q5b2uoE3L7yqWWbyOSWmPM4DahDfMyA8-L3D2Q5nMeDYwnFpVQQujQUoaSDHRVTEXZM0-gZ-cJ0G7obvZ5D2lf36ZVzotAPb7FbLENuh3pdEqktO7p1NY';

  Map<String, String> getHeaders() {
    return {'Accept': 'application/json', 'Authorization': 'Bearer $authToken'};
  }

  // Fetch Airlines - fixed to return List instead of Map
  Future<List<dynamic>> fetchAirlines() async {
    try {
      var response = await dio1.get(
        'https://travelnetwork.pk/api/available/airlines',
        options: dio.Options(headers: getHeaders()),
      );

      if (response.statusCode == 200) {
        return response.data['airlines'] as List<dynamic>;
      } else {
        print("Error: ${response.statusMessage}");
        return [];
      }
    } catch (e) {
      print("Exception in fetchAirlines: $e");
      return [];
    }
  }

  // Fetch Sectors - fixed to return List instead of Map
  Future<List<dynamic>> fetchSectors() async {
    try {
      var response = await dio1.get(
        'https://travelnetwork.pk/api/available/sectors',
        options: dio.Options(headers: getHeaders()),
      );

      if (response.statusCode == 200) {
        return response.data['sectors'] as List<dynamic>;
      } else {
        print("Error: ${response.statusMessage}");
        return [];
      }
    } catch (e) {
      print("Exception in fetchSectors: $e");
      return [];
    }
  }

  Future<List<dynamic>> fetchGroups(String type) async {
    selectedRegion.value = type;
    print("Fetching groups for region: $type");

    try {
      String url = 'https://travelnetwork.pk/api/available/groups';

      if (type.isNotEmpty) {
        url += '?type=$type';
      } else {
        url += '?type=';
      }

      print("Requesting URL: $url");

      var response = await dio1.get(
        url,
        options: dio.Options(headers: getHeaders()),
      );

      if (response.statusCode == 200) {
        // Print summary of response
        print("Groups count: ${(response.data['groups'] as List).length}");

        // Print the first 3 groups (or fewer if there aren't 3)
        print("\n--- Sample of first few groups: ---");
        final groups = response.data['groups'] as List;
        final sampleSize = groups.length > 3 ? 3 : groups.length;

        for (int i = 0; i < sampleSize; i++) {
          print("Group ${i + 1}:");
          print(groups[i]);
          print("----------------------");
        }

        // Print available keys in the response data
        print("\nAvailable keys in response data:");
        (response.data as Map).keys.forEach((key) {
          print("- $key");
        });

        return response.data['groups'] as List<dynamic>;
      } else {
        print("Error: ${response.statusMessage}");
        return [];
      }
    } catch (e) {
      print("Exception in fetchGroups: $e");
      return [];
    }
  }

  // // Add this method to GroupTicketingController
  // Future<int> fetchAvailableSeats(int groupId) async {
  //   print("check 4");
  //   print(groupId);
  //   try {
  //     var response = await dio1.get(
  //       'https://travelnetwork.test/api/check/available_seats/$groupId',
  //       options: dio.Options(headers: getHeaders()),
  //     );

  //     print("ssdd");

  //     if (response.statusCode == 200) {
  //       print("seats deon:");
  //       print(response.data['seats']);
  //       return response.data['seats'] as int;
  //     } else {
  //       print("Error fetching available seats: ${response.statusMessage}");
  //       return 0; // Return 0 as fallback
  //     }
  //   } catch (e) {
  //     print("Exception in fetchAvailableSeats: $e");
  //     return 0; // Return 0 as fallback
  //   }
  // }

  // Add to api_service_group_tickets.dart
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
      // Validate passengers data before creating the request
      for (var passenger in passengers) {
        if (passenger['firstName'] == null ||
            passenger['lastName'] == null ||
            passenger['title'] == null) {
          return {
            'success': false,
            'message': 'Missing required passenger information (name or title)',
            'data': null,
          };
        }

        // Handle potential null dates safely
        String? dob = passenger['dateOfBirth'];
        String? doe = passenger['passportExpiry'];

        // Format dates only if they exist
        if (dob != null && dob.length >= 10) {
          passenger['dateOfBirth'] = dob.substring(0, 10);
        }

        if (doe != null && doe.length >= 10) {
          passenger['passportExpiry'] = doe.substring(0, 10);
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
                    "surname": passenger['lastName'],
                    "given_name": passenger['firstName'],
                    "title": passenger['title'],
                    "passport_no": passenger['passportNumber'] ?? "",
                    "dob": passenger['dateOfBirth'] ?? "",
                    "doe": passenger['passportExpiry'] ?? "",
                  },
                )
                .toList(),
        "group_price_detail_id": groupPriceDetailId,
      };

      print('Sending booking data: ${jsonEncode(data)}');

      // Add timeout to avoid hanging requests
      var response = await dio1.post(
        'https://travelnetwork.pk/api/create/booking',
        data: data,
        options: dio.Options(
          headers: getHeaders(),
          contentType: 'application/json',
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Booking saved successfully',
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to save booking. Status: ${response.statusCode}',
          'error_details': response.data?.toString() ?? 'No error details',
          'data': null,
        };
      }
    } on dio.DioException catch (e) {
      print('DioException details:');
      print('- Type: ${e.type}');
      print('- Message: ${e.message}');
      print('- Response status: ${e.response?.statusCode}');
      print('- Response data: ${e.response?.data}');

      // Check for specific error types
      if (e.type == dio.DioExceptionType.connectionTimeout ||
          e.type == dio.DioExceptionType.sendTimeout ||
          e.type == dio.DioExceptionType.receiveTimeout) {
        return {
          'success': false,
          'message':
              'Request timed out. Please check your internet connection and try again.',
          'error_details': e.message,
          'data': null,
        };
      } else if (e.type == dio.DioExceptionType.badResponse) {
        // Try to parse error response for more details
        final errorData = e.response?.data;
        String errorMessage = 'Server returned an error';

        if (errorData is Map<String, dynamic>) {
          errorMessage = errorData['message'] ?? errorMessage;
        }

        return {
          'success': false,
          'message': errorMessage,
          'error_details': errorData?.toString(),
          'status_code': e.response?.statusCode,
          'data': null,
        };
      }

      return {
        'success': false,
        'message': 'Network error occurred: ${e.message}',
        'error_details': e.response?.data?.toString() ?? 'No error details',
        'data': null,
      };
    } catch (e, stackTrace) {
      print('Unexpected error: $e');
      print('Stack trace: $stackTrace');

      return {
        'success': false,
        'message': 'An unexpected error occurred',
        'error_details': e.toString(),
        'data': null,
      };
    }
  }
}
