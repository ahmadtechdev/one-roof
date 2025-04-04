import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../services/api_service_flight.dart';
import '../../../widgets/city_selection_bottom_sheet.dart';
import '../../../widgets/class_selection_bottom_sheet.dart';
import '../../../widgets/travelers_selection_bottom_sheet.dart';
import '../search_flights/search_flight_utils/flight_controller.dart';
import '../search_flights/search_flights.dart';

enum TripType { oneWay, roundTrip, multiCity }

class CityPair {
  final RxString fromCity;
  final RxString fromCityName;
  final RxString toCity;
  final RxString toCityName;
  final RxString departureDate;

  CityPair({
    String? fromCity,
    String? fromCityName,
    String? toCity,
    String? toCityName,
    String? departureDate,
  }) : fromCity = (fromCity ?? 'DEL').obs,
        fromCityName = (fromCityName ?? 'NEW DELHI').obs,
        toCity = (toCity ?? 'BOM').obs,
        toCityName = (toCityName ?? 'MUMBAI').obs,
        departureDate = (departureDate ?? '03/11/2025').obs;

  void swap() {
    final tempCity = fromCity.value;
    final tempCityName = fromCityName.value;

    fromCity.value = toCity.value;
    fromCityName.value = toCityName.value;

    toCity.value = tempCity;
    toCityName.value = tempCityName;
  }
}

class FlightBookingController extends GetxController {
  // Trip type
  final Rx<TripType> tripType = TripType.roundTrip.obs;
  var isSearching = false.obs;

  // City pairs for multicity
  final RxList<CityPair> cityPairs = <CityPair>[].obs;

  // City selection for one-way and round trip
  final RxString fromCity = 'LHR'.obs;
  final RxString fromCityName = 'Lahore'.obs;
  final RxString toCity = 'JED'.obs;
  final RxString toCityName = 'JEDDAH'.obs;

  // Observable variables for origin, destination
  var origins = RxList<String>([]);
  var destinations = RxList<String>([]);

  // Date selection
  final RxString departureDate =
      DateFormat('dd/MM/yyyy').format(DateTime.now()).obs;
  final RxString returnDate =
      DateFormat(
        'dd/MM/yyyy',
      ).format(DateTime.now().add(const Duration(days: 1))).obs;

  // Traveller and class selection
  final RxInt travellersCount = 1.obs;
  final RxString travelClass = 'Economy'.obs;

  // Individual traveler counts
  final RxInt adultCount = 1.obs;
  final RxInt childrenCount = 0.obs;
  final RxInt infantCount = 0.obs;

  // API Service and Flight Controller
  final ApiServiceFlight apiServiceFlight = Get.put(ApiServiceFlight());
  final FlightController flightController = Get.put(FlightController());

  // Getter for formatted origins string
  String get formattedOrigins =>
      origins.isNotEmpty ? ',${origins.join(',')}' : '';

  // Getter for formatted destinations string
  String get formattedDestinations =>
      destinations.isNotEmpty ? ',${destinations.join(',')}' : '';

  @override
  void onInit() {
    super.onInit();
    initializeTripType();
    initializeCityPairs();
  }

  void initializeTripType() {
    setTripType(TripType.roundTrip);
  }

  void initializeCityPairs() {
    // Clear existing pairs
    cityPairs.clear();

    // Add initial two pairs with proper date sequencing
    DateTime baseDate = DateTime.now();

    cityPairs.addAll([
      CityPair(
        fromCity: 'LHR',
        fromCityName: 'LAHORE',
        toCity: 'DBX',
        toCityName: 'DUBAI',
        departureDate: _formatDateForUI(baseDate),
      ),
      CityPair(
        fromCity: 'DBX',
        fromCityName: 'DUBAI',
        toCity: 'JED',
        toCityName: 'JEDDAH',
        departureDate: _formatDateForUI(baseDate.add(const Duration(days: 1))),
      ),
    ]);
  }

  void setTripType(TripType type) {
    tripType.value = type;

    if (type == TripType.multiCity) {
      // If there are no city pairs, initialize them
      if (cityPairs.isEmpty) {
        initializeCityPairs();
      }
      // If there's only one pair, add another with connected cities and sequential dates
      else if (cityPairs.length < 2) {
        DateTime nextDay = DateFormat('dd/MM/yyyy')
            .parse(cityPairs.last.departureDate.value)
            .add(const Duration(days: 1));

        cityPairs.add(
          CityPair(
            fromCity: cityPairs.last.toCity.value,
            fromCityName: cityPairs.last.toCityName.value,
            toCity: 'LHR',
            toCityName: 'LAHORE',
            departureDate: _formatDateForUI(nextDay),
          ),
        );
      }
    }
  }

