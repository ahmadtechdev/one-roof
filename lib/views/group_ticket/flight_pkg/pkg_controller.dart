import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:oneroof/views/group_ticket/airline/data_controller.dart';
import 'package:oneroof/views/group_ticket/flight_pkg/pkg_model.dart';

import '../../../services/api_service_group_tickets.dart';

class FlightPKGController extends GetxController {
  final GroupTicketingController apiController = Get.put(
    GroupTicketingController(),
  );
  final TravelDataController travelController = Get.put(TravelDataController());

  // Observables
  final RxString selectedSector = 'all'.obs;
  final RxString selectedAirline = 'all'.obs;
  final RxString selectedDate = 'all'.obs;
  final RxList<dynamic> groupFlights = <dynamic>[].obs;
  final RxList<dynamic> combinedAirlines =
      <dynamic>[].obs; // Store airline logos
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Formatters
  final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');
  final DateFormat displayFormatter = DateFormat('dd MMM yyyy');

  // Dynamic sector options based on available flights
  RxList<Map<String, String>> get sectorOptions {
    final sectors = <String>{};

    for (final flight in groupFlights) {
      final sector = flight['sector']?.toString().toLowerCase();
      if (sector != null && sector.isNotEmpty) {
        sectors.add(sector);
      }
    }

    final options =
        sectors.map((sector) {
          final displayName = sector
              .split('-')
              .map((word) => word[0].toUpperCase() + word.substring(1))
              .join('-');

          return {'label': displayName, 'value': sector};
        }).toList();

    options.insert(0, {'label': 'All Sectors', 'value': 'all'});
    options.sort((a, b) => a['label']!.compareTo(b['label']!));

    return options.obs;
  }

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    try {
      await Future.wait([
        travelController.loadAirlines(),
        fetchGroupFlights(),
        loadAirlineLogos(), // Load airline logos
      ]);
    } catch (e) {
      errorMessage.value = 'Failed to load data: ${e.toString()}';
    }
  }

  // Load airline logos from both APIs
  Future<void> loadAirlineLogos() async {
    try {
      final logos = await apiController.fetchCombinedAirlinesLogos();
      combinedAirlines.assignAll(logos);
      print('Loaded ${logos.length} airline logos');

      // Debug: Print first few airlines to check structure
      for (int i = 0; i < (logos.length > 3 ? 3 : logos.length); i++) {
        print('Airline ${i + 1}: ${logos[i]}');
      }
    } catch (e) {
      print('Error loading airline logos: $e');
    }
  }

  Future<void> fetchGroupFlights() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final region = apiController.selectedRegion.value;
      final region2 = apiController.selectedRegion2.value;

      final response = await apiController.fetchCombinedGroups(region, region2);
      groupFlights.assignAll(response);
    } catch (e) {
      errorMessage.value = 'Failed to load flights: ${e.toString()}';
      groupFlights.clear();
    } finally {
      isLoading.value = false;
    }
  }

  // Get airline logo by airline ID or name
  String getAirlineLogo(int? airlineId, String? airlineName) {
    try {
      // First try to find by airline ID
      if (airlineId != null && airlineId != 0) {
        final matchedAirline = combinedAirlines.firstWhere(
          (airline) => airline['id'] == airlineId,
          orElse: () => null,
        );

        if (matchedAirline != null &&
            matchedAirline['logo_url'] != null &&
            matchedAirline['logo_url'].toString().isNotEmpty) {
          print('Found logo by ID $airlineId: ${matchedAirline['logo_url']}');
          return matchedAirline['logo_url'].toString();
        }
      }

      // If not found by ID, try to find by airline name
      if (airlineName != null && airlineName.isNotEmpty) {
        final matchedAirline = combinedAirlines.firstWhere((airline) {
          final name = airline['airline_name']?.toString().toLowerCase() ?? '';
          final shortName =
              airline['short_name']?.toString().toLowerCase() ?? '';
          final searchName = airlineName.toLowerCase();

          return name.contains(searchName) ||
              searchName.contains(name) ||
              shortName == searchName;
        }, orElse: () => null);

        if (matchedAirline != null &&
            matchedAirline['logo_url'] != null &&
            matchedAirline['logo_url'].toString().isNotEmpty) {
          print(
            'Found logo by name $airlineName: ${matchedAirline['logo_url']}',
          );
          return matchedAirline['logo_url'].toString();
        }
      }

      print('No logo found for airline ID: $airlineId, Name: $airlineName');
      return _getDefaultLogoUrl();
    } catch (e) {
      print('Error getting airline logo: $e');
      return _getDefaultLogoUrl();
    }
  }

  String _getDefaultLogoUrl() {
    return 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAACklEQVR4nGMAAQAABQABDQottAAAAABJRU5ErkJggg==';
  }

  GroupFlightModel convertToFlightModel(dynamic groupFlight) {
    try {
      final flightMap = groupFlight as Map<String, dynamic>;
      final airline = flightMap['airline'] ?? {};
      final airlineId = airline['id'];
      final airlineName = airline['airline_name']?.toString();

      // Get the proper logo URL
      final logoUrl = getAirlineLogo(airlineId, airlineName);

      // Create a modified flight map with the correct logo
      final modifiedFlightMap = Map<String, dynamic>.from(flightMap);
      if (modifiedFlightMap['airline'] != null) {
        modifiedFlightMap['airline'] = Map<String, dynamic>.from(airline);
        modifiedFlightMap['airline']['logo_url'] = logoUrl;
      }

      print('Converting flight with airline: $airlineName, logo: $logoUrl');

      return GroupFlightModel.fromJson(modifiedFlightMap);
    } catch (e) {
      print('Error converting flight model: $e');
      return GroupFlightModel.fromJson(groupFlight as Map<String, dynamic>);
    }
  }

  RxList<GroupFlightModel> get filteredFlights {
    return groupFlights
        .where((groupFlight) {
          final sector = groupFlight['sector']?.toString().toLowerCase() ?? '';
          final airlineName =
              groupFlight['airline']?['airline_name']
                  ?.toString()
                  .toLowerCase() ??
              '';
          final flightDate = groupFlight['dept_date']?.toString() ?? '';

          bool sectorMatch =
              selectedSector.value == 'all' ||
              sector.contains(selectedSector.value.toLowerCase());

          bool airlineMatch =
              selectedAirline.value == 'all' ||
              airlineName.contains(selectedAirline.value.toLowerCase());

          bool dateMatch =
              selectedDate.value == 'all' || flightDate == selectedDate.value;

          return sectorMatch && airlineMatch && dateMatch;
        })
        .map((groupFlight) => convertToFlightModel(groupFlight))
        .toList()
        .obs;
  }

  // Filter update methods
  void updateSector(String sector) => selectedSector.value = sector;
  void updateAirline(String airline) => selectedAirline.value = airline;
  void updateDate(String date) => selectedDate.value = date;

  void resetFilters() {
    selectedSector.value = 'all';
    selectedAirline.value = 'all';
    selectedDate.value = 'all';
  }

  // Helper methods for filtering
  List<String> getUniqueAirlines() {
    return groupFlights
        .map((flight) => flight['airline']?['airline_name']?.toString() ?? '')
        .where((airline) => airline.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }

  List<String> getUniqueDates() {
    return groupFlights
        .map((flight) => flight['dept_date']?.toString() ?? '')
        .where((date) => date.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }

  // Method to get flights grouped by sector for better display
  Map<String, List<GroupFlightModel>> getFlightsGroupedBySector() {
    final Map<String, List<GroupFlightModel>> groupedFlights = {};

    for (final flight in filteredFlights) {
      final sectorKey = flight.sector.toLowerCase();
      groupedFlights.putIfAbsent(sectorKey, () => []).add(flight);
    }

    return groupedFlights;
  }

  // Method to check if a flight is an Umrah flight
  bool isUmrahFlight(GroupFlightModel flight) {
    return flight.type.toUpperCase() == 'UMRAH' || flight.isRoundTrip;
  }

  // Method to refresh data and reload logos
  Future<void> refreshData() async {
    await loadInitialData();
  }

  // Debug method to print airline logos
  void debugAirlineLogos() {
    print('=== DEBUG: Airline Logos ===');
    print('Total airlines loaded: ${combinedAirlines.length}');

    for (int i = 0; i < combinedAirlines.length; i++) {
      final airline = combinedAirlines[i];
      print(
        'Airline $i: ID=${airline['id']}, Name=${airline['airline_name']}, Logo=${airline['logo_url']}',
      );
    }
    print('=== END DEBUG ===');
  }
}
