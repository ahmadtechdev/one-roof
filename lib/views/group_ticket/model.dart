// passenger_model.dart
class Passenger {
  String title;
  String firstName;
  String lastName;
  String passportNumber;
  DateTime? dateOfBirth;
  DateTime? passportExpiry;

  Passenger({
    this.title = '',
    this.firstName = '',
    this.lastName = '',
    this.passportNumber = '',
    this.dateOfBirth,
    this.passportExpiry,
  });
}

// booking_data_model.dart
class BookingData {
  String groupName;
  String sector;
  int availableSeats;
  int adults;
  int children;
  int infants;
  double adultPrice;
  double childPrice;
  double infantPrice;
  List<Passenger> passengers = [];

  BookingData({
    required this.groupName,
    required this.sector,
    required this.availableSeats,
    required this.adults,
    required this.children,
    required this.infants,
    required this.adultPrice,
    required this.childPrice,
    required this.infantPrice,
  }) {
    // Initialize passenger list based on counts
    for (int i = 0; i < adults; i++) {
      passengers.add(Passenger(title: 'Mr'));
    }
    for (int i = 0; i < children; i++) {
      passengers.add(Passenger(title: 'Mstr'));
    }
    for (int i = 0; i < infants; i++) {
      passengers.add(Passenger(title: 'INF'));
    }
  }

  int get totalPassengers => adults + children + infants;

  double get totalPrice =>
      (adults * adultPrice) + (children * childPrice) + (infants * infantPrice);

  bool isValidSeatCount() {
    return totalPassengers <= availableSeats;
  }
}