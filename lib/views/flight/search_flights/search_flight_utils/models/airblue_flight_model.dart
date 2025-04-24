// models/airblue_flight_model.dart
import 'package:flutter/foundation.dart';
import 'flight_models.dart';

class AirBlueFlight {
  final String id;
  final double price;
  final String currency;
  final bool isRefundable;
  final BaggageAllowance baggageAllowance;
  final List<Map<String, dynamic>> legSchedules;
  final List<Map<String, dynamic>> stopSchedules;
  final List<FlightSegmentInfo> segmentInfo;
  final String airlineCode;
  final String airlineName;
  final String airlineImg;
  final String rph; // Added RPH field
  final List<AirBlueFareOption>? fareOptions; // Added for storing different fare options

  AirBlueFlight({
    required this.id,
    required this.price,
    required this.currency,
    required this.isRefundable,
    required this.baggageAllowance,
    required this.legSchedules,
    required this.stopSchedules,
    required this.segmentInfo,
    required this.airlineCode,
    required this.airlineName,
    required this.airlineImg,
    required this.rph, // Required RPH parameter
    this.fareOptions,
  });

  factory AirBlueFlight.fromJson(Map<String, dynamic> json, Map<String, AirlineInfo> airlineMap) {
    try {
      // Extract flight segment data
      final flightSegment = json['AirItinerary']['OriginDestinationOptions']['OriginDestinationOption']['FlightSegment'] ?? {};

      // Extract RPH value from the OriginDestinationOption
      final originDestOption = json['AirItinerary']['OriginDestinationOptions']['OriginDestinationOption'] ?? {};
      final rph = originDestOption['RPH']?.toString() ?? '0-0'; // Default value if RPH is not found

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
        currency: totalFare['CurrencyCode'] ?? 'PKR',
        isRefundable: _determineRefundable(json),
        baggageAllowance: baggageInfo,
        legSchedules: _createLegSchedules(json, airlineInfo),
        stopSchedules: _createStopSchedules(json),
        segmentInfo: segmentInfo,
        airlineCode: airlineCode,
        airlineName: airlineInfo.name,
        airlineImg: airlineInfo.logoPath,
        rph: rph, // Set the RPH value
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error creating AirBlueFlight: $e');
        print('Stack trace: $stackTrace');
      }
      rethrow;
    }
  }

  // Create a new instance with fare options
  AirBlueFlight copyWithFareOptions(List<AirBlueFareOption> options) {


    return AirBlueFlight(
      id: id,
      price: price,
      currency: currency,
      isRefundable: isRefundable,
      baggageAllowance: baggageAllowance,
      legSchedules: legSchedules,
      stopSchedules: stopSchedules,
      segmentInfo: segmentInfo,
      airlineCode: airlineCode,
      airlineName: airlineName,
      airlineImg: airlineImg,
      rph: rph,
      fareOptions: options,
    );
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


// New class to represent different fare options for the same flight
// In airblue_flight_model.dart
class AirBlueFareOption {
  final String cabinCode;
  final String cabinName;
  final String brandName;
  final double price;
  final String currency;
  final int seatsAvailable;
  final bool isRefundable;
  final String mealCode;
  final String baggageAllowance;
  final Map<String, dynamic> rawData;

  AirBlueFareOption({
    required this.cabinCode,
    required this.cabinName,
    required this.brandName,
    required this.price,
    required this.currency,
    required this.seatsAvailable,
    required this.isRefundable,
    required this.mealCode,
    required this.baggageAllowance,
    required this.rawData,
  });

  factory AirBlueFareOption.fromFlight(AirBlueFlight flight, Map<String, dynamic> rawData) {
    // Extract fare basis code to determine if refundable
    final String fareBasisCode = _extractFareBasisCode(rawData).toUpperCase();
    final bool isRefundable = !fareBasisCode.contains('NR');

    // Extract cabin information
    final String cabinCode = _extractCabinCode(rawData);
    final String cabinName = _getCabinName(cabinCode);

    // Extract brand name if available
    String brandName = _extractBrandName(rawData);
    if (brandName.isEmpty) {
      brandName = _getBrandFromFareBasis(fareBasisCode);
    }

    // Extract seats available
    final int seatsAvailable = _extractSeatsAvailable(rawData);

    // Extract meal code
    final String mealCode = _extractMealCode(rawData);

    // Extract baggage allowance
    final String baggageAllowance = _extractBaggageAllowance(rawData);

    return AirBlueFareOption(
      cabinCode: cabinCode,
      cabinName: cabinName,
      brandName: brandName,
      price: flight.price,
      currency: flight.currency,
      seatsAvailable: seatsAvailable,
      isRefundable: isRefundable,
      mealCode: mealCode,
      baggageAllowance: baggageAllowance,
      rawData: rawData,
    );
  }

  // Helper methods (_extractFareBasisCode, _extractCabinCode, etc.) go here
  // Copy all the static helper methods from airblue_package_modal.dart
  // Helper method to extract fare basis code
  static String _extractFareBasisCode(Map<String, dynamic> data) {
    try {
      final airItinPricingInfo = data['AirItineraryPricingInfo'];
      if (airItinPricingInfo == null) return '';

      final ptcFareBreakdowns = airItinPricingInfo['PTC_FareBreakdowns']?['PTC_FareBreakdown'];
      if (ptcFareBreakdowns == null) return '';

      // Check if it's a list or a single item
      if (ptcFareBreakdowns is List) {
        if (ptcFareBreakdowns.isEmpty) return '';
        final fareInfos = ptcFareBreakdowns[0]['PassengerFare']?['PricedItineraryFare']?['FareInfos']?['FareInfo'];
        if (fareInfos is List && fareInfos.isNotEmpty) {
          return fareInfos[0]['FareBasisCode'] ?? '';
        } else if (fareInfos != null) {
          return fareInfos['FareBasisCode'] ?? '';
        }
      } else {
        final fareInfos = ptcFareBreakdowns['PassengerFare']?['PricedItineraryFare']?['FareInfos']?['FareInfo'];
        if (fareInfos is List && fareInfos.isNotEmpty) {
          return fareInfos[0]['FareBasisCode'] ?? '';
        } else if (fareInfos != null) {
          return fareInfos['FareBasisCode'] ?? '';
        }
      }
      return '';
    } catch (e) {
      print('Error extracting fare basis code: $e');
      return '';
    }
  }

  // Helper method to extract cabin code
  static String _extractCabinCode(Map<String, dynamic> data) {
    try {
      final originDestOption = data['AirItinerary']?['OriginDestinationOptions']?['OriginDestinationOption'];
      if (originDestOption == null) return 'Y';

      final flightSegment = originDestOption['FlightSegment'];
      if (flightSegment is List && flightSegment.isNotEmpty) {
        return flightSegment[0]['ResBookDesigCode'] ?? 'Y';
      } else if (flightSegment != null) {
        return flightSegment['ResBookDesigCode'] ?? 'Y';
      }
      return 'Y';
    } catch (e) {
      print('Error extracting cabin code: $e');
      return 'Y';
    }
  }

  // Helper method to get proper cabin name based on cabin code
  static String _getCabinName(String cabinCode) {
    switch (cabinCode.toUpperCase()) {
      case 'F': return 'First Class';
      case 'C': return 'Business Class';
      case 'J': return 'Premium Business';
      case 'W': return 'Premium Economy';
      case 'S': return 'Premium Economy';
      case 'Y': return 'Economy';
      default: return 'Economy';
    }
  }

  // Helper method to extract brand name
  static String _extractBrandName(Map<String, dynamic> data) {
    try {
      final airItinPricingInfo = data['AirItineraryPricingInfo'];
      if (airItinPricingInfo == null) return '';

      final fareInfos = airItinPricingInfo['FareInfos']?['FareInfo'];
      if (fareInfos is List && fareInfos.isNotEmpty) {
        return fareInfos[0]['BrandName'] ?? '';
      } else if (fareInfos != null) {
        return fareInfos['BrandName'] ?? '';
      }
      return '';
    } catch (e) {
      print('Error extracting brand name: $e');
      return '';
    }
  }

  // Helper method to derive brand from fare basis code
  static String _getBrandFromFareBasis(String fareBasisCode) {
    if (fareBasisCode.contains('FLEX')) return 'Flex';
    if (fareBasisCode.contains('PLUS')) return 'Plus';
    if (fareBasisCode.contains('LITE')) return 'Lite';
    if (fareBasisCode.contains('BUS')) return 'Business';
    if (fareBasisCode.contains('ECO')) return 'Economy';
    if (fareBasisCode.contains('PREM')) return 'Premium';
    return 'Standard';
  }

  // Helper method to extract seats available
  static int _extractSeatsAvailable(Map<String, dynamic> data) {
    try {
      final originDestOption = data['AirItinerary']?['OriginDestinationOptions']?['OriginDestinationOption'];
      if (originDestOption == null) return 9;

      final flightSegment = originDestOption['FlightSegment'];
      if (flightSegment is List && flightSegment.isNotEmpty) {
        return int.tryParse(flightSegment[0]['SeatsAvailable'] ?? '9') ?? 9;
      } else if (flightSegment != null) {
        return int.tryParse(flightSegment['SeatsAvailable'] ?? '9') ?? 9;
      }
      return 9;
    } catch (e) {
      print('Error extracting seats available: $e');
      return 9;
    }
  }

  // Helper method to extract meal code
  static String _extractMealCode(Map<String, dynamic> data) {
    try {
      final originDestOption = data['AirItinerary']?['OriginDestinationOptions']?['OriginDestinationOption'];
      if (originDestOption == null) return 'M';

      final flightSegment = originDestOption['FlightSegment'];
      if (flightSegment is List && flightSegment.isNotEmpty) {
        return flightSegment[0]['Meal']?['Code'] ?? 'M';
      } else if (flightSegment != null) {
        return flightSegment['Meal']?['Code'] ?? 'M';
      }
      return 'M';
    } catch (e) {
      print('Error extracting meal code: $e');
      return 'M';
    }
  }

  // Helper method to extract baggage allowance
  static String _extractBaggageAllowance(Map<String, dynamic> data) {
    try {
      final airItinPricingInfo = data['AirItineraryPricingInfo'];
      if (airItinPricingInfo == null) return 'Standard baggage';

      final ptcFareBreakdowns = airItinPricingInfo['PTC_FareBreakdowns']?['PTC_FareBreakdown'];
      if (ptcFareBreakdowns == null) return 'Standard baggage';

      String baggageText = '';

      // Check if it's a list or a single item
      if (ptcFareBreakdowns is List) {
        if (ptcFareBreakdowns.isEmpty) return 'Standard baggage';

        // Try to get baggage allowance from different possible locations
        final baggageAllowance = ptcFareBreakdowns[0]['BaggageAllowance'];
        if (baggageAllowance != null) {
          if (baggageAllowance['Quantity'] != null) {
            baggageText = '${baggageAllowance['Quantity']} piece(s)';
          } else if (baggageAllowance['Weight'] != null) {
            baggageText = '${baggageAllowance['Weight']} ${baggageAllowance['Unit'] ?? 'kg'}';
          }
        }
      } else {
        // Try to get baggage allowance from single item
        final baggageAllowance = ptcFareBreakdowns['BaggageAllowance'];
        if (baggageAllowance != null) {
          if (baggageAllowance['Quantity'] != null) {
            baggageText = '${baggageAllowance['Quantity']} piece(s)';
          } else if (baggageAllowance['Weight'] != null) {
            baggageText = '${baggageAllowance['Weight']} ${baggageAllowance['Unit'] ?? 'kg'}';
          }
        }
      }

      return baggageText.isNotEmpty ? baggageText : 'Standard baggage';
    } catch (e) {
      print('Error extracting baggage allowance: $e');
      return 'Standard baggage';
    }
  }
}