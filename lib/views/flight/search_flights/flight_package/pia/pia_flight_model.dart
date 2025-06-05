import 'package:get/get.dart';

class PIAFlight {
  final String imgPath;
  final String airline;
  final String flightNumber;
  final String departureTime;
  final String arrivalTime;
  final String duration;
  final double price;
  final String type;
  final bool isRefundable;
  final bool isNonStop;
  final String departureTerminal;
  final String arrivalTerminal;
  final String aircraftType;
  final List<PIATaxDesc> taxes;
  final PIABaggageAllowance baggageAllowance;
  final List<PIAFlightPackageInfo> packages;
  final List<String> stops;
  final List<Map<String, dynamic>> stopSchedules;
  final int? legElapsedTime;
  final String cabinClass;
  final String mealCode;
  final PIAFlight? returnFlight;
  final bool isReturn;
  final String? groupId;
  final String? returnDepartureTime;
  final String? returnArrivalTime;
  final String? returnFrom;
  final String? returnTo;
  final bool isRoundTrip;
  final List<PIAFlight>? connectedFlights;
  final int? tripSequence;
  final String? tripType;
  final List<Map<String, dynamic>> legSchedules;
  final List<Map<String, dynamic>> legWithStops;
  final List<PIAFlightSegmentInfo> segmentInfo;
  final List<Map<String, dynamic>> pricingInforArray;
  final bool isOutbound;
  final String? boundCode;
  final String? date; // Add date to help with grouping
  final bool isMultiCity;

  PIAFlight({
    required this.imgPath,
    required this.airline,
    required this.flightNumber,
    required this.departureTime,
    required this.arrivalTime,
    required this.duration,
    required this.price,

    required this.type,
    required this.isRefundable,
    required this.isNonStop,
    required this.departureTerminal,
    required this.arrivalTerminal,

    required this.aircraftType,
    required this.taxes,
    required this.baggageAllowance,
    required this.packages,
    required this.stops,
    required this.stopSchedules,
    this.legElapsedTime,
    required this.cabinClass,
    required this.mealCode,
    this.returnFlight,
    this.isReturn = false,
    this.groupId,
    this.returnDepartureTime,
    this.returnArrivalTime,
    this.returnFrom,
    this.returnTo,
    this.isRoundTrip = false,
    this.connectedFlights,
    this.tripSequence,
    this.tripType,
    this.isOutbound = true,
    this.boundCode,
    this.date,
    required this.legSchedules,
    required this.legWithStops,
    required this.segmentInfo,
    required this.pricingInforArray,
    this.isMultiCity = false,
  });

