import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../../services/api_service_pia.dart';
import '../../../../../utility/colors.dart';
import '../../flight_package/pia/pia_flight_model.dart';
import '../helper_functions.dart';
import '../../flight_package/pia/pia_flight_controller.dart';

class PIAFlightCard extends StatefulWidget {
  final PIAFlight flight;
  final bool showReturnFlight;

  const PIAFlightCard({
    super.key,
    required this.flight,
    this.showReturnFlight = true,
  });

  @override
  State<PIAFlightCard> createState() => _PIAFlightCardState();
}

class _PIAFlightCardState extends State<PIAFlightCard>
    with SingleTickerProviderStateMixin {
  bool isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  final Rx<Map<String, dynamic>> marginData = Rx<Map<String, dynamic>>({});
  final RxDouble finalPrice = 0.0.obs;
  int i = 1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    // Initialize with PIA flight price
    finalPrice.value = widget.flight.price;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String getCabinClassName(String cabinCode) {
    switch (cabinCode) {
      case 'F':
        return 'First Class';
      case 'C':
        return 'Business Class';
      case 'Y':
        return 'Economy Class';
      case 'W':
        return 'Premium Economy';
      default:
        return 'Economy Class';
    }
  }

  String getMealInfo(String? mealCode) {
    switch (mealCode?.toUpperCase()) {
      case 'HALAL':
        return 'Halal Meal';
      case 'VEG':
        return 'Vegetarian Meal';
      case 'CHILD':
        return 'Child Meal';
      case 'N':
        return 'No meal service';
      default:
        return 'Standard Meal';
    }
  }

  String formatBaggageInfo() {
    if (widget.flight.baggageAllowance.pieces > 0) {
      return '${widget.flight.baggageAllowance.pieces} piece(s) included';
    } else if (widget.flight.baggageAllowance.weight > 0) {
      return '${widget.flight.baggageAllowance.weight} ${widget.flight.baggageAllowance.unit} included';
    }
    return widget.flight.baggageAllowance.type;
  }

  String formatFullDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('E, d MMM yyyy').format(dateTime);
    } catch (e) {
      return 'N/A';
    }
  }

  String formatTimeFromDateTime(String dateTimeString) {
    print("Time check $i: ");
    print(dateTimeString);
    i++;
    try {
      final dateTime = DateTime.parse(dateTimeString);
      print("Time check final $i: ");
      print(DateFormat('HH:mm').format(dateTime));
      return DateFormat('HH:mm').format(dateTime);
    } catch (e) {
      return 'N/A';
    }
  }

  String formatTime(String time) {
    if (time.isEmpty) return 'N/A';
    try {
      // Extract time part before timezone info
      String timePart;
      if (time.contains('T')) {
        timePart = time.split('T')[1];
        // Remove timezone info if present
        if (timePart.contains('+')) {
          timePart = timePart.split('+')[0];
        } else if (timePart.contains('-') && timePart.lastIndexOf('-') > 2) {
          timePart = timePart.split('-')[0];
        } else if (timePart.contains('Z')) {
          timePart = timePart.split('Z')[0];
        }
      } else {
        timePart = time;
      }

      final timeComponents = timePart.split(':');
      if (timeComponents.length >= 2) {
        final hour = int.parse(timeComponents[0]);
        final minute = int.parse(timeComponents[1]);
        return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
      }

      return 'N/A';
    } catch (e) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    final piaController = Get.find<PIAFlightController>();

    print("Check");
    print(widget.flight.legSchedules);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Flight 1",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: TColors.third,
                                    ),
                                  ),
                                  Text(
                                    widget.flight.airline,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'PIA',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: TColors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      children: [
                        Obx(
                          () => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: TColors.black.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(
                                color: TColors.black.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              '${piaController.selectedCurrency.value} ${finalPrice.value.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: TColors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  children: [
                    for (var i = 0; i < widget.flight.legSchedules.length; i++)
                      _buildFlightSegmentTimeline(i),
                  ],
                ),

                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CachedNetworkImage(
                        imageUrl:
                            'https://onerooftravel.net/assets/img/airline-logo/PIA-logo.png',
                        height: 32,
                        width: 32,
                        placeholder:
                            (context, url) => const SizedBox(
                              height: 24,
                              width: 24,
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                        errorWidget:
                            (context, url, error) => CachedNetworkImage(
                              imageUrl:
                                  'https://cdn-icons-png.flaticon.com/128/15700/15700374.png',
                              height: 24,
                              width: 24,
                              errorWidget:
                                  (context, url, error) =>
                                      const Icon(Icons.flight, size: 24),
                            ),
                        fit: BoxFit.contain,
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formatTime(widget.flight.departureTime),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.flight.from,
                            style: const TextStyle(
                              color: TColors.grey,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            formatDuration(
                              widget.flight.duration,
                            ), // This will show "3h 45m"
                            style: const TextStyle(
                              color: TColors.grey,
                              fontSize: 14,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 2,
                                  ),
                                  color: Colors.white,
                                ),
                              ),
                              Container(
                                height: 2,
                                width: MediaQuery.of(context).size.width * 0.4,
                                color: Colors.grey[300],
                              ),
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 2,
                                  ),
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            widget.flight.isNonStop
                                ? 'Nonstop'
                                : '${widget.flight.stops.length} stop(s)',
                            style: const TextStyle(
                              fontSize: 14,
                              color: TColors.grey,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            formatTime(widget.flight.arrivalTime),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.flight.to,
                            style: const TextStyle(
                              color: TColors.grey,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          InkWell(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
                if (isExpanded) {
                  _controller.forward();
                } else {
                  _controller.reverse();
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Left side - Flight Details
                  Row(
                    children: [
                      const Text(
                        'Flight Details',
                        style: TextStyle(
                          color: TColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AnimatedRotation(
                        duration: const Duration(milliseconds: 300),
                        turns: isExpanded ? 0.5 : 0,
                        child: const Icon(
                          Icons.keyboard_arrow_down,
                          color: TColors.primary,
                        ),
                      ),
                    ],
                  ),

                  // Center - Air Blue Container
                  Container(
                    width: 60,
                    // height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFF47965D),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'PIA',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  // Right side - Book Now Button
                  ElevatedButton(
                    onPressed: () {
                      piaController.handlePIAFlightSelection(widget.flight);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColors.secondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                    ),
                    child: const Text(
                      "Book Now",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFlightSegment(widget.flight),

                  _buildSectionCard(
                    title: 'Baggage Allowance',
                    content: formatBaggageInfo(),
                    icon: Icons.luggage,
                  ),

                  _buildSectionCard(
                    title: 'Policy',
                    content: _buildFareRules(),
                    icon: Icons.rule,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlightSegment(PIAFlight flight) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.flight_takeoff,
                size: 16,
                color: TColors.primary,
              ),
              const SizedBox(width: 8),
              const Text(
                'Segment 1',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: TColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              getCabinClassName(flight.cabinClass),
              style: const TextStyle(
                color: TColors.primary,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Airline Info
          Row(
            children: [
              CachedNetworkImage(
                imageUrl:
                    'https://onerooftravel.net/assets/img/airline-logo/PIA-logo.png',
                height: 24,
                width: 24,
                placeholder:
                    (context, url) => const SizedBox(
                      height: 24,
                      width: 24,
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                errorWidget:
                    (context, url, error) => const Icon(Icons.flight, size: 24),
              ),
              const SizedBox(width: 8),
              Text(
                '${flight.airline} ${flight.flightNumber}',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Departure and Arrival Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      flight.departureCity,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      'Terminal ${flight.departureTerminal}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      formatTime(flight.departureTime),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      formatFullDateTime(flight.departureTime),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  const Icon(Icons.flight, color: TColors.primary),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.restaurant_menu,
                          size: 12,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          getMealInfo(flight.mealCode),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      flight.arrivalCity,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      'Terminal ${flight.arrivalTerminal}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      formatTime(flight.arrivalTime),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      formatFullDateTime(flight.arrivalTime),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFlightSegmentTimeline(int segmentIndex) {
    final segment = widget.flight.legSchedules[segmentIndex];
    final isLast = segmentIndex == widget.flight.legSchedules.length - 1;

    // Extract departure and arrival info from PIA's data structure
    final departureTime =
        segment['departureDateTime'] ??
        segment['departure']['time'] ??
        widget.flight.departureTime;

    final arrivalTime =
        segment['arrivalDateTime'] ??
        segment['arrival']['time'] ??
        widget.flight.arrivalTime;

    final from =
        segment['departureAirport']?['locationCode'] ??
        segment['departure']['airport'] ??
        widget.flight.from;

    final to =
        segment['arrivalAirport']?['locationCode'] ??
        segment['arrival']['airport'] ??
        widget.flight.to;

    final duration = segment['journeyDuration'] ?? widget.flight.duration;

    return Column(
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CachedNetworkImage(
                imageUrl:
                    'https://onerooftravel.net/assets/img/airline-logo/PIA-logo.png',
                height: 32,
                width: 32,
                // ... existing image code ...
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatTime(departureTime),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    from,
                    style: const TextStyle(color: TColors.grey, fontSize: 15),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    formatDuration(duration),
                    style: const TextStyle(color: TColors.grey, fontSize: 14),
                  ),
                  // ... timeline visualization code ...
                  Text(
                    (segment['stopQuantity'] == '0' || widget.flight.isNonStop)
                        ? 'Nonstop'
                        : '${segment['stopQuantity'] ?? (segment['stops']?.length ?? widget.flight.stops.length)} stop(s)',
                    style: const TextStyle(fontSize: 14, color: TColors.grey),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatTime(arrivalTime),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    to,
                    style: const TextStyle(color: TColors.grey, fontSize: 15),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (!isLast)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Row(
              children: [
                const Icon(Icons.flight_land, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Layover: ${_calculateLayoverTime(segment, widget.flight.legSchedules[segmentIndex + 1])}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
      ],
    );
  }

  String _calculateLayoverTime(
    Map<String, dynamic> currentSegment,
    Map<String, dynamic> nextSegment,
  ) {
    try {
      final currentArrival = DateTime.parse(currentSegment['arrivalDateTime']);
      final nextDeparture = DateTime.parse(nextSegment['departureDateTime']);
      final difference = nextDeparture.difference(currentArrival);

      final hours = difference.inHours;
      final minutes = difference.inMinutes % 60;

      return '${hours}h ${minutes}m';
    } catch (e) {
      return 'N/A';
    }
  }

  Widget _buildSectionCard({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: TColors.primary),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  String formatDuration(String isoDuration) {
    // Remove 'PT' prefix
    String duration = isoDuration.replaceFirst('PT', '');

    String formattedDuration = '';

    // Extract hours
    RegExp hoursRegex = RegExp(r'(\d+)H');
    Match? hoursMatch = hoursRegex.firstMatch(duration);
    if (hoursMatch != null) {
      formattedDuration += '${hoursMatch.group(1)}h';
    }

    // Extract minutes
    RegExp minutesRegex = RegExp(r'(\d+)M');
    Match? minutesMatch = minutesRegex.firstMatch(duration);
    if (minutesMatch != null) {
      if (formattedDuration.isNotEmpty) {
        formattedDuration += ' '; // Add space between hours and minutes
      }
      formattedDuration += '${minutesMatch.group(1)}m';
    }

    return formattedDuration;
  }

  String _buildFareRules() {
    return '''
• ${widget.flight.isRefundable ? 'Refundable' : 'Non-refundable'} ticket
• Date change permitted with fee
• ${getMealInfo(widget.flight.mealCode)} included
• Free seat selection
• Cabin baggage allowed
• Check-in baggage: ${formatBaggageInfo()}''';
  }
}
