// // Add this to the models/airblue_flight_model.dart file
//
// import '../../search_flight_utils/models/airblue_flight_model.dart';
//
// class AirBlueFareOption {
//   final String cabinCode;
//   final String cabinName;
//   final String brandName;
//   final double price;
//   final String currency;
//   final int seatsAvailable;
//   final bool isRefundable;
//   final String mealCode;
//   final String baggageAllowance;
//   final Map<String, dynamic> rawData; // Store the original JSON data
//
//   AirBlueFareOption({
//     required this.cabinCode,
//     required this.cabinName,
//     required this.brandName,
//     required this.price,
//     required this.currency,
//     required this.seatsAvailable,
//     required this.isRefundable,
//     required this.mealCode,
//     required this.baggageAllowance,
//     required this.rawData,
//   });
//
//   // Factory method to create a fare option from a flight
//   factory AirBlueFareOption.fromFlight(AirBlueFlight flight, Map<String, dynamic> rawData) {
//     // Extract fare basis code to determine if refundable
//     final String fareBasisCode = _extractFareBasisCode(rawData).toUpperCase();
//     final bool isRefundable = !fareBasisCode.contains('NR');
//
//     // Extract cabin information
//     final String cabinCode = _extractCabinCode(rawData);
//     final String cabinName = _getCabinName(cabinCode);
//
//     // Extract brand name if available
//     String brandName = _extractBrandName(rawData);
//     if (brandName.isEmpty) {
//       brandName = _getBrandFromFareBasis(fareBasisCode);
//     }
//
//     // Extract seats available
//     final int seatsAvailable = _extractSeatsAvailable(rawData);
//
//     // Extract meal code
//     final String mealCode = _extractMealCode(rawData);
//
//     // Extract baggage allowance
//     final String baggageAllowance = _extractBaggageAllowance(rawData);
//
//     return AirBlueFareOption(
//       cabinCode: cabinCode,
//       cabinName: cabinName,
//       brandName: brandName,
//       price: flight.price,
//       currency: flight.currency,
//       seatsAvailable: seatsAvailable,
//       isRefundable: isRefundable,
//       mealCode: mealCode,
//       baggageAllowance: baggageAllowance,
//       rawData: rawData,
//     );
//   }
//
//
// }