  String _getDefaultDepartureDate(int daysToAdd) {
    final DateTime date = DateTime.now().add(Duration(days: daysToAdd));
    return _formatDateForUI(date);
  }

  void swapCities() {
    if (tripType.value != TripType.multiCity) {
      final tempCity = fromCity.value;
      final tempCityName = fromCityName.value;

      fromCity.value = toCity.value;
      fromCityName.value = toCityName.value;

      toCity.value = tempCity;
      toCityName.value = tempCityName;
    }
  }

  void swapCitiesForPair(int index) {
    if (index < cityPairs.length) {
      cityPairs[index].swap();

      // Update the next flight's origin to match this flight's destination
      if (index < cityPairs.length - 1) {
        cityPairs[index + 1].fromCity.value = cityPairs[index].toCity.value;
        cityPairs[index + 1].fromCityName.value =
            cityPairs[index].toCityName.value;
      }
    }
  }

  void addCityPair() {
    if (cityPairs.length < 5) {
      final lastPair = cityPairs.last;

      // Parse the departure date of the last pair
      DateTime lastDepartureDate = DateFormat(
        'dd/MM/yyyy',
      ).parse(lastPair.departureDate.value);
      // Add one day for the new flight's departure date
      DateTime nextDepartureDate = lastDepartureDate.add(
        const Duration(days: 1),
      );

      cityPairs.add(
        CityPair(
          fromCity: lastPair.toCity.value,
          fromCityName: lastPair.toCityName.value,
          toCity: 'BLR',
          toCityName: 'BENGALURU',
          departureDate: _formatDateForUI(nextDepartureDate),
        ),
      );
    }
  }

  void removeCityPair() {
    if (cityPairs.length > 2) {
      cityPairs.removeLast();
    }
  }

  void setDepartureDate(String date) {
    departureDate.value = date;

    // If return date is before the new departure date, update return date
    final DateTime departure = DateFormat(
      'dd/MM/yyyy',
    ).parse(departureDate.value);
    final DateTime returnDt = DateFormat('dd/MM/yyyy').parse(returnDate.value);

    if (returnDt.isBefore(departure)) {
      returnDate.value = date;
    }
  }

  void setReturnDate(String date) {
    returnDate.value = date;

    // If departure date is after the new return date, update departure date
    final DateTime departure = DateFormat(
      'dd/MM/yyyy',
    ).parse(departureDate.value);
    final DateTime returnDt = DateFormat('dd/MM/yyyy').parse(returnDate.value);

    if (departure.isAfter(returnDt)) {
      departureDate.value = date;
    }
  }

  void setDepartureDateForPair(int index, String date) {
    if (index < cityPairs.length) {
      // Update this pair's departure date
      cityPairs[index].departureDate.value = date;

      // If this is not the last pair, update the next pair's departure date to be one day after
      if (index < cityPairs.length - 1) {
        DateTime selectedDate = DateFormat('dd/MM/yyyy').parse(date);
        DateTime nextDay = selectedDate.add(const Duration(days: 1));
        cityPairs[index + 1].departureDate.value = _formatDateForUI(nextDay);
      }
    }
  }

