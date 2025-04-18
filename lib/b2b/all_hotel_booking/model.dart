class HotelBookingModel {
  final String serialNumber;
  final String bookingNumber;
  final String date;
  final String bookerName;
  final String guestName;
  final String destination;
  final String hotel;
  final String status;
  final String checkinCheckout;
  final String price;
  final String cancellationDeadline;

  HotelBookingModel({
    required this.serialNumber,
    required this.bookingNumber,
    required this.date,
    required this.bookerName,
    required this.guestName,
    required this.destination,
    required this.hotel,
    required this.status,
    required this.checkinCheckout,
    required this.price,
    required this.cancellationDeadline,
  });
}
