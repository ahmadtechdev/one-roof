import 'dart:convert';

import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';

class GroupTicketingController extends GetxController {
  final dio1 = dio.Dio();

  // Base URLs for different services
  static const String travelNetworkBaseUrl = 'https://travelnetwork.pk/api';
  static const String alhaiderBaseUrl = 'https://alhaidertravel.pk/api';

  // Store the selected region
  final RxString selectedRegion = ''.obs;
  final RxString selectedRegion2 = ''.obs;

  // Store tokens separately
  final String travelNetworkAuthToken =
      'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiI1IiwianRpIjoiMTdmOTNjMTM2NjkwNmU1ZmZlMWYxMTRkNjFhZmJhODg3YWNjYWYxYmQyM2I0NGU5OTg5MTg5NGYyZmUwMjdlZTBlZGYwMDMyN2Q0YmYzN2IiLCJpYXQiOjE3MzgyNDQ2NDkuODI2MDc4LCJuYmYiOjE3MzgyNDQ2NDkuODI2MDgsImV4cCI6MTc2OTc4MDY0OS43OTQ4MTEsInN1YiI6IjM5Iiwic2NvcGVzIjpbXX0.g09sNMCTRD7V0Y7FKflF63seB5ri6vuwJ66TNrEy2cgQByMKveomh8IAtb2Q5bsdeGZeqQVrkvzD97wblJXVjLNTuBrC0xtLOxkN9pOd1LcPlEHU9gbXpyjUNa841ESXVuLhmabedb2d0CZxitrOb62TIQH81J6k_uapZRQsBbPissnFsZCNZndwlQC3oSFvQmqJJ_qdtliYQ39z27M7XUlVH3NEk0mgVcj34NanGi7ENWuVPjCPiSr33pCRbsAZUcU5eMk97brgpXtiZuMpy2E7EWnFlFbVCme9mffq3ISP4dNigqN09-gS2dObQ_r1HcgPLcaX3netnvDOUBrgvONjdS8YDDQ5Xpxf3gN6Ez-4lxwSFhF1bhHFYvpPEsrv-dLGgN_c3rGSIBqRowrA_JH1jCTo6-HTwB_tPn5ZJ-nN5v5732Rl0OM4Yhhwv23yEToA5q20S74gOx1wMYQbRCMQEEkouZdLabv5Jns_ADBrTnlE8IMlUu5viCYUaLzs0PZeW0IbVAFjKVICiydF7bAuxysRwAedhQcm5zbTQKnKFH65UqLwf7Q5b2uoE3L7yqWWbyOSWmPM4DahDfMyA8-L3D2Q5nMeDYwnFpVQQujQUoaSDHRVTEXZM0-gZ-cJ0G7obvZ5D2lf36ZVzotAPb7FbLENuh3pdEqktO7p1NY';

