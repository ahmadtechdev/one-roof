import 'package:intl/intl.dart';

class FlightModel {
  final String airline;
  final String shortName;
  final DateTime departure;
  final String departureTime;
  final String arrivalTime;
  final String origin;
  final String destination;
  final String flightNumber;
  final int price;
  final bool hasLayover;
  final String baggage;
  final String logoUrl; // New property

  FlightModel({
    required this.airline,
    required this.shortName,
    required this.departure,
    required this.departureTime,
    required this.arrivalTime,
    required this.origin,
    required this.destination,
    required this.flightNumber,
    required this.price,
    required this.hasLayover,
    required this.baggage,
    required this.logoUrl, // Add this to constructor
  });

  // Helper method to get formatted date
  String get formattedDate {
    final formatter = DateFormat('dd MMM yyyy');
    return formatter.format(departure);
  }
}
