// ignore_for_file: non_constant_identifier_names

import 'package:intl/intl.dart';

class FlightSegment {
  final int id;
  final int groupId;
  final int sr;
  final String flightNumber;
  final DateTime flightDate;
  final String origin;
  final String destination;
  final String baggage;
  final String departureTime;
  final String arrivalTime;

  FlightSegment({
    required this.id,
    required this.groupId,
    required this.sr,
    required this.flightNumber,
    required this.flightDate,
    required this.origin,
    required this.destination,
    required this.baggage,
    required this.departureTime,
    required this.arrivalTime,
  });

  factory FlightSegment.fromJson(Map<String, dynamic> json) {
    DateTime flightDate;
    try {
      flightDate = DateTime.parse(json['flight_date'].toString());
    } catch (e) {
      flightDate = DateTime.now();
    }

    return FlightSegment(
      id: _parseIntSafely(json['id'], 0),
      groupId: _parseIntSafely(json['group_id'], 0),
      sr: _parseIntSafely(json['sr'], 0),
      flightNumber: json['flight_no']?.toString() ?? '',
      flightDate: flightDate,
      origin: json['origin']?.toString() ?? '',
      destination: json['destination']?.toString() ?? '',
      baggage: json['baggage']?.toString() ?? '',
      departureTime: _formatTime(json['dept_time']?.toString() ?? '00:00:00'),
      arrivalTime: _formatTime(json['arv_time']?.toString() ?? '00:00:00'),
    );
  }

  String get formattedDate {
    return DateFormat('dd MMM yyyy').format(flightDate);
  }

  String get formattedShortDate {
    return DateFormat('dd MMM').format(flightDate);
  }

  static String _formatTime(String timeStr) {
    if (timeStr.length >= 5) {
      return timeStr.substring(0, 5);
    }
    return timeStr;
  }

  static int _parseIntSafely(dynamic value, int defaultValue) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is String) {
      try {
        return int.parse(value);
      } catch (e) {
        return defaultValue;
      }
    }
    try {
      return int.parse(value.toString());
    } catch (e) {
      return defaultValue;
    }
  }
}

class GroupFlightModel {
  final int id;
  final int group_id;
  final String airline;
  final String sector;
  final String shortName;
  final int groupPriceDetailId;
  final DateTime departure;
  final DateTime? returnDate; // For round-trip flights
  final String type; // 'UMRAH', 'UAE', 'KSA', etc.
  final int price;
  final int seats;
  final String baggage;
  final String logoUrl;
  final String pnr;
  final String meal;
  
  // Flight segments for multi-leg journeys
  final List<FlightSegment> segments;
  
  // Convenience getters for backward compatibility
  String get departureTime => segments.isNotEmpty ? segments.first.departureTime : '';
  String get arrivalTime => segments.isNotEmpty ? segments.first.arrivalTime : '';
  String get origin => segments.isNotEmpty ? segments.first.origin : '';
  String get destination => segments.isNotEmpty ? segments.first.destination : '';
  String get flightNumber => segments.isNotEmpty ? segments.first.flightNumber : '';
  
  // New getters for round-trip flights
  FlightSegment? get outboundSegment => segments.isNotEmpty ? segments.first : null;
  FlightSegment? get returnSegment => segments.length > 1 ? segments.last : null;
  bool get isRoundTrip => segments.length > 1;
  bool get hasLayover => segments.length > 2;

  GroupFlightModel({
    required dynamic id,
    required dynamic group_id,
    required this.airline,
    required this.sector,
    required this.shortName,
    required dynamic groupPriceDetailId,
    required this.departure,
    this.returnDate,
    required this.type,
    required dynamic price,
    required dynamic seats,
    required this.baggage,
    required this.logoUrl,
    required this.pnr,
    required this.meal,
    required this.segments,
  }) : 
       id = FlightSegment._parseIntSafely(id, 0),
       group_id = FlightSegment._parseIntSafely(group_id, 0),
       groupPriceDetailId = FlightSegment._parseIntSafely(groupPriceDetailId, 0),
       price = FlightSegment._parseIntSafely(price, 0),
       seats = FlightSegment._parseIntSafely(seats, 0);

  // Helper method to get formatted date
  String get formattedDate {
    final formatter = DateFormat('dd MMM yyyy');
    return formatter.format(departure);
  }

  String get formattedReturnDate {
    if (returnDate != null) {
      final formatter = DateFormat('dd MMM yyyy');
      return formatter.format(returnDate!);
    }
    return '';
  }

  // Factory constructor to create a GroupFlightModel from JSON
  factory GroupFlightModel.fromJson(Map<String, dynamic> json) {
    // Extract flight details and create segments
    final detailsList = json['details'] as List? ?? [];
    final segments = detailsList
        .map((detail) => FlightSegment.fromJson(detail as Map<String, dynamic>))
        .toList();

    // Extract airline info
    final airline = json['airline'] ?? {};

    // Parse departure date safely
    DateTime departureDate;
    try {
      departureDate = json['dept_date'] != null
          ? DateTime.parse(json['dept_date'].toString())
          : DateTime.now();
    } catch (e) {
      departureDate = DateTime.now();
    }

    // Parse return date for round-trip flights
    DateTime? returnDate;
    try {
      if (json['arv_date'] != null && json['arv_date'].toString().isNotEmpty) {
        returnDate = DateTime.parse(json['arv_date'].toString());
      }
    } catch (e) {
      returnDate = null;
    }

    // Determine baggage from segments or main object
    String baggage = 'N/A';
    if (segments.isNotEmpty) {
      baggage = segments.first.baggage;
    } else if (json['baggage'] != null) {
      baggage = json['baggage'].toString();
    }

    return GroupFlightModel(
      id: json['id'] ?? 0,
      group_id: json['id'] ?? 0, // Using same ID as group_id for consistency
      airline: airline['airline_name']?.toString() ?? 'Unknown Airline',
      sector: json['sector']?.toString() ?? '',
      shortName: airline['short_name']?.toString() ?? '',
      groupPriceDetailId: json['group_price_detail_id'] ?? 0,
      departure: departureDate,
      returnDate: returnDate,
      type: json['type']?.toString() ?? '',
      price: json['price'] ?? 0,
      seats: json['available_no_of_pax'] ?? 0,
      baggage: baggage,
      logoUrl: airline['logo_url']?.toString() ?? 
          'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAACklEQVR4nGMAAQAABQABDQottAAAAABJRU5ErkJggg==',
      pnr: json['pnr']?.toString() ?? '',
      meal: json['meal']?.toString() ?? 'No',
      segments: segments,
    );
  }

  // Method to get flight duration for a segment (you can enhance this)
  String getSegmentDuration(FlightSegment segment) {
    // This is a placeholder - you might want to calculate actual duration
    // based on departure and arrival times
    return "2h 30m"; // Default duration
  }

  // Method to get total journey time for round-trip
  String getTotalJourneyDays() {
    if (returnDate != null) {
      final difference = returnDate!.difference(departure).inDays;
      return "${difference} days";
    }
    return "One way";
  }
}