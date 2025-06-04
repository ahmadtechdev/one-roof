import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oneroof/views/flight/search_flights/flight_package/airblue/airblue_flight_controller.dart';
import 'package:oneroof/views/flight/search_flights/search_flight_utils/widgets/airblue_flight_card.dart';

import '../../../utility/colors.dart';
import 'flight_package/pia/pia_flight_controller.dart';
import 'flight_package/pia/pia_flight_model.dart';
import 'flight_package/sabre/sabre_flight_controller.dart';
import 'search_flight_utils/filter_flight_model.dart';
import 'search_flight_utils/widgets/currency_dialog.dart';
import 'search_flight_utils/widgets/flight_bottom_sheet.dart';
import 'search_flight_utils/widgets/pia_flight_card.dart';
import 'search_flight_utils/widgets/sabre_flight_card.dart';

enum FlightScenario { oneWay, returnFlight, multiCity }



class FlightBookingPage extends StatelessWidget {
  final FlightScenario scenario;
  final FlightController controller = Get.put(FlightController());
  final AirBlueFlightController airBlueController = Get.put(AirBlueFlightController());
  final PIAFlightController piaController = Get.put(PIAFlightController());

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
          final totalFlights = controller.filteredFlights.length + airBlueController.flights.length + piaController.filteredFlights.length;
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
                  builder: (_) => FilterBottomSheet(
                    controller: controller,
                    airBlueController: airBlueController,
                    piaController: piaController,
                  ),
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

  // In the _buildFlightList method
// In search_flights.dart, update the _buildFlightList method:
  Widget _buildFlightList() {
    final airBlueController = Get.put(AirBlueFlightController());
    final piaController = Get.put(PIAFlightController());
    final flightController = Get.find<FlightController>();

    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Sabre flights section
            Obx(() {
              if (flightController.isLoading.value && flightController.filteredFlights.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: flightController.filteredFlights.length,
                itemBuilder: (context, index) {
                  final flight = flightController.filteredFlights[index];
                  return GestureDetector(
                    onTap: () => flightController.handleFlightSelection(flight),
                    child: FlightCard(flight: flight),
                  );
                },
              );
            }),
        
            // AirBlue flights section (only if not multi-city)
            Obx(() {
              // if (tripType.value == TripType.multiCity) return const SizedBox();
              if (airBlueController.isLoading.value && airBlueController.flights.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: airBlueController.flights.length,
                itemBuilder: (context, index) {
                  final flight = airBlueController.flights[index];
                  return GestureDetector(
                    onTap: () => airBlueController.handleAirBlueFlightSelection(flight),
                    child: AirBlueFlightCard(flight: flight),
                  );
                },
              );
            }),
        
            // PIA flights section
            Obx(() {
              if (piaController.isLoading.value && piaController.filteredFlights.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: piaController.filteredFlights.length,
                itemBuilder: (context, index) {
                  final flight = piaController.filteredFlights[index];
                  return GestureDetector(
                    onTap: () => piaController.handlePIAFlightSelection(flight),
                    child: PIAFlightCard(flight: flight),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }
  Widget _filterButton(String text, bool isSelected) {
    return TextButton(
      onPressed: () {
        // Update sort type in all controllers
        controller.updateSortType(text);
        airBlueController.applyFilters(FlightFilter(sortType: text));
        piaController.applyFilters(FlightFilter(sortType: text));
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

