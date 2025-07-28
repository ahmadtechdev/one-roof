import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:oneroof/utility/colors.dart';
import 'package:oneroof/views/group_ticket/booking_form_fields/group_ticket_booking_controller.dart';
import 'package:oneroof/views/group_ticket/flight_pkg/pkg_controller.dart';
import 'package:oneroof/views/group_ticket/flight_pkg/pkg_model.dart';
import 'package:oneroof/views/group_ticket/booking_form_fields/passenger_detail.dart';

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
            Expanded(
              child: _buildFlightsList(
                flights: controller.filteredFlights,
                context: context,
              ),
            ),
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
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
          const Text(
            'Filters',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
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
      final hasFilters =
          controller.selectedSector.value != 'all' ||
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
                label:
                    controller.sectorOptions.firstWhere(
                      (option) =>
                          option['value'] == controller.selectedSector.value,
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
                label: DateFormat(
                  'dd MMM yyyy',
                ).format(DateTime.parse(controller.selectedDate.value)),
                onDeleted: () => controller.updateDate('all'),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildFlightsList({
    required List<GroupFlightModel> flights,
    required BuildContext context,
  }) {
    final flightsBySector = <String, List<GroupFlightModel>>{};

    for (final flight in flights) {
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
            ...sectorFlights.map((flight) => _buildFlightCard(flight, context)),
          ],
        );
      },
    );
  }

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
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFilterSection(
                        title: 'Sector',
                        options: controller.sectorOptions,
                        currentValue: controller.selectedSector,
                        onSelect: controller.updateSector,
                      ),
                      const SizedBox(height: 25),
                      _buildAirlineFilterSection(),
                      const SizedBox(height: 25),
                      _buildDateFilterSection(),
                    ],
                  ),
                ),
              ),
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

  Widget _buildAirlineFilterSection() {
    final airlineOptions =
        controller.groupFlights
            .map(
              (flight) => flight['airline']['airline_name'] as String,
            ) // Cast to String
            .toSet()
            .toList()
            .map(
              (airline) => <String, String>{
                // Explicitly create Map<String, String>
                'label': airline,
                'value': airline.toLowerCase(),
              },
            )
            .toList();

    return _buildFilterSection(
      title: 'Airlines',
      options: [
        {'label': 'All Airlines', 'value': 'all'},
        ...airlineOptions,
      ],
      currentValue: controller.selectedAirline,
      onSelect: controller.updateAirline,
    );
  }

  Widget _buildDateFilterSection() {
    final dateOptions =
        controller.groupFlights
            .map((flight) => flight['dept_date'] as String) // Cast to String
            .toSet()
            .toList()
            .map((date) {
              final formattedDate = DateFormat('yyyy-MM-dd').parse(date);
              return <String, String>{
                // Explicitly create Map<String, String>
                'label': DateFormat('dd MMM yyyy').format(formattedDate),
                'value': date,
              };
            })
            .toList();

    return _buildFilterSection(
      title: 'Departure Dates',
      options: [
        {'label': 'All Dates', 'value': 'all'},
        ...dateOptions,
      ],
      currentValue: controller.selectedDate,
      onSelect: controller.updateDate,
    );
  }

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
        Obx(
          () => Wrap(
            spacing: 10,
            runSpacing: 10,
            children:
                options.map((option) {
                  final isSelected = currentValue.value == option['value'];
                  return GestureDetector(
                    onTap: () => onSelect(option['value']!),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? TColors.third : TColors.background,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? TColors.third : Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        option['label']!,
                        style: TextStyle(
                          fontSize: 14,
                          color: isSelected ? TColors.white : TColors.text,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  // Enhanced flight card widgets for displaying flights with dynamic segments (1, 2, 4, or more legs)

  Widget _buildFlightCard(GroupFlightModel flight, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: TColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _buildFlightHeader(flight),
            const SizedBox(height: 12),

            // Display all segments dynamically
            ...flight.segments.asMap().entries.map((entry) {
              int index = entry.key;
              FlightSegment segment = entry.value;

              return Column(
                children: [
                  _buildSegmentHeader(
                    _getSegmentTitle(index, flight.segments.length),
                    segment,
                  ),
                  const SizedBox(height: 8),
                  _buildFlightRoute(segment),

                  // Show layover info between segments (except after the last segment)
                  if (index < flight.segments.length - 1) ...[
                    const SizedBox(height: 8),
                    _buildLayoverInfoBetweenSegments(
                      segment,
                      flight.segments[index + 1],
                    ),
                  ],

                  const SizedBox(height: 12),
                ],
              );
            }).toList(),

            _buildFlightDetails(flight),
            const SizedBox(height: 8),
            _buildFlightFooter(flight, context),
          ],
        ),
      ),
    );
  }

  // Helper method to determine segment title based on position and total segments
  String _getSegmentTitle(int index, int totalSegments) {
    if (totalSegments == 1) {
      return "Direct Flight";
    } else if (totalSegments == 2) {
      return index == 0 ? "Outbound Flight" : "Return Flight";
    } else {
      // For more than 2 segments (complex itinerary)
      if (index == 0) {
        return "Departure - Leg ${index + 1}";
      } else if (index == totalSegments - 1) {
        return "Final Leg - Leg ${index + 1}";
      } else {
        return "Connecting Flight - Leg ${index + 1}";
      }
    }
  }

  // Enhanced segment header with more detailed information
  Widget _buildSegmentHeader(String title, FlightSegment segment) {
    IconData segmentIcon;
    Color segmentColor;

    if (title.contains("Departure") || title.contains("Outbound")) {
      segmentIcon = Icons.flight_takeoff;
      segmentColor = TColors.primary;
    } else if (title.contains("Final") || title.contains("Return")) {
      segmentIcon = Icons.flight_land;
      segmentColor = TColors.secondary;
    } else if (title.contains("Connecting")) {
      segmentIcon = Icons.connecting_airports;
      segmentColor = TColors.third;
    } else {
      segmentIcon = Icons.flight;
      segmentColor = TColors.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: segmentColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: segmentColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(segmentIcon, size: 16, color: segmentColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: segmentColor,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: segmentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              segment.formattedShortDate,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: segmentColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // New method to show layover information between segments
  Widget _buildLayoverInfoBetweenSegments(
    FlightSegment currentSegment,
    FlightSegment nextSegment,
  ) {
    // Calculate layover duration (simplified - you might want to make this more accurate)
    String layoverLocation = currentSegment.destination;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.schedule, size: 16, color: Colors.orange[700]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Layover at $layoverLocation',
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Transit',
              style: TextStyle(
                fontSize: 10,
                color: Colors.orange[800],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Enhanced flight route with better visual indicators for different segment types
  Widget _buildFlightRoute(FlightSegment segment) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Row(
        children: [
          // Departure info
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  segment.departureTime,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: TColors.background4,
                  ),
                ),
                Text(
                  segment.origin,
                  style: TextStyle(
                    fontSize: 14,
                    color: TColors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Flight path visualization with enhanced design
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: TColors.third,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              TColors.third,
                              TColors.third.withOpacity(0.3),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: TColors.third.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Transform.rotate(
                        angle: 1.5708, // 90 degrees
                        child: Icon(
                          Icons.flight,
                          color: TColors.third,
                          size: 20,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              TColors.third.withOpacity(0.3),
                              TColors.third,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: TColors.third,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: TColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    segment.flightNumber,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: TColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Arrival info
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  segment.arrivalTime,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: TColors.background4,
                  ),
                ),
                Text(
                  segment.destination,
                  style: TextStyle(
                    fontSize: 14,
                    color: TColors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Enhanced flight header with journey summary
  Widget _buildFlightHeader(GroupFlightModel flight) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: TColors.background,
            border: Border.all(
              color: TColors.primary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: _buildAirlineLogo(flight),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      flight.airline,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: TColors.text,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getTypeColor(flight.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getTypeColor(flight.type).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      flight.type,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getTypeColor(flight.type),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.route, size: 14, color: TColors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${flight.segments.length} segment${flight.segments.length > 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 12,
                      color: TColors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (flight.segments.length > 2) ...[
                    const SizedBox(width: 12),
                    Icon(
                      Icons.connecting_airports,
                      size: 14,
                      color: TColors.secondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${flight.segments.length - 1} stop${flight.segments.length > 2 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: 12,
                        color: TColors.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFlightFooter(GroupFlightModel flight, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: 'PKR ',
                      style: TextStyle(
                        fontSize: 14,
                        color: TColors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text:
                          '${flight.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                      style: const TextStyle(
                        fontSize: 22,
                        color: TColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (flight.isRoundTrip)
                Text(
                  'Round Trip',
                  style: TextStyle(
                    fontSize: 12,
                    color: TColors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              final bookingController = Get.put(GroupTicketBookingController());
              bookingController.initializeFromFlight(flight, flight.id);
              Get.to(() => BookingSummaryScreen());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TColors.secondary,
              foregroundColor: TColors.background,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 3,
            ),
            child: const Text(
              'Book Now',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to get color based on flight type
  Color _getTypeColor(String type) {
    switch (type.toUpperCase()) {
      case 'UMRAH':
        return Colors.green;
      case 'UAE':
        return Colors.blue;
      case 'KSA':
        return Colors.purple;
      case 'UK':
        return Colors.indigo;
      case 'OMAN':
        return Colors.orange;
      default:
        return TColors.primary;
    }
  }

  // Helper widget to build airline logo with proper error handling
  Widget _buildAirlineLogo(GroupFlightModel flight) {
    print('Building logo for: ${flight.airline}, URL: ${flight.logoUrl}');

    // Check if we have a valid logo URL
    if (flight.logoUrl.isNotEmpty &&
        flight.logoUrl !=
            'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAACklEQVR4nGMAAQAABQABDQottAAAAABJRU5ErkJggg==') {
      try {
        if (flight.logoUrl.startsWith('data:image')) {
          // Handle base64 encoded images
          final base64String = flight.logoUrl.split(',')[1];
          return Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: MemoryImage(base64Decode(base64String)),
                fit: BoxFit.contain,
                onError: (exception, stackTrace) {
                  print('Error loading base64 image: $exception');
                },
              ),
            ),
          );
        } else if (flight.logoUrl.startsWith('http')) {
          // Handle network images
          return Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage(flight.logoUrl),
                fit: BoxFit.contain,
                onError: (exception, stackTrace) {
                  print('Error loading network image: $exception');
                },
              ),
            ),
          );
        } else if (flight.logoUrl.startsWith('assets/')) {
          // Handle asset images
          return Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage(flight.logoUrl),
                fit: BoxFit.contain,
                onError: (exception, stackTrace) {
                  print('Error loading asset image: $exception');
                },
              ),
            ),
          );
        }
      } catch (e) {
        print('Error building airline logo: $e');
      }
    }

    // Fallback to flight icon
    return Icon(Icons.flight, color: TColors.primary, size: 24);
  }

  // Enhanced flight details with total journey information
  Widget _buildFlightDetails(GroupFlightModel flight) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: TColors.background,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Seats available
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.airline_seat_recline_normal,
                      size: 16,
                      color: TColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${flight.seats} seats',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: TColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              // Baggage
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.luggage, size: 16, color: TColors.third),
                    const SizedBox(width: 4),
                    Text(
                      flight.baggage,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: TColors.third,
                      ),
                    ),
                  ],
                ),
              ),

              // Meal
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.restaurant, size: 16, color: TColors.secondary),
                    const SizedBox(width: 4),
                    Text(
                      flight.meal,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: TColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Show journey summary for multi-segment flights
          if (flight.segments.length > 1) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: TColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Journey: ${flight.segments.first.origin} → ${flight.segments.last.destination}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: TColors.primary,
                    ),
                  ),
                  if (flight.segments.length > 2)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        '${flight.segments.length - 1} stops',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
