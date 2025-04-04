import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class GroupTicketingController extends GetxController {
  final dio1 = dio.Dio();

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
    try {
      var data = dio.FormData.fromMap({'type': type});

      var response = await dio1.get(
        'https://travelnetwork.pk/api/available/groups?type&airline_id&dept_date',
        options: dio.Options(headers: getHeaders()),

        data: data,
      );

      if (response.statusCode == 200) {
        print(response.data);
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

  // Add this method to GroupTicketingController
  Future<int> fetchAvailableSeats(int groupId) async {
    print("check 4");
    print(groupId);
    try {
      var response = await dio1.get(
        'https://travelnetwork.test/api/check/available_seats/$groupId',
        options: dio.Options(headers: getHeaders()),
      );

      print("ssdd");

      if (response.statusCode == 200) {
        print("seats deon:");
        print(response.data['seats']);
        return response.data['seats'] as int;

      } else {
        print("Error fetching available seats: ${response.statusMessage}");
        return 0; // Return 0 as fallback
      }
    } catch (e) {
      print("Exception in fetchAvailableSeats: $e");
      return 0; // Return 0 as fallback
    }
  }

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
      final data = {
        "group_id": groupId,
        "agency_info": {
          "group_id": groupId,
          "agent_name": agentName,
          "agency_name": agencyName,
          "email": email,
          "mobile": mobile,
          "adults": adults,
          "child": children ?? 0, // Instead of null
          "infant": infants ?? 0, // Instead of null
          "agent_notes": agentNotes ?? "", // Instead of null
        },
        "booking_details": passengers.map((passenger) => {
          "surname": passenger['lastName'],
          "given_name": passenger['firstName'],
          "title": passenger['title'],
          "passport_no": passenger['passportNumber'],
          "dob": passenger['dateOfBirth']?.substring(0, 10), // "2007-04-20"
          "doe": passenger['passportExpiry']?.substring(0, 10), // "2026-03-28"
        }).toList(),
        "group_price_detail_id": groupPriceDetailId,
      };

      print('Sending booking data: $data');

      var response = await dio1.post(
        'https://travelnetwork.pk/api/create/booking',
        data: data,
        options: dio.Options(
          headers: getHeaders(),
          contentType: 'application/json',
        ),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Booking saved successfully',
          'data': response.data,
        };
      } else {
        // Add detailed error info
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
      print('- Response: ${e.response?.data}');
      print('- StackTrace: ${e.stackTrace}');

      return {
        'success': false,
        'message': 'Network error occurred: ${e.message}',
        'error_details': e.response?.data?.toString() ?? 'No error details',
        'data': null,
      };
    } catch (e) {
      print('Unexpected error: $e');
      return {
        'success': false,
        'message': 'An unexpected error occurred',
        'error_details': e.toString(),
        'data': null,
      };
    }
  }
}