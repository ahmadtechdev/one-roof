import 'package:get/get.dart';

import '../../../../services/api_service_flight.dart';

import 'models/airblue_flight_model.dart';

class AirBlueFlightController extends GetxController {
  final ApiServiceFlight apiService = Get.find<ApiServiceFlight>();

  // List of AirBlue flights
  final RxList<AirBlueFlight> flights = <AirBlueFlight>[].obs;

  // Loading state
  final RxBool isLoading = false.obs;

  // Error message
  final RxString errorMessage = ''.obs;

  void clearFlights() {
    flights.clear();
    errorMessage.value = '';
  }

  void setErrorMessage(String message) {
    errorMessage.value = message;
  }

  // Search AirBlue flights
  Future<void> parseApiResponse(Map<String, dynamic>? response) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Clear previous flights
      flights.clear();

     // Parse the response
      if (response == null ||
          response['soap\$Envelope'] == null ||
          response['soap\$Envelope']['soap\$Body'] == null) {
        isLoading.value = false;
        return;
      }

      final pricedItineraries =
      response['soap\$Envelope']['soap\$Body']['AirLowFareSearchResponse']?['AirLowFareSearchResult']?['PricedItineraries']?['PricedItinerary'];

      if (pricedItineraries == null) {
        isLoading.value = false;
        return;
      }

      if (pricedItineraries is List) {
        for (var itinerary in pricedItineraries) {
          try {
            final flight = AirBlueFlight.fromJson(
              itinerary,
              apiService.airlineMap.value,
            );
            flights.add(flight);
          } catch (e) {
            print('Error parsing AirBlue flight: $e');
          }
        }
      } else if (pricedItineraries is Map) {
        try {
          final flight = AirBlueFlight.fromJson(
            Map<String, dynamic>.from(pricedItineraries),
            apiService.airlineMap.value,
          );
          flights.add(flight);
        } catch (e) {
          print('Error parsing AirBlue flight: $e');
        }
      }
    } catch (e) {
      errorMessage.value = 'Failed to load AirBlue flights: $e';
      print('Error searching AirBlue flights: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void loadFlights(Map<String, dynamic> apiResponse) {
    parseApiResponse(apiResponse);
  }

  // Add to AirBlueFlightController class
  final Rx<AirBlueFlight?> selectedFlight = Rx<AirBlueFlight?>(null);

  void handleAirBlueFlightSelection(AirBlueFlight flight) {
    selectedFlight.value = flight;
  }
}