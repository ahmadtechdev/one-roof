import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:xml/xml.dart' as xml;

import '../../../../../services/api_service_pia.dart';
import '../../search_flight_utils/filter_flight_model.dart';
import 'pia_flight_model.dart';
import 'pia_flight_package.dart';
import 'pia_return_flight_page.dart';

class PIAFlightController extends GetxController {
  final RxList<PIAFlight> outboundFlights = <PIAFlight>[].obs;
  final RxList<PIAFlight> inboundFlights = <PIAFlight>[].obs;
  final RxList<PIAFlight> filteredFlights = <PIAFlight>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString selectedCurrency = 'PKR'.obs;
  final RxBool isRoundTrip = false.obs;
  // final Rx<PIAFlight?> selectedOutboundFlight = Rx<PIAFlight?>(null);
  final RxBool showReturnFlights = false.obs;
  final RxBool isMultiCity = false.obs; // Add this flag
  final RxMap<String, List<PIAFareOption>> fareOptionsByFlight = <String, List<PIAFareOption>>{}.obs;
  final Rx<PIAFlight?> selectedFlight = Rx<PIAFlight?>(null);
  PIAFlight? selectedOutboundFlight;
  PIAFareOption? selectedOutboundFareOption;
  PIAFlight? selectedReturnFlight;
  PIAFareOption? selectedReturnFareOption;
  int i=0;

  void updateCurrency(String currency) {
    selectedCurrency.value = currency;
  }

  void clearFlights() {
    outboundFlights.clear();
    inboundFlights.clear();
    filteredFlights.clear();
    errorMessage.value = '';
    isRoundTrip.value = false;
    showReturnFlights.value = false;
  }

  void setErrorMessage(String message) {
    errorMessage.value = message;
  }