  final String alhaiderAuthToken =
      'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiI5ZTc4OTIxMS0zZjc0LTQ1ZTUtOWE3NC03YzZhYzNmMWVjZGQiLCJqdGkiOiIxNDE0NDE2YmNlNjE5OTk3YTJkNzE4MWYzYWY3YTRkMTA1YzZmZGUxNDYwNDFhZTJjYjVjZDA5ZTlhYTVhYjQ1Y2Q2M2EyNDI2MzBhZjdiZiIsImlhdCI6MTc0MzA3MjA1NC4yMDk1MTgsIm5iZiI6MTc0MzA3MjA1NC4yMDk1MjMsImV4cCI6MTc3NDYwODA1NC4xOTM4MzYsInN1YiI6Ijc0Iiwic2NvcGVzIjpbXX0.mv6GXni4w0wCJAUKWAtFOcfnH9fmI5bWTSIddDzkS3H3UUgk-0CcehU86U_m_91XRUwljgO_X06VtS3VQs29m3wwjBcNxZcL74gkmWk5zSzgjezhoaMSSuYsF_yHb3-XXODLFe6yq0-6yQ8nydhr57ifa1CLvRZRfVYdfPTCnkZqb6Y6pH_FXex4EjC5vHWHPPUOU9n6jrIvL1TM4sSs7Ie4PznkazOLdJME1XZqwrge1gdVhA7MYSVvEbPZBw7nuRdNAuA1xUHWgS2PC-qvrO_4atWEeWA__2jI6_0_Hr1nE1vUqVbRmtg3eiudmZgqo2Zfb2xjhwNfPdNgVqveFSZDiN2HmweWylN-7oGM6yKZyfa8RMSR1OH1-ubyr2TEcggUiv7Dew0gUGgq5J-kjUTWMIKpWJ_o_yZUXMCrMaBheKqDMXTZQ2w3C4CNqKf96Ky2YIU3kuQHtfgTOwhzysZSzU1Fpd9fCPo6UGbsPbzFut2vTj413dlvu1NdXWT6n-ZGhhbGxoi3JVUuOvWksKP-W1XugsbAUIeh5hyp_tr8iiORpf5DGiGjphD2PEksIxE7n9NTp1iR4TQZlSY_nUXyuW1TNd3KmdWb7eZFhP_lWc2Ycfkmt8Kq9ii_DbtTlrjtimTn24Nud33szwK19mFOfkXN55wA1DXAKA4anDs';

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
        print("Error: ${response.statusMessage}");
        return [];
      }
    } catch (e) {
      print("Exception in fetchAirlines: $e");
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
        print("Error: ${response.statusMessage}");
        return [];
      }
    } catch (e) {
      print("Exception in fetchSectors: $e");
      return [];
    }
  }

  // Fetch Groups from Travel Network
  Future<List<dynamic>> fetchGroups(String type) async {
    selectedRegion.value = type;
    print("Fetching groups for region: $type");

    try {
      String url = '$travelNetworkBaseUrl/available/groups';

      if (type.isNotEmpty) {
        url += '?type=$type';
      } else {
        url += '?type=';
      }

      print("Requesting URL: $url");

      var response = await dio1.get(
        url,
        options: dio.Options(headers: getTravelNetworkHeaders()),
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

  // Save Booking to Travel Network
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
        '$travelNetworkBaseUrl/create/booking',
        data: data,
        options: dio.Options(
          headers: getTravelNetworkHeaders(),
          contentType: 'application/json',
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Check if the response has the nested data structure
        var responseData = response.data;

        // Check for business logic success/failure in nested data
        if (responseData is Map<String, dynamic> &&
            responseData['data'] != null) {
          var innerData = responseData['data'];

          // Check if the inner data indicates an error or empty data
          if (innerData is Map<String, dynamic>) {
            // Check for explicit error flag or success flag
            if (innerData['error'] == true || innerData['success'] == false) {
              return {
                'success': false,
                'message': innerData['message'] ?? 'Booking failed',
                'data': null,
              };
            }

            // Check if data array is empty (booking not created)
            if (innerData['data'] is List &&
                (innerData['data'] as List).isEmpty) {
              return {
                'success': false,
                'message':
                    innerData['message'] ??
                    'Booking could not be created - no data returned',
                'data': null,
              };
            }
          }
        }

        // If we reach here, the booking was successful
        return {
          'success': true,
          'message': responseData['message'] ?? 'Booking saved successfully',
          'data': responseData,
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

  // ALHAIDER API METHODS

  // Fetch Groups from Alhaider
  Future<List<dynamic>> fetchAlhaiderGroups(String type) async {
    selectedRegion2.value = type;

    try {
      final response = await dio1.request(
        '$alhaiderBaseUrl/available/groups?type=$type',
        options: dio.Options(method: 'GET', headers: getAlhaiderHeaders()),
      );

      if (response.statusCode == 200) {
        print(
          "Alhaider groups count: ${(response.data['groups'] as List).length}",
        );
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
        print("Error fetching Alhaider groups: ${response.statusMessage}");
        return [];
      }
    } catch (e) {
      print("Exception in fetchAlhaiderGroups: $e");
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
        print(
          "Alhaider airlines count: ${(response.data['airlines'] as List).length}",
        );
        return response.data['airlines'] as List<dynamic>;
      } else {
        print(
          'Failed to fetch Alhaider airlines. Status: ${response.statusCode}',
        );
        return [];
      }
    } catch (e) {
      print('Error occurred in fetchAlhaiderAirlines: $e');
      return [];
    }
  }

  // COMBINED API METHODS

  // Fetch combined groups from both services
  Future<List<dynamic>> fetchCombinedGroups(String type, String type2) async {
    selectedRegion.value = type;

    print("Fetching combined groups for region: $type");
    print("Fetching combined groups for region: $type2 ");

    try {
      // Fetch groups from both APIs concurrently
      final travelNetworkFuture = fetchGroups(type);
      final alhaiderFuture = fetchAlhaiderGroups(type2);

      // Wait for both to complete
      final travelNetworkGroups = await travelNetworkFuture;
      final alhaiderGroups = await alhaiderFuture;

      // Combine the results (ensure alhaiderGroups is also a List)
      final combinedGroups = [...travelNetworkGroups, ...alhaiderGroups];

      print("Combined ${combinedGroups.length} groups from both services");
      return combinedGroups;
    } catch (e) {
      print("Exception in fetchCombinedGroups: $e");
      return [];
    }
  }

  // Fetch all airlines from both services
  Future<List<dynamic>> fetchCombinedAirlines_logos() async {
    try {
      // Fetch airlines from both APIs concurrently
      final travelNetworkFuture = fetchtravelnetworkAirlines();
      final alhaiderFuture = fetchAlhaiderAirlines();

      // Wait for both to complete
      final travelNetworkAirlines = await travelNetworkFuture;
      final alhaiderAirlines = await alhaiderFuture;

      // Combine the results
      final combinedAirlines = [...travelNetworkAirlines, ...alhaiderAirlines];

      print("Combined ${combinedAirlines.length} airlines from both services");
      return combinedAirlines;
    } catch (e) {
      print("Exception in fetchCombinedAirlines: $e");
      return [];
    }
  }
}
