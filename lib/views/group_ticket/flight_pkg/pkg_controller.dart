import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:oneroof/views/group_ticket/airline_model.dart';
import 'package:oneroof/views/group_ticket/data_controller.dart';
import 'package:oneroof/views/group_ticket/flight_pkg/pkg_model.dart';

import '../../../services/api_service_group_tickets.dart';

class FlightPKGController extends GetxController {
  final GroupTicketingController apiController = Get.put(GroupTicketingController());
  final TravelDataController travelController = Get.put(TravelDataController());

  // Observables
  final RxString selectedSector = 'all'.obs;
  final RxString selectedAirline = 'all'.obs;
  final RxString selectedDate = 'all'.obs;
  final RxList<dynamic> groupFlights = <dynamic>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Formatters
  final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');
  final DateFormat displayFormatter = DateFormat('dd MMM yyyy');

  // Sector options
  final List<Map<String, String>> sectorOptions = [
    {'label': 'Lahore-Dammam', 'value': 'lahore-dammam'},
    {'label': 'Islamabad-Riyadh', 'value': 'islamabad-riyadh'},
    {'label': 'Islamabad-Dammam', 'value': 'islamabad-dammam'},
    {'label': 'Lahore-Riyadh', 'value': 'lahore-riyadh'},
    {'label': 'Lahore-Jeddah', 'value': 'lahore-jeddah'},
    {'label': 'Faisalabad-Sharjah', 'value': 'faisalabad-sharjah'},
    {'label': 'Peshawar-Riyadh', 'value': 'peshawar-riyadh'},
  ];

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
      ]);
    } catch (e) {
      errorMessage.value = 'Failed to load data: ${e.toString()}';
    }
  }

  Future<void> fetchGroupFlights() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await apiController.fetchGroups('KSA');
      groupFlights.assignAll(response);
    } catch (e) {
      errorMessage.value = 'Failed to load flights: ${e.toString()}';
      groupFlights.clear();
    } finally {
      isLoading.value = false;
    }
  }

  FlightModel convertToFlightModel(dynamic groupFlight) {
    final airline = groupFlight['airline'] ?? {};
    final int airlineId = airline['id'] ?? 0;
    String logoUrl = _getDefaultLogoUrl();

    // Try to get airline details if ID is available
    if (airlineId != 0) {
      final matchedAirline = travelController.getAirlineById(airlineId);
      if (matchedAirline != null) {
        logoUrl = matchedAirline.logoUrl.isNotEmpty
            ? matchedAirline.logoUrl
            : _getDefaultLogoUrl();
      }
    }

    final flightDetails = groupFlight['details']?.first ?? {};

    return FlightModel(
      airline: airline['airline_name'] ?? 'Unknown Airline',
      shortName: airline['short_name'] ?? '',
      departure: _parseDate(groupFlight['dept_date']),
      departureTime: flightDetails['dept_time'] ?? '',
      arrivalTime: flightDetails['arv_time'] ?? '',
      origin: flightDetails['origin'] ?? '',
      destination: flightDetails['destination'] ?? '',
      flightNumber: flightDetails['flight_no'] ?? '',
      price: groupFlight['price'] ?? 0,
      hasLayover: false,
      baggage: flightDetails['baggage'] ?? '',
      logoUrl: logoUrl,
    );
  }

  DateTime _parseDate(String dateString) {
    try {
      return dateFormatter.parse(dateString);
    } catch (e) {
      return DateTime.now();
    }
  }

  String _getDefaultLogoUrl() {
    return 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAACklEQVR4nGMAAQAABQABDQottAAAAABJRU5ErkJggg==';
  }

  RxList<FlightModel> get filteredFlights {
    return groupFlights
        .where((groupFlight) {
      final sector = groupFlight['sector']?.toString().toLowerCase() ?? '';
      final airlineName = groupFlight['airline']?['airline_name']?.toString().toLowerCase() ?? '';
      final flightDate = groupFlight['dept_date']?.toString() ?? '';

      bool sectorMatch = selectedSector.value == 'all' ||
          sector.contains(selectedSector.value.toLowerCase());

      bool airlineMatch = selectedAirline.value == 'all' ||
          airlineName.contains(selectedAirline.value.toLowerCase());

      bool dateMatch = selectedDate.value == 'all' ||
          flightDate == selectedDate.value;

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
}