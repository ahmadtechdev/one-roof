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
  final RxMap<String, List<PIAFareOption>> fareOptionsByFlight =
      <String, List<PIAFareOption>>{}.obs;
  final Rx<PIAFlight?> selectedFlight = Rx<PIAFlight?>(null);
  PIAFlight? selectedOutboundFlight;
  PIAFareOption? selectedOutboundFareOption;
  PIAFlight? selectedReturnFlight;
  PIAFareOption? selectedReturnFareOption;
  int i = 0;

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
  void _processRouteList(
    Map<String, dynamic> routeList, {
    required bool isOutbound,
  }) {
    try {
      final byDateList =
          routeList['availabilityByDateList'] ??
          routeList['\$']?['availabilityByDateList'];
      if (byDateList == null) return;

      final dateLists = byDateList is List ? byDateList : [byDateList];

      for (final dateData in dateLists) {
        final date = _extractStringValue(dateData['dateList']);
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

            if (isMultiCity.value && bounds.length > 1) {
              _processMultiCityFareGroup(
                bounds,
                fareGroup,
                isOutbound: isOutbound,
                date: date,
              );
            } else {
              _processFareGroup(
                fareGroup,
                option,
                isOutbound: isOutbound,
                date: date,
              );
            }
          }
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Error processing route list: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  // Replace the _processFareGroup method in PIAFlightController

  void _processFareGroup(
    Map<String, dynamic> fareGroup,
    Map<String, dynamic> option, {
    required bool isOutbound,
    String? date,
  }) {
    try {
      final boundList = fareGroup['boundList'] ?? option['boundList'];
      if (boundList == null) return;

      final bounds = boundList is List ? boundList : [boundList];
      final segments = bounds[0]['availFlightSegmentList'];
      final segmentList = segments is List ? segments : [segments];
      if (segmentList.isEmpty) return;

      // Process all fare components
      final fareComponents = fareGroup['fareComponentList'];
      if (fareComponents == null) return;

      final componentList =
          fareComponents is List ? fareComponents : [fareComponents];

      // Create flight with first component (lowest price)
      if (componentList.isNotEmpty) {
        final flight = _createFlightFromComponents(
          segmentList[0],
          componentList[0],
          isOutbound: isOutbound,
          date: date,
          isMultiCity: isMultiCity.value,
        );

        if (flight != null) {
          // Store all fare options for this flight - with null checking
          final fareOptions = <PIAFareOption>[];

          for (final component in componentList) {
            try {
              if (component != null && component is Map<String, dynamic>) {
                final fareOption = PIAFareOption.fromFareInfo(component);
                fareOptions.add(fareOption);
              }
            } catch (e) {
              print('Error creating fare option from component: $e');
              // Continue with other components instead of failing completely
            }
          }

          // Only store if we have at least one valid fare option
          if (fareOptions.isNotEmpty) {
            fareOptionsByFlight[flight.flightNumber] = fareOptions;

            if (isOutbound) {
              outboundFlights.add(flight);
            } else {
              inboundFlights.add(flight);
              print("ahmad: $i : ");
              print(inboundFlights);
            }
          }
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Error processing fare group: $e');
      debugPrint('Stack trace: $stackTrace');
      // Don't rethrow - just log and continue with other fare groups
    }
  }

  void _processMultiCityFareGroup(
    List<dynamic> bounds,
    Map<String, dynamic> fareGroup, {
    required bool isOutbound,
    String? date,
  }) {
    try {
      // Collect all segments from all bounds
      List<Map<String, dynamic>> allSegments = [];
      for (final bound in bounds) {
        final segments = bound['availFlightSegmentList'];
        if (segments == null) continue;

        final segmentList = segments is List ? segments : [segments];
        allSegments.addAll(segmentList as Iterable<Map<String, dynamic>>);
      }

      if (allSegments.isEmpty) return;

      // Process fare components - only take the first one
      final fareComponents = fareGroup['fareComponentList'];
      if (fareComponents == null) return;

      // Handle both single fare component and list of fare components
      final componentList =
          fareComponents is List ? fareComponents : [fareComponents];
      if (componentList.isEmpty) return;

      // Only process the first component
      final firstComponent = componentList[0];

      // Create a combined flight for all segments
      final flight = _createMultiCityFlight(
        allSegments,
        firstComponent,
        isOutbound: isOutbound,
        date: date,
      );

      if (flight != null) {
        outboundFlights.add(
          flight,
        ); // Multi-city flights are always added to outbound
      }
    } catch (e, stackTrace) {
      debugPrint('Error processing multi-city fare group: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  // Update the _createMultiCityFlight method
  PIAFlight? _createMultiCityFlight(
    List<Map<String, dynamic>> segments,
    Map<String, dynamic> fareComponent, {
    required bool isOutbound,
    String? date,
  }) {
    try {
      if (segments.isEmpty) return null;

      // Use first segment as the base
      final firstSegment = segments[0];
      final flightSegment = firstSegment['flightSegment'] ?? firstSegment;

      print("ahmad");
      print(flightSegment);
      // Get passenger fare info
      final passengerFareInfoList =
          fareComponent['passengerFareInfoList'] ??
          fareComponent['\$']?['passengerFareInfoList'];
      if (passengerFareInfoList == null) return null;

      final fareInfoList =
          passengerFareInfoList is List
              ? (passengerFareInfoList.isNotEmpty
                  ? passengerFareInfoList[0]
                  : null)
              : passengerFareInfoList;
      if (fareInfoList == null) return null;

      final fareInfo =
          fareInfoList['fareInfoList'] ?? fareInfoList['\$']?['fareInfoList'];
      if (fareInfo == null) return null;

      final firstFareInfo =
          fareInfo is List
              ? (fareInfo.isNotEmpty ? fareInfo[0] : null)
              : fareInfo;
      if (firstFareInfo == null) return null;

      final pricingInfo =
          fareInfoList['pricingInfo'] ?? fareInfoList['\$']?['pricingInfo'];
      if (pricingInfo == null) return null;

      // Create flight data structure
      final flightData = {
        'flightSegment': flightSegment,
        'fareInfoList': [
          {
            'fareInfoList': [firstFareInfo],
          },
        ],
        'pricingInfo': pricingInfo,
      };

      // Create base flight
      final flight = PIAFlight.fromApiResponse(
        flightData,
        isOutbound: isOutbound,
        date: date,
        isMultiCity: true,
      );

      // Update with multi-city specific data
      return flight.copyWith(
        legSchedules: segments,
        duration: _calculateTotalDuration(segments),
        isMultiCity: true,
      );
    } catch (e, stackTrace) {
      debugPrint('Error creating multi-city flight: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  PIAFlight? _createFlightFromComponents(
    Map<String, dynamic> segment,
    Map<String, dynamic> fareComponent, {
    required bool isOutbound,
    String? boundCode,
    String? date,
    bool isMultiCity = false,
  }) {
    try {
      debugPrint('Creating flight from segment: ${segment['flightNumber']}');

      // Handle different segment structures
      final flightSegment = segment['flightSegment'] ?? segment;

      // Validate required fields are present
      if (flightSegment['departureAirport'] == null ||
          flightSegment['arrivalAirport'] == null) {
        debugPrint(
          'Missing airport information in segment: ${flightSegment.keys}',
        );
        return null;
      }

      // Get passenger fare info (first passenger type)
      final passengerFareInfoList =
          fareComponent['passengerFareInfoList'] ??
          fareComponent['\$']?['passengerFareInfoList'];

      if (passengerFareInfoList == null) {
        debugPrint('No passenger fare info list');
        return null;
      }

      // Handle both single info and list
      final fareInfoList =
          passengerFareInfoList is List
              ? (passengerFareInfoList.isNotEmpty
                  ? passengerFareInfoList[0]
                  : null)
              : passengerFareInfoList;

      if (fareInfoList == null) {
        debugPrint('No fare info list');
        return null;
      }

      final fareInfo =
          fareInfoList['fareInfoList'] ?? fareInfoList['\$']?['fareInfoList'];
      if (fareInfo == null) {
        debugPrint('No fare info found');
        return null;
      }

      // Handle both single fare info and list
      final firstFareInfo =
          fareInfo is List
              ? (fareInfo.isNotEmpty ? fareInfo[0] : null)
              : fareInfo;

      if (firstFareInfo == null) {
        debugPrint('No first fare info found');
        return null;
      }

      final pricingInfo =
          fareInfoList['pricingInfo'] ?? fareInfoList['\$']?['pricingInfo'];
      if (pricingInfo == null) {
        debugPrint('No pricing info found');
        return null;
      }

      // Create flight data structure for the model
      final flightData = {
        'flightSegment': flightSegment,
        'fareInfoList': [
          {
            'fareInfoList': [firstFareInfo],
          },
        ],
        'pricingInfo': pricingInfo,
      };

      return PIAFlight.fromApiResponse(
        flightData,
        isOutbound: isOutbound,
        boundCode: boundCode,
        date: date,
        isMultiCity: isMultiCity,
      );
    } catch (e, stackTrace) {
      debugPrint('Error creating flight from components: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  String _calculateTotalDuration(List<Map<String, dynamic>> segments) {
    int totalMinutes = 0;
    for (var segment in segments) {
      final durationStr = segment['journeyDuration'] ?? 'PT0H0M';
      totalMinutes += _parseDurationToMinutes(durationStr);
    }
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return 'PT${hours}H${minutes}M';
  }

  int _parseDurationToMinutes(String durationStr) {
    // Handle null or empty strings
    if (durationStr.isEmpty) return 0;

    // Remove 'PT' prefix if present
    String duration = durationStr.replaceFirst('PT', '');

    int hours = 0;
    int minutes = 0;

    // Extract hours
    RegExp hoursRegex = RegExp(r'(\d+)H');
    Match? hoursMatch = hoursRegex.firstMatch(duration);
    if (hoursMatch != null) {
      hours = int.parse(hoursMatch.group(1)!);
    }

    // Extract minutes
    RegExp minutesRegex = RegExp(r'(\d+)M');
    Match? minutesMatch = minutesRegex.firstMatch(duration);
    if (minutesMatch != null) {
      minutes = int.parse(minutesMatch.group(1)!);
    }

    // Convert total to minutes
    return (hours * 60) + minutes;
  }

  // Update the handlePIAFlightSelection method
  // Update the handlePIAFlightSelection method
  void handlePIAFlightSelection(
    PIAFlight flight, {
    bool isReturnFlight = false,
  }) {
    if (isRoundTrip.value) {
      print("ahmad 5");
      print(isReturnFlight);
      if (!isReturnFlight) {
        // First flight selection (outbound)
        selectedOutboundFlight = flight;
        selectedFlight.value = flight;
        Get.to(
          () =>
              PIAPackageSelectionDialog(flight: flight, isReturnFlight: false),
        );
      } else {
        // Return flight selection
        selectedReturnFlight = flight;
        selectedFlight.value = flight;
        Get.to(
          () => PIAPackageSelectionDialog(flight: flight, isReturnFlight: true),
        );
      }
    } else if (isMultiCity.value) {
      // Multi-city flight selection
      selectedFlight.value = flight;
      Get.to(
        () => PIAPackageSelectionDialog(flight: flight, isReturnFlight: false),
      );
    } else {
      // One-way flight selection
      selectedFlight.value = flight;
      Get.to(
        () => PIAPackageSelectionDialog(flight: flight, isReturnFlight: false),
      );
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