  Future<void> loadFlights(Map<String, dynamic> apiResponse) async {
    try {
      isLoading.value = true;
      clearFlights();

      if (apiResponse.isEmpty) {
        throw Exception('Empty API response');
      }

      if (apiResponse['error'] != null) {
        throw Exception(apiResponse['error']);
      }

      // Handle both direct response and SOAP envelope
      Map<String, dynamic> availability;

      // Check for SOAP envelope structure
      if (apiResponse['S:Envelope'] != null ||
          apiResponse['soapenv:Envelope'] != null) {
        final envelope =
            apiResponse['S:Envelope'] ?? apiResponse['soapenv:Envelope'];
        final body = envelope['S:Body'] ?? envelope['soapenv:Body'];
        final response =
            body['ns2:GetAvailabilityResponse'] ??
                body['impl:GetAvailabilityResponse'];
        availability = response['Availability'] ?? {};
      } else {
        availability = apiResponse;
      }

      // Check if this is a round trip or multi-city response
      final availabilityRouteLists =
          availability['availabilityRouteList'] ??
              availability['availabilityResultList']?['availabilityRouteList'];

      if (availabilityRouteLists == null) {
        throw Exception('No availability route lists found');
      }

      // Handle both single route list and list of route lists
      final routeLists =
      availabilityRouteLists is List
          ? availabilityRouteLists
          : [availabilityRouteLists];

      // Determine trip type
      isRoundTrip.value = routeLists.length > 1;
      isMultiCity.value = _isMultiCity(routeLists);

      for (int i = 0; i < routeLists.length; i++) {
        final routeList = routeLists[i];
        final bool isOutbound = i == 0; // First route is outbound

        _processRouteList(routeList, isOutbound: isOutbound);
      }

      // For one-way and multi-city trips, show all flights immediately
      // For round trips, only show outbound flights first
      print("Ahamd 4");
      print(inboundFlights.length);
      filteredFlights.assignAll(
        isRoundTrip.value
            ? outboundFlights
            : [...outboundFlights, ...inboundFlights],
      );
    } catch (e, stackTrace) {
      debugPrint('Error loading PIA flights: $e');
      debugPrint('Stack trace: $stackTrace');
      setErrorMessage('Failed to load PIA flights: ${e.toString()}');
      outboundFlights.value = [];
      inboundFlights.value = [];
      filteredFlights.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  bool _isMultiCity(List<dynamic> routeLists) {
    // Check if this is a multi-city flight by examining the structure
    if (routeLists.length <= 1) return false;

    // Multi-city flights typically have multiple bounds within a single route list
    for (final routeList in routeLists) {
      final byDateList =
          routeList['availabilityByDateList'] ??
              routeList['\$']?['availabilityByDateList'];
      if (byDateList == null) continue;

      final dateLists = byDateList is List ? byDateList : [byDateList];
      for (final dateData in dateLists) {
        final options =
            dateData['originDestinationOptionList'] ??
                dateData['\$']?['originDestinationOptionList'];
        if (options == null) continue;

        final optionList = options is List ? options : [options];
        for (final option in optionList) {
          final fareGroups =
              option['fareComponentGroupList'] ??
                  option['\$']?['fareComponentGroupList'];
          if (fareGroups == null) continue;

          final fareGroupList = fareGroups is List ? fareGroups : [fareGroups];
          for (final fareGroup in fareGroupList) {
            final boundList = fareGroup['boundList'] ?? option['boundList'];
            if (boundList == null) continue;

            final bounds = boundList is List ? boundList : [boundList];
            if (bounds.length > 1) {
              return true; // Multiple bounds in a single route list indicates multi-city
            }
          }
        }
      }
    }
    return false;
  }

  // Update the _processRouteList method
  // In PIAFlightController.dart
  void _processRouteList(
      Map<String, dynamic> routeList, {
        required bool isOutbound,
      }) {
    try {
      final byDateList = routeList['availabilityByDateList'] ??
          routeList['\$']?['availabilityByDateList'];
      if (byDateList == null) return;

      final dateLists = byDateList is List ? byDateList : [byDateList];

      for (final dateData in dateLists) {
        final date = _extractStringValue(dateData['dateList']);
        final options = dateData['originDestinationOptionList'] ??
            dateData['\$']?['originDestinationOptionList'];
        if (options == null) continue;

        final optionList = options is List ? options : [options];


        for (final option in optionList) {
          _processOriginDestinationOption(
            option,
            isOutbound: isOutbound,
            date: date,
          );
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Error processing route list: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  void _processOriginDestinationOption(
      Map<String, dynamic> option, {
        required bool isOutbound,
        String? date,
      }) {
    try {
      final fareGroups = option['fareComponentGroupList'] ??
          option['\$']?['fareComponentGroupList'];
      if (fareGroups == null) return;

      final fareGroupList = fareGroups is List ? fareGroups : [fareGroups];

      for (final fareGroup in fareGroupList) {
        final boundList = fareGroup['boundList'] ?? option['boundList'];
        if (boundList == null) continue;

        final bounds = boundList is List ? boundList : [boundList];
        print("xyz: check");
        print(bounds.length);
        // Get fare components
        final fareComponents = fareGroup['fareComponentList'];
        if (fareComponents == null) continue;

        final componentList = fareComponents is List ? fareComponents : [fareComponents];
        if (componentList.isEmpty) continue;

        // Use the first fare component for the flight
        final firstComponent = componentList[0];

        // Create flight with all legs
        final flight = _createMultiCityFlight(
          bounds,
          firstComponent,
          isOutbound: isOutbound,
          date: date,
        );

        if (flight != null) {
          if (isOutbound) {
            outboundFlights.add(flight);
          } else {
            inboundFlights.add(flight);
          }

          // Store all fare options for this flight
          final fareOptions = componentList
              .whereType<Map<String, dynamic>>()
              .map((c) => PIAFareOption.fromFareInfo(c))
              .toList();

          if (fareOptions.isNotEmpty) {
            fareOptionsByFlight[flight.flightNumber] = fareOptions;
          }
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Error processing origin-destination option: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }


  // Replace the _processFareGroup method in PIAFlightController



  // Update the _createMultiCityFlight method
  PIAFlight? _createMultiCityFlight(
      List<dynamic> segments,
      Map<String, dynamic> fareComponent, {
        required bool isOutbound,
        String? date,
      }) {
    try {
      if (segments.isEmpty) return null;

      // Extract availFlightSegmentList from each segment
      final List<Map<String, dynamic>> legSchedules = [];
      final List<Map<String, dynamic>> legWithStops = [];

      for (var segment in segments) {
        legSchedules.add(segment);
        final availFlightSegments = segment['availFlightSegmentList'];
        if (availFlightSegments == null) continue;

        // Handle both single segment and list of segments
        if (availFlightSegments is List) {
          for (var flightSegment in availFlightSegments) {
            legWithStops.add(flightSegment);
          }
        } else {
          legWithStops.add(availFlightSegments);
        }
      }

      if (legSchedules.isEmpty) return null;

      // Use first segment as the base for flight creation
      final firstSegment = legSchedules[0];
      final flightSegment = firstSegment['flightSegment'] ?? firstSegment;

      // Get passenger fare info from the fareComponent
      final passengerFareInfoList = fareComponent['passengerFareInfoList'];
      if (passengerFareInfoList == null) return null;

      // Handle both single fare info and list of fare infos
      final fareInfoList = passengerFareInfoList is List
          ? (passengerFareInfoList.isNotEmpty ? passengerFareInfoList[0] : null)
          : passengerFareInfoList;
      if (fareInfoList == null) return null;

      final fareInfo = fareInfoList['fareInfoList'];
      if (fareInfo == null) return null;

      // Handle both single fare info and list of fare infos
      final firstFareInfo = fareInfo is List
          ? (fareInfo.isNotEmpty ? fareInfo[0] : null)
          : fareInfo;
      if (firstFareInfo == null) return null;

      final pricingInfo = fareInfoList['pricingInfo'];
      if (pricingInfo == null) return null;

      // Create flight data structure
      final flightData = {
        'flightSegment': flightSegment,
        'fareInfoList': [{'fareInfoList': [firstFareInfo]}],
        'pricingInfo': pricingInfo,
      };

      // Create base flight
      final flight = PIAFlight.fromApiResponse(
        flightData,
        isOutbound: isOutbound,
        date: date,
        isMultiCity: true,
        legSchedules: legSchedules,
        legWithStops: legWithStops,
      );

      return flight;
    } catch (e, stackTrace) {
      debugPrint('Error creating multi-city flight: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }


  // Update the handlePIAFlightSelection method
  // Update the handlePIAFlightSelection method
  void handlePIAFlightSelection(PIAFlight flight, {bool isReturnFlight = false}) {

    if (isRoundTrip.value) {

      print("ahmad 5");
      print(isReturnFlight);
      if (!isReturnFlight) {
        // First flight selection (outbound)
        selectedOutboundFlight = flight;
        selectedFlight.value = flight;
        Get.to(() => PIAPackageSelectionDialog(
          flight: flight,
          isReturnFlight: false,
        ));
      } else {
        // Return flight selection
        selectedReturnFlight = flight;
        selectedFlight.value = flight;
        Get.to(() => PIAPackageSelectionDialog(
          flight: flight,
          isReturnFlight: true,
        ));
      }
    } else if (isMultiCity.value) {
      // Multi-city flight selection
      selectedFlight.value = flight;
      Get.to(() => PIAPackageSelectionDialog(
        flight: flight,
        isReturnFlight: false,
      ));
    } else {
      // One-way flight selection
      selectedFlight.value = flight;
      Get.to(() => PIAPackageSelectionDialog(
        flight: flight,
        isReturnFlight: false,
      ));
    }
  }
  // Add method to get fare options for a flight
  List<PIAFareOption> getFareOptionsForFlight(PIAFlight flight) {
    return fareOptionsByFlight[flight.flightNumber] ?? [];
  }

  static String _extractStringValue(dynamic value) {
    if (value == null) return '';
    if (value is String) return value.trim();
    if (value is Map<String, dynamic>) {
      // Handle Badgerfish format where text might be under '$'
      if (value.containsKey('\$')) {
        return _extractStringValue(value['\$']);
      }
      return value['text']?.toString().trim() ?? '';
    }
    return value.toString().trim();
  }
}

// In pia_flight_controller.dart
extension PIAFlightFiltering on PIAFlightController {
  void applyFilters(FlightFilter filter) {
    // Filter by airlines (PIA only)
    List<PIAFlight> airlineFiltered =
    outboundFlights.where((flight) {
      if (filter.selectedAirlines.isEmpty) return true;
      return filter.selectedAirlines.contains('PK'); // PIA's code
    }).toList();

    // Filter by stops (PIA flights are usually non-stop)
    List<PIAFlight> stopsFiltered =
    airlineFiltered.where((flight) {
      if (filter.maxStops == null) return true;
      return flight.isNonStop
          ? 0 <= filter.maxStops!
          : 1 <= filter.maxStops!;
    }).toList();

    // Sort
    List<PIAFlight> sorted = [...stopsFiltered];
    switch (filter.sortType) {
      case 'Cheapest':
        sorted.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Fastest':
        sorted.sort(
              (a, b) => (a.legElapsedTime ?? 0).compareTo(b.legElapsedTime ?? 0),
        );
        break;
      default:
      // Suggested sorting
        break;
    }

    filteredFlights.value = sorted;
  }
}