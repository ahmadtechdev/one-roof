// ignore_for_file: empty_catches

import 'package:get/get.dart';
import '../../../../services/api_service_group_tickets.dart';
import 'package:oneroof/views/group_ticket/airline/airline_model.dart';
import 'package:oneroof/views/group_ticket/sector_model.dart';

class TravelDataController extends GetxController {
  // Observable lists
  final RxList<Airline> airlines = <Airline>[].obs;
  final RxList<Sector> sectors = <Sector>[].obs;
  final RxBool isLoading = true.obs;

  // Instance of the API controller
  final GroupTicketingController apiController = Get.put(
    GroupTicketingController(),
  );


  // Modification for data_controller.dart

  Future<void> loadAirlines() async {
    try {
      // Use combined airlines method
      final List<dynamic> airlineData =
          await apiController.fetchCombinedAirlinesLogos();

      airlines.value =
          airlineData
              .map((item) {
                // Ensure item is a Map<String, dynamic>
                if (item is Map<String, dynamic>) {
                  try {
                    return Airline.fromJson(item);
                  } catch (e) {
                    return null;
                  }
                } else {
                  return null;
                }
              })
              .whereType<Airline>()
              .toList(); // Filter out null values

    } catch (e) {
    }
  }

  // Method to load sectors
  Future<void> loadSectors() async {
    try {
      final List<dynamic> sectorData = await apiController.fetchSectors();

      sectors.value =
          sectorData
              .map((item) {
                // Handle string or map
                if (item is String) {
                  return Sector.fromString(item);
                } else {
                  return null;
                }
              })
              .whereType<Sector>()
              .toList(); // Filter out null values

    } catch (e) {
    }
  }

  // Get airline by ID
  Airline? getAirlineById(int id) {
    // loadAirlines();
    try {
      return airlines.firstWhere((airline) => airline.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get sector by name
  Sector? getSectorByName(String name) {
    try {
      return sectors.firstWhere((sector) => sector.name == name);
    } catch (e) {
      return null;
    }
  }
}
