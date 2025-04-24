import 'package:get/get.dart';

import '../../../../services/api_service_flight.dart';

import '../flight_package/airblue/airblue_flight_package.dart';
import 'models/airblue_flight_model.dart';

class AirBlueFlightController extends GetxController {
  final ApiServiceFlight apiService = Get.find<ApiServiceFlight>();

  // List of AirBlue flights (now with unique RPH)
  final RxList<AirBlueFlight> flights = <AirBlueFlight>[].obs;

  // Map to store all fare options for each RPH
  final RxMap<String, List<AirBlueFareOption>> fareOptionsByRPH = <String, List<AirBlueFareOption>>{}.obs;

  // Loading state
  final RxBool isLoading = false.obs;

  // Error message
  final RxString errorMessage = ''.obs;

  void clearFlights() {
    flights.clear();
    fareOptionsByRPH.clear();
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

      // Clear previous flights and options
      flights.clear();
      fareOptionsByRPH.clear();

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

      // Temporary map to store flights by RPH
      Map<String, List<Map<String, dynamic>>> flightsByRPH = {};

      // First, group all flights by RPH
      if (pricedItineraries is List) {
        for (var itinerary in pricedItineraries) {
          try {
            // Get the RPH value
            final originDestOption = itinerary['AirItinerary']?['OriginDestinationOptions']?['OriginDestinationOption'];
            final rph = originDestOption?['RPH']?.toString() ?? '0-0';

            // Add to map
            if (!flightsByRPH.containsKey(rph)) {
              flightsByRPH[rph] = [];
            }
            flightsByRPH[rph]!.add(itinerary);
          } catch (e) {
            print('Error grouping AirBlue flight by RPH: $e');
          }
        }
      } else if (pricedItineraries is Map) {
        try {
          // Get the RPH value
          final originDestOption = pricedItineraries['AirItinerary']?['OriginDestinationOptions']?['OriginDestinationOption'];
          final rph = originDestOption?['RPH']?.toString() ?? '0-0';

          // Add to map
          flightsByRPH[rph] = [Map<String, dynamic>.from(pricedItineraries)];
        } catch (e) {
          print('Error processing single AirBlue flight: $e');
        }
      }

      // Process each RPH group
      flightsByRPH.forEach((rph, itineraries) {
        try {
          // Create fare options for this RPH
          List<AirBlueFareOption> fareOptions = [];

          // Process each itinerary in this RPH group
          for (var itinerary in itineraries) {
            try {
              // Create a flight from the itinerary
              final flight = AirBlueFlight.fromJson(
                itinerary,
                apiService.airlineMap.value,
              );

              // Create a fare option from this flight
              fareOptions.add(AirBlueFareOption.fromFlight(flight, itinerary));
            } catch (e) {
              print('Error creating fare option: $e');
            }
          }

          // If we have fare options, create a representative flight
          if (fareOptions.isNotEmpty) {
            // Sort fare options by price (lowest first)
            fareOptions.sort((a, b) => a.price.compareTo(b.price));

            // Store fare options by RPH
            fareOptionsByRPH[rph] = fareOptions;

            // Create a flight using the lowest price option as the representative
            final lowestPriceOption = fareOptions.first;
            final representativeFlight = AirBlueFlight.fromJson(
              lowestPriceOption.rawData,
              apiService.airlineMap.value,
            ).copyWithFareOptions(fareOptions);

            // Add to the flights list
            flights.add(representativeFlight);
          }
        } catch (e) {
          print('Error processing RPH group: $e');
        }
      });

      // Sort flights by price
      flights.sort((a, b) => a.price.compareTo(b.price));
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

  // Replace the existing handleAirBlueFlightSelection method with this one
  void handleAirBlueFlightSelection(AirBlueFlight flight, {bool isAnyFlightRemaining = false}) {
    selectedFlight.value = flight;

    // Open the AirBlue package selection dialog
    Get.dialog(
       AirBluePackageSelectionDialog(
        flight: flight,
        isAnyFlightRemaining: isAnyFlightRemaining,
      ),
      barrierDismissible: false,
    );
  }

  // Get fare options for a selected flight
  List<AirBlueFareOption> getFareOptionsForFlight(AirBlueFlight flight) {
    return fareOptionsByRPH[flight.rph] ?? [];
  }
}