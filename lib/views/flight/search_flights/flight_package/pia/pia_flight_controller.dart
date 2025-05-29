import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:xml/xml.dart' as xml;

import '../../../../../services/api_service_pia.dart';
import 'pia_flight_model.dart';
import 'pia_return_flight_page.dart';

class PIAFlightController extends GetxController {
  final RxList<PIAFlight> outboundFlights = <PIAFlight>[].obs;
  final RxList<PIAFlight> inboundFlights = <PIAFlight>[].obs;
  final RxList<PIAFlight> filteredFlights = <PIAFlight>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString selectedCurrency = 'PKR'.obs;
  final RxBool isRoundTrip = false.obs;
  final Rx<PIAFlight?> selectedOutboundFlight = Rx<PIAFlight?>(null);
  final RxBool showReturnFlights = false.obs;

  final PIAFlightApiService _apiService = Get.put(PIAFlightApiService());

  void updateCurrency(String currency) {
    selectedCurrency.value = currency;
  }

  void clearFlights() {
    outboundFlights.clear();
    inboundFlights.clear();
    filteredFlights.clear();
    errorMessage.value = '';
    isRoundTrip.value = false;
    selectedOutboundFlight.value = null;
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
      if (apiResponse['S:Envelope'] != null || apiResponse['soapenv:Envelope'] != null) {
        final envelope = apiResponse['S:Envelope'] ?? apiResponse['soapenv:Envelope'];
        final body = envelope['S:Body'] ?? envelope['soapenv:Body'];
        final response = body['ns2:GetAvailabilityResponse'] ?? body['impl:GetAvailabilityResponse'];
        availability = response['Availability'] ?? {};
      } else {
        availability = apiResponse;
      }

      // Check if this is a round trip response
      final availabilityRouteLists = availability['availabilityRouteList'] ??
          availability['availabilityResultList']?['availabilityRouteList'];

      if (availabilityRouteLists == null) {
        throw Exception('No availability route lists found');
      }

      // Handle both single route list and list of route lists
      final routeLists = availabilityRouteLists is List ? availabilityRouteLists : [availabilityRouteLists];
      isRoundTrip.value = routeLists.length > 1;

      for (int i = 0; i < routeLists.length; i++) {
        final routeList = routeLists[i];
        final bool isOutbound = i == 0; // First route is outbound

        _processRouteList(routeList, isOutbound: isOutbound);
      }

      // For one-way trips, show all flights immediately
      // For round trips, only show outbound flights first
      filteredFlights.assignAll(isRoundTrip.value ? outboundFlights : [...outboundFlights, ...inboundFlights]);

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

  void _processRouteList(Map<String, dynamic> routeList, {required bool isOutbound}) {
    try {
      final byDateList = routeList['availabilityByDateList'] ?? routeList['\$']?['availabilityByDateList'];
      if (byDateList == null) return;

      // Handle both single date and list of dates
      final dateLists = byDateList is List ? byDateList : [byDateList];

      for (final dateData in dateLists) {
        final date = _extractStringValue(dateData['dateList']);
        final options = dateData['originDestinationOptionList'] ?? dateData['\$']?['originDestinationOptionList'];
        if (options == null) continue;

        // Handle both single option and list of options
        final optionList = options is List ? options : [options];

        for (final option in optionList) {
          final fareGroups = option['fareComponentGroupList'] ?? option['\$']?['fareComponentGroupList'];
          if (fareGroups == null) continue;

          // Handle both single fare group and list
          final fareGroupList = fareGroups is List ? fareGroups : [fareGroups];
          for (final fareGroup in fareGroupList) {
            _processFareGroup(fareGroup, option, isOutbound: isOutbound, date: date);
          }
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Error processing route list: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  void _processFareGroup(Map<String, dynamic> fareGroup, Map<String, dynamic> option,
      {required bool isOutbound, String? date}) {
    try {
      final boundList = fareGroup['boundList'] ?? option['boundList'];
      if (boundList == null) return;

      // Handle both single bound and list of bounds
      final bounds = boundList is List ? boundList : [boundList];

      for (final bound in bounds) {
        final boundCode = _extractStringValue(bound['boundCode']);
        final segments = bound['availFlightSegmentList'];
        if (segments == null) continue;

        // Handle both single segment and list of segments
        final segmentList = segments is List ? segments : [segments];

        // Get the main flight segment (first segment)
        if (segmentList.isEmpty) continue;
        final mainSegment = segmentList[0];

        // Process fare components - only take the first one
        final fareComponents = fareGroup['fareComponentList'];
        if (fareComponents == null) continue;

        // Handle both single fare component and list of fare components
        final componentList = fareComponents is List ? fareComponents : [fareComponents];
        if (componentList.isEmpty) continue;

        // Only process the first component
        final firstComponent = componentList[0];
        final flight = _createFlightFromComponents(
          mainSegment,
          firstComponent,
          isOutbound: isOutbound,
          boundCode: boundCode,
          date: date,
        );

        if (flight != null) {
          if (isOutbound) {
            outboundFlights.add(flight);
          } else {
            inboundFlights.add(flight);
          }
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Error processing fare group: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  PIAFlight? _createFlightFromComponents(
      Map<String, dynamic> segment, Map<String, dynamic> fareComponent,
      {required bool isOutbound, String? boundCode, String? date}) {
    try {
      debugPrint('Creating flight from segment: ${segment['flightNumber']}');

      // Handle different segment structures
      final flightSegment = segment['flightSegment'] ?? segment;

      // Validate required fields are present
      if (flightSegment['departureAirport'] == null || flightSegment['arrivalAirport'] == null) {
        debugPrint('Missing airport information in segment: ${flightSegment.keys}');
        return null;
      }

      // Get passenger fare info (first passenger type)
      final passengerFareInfoList = fareComponent['passengerFareInfoList'] ??
          fareComponent['\$']?['passengerFareInfoList'];

      if (passengerFareInfoList == null) {
        debugPrint('No passenger fare info list');
        return null;
      }

      // Handle both single info and list
      final fareInfoList = passengerFareInfoList is List
          ? (passengerFareInfoList.isNotEmpty ? passengerFareInfoList[0] : null)
          : passengerFareInfoList;

      if (fareInfoList == null) {
        debugPrint('No fare info list');
        return null;
      }

      final fareInfo = fareInfoList['fareInfoList'] ?? fareInfoList['\$']?['fareInfoList'];
      if (fareInfo == null) {
        debugPrint('No fare info found');
        return null;
      }

      // Handle both single fare info and list
      final firstFareInfo = fareInfo is List ? (fareInfo.isNotEmpty ? fareInfo[0] : null) : fareInfo;

      if (firstFareInfo == null) {
        debugPrint('No first fare info found');
        return null;
      }

      final pricingInfo = fareInfoList['pricingInfo'] ?? fareInfoList['\$']?['pricingInfo'];
      if (pricingInfo == null) {
        debugPrint('No pricing info found');
        return null;
      }

      // Create flight data structure for the model
      final flightData = {
        'flightSegment': flightSegment,
        'fareInfoList': [{'fareInfoList': [firstFareInfo]}],
        'pricingInfo': pricingInfo,
      };

      return PIAFlight.fromApiResponse(
        flightData,
        isOutbound: isOutbound,
        boundCode: boundCode,
        date: date,
      );
    } catch (e, stackTrace) {
      debugPrint('Error creating flight from components: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  void handlePIAFlightSelection(PIAFlight flight) {
    if (isRoundTrip.value) {
      if (selectedOutboundFlight.value == null) {
        // First flight selection (outbound)
        selectedOutboundFlight.value = flight;
        showReturnFlights.value = true;

        // Navigate to return flights page
        Get.to(() => PIAReturnFlightsPage(
          returnFlights: inboundFlights,
        ));
      } else {
        // Second flight selection (return)
        // Handle the complete booking with both flights
        Get.back(); // Close the return flights page
        Get.snackbar("Booking Selected",
            "Outbound: ${selectedOutboundFlight.value!.flightNumber} "
                "Return: ${flight.flightNumber}");

        // Reset selection
        selectedOutboundFlight.value = null;
        showReturnFlights.value = false;
      }
    } else {
      // One-way flight selection
      Get.snackbar("Flight Selected", "Flight ${flight.flightNumber} selected");
      // Proceed with booking
    }
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