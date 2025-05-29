// Create a new file: pia_return_flights_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../search_flight_utils/widgets/pia_flight_card.dart';
import 'pia_flight_model.dart';
import 'pia_flight_controller.dart';


class PIAReturnFlightsPage extends StatelessWidget {
  final List<PIAFlight> returnFlights;
  final PIAFlightController piaController = Get.find<PIAFlightController>();

  PIAReturnFlightsPage({super.key, required this.returnFlights});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Select Return Flight'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            piaController.selectedOutboundFlight.value = null;
            piaController.showReturnFlights.value = false;
            Get.back();
          },
        ),
      ),
      body: _buildFlightList(),
    );
  }

  Widget _buildFlightList() {
    return ListView.builder(
      itemCount: returnFlights.length,
      itemBuilder: (context, index) {
        final flight = returnFlights[index];
        return GestureDetector(
          onTap: () => piaController.handlePIAFlightSelection(flight),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: PIAFlightCard(flight: flight, showReturnFlight: false),
          ),
        );
      },
    );
  }
}