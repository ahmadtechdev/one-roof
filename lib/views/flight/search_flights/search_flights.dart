import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oneroof/views/flight/search_flights/search_flight_utils/airblue_flight_controller.dart';
import 'package:oneroof/views/flight/search_flights/search_flight_utils/widgets/airblue_flight_card.dart';

import '../../../utility/colors.dart';
import 'search_flight_utils/flight_controller.dart';
import 'search_flight_utils/widgets/currency_dialog.dart';
import 'search_flight_utils/widgets/flight_bottom_sheet.dart';
import 'search_flight_utils/widgets/sabre_flight_card.dart';

enum FlightScenario { oneWay, returnFlight, multiCity }

class ReturnCaseScenario extends StatelessWidget {
  final String stepNumber;
  final String stepText;
  final bool isActive;

  const ReturnCaseScenario({
    super.key,
    required this.stepNumber,
    required this.stepText,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(

      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: isActive ? TColors.primary : TColors.grey,
              shape: BoxShape.circle,
              borderRadius: BorderRadius.circular(16),

            ),

            alignment: Alignment.center,
            child: Text(
              stepNumber,
              style: const TextStyle(
                color: TColors.background,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            stepText,
            style: TextStyle(
              color: isActive ? TColors.primary : TColors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class FlightBookingPage extends StatelessWidget {
  final FlightScenario scenario;
  final FlightController controller = Get.put(FlightController());
  final AirBlueFlightController airBlueController = Get.put(AirBlueFlightController());

  FlightBookingPage({super.key, required this.scenario}) {
    controller.setScenario(scenario);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.background,
      appBar: AppBar(
        surfaceTintColor: TColors.background,
        backgroundColor: TColors.background,
        leading: const BackButton(),
        title: Obx(() {
          // Get total flight count
          final totalFlights = controller.filteredFlights.length + airBlueController.flights.length;
          final isLoading = controller.isLoading.value || airBlueController.isLoading.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (isLoading)
                    const Text(
                      'Searching flights...',
                      style: TextStyle(
                        fontSize: 16,
                        color: TColors.text,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  else
                    Text(
                      '$totalFlights Flights Found',
                      style: const TextStyle(
                        fontSize: 16,
                        color: TColors.text,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(width: 8),
                  // Show loading indicator in the title
                  if (isLoading)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
            ],
          );
        }),
        actions: [
          GetX<FlightController>(
            builder: (controller) => TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => CurrencyDialog(controller: controller),
                );
              },
              child: Text(
                controller.selectedCurrency.value,
                style: const TextStyle(
                  color: TColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          _buildFlightList(),
        ],
      ),
    );
  }


  Widget _buildFilterSection() {
    return Container(
      // color: TColors.background,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: TColors.background,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: TColors.secondary.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Obx(() => _filterButton(
                'Suggested', controller.sortType.value == 'Suggested')),
            Obx(() => _filterButton(
                'Cheapest', controller.sortType.value == 'Cheapest')),
            Obx(() =>
                _filterButton('Fastest', controller.sortType.value == 'Fastest')),
            OutlinedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: Get.context!,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (_) => FilterBottomSheet(controller: controller),
                );
              },
              child: const Row(
                children: [
                  Icon(Icons.tune, size: 12),
                  SizedBox(width: 4),
                  Text(
                    'Filters',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Update the _buildFlightList method in FlightBookingPage
// Update the _buildFlightList method
  // In search_flights.dart, update the _buildFlightList method:
  // Widget _buildFlightList() {
  //   final airBlueController = Get.put(AirBlueFlightController());
  //
  //   return Expanded(
  //     child: Obx(() {
  //       if (controller.filteredFlights.isEmpty && airBlueController.flights.isEmpty) {
  //         return Center(
  //           child: Column(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               const Text(
  //                 'No flights match your criteria.',
  //                 style: TextStyle(color: TColors.grey),
  //               ),
  //               if (airBlueController.errorMessage.isNotEmpty)
  //                 Padding(
  //                   padding: const EdgeInsets.only(top: 8.0),
  //                   child: Text(
  //                     airBlueController.errorMessage.value,
  //                     style: const TextStyle(color: Colors.red),
  //                   ),
  //                 ),
  //             ],
  //           ),
  //         );
  //       }
  //
  //       return ListView.builder(
  //         itemCount: controller.filteredFlights.length + airBlueController.flights.length,
  //         itemBuilder: (context, index) {
  //           if (index < controller.filteredFlights.length) {
  //             // Sabre flight
  //             final flight = controller.filteredFlights[index];
  //             return GestureDetector(
  //               onTap: () => controller.handleFlightSelection(flight),
  //               child: FlightCard(flight: flight),
  //             );
  //           } else {
  //             // AirBlue flight
  //             final airBlueIndex = index - controller.filteredFlights.length;
  //             final airBlueFlight = airBlueController.flights[airBlueIndex];
  //             return GestureDetector(
  //               onTap: () => airBlueController.handleAirBlueFlightSelection(airBlueFlight),
  //               child: AirBlueFlightCard(flight: airBlueFlight),
  //             );
  //           }
  //         },
  //       );
  //     }),
  //   );
  // }

  Widget _buildFlightList() {
    final airBlueController = Get.put(AirBlueFlightController());
    final flightController = Get.find<FlightController>();

    return Expanded(
      child: Obx(() {
        // Show loading indicator if either API is still loading
        if (flightController.isLoading.value || airBlueController.isLoading.value) {
          return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Searching for flights...', style: TextStyle(color: TColors.grey))
                ],
              )
          );
        }

        // Show empty state if both APIs returned no results
        if (flightController.filteredFlights.isEmpty && airBlueController.flights.isEmpty) {
          return const Center(
            child: Text(
              'No flights match your criteria.',
              style: TextStyle(color: TColors.grey),
            ),
          );
        }

        // Show combined results
        return ListView.builder(
          // Add a key for better performance when list changes
          key: ValueKey('${flightController.filteredFlights.length}-${airBlueController.flights.length}'),
          itemCount: flightController.filteredFlights.length + airBlueController.flights.length,
          itemBuilder: (context, index) {
            if (index < flightController.filteredFlights.length) {
              final flight = flightController.filteredFlights[index];
              return GestureDetector(
                onTap: () => flightController.handleFlightSelection(flight),
                child: FlightCard(flight: flight),
              );
            } else {
              final airBlueIndex = index - flightController.filteredFlights.length;
              final airBlueFlight = airBlueController.flights[airBlueIndex];
              return GestureDetector(
                onTap: () => airBlueController.handleAirBlueFlightSelection(airBlueFlight),
                child: AirBlueFlightCard(flight: airBlueFlight),
              );
            }
          },
        );
      }),
    );
  }
  Widget _filterButton(String text, bool isSelected) {
    return TextButton(
      onPressed: () {
        controller.updateSortType(text);
      },
      style: TextButton.styleFrom(
        foregroundColor: isSelected ? TColors.primary : TColors.grey,
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}

