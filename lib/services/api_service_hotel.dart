import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../views/hotel/search_hotels/booking_hotel/booking_controller.dart';
import '../views/hotel/search_hotels/search_hotel_controller.dart';

class ApiServiceHotel extends GetxService {
  final SearchHotelController controller = Get.put(SearchHotelController());

  late final Dio dio;
  static const String _apiKey = 'VSXYTrVlCtVXRAOXGS2==';
  static const String _baseUrl = 'http://uat-apiv2.giinfotech.ae/api/v2';

  ApiServiceHotel() {
    dio = Dio(BaseOptions(baseUrl: _baseUrl));
    if (!Get.isRegistered<SearchHotelController>()) {
      Get.put(SearchHotelController());
    }
  }

  /// Helper: Sets default headers for API requests.
  Options _defaultHeaders() {
    return Options(
      headers: {
        'apikey': _apiKey,
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );
  }

  Future<Map<String, dynamic>?> getCancellationPolicy({
    required String sessionId,
    required String hotelCode,
    required int groupCode,
    required String currency,
    required List<String> rateKeys,
  }) async {
    final requestBody = {
      "SessionId": sessionId,
      "SearchParameter": {
        "HotelCode": hotelCode,
        "GroupCode": groupCode,
        "Currency": currency,
        "RateKeys": {"RateKey": rateKeys},
      },
    };

    print(
      'Fetching Cancellation Policy with Request: ${json.encode(requestBody)}',
    );
    try {
      final response = await dio.post(
        '/hotel/CancellationPolicy',
        data: requestBody,
        options: _defaultHeaders(),
      );

      if (response.statusCode == 200) {
        print('Cancellation Policy Response: ${response.data}');
        return response.data as Map<String, dynamic>;
      } else {
        print('Cancellation Policy Failed: ${response.statusMessage}');
      }
    } catch (e) {
      print('Error fetching cancellation policy: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> getPriceBreakup({
    required String sessionId,
    required String hotelCode,
    required int groupCode,
    required String currency,
    required List<String> rateKeys,
  }) async {
    final requestBody = {
      "SessionId": sessionId,
      "SearchParameter": {
        "HotelCode": hotelCode,
        "GroupCode": groupCode,
        "Currency": currency,
        "RateKeys": {"RateKey": rateKeys},
      },
    };

    print('Fetching Price Breakup with Request: ${json.encode(requestBody)}');
    try {
      final response = await dio.post(
        '/hotel/PriceBreakup',
        data: requestBody,
        options: _defaultHeaders(),
      );

      if (response.statusCode == 200) {
        print('Price Breakup Response: ${response.data}');
        return response.data as Map<String, dynamic>;
      } else {
        print('Price Breakup Failed: ${response.statusMessage}');
      }
    } catch (e) {
      print('Error fetching price breakup: $e');
    }
    return null;
  }

  Future<bool> bookHotel(Map<String, dynamic> requestBody) async {
    final BookingController bookingcontroller = Get.put(BookingController());

    const String bookingEndpoint =
        'https://sastayhotels.pk/mobile_thankyou.php';

    try {
      // Log the request for debugging
      print('\n=== SENDING BOOKING REQUEST1 ===');
      print('Endpoint: $bookingEndpoint');
      print('Request Body: ${json.encode(requestBody)}');

      final response = await dio.post(
        bookingEndpoint,
        data: requestBody,
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );

      // Log the response
      print('\n=== BOOKING RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');

      if (response.statusCode == 200) {
        if (response.data != null) {
          // Extract and store booking number
          if (response.data is Map && response.data['BookingNO'] != null) {
            String bookingStr = response.data['BookingNO'].toString();
            bookingStr = bookingStr.replaceAll('SHBK-', '');
            bookingcontroller.booking_num.value = int.tryParse(bookingStr) ?? 0;
            print(
              'Booking number stored: ${bookingcontroller.booking_num.value}',
            );
          }

          if (response.data is Map) {
            if (response.data['status'] == 'success' ||
                response.data['Success'] == 1 ||
                response.data['success'] == true ||
                response.data['code'] == 200) {
              return true;
            }
          } else if (response.data.toString().toLowerCase().contains(
            'success',
          )) {
            return true;
          }
        }
        return true; // Return true if we get 200 but can't determine more specific success
      } else {
        print('Booking failed with status: ${response.statusCode}');
        print('Error message: ${response.statusMessage}');
        return false;
      }
    } on DioException catch (e) {
      print('\n=== BOOKING ERROR ===');
      print('DioError Type: ${e.type}');
      print('Error Message: ${e.message}');
      if (e.response != null) {
        print('Error Response: ${e.response?.data}');
        print('Error Status Code: ${e.response?.statusCode}');
      }
      return false;
    } catch (e) {
      print('\n=== UNEXPECTED ERROR ===');
      print('Error: $e');
      return false;
    }
  }

  final String apiKey = 'd2608a45ff6c31a8feda78765ae53600';
  final String secretKey = '93a80d2ffb';

  String getSignature() {
    // Get current timestamp in seconds
    int utcDate = (DateTime.now().millisecondsSinceEpoch / 1000).round();

    // Assemble the string similar to PHP
    String assemble = '$apiKey$secretKey$utcDate';

    // Generate SHA-256 hash
    var bytes = utf8.encode(assemble);
    var digest = sha256.convert(bytes);
    print(digest);

    return digest.toString();
  }
  Future<void> fetchHotel({
    required String checkInDate,
    required String checkOutDate,
    required List<Map<String, dynamic>> rooms,
  }) async {
    try {
      String signature = getSignature();

      // Ensure hotel_ids is not empty and properly formatted
      if (controller.hotel_ids.isEmpty) {
        throw Exception('No hotel IDs available');
      }

      // Convert hotel IDs to proper format
      List<String> hotelIds =
      controller.hotel_ids.cast<String>().map((id) => id.trim()).toList();

      var headers = {
        'Api-key': apiKey,
        'X-Signature': signature,
        'Accept': 'application/json',
        'Accept-Encoding': 'gzip',
        'Content-Type': 'application/json',
      };

      // Create the request body with proper formatting
      var requestBody = {
        "stay": {"checkIn": checkInDate, "checkOut": checkOutDate},
        "occupancies":
        rooms
            .map(
              (room) => {
            "rooms": 1,
            "adults": room['Adult'],
            "children": room['Children'],
            if (room['Children'] > 0)
              "childAges": room['ChildrenAges'] ?? [],
          },
        )
            .toList(),
        "hotels": {"hotel": hotelIds},
      };

      // Log the complete request for debugging
      print('REQUEST HEADERS:');
      print(json.encode(headers));
      print('REQUEST BODY:');
      print(json.encode(requestBody));

      final response = await dio.request(
        'https://api.hotelbeds.com/hotel-api/1.0/hotels',
        options: Options(method: 'POST', headers: headers),
        data: requestBody,
      );

      if (response.statusCode == 200) {
        if (response.data == null) {
          throw Exception('Empty response received');
        }

        // Store the original response
        controller.originalResponse.value = response.data;

        // Safely handle the hotels data
        final hotels = response.data['hotels']?['hotels'] as List? ?? [];
        controller.sessionId.value = response.data['auditData']?['token'] ?? '';

        // Transform hotel data for the UI with null safety
        controller.hotels.value =
            hotels.map((hotel) {
              final minRate =
                  double.tryParse(hotel['minRate']?.toString() ?? '0') ?? 0.0;
              return {
                'hotelCode': hotel['code']?.toString() ?? '',
                'name': hotel['name'] ?? 'Unknown Hotel',
                'rating': int.tryParse(hotel['categoryCode']?[0] ?? '3') ?? 3,
                'address':
                '${hotel['zoneName'] ?? ''}, ${hotel['destinationName'] ?? ''}',
                'price': minRate.toStringAsFixed(2),
                'image': 'assets/images/hotel.jpg',
                'latitude': hotel['latitude']?.toString() ?? '0',
                'longitude': hotel['longitude']?.toString() ?? '0',
                'hotelCity': hotel['destinationName'] ?? '',
              };
            }).toList();

        // Store original hotels data
        controller.originalHotels.value = List.from(controller.hotels);
      } else {
        throw Exception('Failed to load hotels: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching hotels: $e");
      rethrow;
    }
  }
  Future<Map<String, dynamic>?> checkRate({
    required List<String> rateKeys,
  }) async {
    String signature = getSignature();

    final headers = {
      'Api-key': apiKey,
      'X-Signature': signature,
      'Accept': 'application/json',
      'Accept-Encoding': 'gzip',
      'Content-Type': 'application/json',
    };

    // Format the request body properly
    var rooms = rateKeys.map((rateKey) => {"rateKey": rateKey}).toList();
    var requestBody = {"rooms": rooms};
    var data = json.encode(requestBody);

    // Pretty print the request data
    print('\n=== Request Data ===');
    JsonEncoder encoder = const JsonEncoder.withIndent('  ');
    print(encoder.convert(requestBody));

    try {
      final response = await dio.post(
        'https://api.hotelbeds.com/hotel-api/1.0/checkrates',
        options: Options(headers: headers),
        data: data,
      );

      if (response.statusCode == 200) {
        // Split the response logging into smaller chunks
        print('\n=== Response Data ===');

        // Convert response data to pretty JSON string
        String prettyJson = encoder.convert(response.data);

        // Split the pretty JSON into manageable chunks (e.g., 1000 characters)
        const int chunkSize = 1000;
        List<String> chunks = [];

        for (var i = 0; i < prettyJson.length; i += chunkSize) {
          var end =
          (i + chunkSize < prettyJson.length)
              ? i + chunkSize
              : prettyJson.length;
          chunks.add(prettyJson.substring(i, end));
        }

        // Print each chunk with a separator
        for (var i = 0; i < chunks.length; i++) {
          print('\n--- Chunk ${i + 1}/${chunks.length} ---');
          print(chunks[i]);
        }

        return response.data as Map<String, dynamic>;
      } else {
        print('\n=== Error Response ===');
        print('Status Code: ${response.statusCode}');
        print('Status Message: ${response.statusMessage}');
        return null;
      }
    } catch (e) {
      print('\n=== Exception Caught ===');
      print('Error checking rates: $e');

      // If the error has response data, try to print it
      if (e is DioException && e.response?.data != null) {
        print('\n=== Error Response Data ===');
        try {
          print(encoder.convert(e.response?.data));
        } catch (jsonError) {
          print(e.response?.data.toString());
        }
      }

      return null;
    }
  }

  String? _sastayToken;
  DateTime? _tokenExpiry;

  Future<String?> _getOrGenerateToken() async {
    // If we have a token that hasn't expired, use it
    if (_sastayToken != null &&
        _tokenExpiry != null &&
        _tokenExpiry!.isAfter(DateTime.now())) {
      return _sastayToken;
    }

    // Otherwise generate a new token
    try {
      _sastayToken = await generateSastayToken();
      if (_sastayToken != null) {
        // Set expiry to 1 hour from now (adjust based on actual token expiry)
        _tokenExpiry = DateTime.now().add(Duration(hours: 1));
        return _sastayToken;
      }
    } catch (e) {
      print("Error getting token: $e");
    }
    return null;
  }

  Future<String?> generateSastayToken() async {
    try {
      var data = json.encode({"req_type": "get_margin"});

      var response = await dio.request(
        'https://agent1.pk/group_api/generate_token.php',
        options: Options(method: 'GET', headers: sastayBasicHeaders),
        data: data,
      );

      if (response.statusCode == 200) {
        print("Token response: ${json.encode(response.data)}");

        // Extract token from response - adjust based on actual response structure
        if (response.data != null && response.data['token'] != null) {
          return response.data['token'] as String;
        } else if (response.data != null &&
            response.data['auth_token'] != null) {
          return response.data['auth_token'] as String;
        } else {
          print("No token found in response");
          return null;
        }
      } else {
        print("Error generating token: ${response.statusMessage}");
        return null;
      }
    } catch (e) {
      print("Exception in generateSastayToken: $e");
      return null;
    }
  }

  final Map<String, String> sastayBasicHeaders = {
    'Userid': 'Group-121',
    'Username': 'travelocity',
    'Content-Type': 'application/json',
  };

  // Fetch Cities using dynamic token
  Future<List<dynamic>> fetchCities(String keyword) async {
    try {
      String? token = await _getOrGenerateToken();
      if (token == null) {
        print("Failed to generate token for city search");
        return [];
      }

      Map<String, String> headers = {
        'Userid': 'Group-121',
        'Username': 'travelocity',
        'Authorization': token,
      };

      var requestData = json.encode({
        "req_type": "get_city",
        "keyword": keyword,
      });

      var response = await dio.request(
        'https://agent1.pk/group_api/sastay_restapi.php',
        options: Options(method: 'GET', headers: headers),
        data: requestData,
      );

      if (response.statusCode == 200) {
        print("Cities data: ${json.encode(response.data)}");

        // Corrected response parsing
        if (response.data != null &&
            response.data['status'] == 'success' &&
            response.data['response'] != null &&
            response.data['response']['cities'] != null) {
          return response.data['response']['cities'] as List<dynamic>;
        } else {
          print("No cities found in response");
          return [];
        }
      } else {
        print("Error fetching cities: ${response.statusMessage}");
        return [];
      }
    } catch (e) {
      print("Exception in fetchCities: $e");
      return [];
    }
  }

  Future<List<String>> fetchHotelIds({
    required String countryCode,
    required String zoneCode,
    required String cityStateCode,
  }) async {
    try {
      String? token = await _getOrGenerateToken();
      if (token == null) {
        print("Failed to generate token for hotel IDs search");
        return [];
      }

      Map<String, String> headers = {
        'Userid': 'Group-121',
        'Username': 'travelocity',
        'Authorization': token,
        'Content-Type': 'application/json',
      };

      var requestData = json.encode({
        "req_type": "get_hotel_ids",
        "country_code": countryCode,
        "zone_code": zoneCode,
        "cityState_code": cityStateCode,
      });

      var response = await dio.request(
        'https://agent1.pk/group_api/sastay_restapi.php',
        options: Options(method: 'GET', headers: headers),
        data: requestData,
      );

      if (response.statusCode == 200) {
        print("Hotel IDs data: ${json.encode(response.data)}");

        // Check if the response has the expected structure
        if (response.data != null &&
            response.data['status'] == 'success' &&
            response.data['response'] != null &&
            response.data['response']['hotel_ids'] != null) {
          // Convert the comma-separated string to a list of strings
          String hotelIdsString = response.data['response']['hotel_ids'];
          List<String> hotelIdsList = hotelIdsString.split(',');

          // Store in controller if needed
          SearchHotelController().hotel_ids.value = hotelIdsList;
          print("Hotel IDs data: ${(response.data)}");

          return hotelIdsList;
        } else {
          print("No hotel IDs found in response");
          return [];
        }
      } else {
        print("Error fetching hotel IDs: ${response.statusMessage}");
        return [];
      }
    } catch (e) {
      print("Exception in fetchHotelIds: $e");
      return [];
    }
  }
}