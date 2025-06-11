import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utility/colors.dart';
import '../../form/flight_booking_controller.dart';
import '../flight_package/pia/pia_flight_model.dart';

class PIABookingFlight extends StatelessWidget {
  final PIAFlight flight;
  final PIAFlight? returnFlight;
  final double totalPrice;
  final String currency;

  const PIABookingFlight({
    super.key,
    required this.flight,
    this.returnFlight,
    required this.totalPrice,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final bookingController = Get.find<FlightBookingController>();

    return Scaffold(
      backgroundColor: TColors.background,
      appBar: AppBar(
        backgroundColor: TColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Flight Booking',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Flight Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: TColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            // Add your booking form fields here
            // ...
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {
            // Handle booking submission
            // bookingController.bookFlight(flight, returnFlight);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: TColors.primary,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Confirm Booking - $currency ${totalPrice.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}