// models/airblue_flight_model.dart
import 'package:flutter/foundation.dart';
import 'flight_models.dart';

class AirBlueFlight {
  final String id;
  final double price;
  final bool isRefundable;
  final BaggageAllowance baggageAllowance;
  final List<Map<String, dynamic>> legSchedules;
  final List<Map<String, dynamic>> stopSchedules;
  final List<FlightSegmentInfo> segmentInfo;
  final String airlineCode;
  final String airlineName;
  final String airlineImg;

  AirBlueFlight({
    required this.id,
    required this.price,
    required this.isRefundable,
    required this.baggageAllowance,
    required this.legSchedules,
    required this.stopSchedules,
    required this.segmentInfo,
    required this.airlineCode,
    required this.airlineName,
    required this.airlineImg,
  });

  factory AirBlueFlight.fromJson(Map<String, dynamic> json, Map<String, AirlineInfo> airlineMap) {
    try {
      // Extract flight segment data
      final flightSegment = json['AirItinerary']['OriginDestinationOptions']['OriginDestinationOption']['FlightSegment'];

      // Extract airline info
      final marketingAirline = flightSegment['MarketingAirline'] ?? {};
      final airlineCode = marketingAirline['Code'] ?? 'PA';

      // Get airline info from the map
      final airlineInfo = airlineMap[airlineCode] ??
          AirlineInfo('Air Blue', 'https://images.kiwi.com/airlines/64/PA.png');

      // Extract pricing info
      final pricingInfo = json['AirItineraryPricingInfo'];
      final totalFare = pricingInfo['ItinTotalFare']['TotalFare'];

      // Generate a unique ID
      final flightId = '${flightSegment['FlightNumber'] ?? 'UNKNOWN'}-${DateTime.now().millisecondsSinceEpoch}';

      // Get baggage allowance
      final baggageInfo = _getBaggageAllowance(pricingInfo);

      // Create flight segments
      final segmentInfo = _createSegmentInfo(json);

      return AirBlueFlight(
        id: flightId,
        price: double.tryParse(totalFare['Amount']?.toString() ?? '0') ?? 0,
        isRefundable: _determineRefundable(json),
        baggageAllowance: baggageInfo,
        legSchedules: _createLegSchedules(json, airlineInfo),
        stopSchedules: _createStopSchedules(json),
        segmentInfo: segmentInfo,
        airlineCode: airlineCode,
        airlineName: airlineInfo.name,
        airlineImg: airlineInfo.logoPath,
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error creating AirBlueFlight: $e');
        print('Stack trace: $stackTrace');
      }
      rethrow;
    }
  }
  static BaggageAllowance _getBaggageAllowance(Map<String, dynamic> pricingInfo) {
    try {
      final fareBreakdown = pricingInfo['PTC_FareBreakdowns']['PTC_FareBreakdown'];

      // Check if FareInfo is a list and get the baggage information
      if (fareBreakdown['FareInfo'] is List) {
        // Find the entry with baggage information
        for (var fareInfo in fareBreakdown['FareInfo']) {
          if (fareInfo['PassengerFare']?['FareBaggageAllowance'] != null) {
            final baggage = fareInfo['PassengerFare']['FareBaggageAllowance'];
            final weight = baggage['UnitOfMeasureQuantity']?.toString() ?? '20';
            final unit = baggage['UnitOfMeasure']?.toString() ?? 'KGS';

            return BaggageAllowance(
              type: 'Checked',
              pieces: 0, // AirBlue typically specifies by weight, not pieces
              weight: double.tryParse(weight) ?? 20,
              unit: unit,
            );
          }
        }
      } else if (fareBreakdown['FareInfo']?['PassengerFare']?['FareBaggageAllowance'] != null) {
        // Direct access if not a list
        final baggage = fareBreakdown['FareInfo']['PassengerFare']['FareBaggageAllowance'];
        final weight = baggage['UnitOfMeasureQuantity']?.toString() ?? '20';
        final unit = baggage['UnitOfMeasure']?.toString() ?? 'KGS';

        return BaggageAllowance(
          type: 'Checked',
          pieces: 0,
          weight: double.tryParse(weight) ?? 20,
          unit: unit,
        );
      }

      // Default baggage allowance if not found
      return BaggageAllowance(
        type: 'Checked',
        pieces: 0,
        weight: 20,
        unit: 'KGS',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error getting baggage allowance: $e');
      }
      return BaggageAllowance(
        type: 'Checked',
        pieces: 0,
        weight: 20,
        unit: 'KGS',
      );
    }
  }