  factory PIAFlight.fromApiResponse(
      Map<String, dynamic> flightData, {
        required List<Map<String, dynamic>> legSchedules,
        required List<Map<String, dynamic>> legWithStops,
        bool isOutbound = true,
        String? boundCode,
        String? date,
        bool isMultiCity = false,
      }) {
    try {
      final firstSegment = legSchedules.first['flightSegment'] ?? legSchedules.first;
      final flightSegment = flightData['flightSegment'];
      final fareInfo = flightData['fareInfoList'][0]['fareInfoList'][0];
      final pricingInfo = flightData['pricingInfo'];

      // Safely extract values with null checks
      final String departureDateTime = _extractStringValue(flightSegment['departureDateTime']);
      final String arrivalDateTime = _extractStringValue(flightSegment['arrivalDateTime']);
      final String journeyDuration = _extractStringValue(flightSegment['journeyDuration']);

      // Safely extract airport codes
      final String? fromCity = _extractNestedValue(flightSegment, ['departureAirport', 'locationCode']);
      final String? toCity = _extractNestedValue(flightSegment, ['arrivalAirport', 'locationCode']);

      // Safe extraction of required values
      final String airlineName = _extractNestedValue(flightSegment, ['airline', 'companyShortName'])
          ?? 'Pakistan International Airlines';
      final String flightNum = _extractStringValue(flightSegment['flightNumber']);

      // Extract price with fallback
      double flightPrice = 0.0;
      try {
        final priceValue = _extractNestedValue(pricingInfo, ['totalFare', 'amount', 'value']);
        flightPrice = priceValue != null ? double.tryParse(priceValue) ?? 0.0 : 0.0;
      } catch (e) {
        print('Error parsing price: $e');
      }

      // Get fare type safely
      final String fareType = _extractStringValue(fareInfo['fareKind']);

      // Determine if refundable
      bool refundable = false;
      try {
        final endorsement = _extractStringValue(fareInfo['endorsementList']);
        refundable = endorsement != 'NON REFUNDABLE';
      } catch (e) {
        print('Error determining refundable status: $e');
      }

      // Determine if non-stop
      bool nonStop = true;
      try {
        final stopQuantity = _extractStringValue(flightSegment['stopQuantity']);
        nonStop = stopQuantity == '0';
      } catch (e) {
        print('Error determining non-stop status: $e');
      }

      // Extract terminals with fallbacks
      final String depTerminal = _extractNestedValue(flightSegment, ['departureAirport', 'terminal']) ?? '';
      final String arrTerminal = _extractNestedValue(flightSegment, ['arrivalAirport', 'terminal']) ?? '';

      // Extract city names with fallbacks
      final String? depCity = _extractNestedValue(
          flightSegment, ['departureAirport', 'cityInfo', 'city', 'locationName']) ?? fromCity;
      final String? arrCity = _extractNestedValue(
          flightSegment, ['arrivalAirport', 'cityInfo', 'city', 'locationName']) ?? toCity;

      // Extract aircraft type
      final String aircraft = _extractNestedValue(flightSegment, ['equipment', 'airEquipType']) ?? 'Unknown';

      // Extract cabin class
      final String cabin = _extractStringValue(fareInfo['cabin']);

      // Extract meal code
      final String meal = _extractNestedValue(flightSegment, ['flightNotes', 'note']) ?? 'N';

      // Create baggage allowance and taxes
      final baggageAllowance = PIABaggageAllowance.fromFareInfo(fareInfo);
      final taxes = PIATaxDesc.fromPricingInfoList(pricingInfo);
      final packages = [PIAFlightPackageInfo.fromFareInfo(fareInfo)];

      // Calculate stops
      final stops = <String>[];
      if (legSchedules.length > 1) {
        for (int i = 1; i < legSchedules.length; i++) {
          final segment = legSchedules[i];
          final arrival = _extractNestedValue(segment, ['flightSegment', 'arrivalAirport', 'locationCode']);
          if (arrival != null) {
            stops.add(arrival);
          }
        }
      }

      return PIAFlight(
        imgPath: 'assets/pia_logo.png',
        airline: airlineName,
        flightNumber: flightNum,
        departureTime: departureDateTime,
        arrivalTime: arrivalDateTime,
        duration: _calculateTotalDuration(legSchedules),
        price: flightPrice,

        type: fareType,
        isRefundable: refundable,
        isNonStop: nonStop,
        departureTerminal: depTerminal,
        arrivalTerminal: arrTerminal,

        aircraftType: aircraft,
        taxes: taxes,
        baggageAllowance: baggageAllowance,
        packages: packages,
        stops: stops,
        stopSchedules: [],
        legElapsedTime: _parseDurationToMinutes(journeyDuration),
        cabinClass: cabin,
        mealCode: meal,
        legSchedules: legSchedules,
        legWithStops: legWithStops,
        segmentInfo: [PIAFlightSegmentInfo.fromFlightSegment(flightSegment)],
        pricingInforArray: [pricingInfo],
        isOutbound: isOutbound,
        boundCode: boundCode,
        date: date,
        isMultiCity: isMultiCity,
      );
    } catch (e, stackTrace) {
      print('Error in PIAFlight.fromApiResponse: $e');
      print('Stack trace: $stackTrace');
      rethrow; // Rethrow to be handled by the caller
    }
  }

