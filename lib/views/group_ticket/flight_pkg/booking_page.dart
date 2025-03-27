import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:oneroof/utility/colors.dart';
import 'package:oneroof/views/group_ticket/flight_pkg/pkg_controller.dart';
import 'package:oneroof/views/group_ticket/flight_pkg/pkg_model.dart';
import 'package:oneroof/views/group_ticket/passenger_detail.dart';

class SelectPkgScreen extends StatelessWidget {

  SelectPkgScreen({super.key});

  final FlightPKGController controller = Get.put(FlightPKGController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Flight Search Results'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () {},
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return _buildErrorState(controller.errorMessage.value);
        }

        if (controller.filteredFlights.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          children: [
            _buildFiltersHeader(context),
            _buildAppliedFilters(),
            Expanded(child: _buildFlightsList()),
          ],
        );
      }),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error Loading Flights',
            style: TextStyle(
              fontSize: 18,
              color: TColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: controller.loadInitialData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.flight, size: 80, color: TColors.primary),
          const SizedBox(height: 16),
          const Text(
            'No flights available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'Try adjusting your filters',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: controller.resetFilters,
            child: const Text('Reset Filters'),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Text('Filters', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Spacer(),
          TextButton(
            onPressed: controller.resetFilters,
            child: const Text('Clear All'),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterBottomSheet(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAppliedFilters() {
    return Obx(() {
      final hasFilters = controller.selectedSector.value != 'all' ||
          controller.selectedAirline.value != 'all' ||
          controller.selectedDate.value != 'all';

      if (!hasFilters) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        height: 50,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            if (controller.selectedSector.value != 'all')
              _buildFilterChip(
                label: controller.sectorOptions.firstWhere(
                      (option) => option['value'] == controller.selectedSector.value,
                )['label']!,
                onDeleted: () => controller.updateSector('all'),
              ),
            if (controller.selectedAirline.value != 'all')
              _buildFilterChip(
                label: controller.selectedAirline.value,
                onDeleted: () => controller.updateAirline('all'),
              ),
            if (controller.selectedDate.value != 'all')
              _buildFilterChip(
                label: DateFormat('dd MMM yyyy').format(
                  DateTime.parse(controller.selectedDate.value),
                ),
                onDeleted: () => controller.updateDate('all'),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildFlightsList() {
    return Obx(() {
      final flightsBySector = <String, List<FlightModel>>{};

      for (final flight in controller.filteredFlights) {
        final sector = '${flight.origin}-${flight.destination}'.toLowerCase();
        flightsBySector.putIfAbsent(sector, () => []).add(flight);
      }

      return ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: flightsBySector.length,
        itemBuilder: (context, index) {
          final sector = flightsBySector.keys.elementAt(index);
          final sectorFlights = flightsBySector[sector]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  sector.toUpperCase(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: TColors.primary,
                  ),
                ),
              ),
              ...sectorFlights.map(_buildFlightCard).toList(),
            ],
          );
        },
      );
    });
  }



  // Helper method to build applied filters chips
  Widget _buildAppliedFiltersChips() {
    return Obx(() {
      // Only show if any filter is applied
      if (controller.selectedSector.value != 'lahore-dammam' ||
          controller.selectedAirline.value != 'all' ||
          controller.selectedDate.value != 'all') {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Sector chip
                if (controller.selectedSector.value != 'lahore-dammam')
                  _buildFilterChip(
                    label:
                        controller.sectorOptions.firstWhere(
                          (option) =>
                              option['value'] ==
                              controller.selectedSector.value,
                        )['label']!,
                    onDeleted: () => controller.updateSector('lahore-dammam'),
                  ),

                // Airline chip
                if (controller.selectedAirline.value != 'all')
                  _buildFilterChip(
                    label:
                        controller.selectedAirline.value == 'all'
                            ? 'All Airlines'
                            : controller.selectedAirline.value,
                    onDeleted: () => controller.updateAirline('all'),
                  ),

                // Date chip
                if (controller.selectedDate.value != 'all')
                  _buildFilterChip(
                    label:
                        controller.selectedDate.value == 'all'
                            ? 'All Dates'
                            : controller.selectedDate.value,
                    onDeleted: () => controller.updateDate('all'),
                  ),
              ],
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }

  // Helper method to build flight list


  // Helper method to build filter chips
  Widget _buildFilterChip({
    required String label,
    required VoidCallback onDeleted,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white),
        ),
        backgroundColor: TColors.third,
        deleteIconColor: Colors.white,
        onDeleted: onDeleted,
      ),
    );
  }

  // Method to show filter bottom sheet
  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filters',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: TColors.primary,
                      ),
                    ),
                    TextButton(
                      onPressed: controller.resetFilters,
                      child: const Text(
                        'Clear All',
                        style: TextStyle(fontSize: 14, color: TColors.third),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Filter content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sector Filter
                      _buildFilterSection(
                        title: 'Sector',
                        options: controller.sectorOptions,
                        currentValue: controller.selectedSector,
                        onSelect: controller.updateSector,
                      ),

                      const SizedBox(height: 25),

                      // Airlines Filter
                      _buildAirlineFilterSection(),

                      const SizedBox(height: 25),

                      // Departure Dates Filter
                      _buildDateFilterSection(),
                    ],
                  ),
                ),
              ),

              // Apply button
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColors.secondary,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Custom method for airline filter section to dynamically generate options
  Widget _buildAirlineFilterSection() {
    // Get unique airlines from group flights
    final airlineOptions =
        controller.groupFlights
            .map((flight) => flight['airline']['airline_name'])
            .toSet()
            .toList()
            .map(
              (airline) => {'label': airline, 'value': airline.toLowerCase()},
            )
            .toList();

    return _buildFilterSection(
      title: 'Airlines',
      options: [
        {'label': 'All Airlines', 'value': 'all'},
        ...airlineOptions.map(
          (option) => {
            'label': option['label'].toString(),
            'value': option['value'].toString(),
          },
        ),
      ],
      currentValue: controller.selectedAirline,
      onSelect: controller.updateAirline,
    );
  }

  // Custom method for date filter section to dynamically generate options
  Widget _buildDateFilterSection() {
    // Get unique dates from group flights
    final dateOptions =
        controller.groupFlights
            .map((flight) => flight['dept_date'])
            .toSet()
            .toList()
            .map((date) {
              final formattedDate = DateFormat('yyyy-MM-dd').parse(date);
              return {
                'label': DateFormat('dd MMM yyyy').format(formattedDate),
                'value': date,
              };
            })
            .toList();

    return _buildFilterSection(
      title: 'Departure Dates',
      options: [
        {'label': 'All Dates', 'value': 'all'},
        ...dateOptions.map(
          (option) => {
            'label': option['label'].toString(),
            'value': option['value'].toString(),
          },
        ),
      ],
      currentValue: controller.selectedDate,
      onSelect: controller.updateDate,
    );
  }

  // Helper method to build filter section
  Widget _buildFilterSection({
    required String title,
    required List<Map<String, String>> options,
    required RxString currentValue,
    required Function(String) onSelect,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: TColors.text,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children:
              options.map((option) {
                final bool isSelected = currentValue.value == option['value'];
                return GestureDetector(
                  onTap: () => onSelect(option['value']!),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? TColors.third : Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border:
                          isSelected
                              ? Border.all(color: TColors.third, width: 2)
                              : Border.all(color: Colors.transparent),
                    ),
                    child: Text(
                      option['label']!,
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected ? Colors.white : TColors.text,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  // Method to build flight card
  Widget _buildFlightCard(FlightModel flight) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with airline and date
          // Header with airline and date
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: Row(
              children: [
                // Airline Logo
                Container(
  width: 40,
  height: 40,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    image: flight.logoUrl.startsWith('data:')
      ? DecorationImage(
          image: MemoryImage(base64Decode(flight.logoUrl.split(',')[1])),
          fit: BoxFit.cover,
        )
      : DecorationImage(
          image: NetworkImage(flight.logoUrl),
          fit: BoxFit.cover,
        ),
  ),
),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      flight.airline,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: TColors.primary,
                      ),
                    ),
                    Text(
                      'Departure',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  DateFormat('dd MMM yyyy').format(flight.departure),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: TColors.primary,
                  ),
                ),
              ],
            ),
          ),
          // Route details
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        flight.departureTime,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: TColors.primary,
                        ),
                      ),
                      Text(
                        flight.origin,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: TColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Container(height: 1, color: Colors.grey[300]),
                      ),
                      const Icon(
                        Icons.flight,
                        color: TColors.primary,
                        size: 16,
                      ),
                      Expanded(
                        child: Container(height: 1, color: Colors.grey[300]),
                      ),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: TColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        flight.arrivalTime,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: TColors.primary,
                        ),
                      ),
                      Text(
                        flight.destination,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Flight details row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                Text(
                  flight.flightNumber,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: TColors.primary,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 14,
                      color: TColors.secondary,
                    ),
                    const SizedBox(width: 2),
                    const Text(
                      'NO',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: TColors.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Row(
                  children: [
                    const Icon(Icons.luggage, size: 14, color: TColors.primary),
                    const SizedBox(width: 2),
                    Text(
                      flight.baggage,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: TColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Price and booking
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
            child: Row(
              children: [
                Text(
                  'PKR ${flight.price}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: TColors.primary,
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    Get.to(() => BookingSummaryScreen());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColors.secondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Book Now',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