  static bool _determineRefundable(Map<String, dynamic> json) {
    try {
      final pricingInfo = json['AirItineraryPricingInfo'] ?? {};
      final fareBreakdown = pricingInfo['PTC_FareBreakdowns']?['PTC_FareBreakdown'];

      if (fareBreakdown == null) return false;

      // Check if FareInfo is a list
      if (fareBreakdown['FareInfo'] is List) {
        for (var fareInfo in fareBreakdown['FareInfo']) {
          final fareType = fareInfo['FareInfo']?['FareType']?.toString() ?? '';
          if (fareType.contains('NONREF')) {
            return false;
          }
        }
      } else {
        final fareType = fareBreakdown['FareInfo']?['FareInfo']?['FareType']?.toString() ?? '';
        if (fareType.contains('NONREF')) {
          return false;
        }
      }

      // If no non-refundable indication found, return true
      // This is based on the fare basis code containing 'EF' or 'EV' from the sample data
      // You might need to adjust this logic based on your actual business requirements
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error determining refundable status: $e');
      }
      return false;
    }
  }

  static List<Map<String, dynamic>> _createLegSchedules(
      Map<String, dynamic> json,
      AirlineInfo airlineInfo
      ) {
    try {
      final airItinerary = json['AirItinerary'] ?? {};
      final originDestOption = airItinerary['OriginDestinationOptions']['OriginDestinationOption'] ?? {};
      final flightSegment = originDestOption['FlightSegment'] ?? {};

      final departure = flightSegment['DepartureAirport'] ?? {};
      final arrival = flightSegment['ArrivalAirport'] ?? {};
      final departureDateTime = flightSegment['DepartureDateTime']?.toString() ?? '';
      final arrivalDateTime = flightSegment['ArrivalDateTime']?.toString() ?? '';

      return [
        {
          'airlineCode': flightSegment['MarketingAirline']?['Code'] ?? 'PA',
          'airlineName': airlineInfo.name,
          'airlineImg': airlineInfo.logoPath,
          'departure': {
            'airport': departure['LocationCode'] ?? '',
            'city': _getCityName(departure['LocationCode']?.toString() ?? ''),
            'terminal': 'Main', // Default terminal
            'time': departureDateTime,
            'dateTime': departureDateTime,
          },
          'arrival': {
            'airport': arrival['LocationCode'] ?? '',
            'city': _getCityName(arrival['LocationCode']?.toString() ?? ''),
            'terminal': 'Main', // Default terminal
            'time': arrivalDateTime,
            'dateTime': arrivalDateTime,
          },
          'elapsedTime': _calculateFlightDuration(departureDateTime, arrivalDateTime),
          'stops': 0, // AirBlue flights in the sample are non-stop
          'schedules': [
            {
              'carrier': {
                'marketing': flightSegment['MarketingAirline']['Code'] ?? 'PA',
                'marketingFlightNumber': flightSegment['FlightNumber'] ?? '',
                'operating': flightSegment['OperatingAirline']?['Code'] ?? flightSegment['MarketingAirline']['Code'] ?? 'PA',
              },
              'departure': {
                'airport': departure['LocationCode'] ?? '',
                'terminal': 'Main',
                'time': departureDateTime,
                'dateTime': departureDateTime,
              },
              'arrival': {
                'airport': arrival['LocationCode'] ?? '',
                'terminal': 'Main',
                'time': arrivalDateTime,
                'dateTime': arrivalDateTime,
              },
              'equipment': flightSegment['Equipment']?['AirEquipType'] ?? 'A320',
            }
          ],
        }
      ];
    } catch (e) {
      if (kDebugMode) {
        print('Error creating leg schedules: $e');
      }
      return [];
    }
  }

  static List<Map<String, dynamic>> _createStopSchedules(Map<String, dynamic> json) {
    try {
      final airItinerary = json['AirItinerary'] ?? {};
      final originDestOption = airItinerary['OriginDestinationOptions']['OriginDestinationOption'] ?? {};
      final flightSegment = originDestOption['FlightSegment'] ?? {};

      final departure = flightSegment['DepartureAirport'] ?? {};
      final arrival = flightSegment['ArrivalAirport'] ?? {};

      return [
        {
          'carrier': {
            'marketing': flightSegment['MarketingAirline']['Code'] ?? 'PA',
            'marketingFlightNumber': flightSegment['FlightNumber'] ?? '',
            'operating': flightSegment['OperatingAirline']?['Code'] ?? flightSegment['MarketingAirline']['Code'] ?? 'PA',
          },
          'departure': {
            'airport': departure['LocationCode'] ?? '',
            'terminal': 'Main',
            'time': flightSegment['DepartureDateTime'] ?? '',
            'dateTime': flightSegment['DepartureDateTime'] ?? '',
          },
          'arrival': {
            'airport': arrival['LocationCode'] ?? '',
            'terminal': 'Main',
            'time': flightSegment['ArrivalDateTime'] ?? '',
            'dateTime': flightSegment['ArrivalDateTime'] ?? '',
          },
          'equipment': flightSegment['Equipment']?['AirEquipType'] ?? 'A320',
        }
      ];
    } catch (e) {
      if (kDebugMode) {
        print('Error creating stop schedules: $e');
      }
      return [];
    }
  }

  static List<FlightSegmentInfo> _createSegmentInfo(Map<String, dynamic> json) {
    try {
      final pricingInfo = json['AirItineraryPricingInfo'] ?? {};
      final fareBreakdown = pricingInfo['PTC_FareBreakdowns']?['PTC_FareBreakdown'];

      if (fareBreakdown == null) {
        return [FlightSegmentInfo(bookingCode: 'L', cabinCode: 'Y', mealCode: 'M', seatsAvailable: '')];
      }

      // Check if FareInfo is a list
      if (fareBreakdown['FareInfo'] is List) {
        final fareInfo = fareBreakdown['FareInfo'][0];
        final bookingCode = fareInfo['FareInfo']?['FareBasisCode']?.toString() ?? 'L';
        final fareType = fareInfo['FareInfo']?['FareType']?.toString() ?? '';

        return [
          FlightSegmentInfo(
            bookingCode: bookingCode,
            cabinCode: _determineCabinClass(fareType),
            mealCode: 'M', // Default meal code
            seatsAvailable: '',
          )
        ];
      } else {
        final fareInfo = fareBreakdown['FareInfo'];
        final bookingCode = fareInfo['FareInfo']?['FareBasisCode']?.toString() ?? 'L';
        final fareType = fareInfo['FareInfo']?['FareType']?.toString() ?? '';

        return [
          FlightSegmentInfo(
            bookingCode: bookingCode,
            cabinCode: _determineCabinClass(fareType),
            mealCode: 'M',
            seatsAvailable: '',
          )
        ];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating segment info: $e');
      }
      return [FlightSegmentInfo(bookingCode: 'L', cabinCode: 'Y', mealCode: 'M', seatsAvailable: '')];
    }
  }

  static String _determineCabinClass(String fareType) {
    if (fareType.contains('F')) return 'F'; // First
    if (fareType.contains('C')) return 'C'; // Business
    if (fareType.contains('W')) return 'W'; // Premium Economy
    return 'Y'; // Default to Economy
  }

  static int _calculateFlightDuration(String departure, String arrival) {
    try {
      final depTime = DateTime.parse(departure);
      final arrTime = DateTime.parse(arrival);
      return arrTime.difference(depTime).inMinutes;
    } catch (e) {
      if (kDebugMode) {
        print('Error calculating flight duration: $e');
      }
      return 0;
    }
  }

   static String _getCityName(String airportCode) {
    // Add more airport codes as needed
    const cityMap = {
      'LHE': 'Lahore',
      'KHI': 'Karachi',
      'ISB': 'Islamabad',
      'PEW': 'Peshawar',
      'JED': 'Jeddah',
      'DXB': 'Dubai',
    };
    return cityMap[airportCode] ?? airportCode;
  }
}