  // Add these methods:
  List<String> getStopCities() {
    final stops = <String>[];
    if (legSchedules.length > 1) {
      for (int i = 1; i < legSchedules.length; i++) {
        final segment = legSchedules[i];
        final arrival = _extractNestedValue(segment, ['flightSegment', 'arrivalAirport', 'locationCode']);
        if (arrival != null) {
          stops.add(arrival);
        }
      }
    }
    return stops;
  }

  String getDisplayDeparture() {
    if (legSchedules.isEmpty) return '';
    return _extractNestedValue(
      legSchedules.first,
      ['flightSegment', 'departureAirport', 'locationCode'],
    ) ?? '';
  }

  String getDisplayArrival() {
    if (legSchedules.isEmpty) return '';
    return _extractNestedValue(
      legSchedules.last,
      ['flightSegment', 'arrivalAirport', 'locationCode'],
    ) ?? '';
  }

  static String _calculateTotalDuration(List<Map<String, dynamic>> segments) {
    int totalMinutes = 0;
    for (var segment in segments) {
      final durationStr = segment['journeyDuration'] ?? 'PT0H0M';
      totalMinutes += _parseDurationToMinutes(durationStr);
    }
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return 'PT${hours}H${minutes}M';
  }
  // Helper function to safely navigate nested maps
  static String? _extractNestedValue(Map<String, dynamic>? data, List<String> keys) {
    if (data == null) return null;

    dynamic current = data;
    for (final key in keys) {
      if (current is! Map<String, dynamic>) return null;

      // Handle Badgerfish format where text might be under '$'
      if (current.containsKey('\$') && current['\$'] is Map) {
        current = current['\$'];
      }

      if (!current.containsKey(key)) {
        // Check if key exists with namespace prefix
        final nsKey = current.keys.firstWhere(
              (k) => k.endsWith(':${key}') || k.endsWith('@${key}'),
          orElse: () => key,
        );
        if (!current.containsKey(nsKey)) return null;
        current = current[nsKey];
      } else {
        current = current[key];
      }

      // Handle cases where value might be in a map with 'text' key
      if (current is Map && current.containsKey('text')) {
        current = current['text'];
      }
    }

    return _extractStringValue(current);
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
  static int _parseDurationToMinutes(String duration) {
    try {
      if (duration.startsWith('PT')) {
        final parts = duration.substring(2).split(RegExp(r'[HMS]'));
        final hours = int.tryParse(parts[0]) ?? 0;
        final minutes = int.tryParse(parts[1]) ?? 0;
        return hours * 60 + minutes;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  List<Map<String, dynamic>> getAllLegsSchedule() {
    if (isMultiCity) {
      return legWithStops;
    }
    return [legWithStops.first];
  }

// Add this method to calculate total duration for multi-city
  String getTotalDuration() {
    if (!isMultiCity) return duration;

    int totalMinutes = 0;
    for (var segment in legSchedules) {
      final durationStr = segment['journeyDuration'] ?? 'PT0H0M';
      totalMinutes += _parseDurationToMinutes(durationStr);
    }

    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return 'PT${hours}H${minutes}M';
  }
  // In pia_flight_model.dart
  // Update copyWith to include all new properties
  PIAFlight copyWith({
    List<Map<String, dynamic>>? legSchedules,
    String? duration,
    bool? isMultiCity,
    List<PIAFlight>? connectedFlights,
    bool? isOutbound,
    String? boundCode,
    String? date,
  }) {
    return PIAFlight(
      imgPath: imgPath,
      airline: airline,
      flightNumber: flightNumber,
      departureTime: departureTime,
      arrivalTime: arrivalTime,
      duration: duration ?? this.duration,
      price: price,

      type: type,
      isRefundable: isRefundable,
      isNonStop: isNonStop,
      departureTerminal: departureTerminal,
      arrivalTerminal: arrivalTerminal,

      aircraftType: aircraftType,
      taxes: taxes,
      baggageAllowance: baggageAllowance,
      packages: packages,
      stops: stops,
      stopSchedules: stopSchedules,
      legElapsedTime: legElapsedTime,
      cabinClass: cabinClass,
      mealCode: mealCode,
      returnFlight: returnFlight,
      isReturn: isReturn,
      groupId: groupId,
      returnDepartureTime: returnDepartureTime,
      returnArrivalTime: returnArrivalTime,
      returnFrom: returnFrom,
      returnTo: returnTo,
      isRoundTrip: isRoundTrip,
      connectedFlights: connectedFlights ?? this.connectedFlights,
      tripSequence: tripSequence,
      tripType: tripType,
      legSchedules: legSchedules ?? this.legSchedules,
      legWithStops: legWithStops,
      segmentInfo: segmentInfo,
      pricingInforArray: pricingInforArray,
      isOutbound: isOutbound ?? this.isOutbound,
      boundCode: boundCode ?? this.boundCode,
      date: date ?? this.date,
      isMultiCity: isMultiCity ?? this.isMultiCity,
    );
  }

}

class PIAPriceInfo {
  final double totalPrice;
  final double totalTaxAmount;
  final String currency;
  final double baseFareAmount;
  final String baseFareCurrency;
  final double constructionAmount;
  final String constructionCurrency;
  final double equivalentAmount;
  final String equivalentCurrency;

  PIAPriceInfo({
    required this.totalPrice,
    required this.totalTaxAmount,
    required this.currency,
    required this.baseFareAmount,
    required this.baseFareCurrency,
    required this.constructionAmount,
    required this.constructionCurrency,
    required this.equivalentAmount,
    required this.equivalentCurrency,
  });

  factory PIAPriceInfo.fromApiResponse(Map<String, dynamic> fareInfo) {
    final totalFare = fareInfo['totalFare'] as Map<String, dynamic>;
    return PIAPriceInfo(
      totalPrice: (totalFare['totalPrice'] is int)
          ? totalFare['totalPrice'].toDouble()
          : totalFare['totalPrice'] as double,
      totalTaxAmount: (totalFare['totalTaxAmount'] is int)
          ? totalFare['totalTaxAmount'].toDouble()
          : totalFare['totalTaxAmount'] as double,
      currency: totalFare['currency'] as String,
      baseFareAmount: (totalFare['baseFareAmount'] is int)
          ? totalFare['baseFareAmount'].toDouble()
          : totalFare['baseFareAmount'] as double,
      baseFareCurrency: totalFare['baseFareCurrency'] as String,
      constructionAmount: (totalFare['constructionAmount'] is int)
          ? totalFare['constructionAmount'].toDouble()
          : totalFare['constructionAmount'] as double,
      constructionCurrency: totalFare['constructionCurrency'] as String,
      equivalentAmount: (totalFare['equivalentAmount'] is int)
          ? totalFare['equivalentAmount'].toDouble()
          : totalFare['equivalentAmount'] as double,
      equivalentCurrency: totalFare['equivalentCurrency'] as String,
    );
  }

  double getPriceInCurrency(String targetCurrency) {
    switch (targetCurrency) {
      case 'PKR':
        return equivalentCurrency == 'PKR' ? equivalentAmount : totalPrice;
      case 'USD':
        return baseFareCurrency == 'USD' ? baseFareAmount : totalPrice;
      default:
        return totalPrice;
    }
  }
}

class PIATaxDesc {
  final String code;
  final double amount;
  final String currency;
  final String description;

  PIATaxDesc({
    required this.code,
    required this.amount,
    required this.currency,
    required this.description,
  });

  static List<PIATaxDesc> fromPricingInfoList(Map<String, dynamic> pricingInfo) {
    try {
      final taxList = pricingInfo['taxes']?['taxList'];
      if (taxList == null) return [];

      final List<dynamic> taxes = taxList is List ? taxList : [taxList];
      return taxes.map((tax) {
        String code = '';
        double amount = 0.0;
        String currency = '';

        try {
          code = PIAFlight._extractNestedValue(tax, ['taxCode']) ?? '';

          final amountValue = PIAFlight._extractNestedValue(tax, ['taxAmount', 'value']);
          if (amountValue != null) {
            amount = double.tryParse(amountValue) ?? 0.0;
          }

          currency = PIAFlight._extractNestedValue(tax, ['taxAmount', 'currency']) ?? '';
        } catch (e) {
          print('Error parsing tax: $e');
        }

        return PIATaxDesc(
          code: code,
          amount: amount,
          currency: currency,
          description: code,
        );
      }).toList();
    } catch (e) {
      print('Error in fromPricingInfoList: $e');
      return [];
    }
  }
}

class PIABaggageAllowance {
  final int pieces;
  final double weight;
  final String unit;
  final String type;

  PIABaggageAllowance({
    required this.pieces,
    required this.weight,
    required this.unit,
    required this.type,
  });

  factory PIABaggageAllowance.fromFareInfo(Map<String, dynamic> fareInfo) {
    try {
      final baggage = fareInfo['fareBaggageAllowance'];
      if (baggage == null) {
        return PIABaggageAllowance(
          pieces: 0,
          weight: 0,
          unit: 'KG',
          type: '0 KG',
        );
      }

      final allowanceType = PIAFlight._extractStringValue(baggage['allowanceType']);

      if (allowanceType == 'WEIGHT') {
        final weightValue = PIAFlight._extractNestedValue(baggage, ['maxAllowedWeight', 'weight']) ?? '0';
        final unitCode = PIAFlight._extractNestedValue(baggage, ['maxAllowedWeight', 'unitOfMeasureCode']) ?? 'KG';

        final double parsedWeight = double.tryParse(weightValue) ?? 0.0;

        return PIABaggageAllowance(
          pieces: 0,
          weight: parsedWeight,
          unit: unitCode,
          type: '$weightValue $unitCode',
        );
      } else {
        final piecesValue = PIAFlight._extractStringValue(baggage['maxAllowedPieces'] ?? '0');
        final int parsedPieces = int.tryParse(piecesValue) ?? 0;

        return PIABaggageAllowance(
          pieces: parsedPieces,
          weight: 0,
          unit: 'PC',
          type: '$piecesValue PC',
        );
      }
    } catch (e) {
      print('Error in PIABaggageAllowance.fromFareInfo: $e');
      return PIABaggageAllowance(
        pieces: 0,
        weight: 0,
        unit: 'KG',
        type: '0 KG',
      );
    }
  }
}

class PIAFlightPackageInfo {
  final String name;
  final String code;
  final String cabinClass;
  final double price;
  final PIABaggageAllowance baggageAllowance;
  final bool isRefundable;
  final bool isSoldOut;

  PIAFlightPackageInfo({
    required this.name,
    required this.code,
    required this.cabinClass,
    required this.price,
    required this.baggageAllowance,
    required this.isRefundable,
    this.isSoldOut = false,
  });

  factory PIAFlightPackageInfo.fromFareInfo(Map<String, dynamic> fareInfo) {
    try {
      String name = PIAFlight._extractNestedValue(fareInfo, ['fareGroupName']) ?? 'Standard';
      String code = PIAFlight._extractNestedValue(fareInfo, ['fareReferenceCode']) ?? '';
      String cabin = PIAFlight._extractNestedValue(fareInfo, ['cabin']) ?? 'Economy';

      // Extract price
      double price = 0.0;
      try {
        final priceValue = PIAFlight._extractNestedValue(
            fareInfo, ['pricingInfo', 'totalAmount', 'value']);
        if (priceValue != null) {
          price = double.tryParse(priceValue) ?? 0.0;
        }
      } catch (e) {
        print('Error parsing package price: $e');
      }

      // Determine if refundable
      bool refundable = false;
      try {
        final endorsement = PIAFlight._extractStringValue(fareInfo['endorsementList']);
        refundable = endorsement != 'NON REFUNDABLE';
      } catch (e) {
        print('Error determining package refundable status: $e');
      }

      return PIAFlightPackageInfo(
        name: name,
        code: code,
        cabinClass: cabin,
        price: price,
        baggageAllowance: PIABaggageAllowance.fromFareInfo(fareInfo),
        isRefundable: refundable,
      );
    } catch (e) {
      print('Error in PIAFlightPackageInfo.fromFareInfo: $e');
      return PIAFlightPackageInfo(
        name: 'Standard',
        code: '',
        cabinClass: 'Economy',
        price: 0.0,
        baggageAllowance: PIABaggageAllowance(
          pieces: 0,
          weight: 0,
          unit: 'KG',
          type: '0 KG',
        ),
        isRefundable: false,
      );
    }
  }
}

class PIAFlightSegmentInfo {
  final String bookingCode;
  final String cabinCode;
  final String mealCode;
  final String seatsAvailable;
  final String fareBasisCode;

  PIAFlightSegmentInfo({
    required this.bookingCode,
    required this.cabinCode,
    required this.mealCode,
    required this.seatsAvailable,
    this.fareBasisCode = '',
  });

  factory PIAFlightSegmentInfo.fromFlightSegment(Map<String, dynamic> segment) {
    try {
      final bookingClass = segment['bookingClassList'];
      if (bookingClass == null) {
        return PIAFlightSegmentInfo(
          bookingCode: '',
          cabinCode: 'Y',
          mealCode: 'N',
          seatsAvailable: '0',
          fareBasisCode: '',
        );
      }

      final String bookingCode = PIAFlight._extractNestedValue(bookingClass, ['resBookDesigCode']) ?? '';
      final String cabinCode = PIAFlight._extractNestedValue(bookingClass, ['cabin']) ?? 'Y';
      final String mealCode = PIAFlight._extractNestedValue(segment, ['flightNotes', 'note']) ?? 'N';
      final String seatsAvailable = PIAFlight._extractNestedValue(bookingClass, ['resBookDesigQuantity']) ?? '0';

      return PIAFlightSegmentInfo(
        bookingCode: bookingCode,
        cabinCode: cabinCode,
        mealCode: mealCode,
        seatsAvailable: seatsAvailable,
        fareBasisCode: bookingCode,
      );
    } catch (e) {
      print('Error in PIAFlightSegmentInfo.fromFlightSegment: $e');
      return PIAFlightSegmentInfo(
        bookingCode: '',
        cabinCode: 'Y',
        mealCode: 'N',
        seatsAvailable: '0',
        fareBasisCode: '',
      );
    }
  }
}

class PIASegmentInfo {
  final String bookingCode;
  final String cabinCode;
  final String mealCode;
  final String seatsAvailable;
  final String fareBasisCode;

  PIASegmentInfo({
    required this.bookingCode,
    required this.cabinCode,
    required this.mealCode,
    required this.seatsAvailable,
    this.fareBasisCode = '',
  });

  factory PIASegmentInfo.fromFlightSegment(Map<String, dynamic> segment) {
    try {
      final bookingClass = segment['bookingClassList'];
      if (bookingClass == null) {
        return PIASegmentInfo(
          bookingCode: '',
          cabinCode: 'Y',
          mealCode: 'N',
          seatsAvailable: '0',
        );
      }

      final bookingCode = PIAFlight._extractNestedValue(bookingClass, ['resBookDesigCode']) ?? '';
      final cabinCode = PIAFlight._extractNestedValue(bookingClass, ['cabin']) ?? 'Y';
      final mealCode = PIAFlight._extractNestedValue(segment, ['flightNotes', 'note']) ?? 'N';
      final seatsAvailable = PIAFlight._extractNestedValue(bookingClass, ['resBookDesigQuantity']) ?? '0';

      return PIASegmentInfo(
        bookingCode: bookingCode,
        cabinCode: cabinCode,
        mealCode: mealCode,
        seatsAvailable: seatsAvailable,
        fareBasisCode: bookingCode,
      );
    } catch (e) {
      print('Error in PIASegmentInfo.fromFlightSegment: $e');
      return PIASegmentInfo(
        bookingCode: '',
        cabinCode: 'Y',
        mealCode: 'N',
        seatsAvailable: '0',
      );
    }
  }
}


class PIAFareOption {
  final String fareName;
  final String fareReferenceCode;
  final double price;
  final String currency;
  final String cabinClass;
  final String cabinClassCode;
  final PIABaggageAllowance baggageAllowance;
  final bool isRefundable;
  final String changeFee;
  final String refundFee;
  final Map<String, dynamic> rawData;

  PIAFareOption({
    required this.fareName,
    required this.fareReferenceCode,
    required this.price,
    required this.currency,
    required this.cabinClass,
    required this.cabinClassCode,
    required this.baggageAllowance,
    required this.isRefundable,
    required this.changeFee,
    required this.refundFee,
    required this.rawData,
  });

  factory PIAFareOption.fromFareInfo(Map<String, dynamic> fareInfo) {
    try {
      // Extract pricing info
      final pricingInfo = fareInfo['pricingInfo'] ?? {};
      final totalFare = pricingInfo['totalFare']?['amount'] ?? {};

      // Extract price and currency
      double price = 0.0;
      String currency = 'PKR';

      if (totalFare.isNotEmpty) {
        price = double.tryParse(totalFare['value']?.toString() ?? '0') ?? 0.0;
        currency = totalFare['currency']?.toString() ?? 'PKR';
      } else {
        // Fallback to totalAmount if totalFare not available
        final totalAmount = pricingInfo['totalAmount'] ?? {};
        price = double.tryParse(totalAmount['value']?.toString() ?? '0') ?? 0.0;
        currency = totalAmount['currency']?.toString() ?? 'PKR';
      }

      // Extract baggage allowance
      final baggageAllowance = PIABaggageAllowance.fromFareInfo(fareInfo);

      // Determine refund policy
      final isRefundable = (fareInfo['endorsementList'] as String?)?.contains('NON REFUNDABLE') != true;

      // Default fees (can be customized based on fare rules)
      final changeFee = 'PKR 1000';
      final refundFee = isRefundable ? 'PKR 2000' : 'Non-Refundable';

      return PIAFareOption(
        fareName: fareInfo['fareGroupName']?.toString() ?? 'Standard',
        fareReferenceCode: fareInfo['fareReferenceCode']?.toString() ?? '',
        price: price,
        currency: currency,
        cabinClass: fareInfo['cabin']?.toString() ?? 'Economy',
        cabinClassCode: fareInfo['cabinClassCode']?.toString() ?? 'Y',
        baggageAllowance: baggageAllowance,
        isRefundable: isRefundable,
        changeFee: changeFee,
        refundFee: refundFee,
        rawData: fareInfo,
      );
    } catch (e, stackTrace) {
      print('Error in PIAFareOption.fromFareInfo: $e');
      print('Stack trace: $stackTrace');

      return PIAFareOption(
        fareName: 'Standard',
        fareReferenceCode: '',
        price: 0.0,
        currency: 'PKR',
        cabinClass: 'Economy',
        cabinClassCode: 'Y',
        baggageAllowance: PIABaggageAllowance(
          pieces: 0,
          weight: 0,
          unit: 'KG',
          type: '0 KG',
        ),
        isRefundable: false,
        changeFee: 'PKR 1000',
        refundFee: 'Non-Refundable',
        rawData: {},
      );
    }
  }
}