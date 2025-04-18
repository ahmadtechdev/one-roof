
// booking_model.dart
class BookingModel {
  final DateTime bookingOn;
  final String bookingId;
  final String pnr;
  final String airline;
  final String supplier;
  final String trip;
  final String passengerName;
  final DateTime travelDate;
  final int totalPrice;
  final String status;
  final DateTime? deadline;
  
  BookingModel({
    required this.bookingOn,
    required this.bookingId,
    required this.pnr,
    required this.airline,
    required this.supplier,
    required this.trip,
    required this.passengerName,
    required this.travelDate,
    required this.totalPrice,
    required this.status,
    this.deadline,
  });
}