  Future<void> searchFlights() async {
    try {
      isSearching.value = true;
      // Debugging: Print all search parameters
      print('Search parameters:');
      print('Trip type: ${tripType.value}');
      print('From City: ${fromCity.value}');
      print('To City: ${toCity.value}');
      print('Departure Date: ${departureDate.value}');
      print('Return Date: ${returnDate.value}');
      print('Adults: ${adultCount.value}');
      print('Children: ${childrenCount.value}');
      print('Infants: ${infantCount.value}');
      print('Cabin: ${travelClass.value}');

      // Validate inputs
      if (fromCity.value.isEmpty || toCity.value.isEmpty) {
        Get.snackbar(
          'Error',
          'Please select both departure and destination cities.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Prepare parameters for API call with leading commas to match API expectations
      String origin = '';
      String destination = '';
      String formattedDates = '';

      if (tripType.value == TripType.multiCity) {
        // For multi-city trips, populate origins and destinations from cityPairs
        origins.clear();
        destinations.clear();

        for (var pair in cityPairs) {
          origins.add(pair.fromCity.value);
          destinations.add(pair.toCity.value);
        }

        // Format dates for multi-city with leading comma
        formattedDates = ','; // Start with a comma
        for (int i = 0; i < cityPairs.length; i++) {
          if (i > 0) formattedDates += ',';
          formattedDates += _formatDateForAPI(
            DateFormat('dd/MM/yyyy').parse(cityPairs[i].departureDate.value),
          );
        }

        // Use formattedOrigins and formattedDestinations which add a leading comma
        origin = formattedOrigins;
        destination = formattedDestinations;
      } else {
        // For one-way and round-trip, add a leading comma to match API expectations
        origin = ',${fromCity.value}';
        destination = ',${toCity.value}';

        // Format dates for one-way and round-trip with leading comma
        formattedDates =
        ',${_formatDateForAPI(DateFormat('dd/MM/yyyy').parse(departureDate.value))}';
        if (tripType.value == TripType.roundTrip) {
          formattedDates +=
          ',${_formatDateForAPI(DateFormat('dd/MM/yyyy').parse(returnDate.value))}';
        }
      }

      // Debugging: Print formatted parameters
      print('Formatted Dates: $formattedDates');
      print('Origin: $origin');
      print('Destination: $destination');

      // Call the API with parameters correctly formatted with leading commas
      final results = await apiServiceFlight.searchFlights(
        type:
        tripType.value == TripType.multiCity
            ? 2
            : (tripType.value == TripType.roundTrip ? 1 : 0),
        origin: origin,
        destination: destination,
        depDate: formattedDates,
        adult: adultCount.value,
        child: childrenCount.value,
        infant: infantCount.value,
        stop: 2, // Assuming max 2 stops
        cabin: travelClass.value.toUpperCase(),
      );

      // Load results into FlightController
      flightController.loadFlights(results);

      // Navigate to the results page
      Get.to(
            () => FlightBookingPage(
          scenario:
          tripType.value == TripType.roundTrip
              ? FlightScenario.returnFlight
              : (tripType.value == TripType.multiCity
              ? FlightScenario.multiCity
              : FlightScenario.oneWay),
        ),
      );
    } catch (e, stackTrace) {
      // Debugging: Print the error and stack trace
      print('Error in searchFlights: $e');
      print('Stack trace: $stackTrace');

      // Show error message to the user
      Get.snackbar(
        'Error',
        'Error searching flights: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }finally {
      isSearching.value = false;
    }
  }

  String _formatDateForUI(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _formatDateForAPI(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  void openDepartureDatePicker(BuildContext context) {
    _showDatePicker(context, (date) {
      setDepartureDate(_formatDateForUI(date));
    });
  }

  void openReturnDatePicker(BuildContext context) {
    if (tripType.value != TripType.oneWay) {
      _showDatePicker(context, (date) {
        setReturnDate(_formatDateForUI(date));
      });
    }
  }

  void openDatePickerForPair(BuildContext context, int index) {
    _showDatePicker(context, (date) {
      setDepartureDateForPair(index, _formatDateForUI(date));
    });
  }

  void _showDatePicker(
      BuildContext context,
      Function(DateTime) onDateSelected,
      ) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    ).then((date) {
      if (date != null) {
        onDateSelected(date);
      }
    });
  }

  void showCitySelectionBottomSheet(
      BuildContext context,
      FieldType fieldType, {
        int? multiCityIndex,
      }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => CitySelectionBottomSheet(
        fieldType: fieldType,
        onCitySelected: (AirportData airport) {
          if (tripType.value == TripType.multiCity &&
              multiCityIndex != null) {
            if (fieldType == FieldType.departure) {
              cityPairs[multiCityIndex].fromCity.value = airport.code;
              cityPairs[multiCityIndex].fromCityName.value =
                  airport.cityName;
            } else {
              cityPairs[multiCityIndex].toCity.value = airport.code;
              cityPairs[multiCityIndex].toCityName.value = airport.cityName;

              // If this is not the last pair, update the next pair's departure city
              if (multiCityIndex < cityPairs.length - 1) {
                cityPairs[multiCityIndex + 1].fromCity.value = airport.code;
                cityPairs[multiCityIndex + 1].fromCityName.value =
                    airport.cityName;
              }
            }
          } else {
            if (fieldType == FieldType.departure) {
              fromCity.value = airport.code;
              fromCityName.value = airport.cityName;
            } else {
              toCity.value = airport.code;
              toCityName.value = airport.cityName;
            }
          }
        },
      ),
    );
  }

  void showTravelersSelectionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => TravelersSelectionBottomSheet(
        onTravelersSelected: (adults, children, infants) {
          if (infants > adults) {
            Get.snackbar(
              'Error',
              'Number of infants cannot exceed the number of adults.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          } else {
            updateTravellerCounts(adults, children, infants);
          }
        },
      ),
    );
  }

  void showClassSelectionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => ClassSelectionBottomSheet(
        initialClass: travelClass.value,
        onClassSelected: (selectedClass) {
          travelClass.value = selectedClass;
        },
      ),
    );
  }

  void updateTravellerCounts(int adults, int children, int infants) {
    adultCount.value = adults;
    childrenCount.value = children;
    infantCount.value = infants;
    travellersCount.value = adults + children + infants;
  }
}
