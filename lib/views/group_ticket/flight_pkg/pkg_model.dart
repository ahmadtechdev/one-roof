import 'package:intl/intl.dart';

class GroupFlightModel {
  final int id;
  final String airline;
  final String sector;
  final String shortName;
  final int groupPriceDetailId;
  final DateTime departure;
  final String departureTime;
  final String arrivalTime;
  final String origin;
  final String destination;
  final String flightNumber;
  final int price;
  final int seats;
  final bool hasLayover;
  final String baggage;
  final String logoUrl; // New property

  GroupFlightModel({
    required this.id,
    required this.airline,
    required this.sector,
    required this.shortName,
    required this.groupPriceDetailId,
    required this.departure,
    required this.departureTime,
    required this.arrivalTime,
    required this.origin,
    required this.destination,
    required this.flightNumber,
    required this.price,
    required this.seats,
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
