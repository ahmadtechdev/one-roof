// all_flight_booking_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:oneroof/b2b/all_flight_booking/all_flight_booking_controler.dart';
import 'package:oneroof/b2b/all_flight_booking/model.dart';
import 'package:oneroof/utility/colors.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:oneroof/widgets/app_drawer.dart';

class AllFlightBookingScreen extends StatefulWidget {
  AllFlightBookingScreen({super.key});

  @override
  State<AllFlightBookingScreen> createState() => _AllFlightBookingScreenState();
}

class _AllFlightBookingScreenState extends State<AllFlightBookingScreen> {
  final AllFlightBookingController controller = Get.put(AllFlightBookingController());
  String? _selectedStatusFilter; // null => all
  String _selectedAirline = 'All Airlines';

  List<BookingModel> _computeVisibleBookings() {
    final base = controller.filteredBookings;
    final statusFiltered = _selectedStatusFilter == null
        ? base
        : base.where((b) => b.status.toLowerCase() == _selectedStatusFilter!.toLowerCase()).toList();
    final query = controller.searchController.text.trim().toLowerCase();
    // Apply airline filter
    final airlineFiltered = _selectedAirline == 'All Airlines'
        ? statusFiltered
        : statusFiltered.where((b) => b.supplier.toLowerCase() == _selectedAirline.toLowerCase()).toList();
    if (query.isEmpty) return airlineFiltered;
    return airlineFiltered.where((b) {
      final supplier = b.supplier.toLowerCase();
      return supplier.contains(query);
    }).toList();
  }

  void _setStatusFilter(String? status) {
    setState(() {
      _selectedStatusFilter = status;
    });
  }

  void _setAirlineFilter(String airline) {
    setState(() {
      _selectedAirline = airline;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: TColors.background4,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
            tooltip: 'Menu',
          ),
        ),
        title: const Text(
          'All Flights Booking',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          Obx(
            () => controller.isLoading.value
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.refresh_rounded),
                    onPressed: controller.loadBookings,
                    tooltip: 'Refresh data',
                  ),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // Collapsible filter section
          _CollapsibleFilterSection(
            controller: controller,
            selectedStatus: _selectedStatusFilter,
            onStatusChanged: _setStatusFilter,
            selectedAirline: _selectedAirline,
            onAirlineChanged: _setAirlineFilter,
          ),
          // Scrollable content area with stats and search
          Expanded(
            child: CustomScrollView(
              slivers: [
                // Stat cards section
                SliverToBoxAdapter(
                  child: _buildStatCards(),
                ),
                // Search bar section
                SliverToBoxAdapter(
                  child: _buildSearchBar(),
                ),
                // Booking cards section
                Obx(() {
                  if (controller.isLoading.value) {
                    return const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else if (controller.hasError.value) {
                    return SliverFillRemaining(
                      child: _buildErrorWidget(),
                    );
                  } else if (_computeVisibleBookings().isEmpty) {
                    return SliverFillRemaining(
                      child: _buildEmptyStateWidget(),
                    );
                  } else {
                    return _buildBookingCards();
                  }
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: TColors.background4,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildDateSelector(
              label: 'From',
              date: controller.fromDate,
              onTap: () => controller.selectFromDate(Get.context!),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildDateSelector(
              label: 'To',
              date: controller.toDate,
              onTap: () => controller.selectToDate(Get.context!),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector({
    required String label,
    required Rx<DateTime> date,
    required VoidCallback onTap,
  }) {
    return Obx(
      () => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 16,
                color: TColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 10,
                        color: TColors.grey.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('dd/MM/yyyy').format(date.value),
                      style: TextStyle(
                        color: TColors.text,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCards() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // First row - 2 cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total',
                    controller.totalBookings.value,
                    const Color(0xFF6366F1),
                    Icons.flight_takeoff_rounded,
                    onTap: () => _setStatusFilter(null),
                    isSelected: _selectedStatusFilter == null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Ticketed',
                    controller.confirmedBookings.value,
                    const Color(0xFF10B981),
                    Icons.check_circle_rounded,
                    onTap: () => _setStatusFilter('Confirmed'),
                    isSelected: _selectedStatusFilter == 'Confirmed',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Second row - 3 cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'On Hold',
                    controller.onHoldBookings.value,
                    const Color(0xFFF59E0B),
                    Icons.pause_circle_rounded,
                    onTap: () => _setStatusFilter('On Hold'),
                    isSelected: _selectedStatusFilter == 'On Hold',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Cancelled',
                    controller.cancelledBookings.value,
                    const Color(0xFFEF4444),
                    Icons.cancel_rounded,
                    onTap: () => _setStatusFilter('Cancelled'),
                    isSelected: _selectedStatusFilter == 'Cancelled',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Error',
                    controller.errorBookings.value,
                    const Color(0xFF6B7280),
                    Icons.error_outline_rounded,
                    onTap: () => _setStatusFilter('Error'),
                    isSelected: _selectedStatusFilter == 'Error',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, int count, Color color, IconData icon, {VoidCallback? onTap, bool isSelected = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: isSelected
            ? Border.all(color: color, width: 1)
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: TColors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 18,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: controller.searchController,
        style: const TextStyle(color: TColors.text),
        decoration: InputDecoration(
          hintText: 'Search by booking ID, PNR, passenger, airline...',
          hintStyle: TextStyle(
            color: TColors.grey.withOpacity(0.6),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: TColors.primary,
            size: 20,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.grey.withOpacity(0.2),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.grey.withOpacity(0.2),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: TColors.primary,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onChanged: (_) {
          // trigger UI refresh to apply local supplier filter
          setState(() {});
        },
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Colors.red,
                size: 60,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Error loading bookings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: TColors.text,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                controller.errorMessage.value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: TColors.grey,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: controller.retryLoading,
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              label: const Text(
                'Try Again',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyStateWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: TColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.flight_takeoff_rounded,
                color: TColors.primary,
                size: 60,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No flight bookings found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: TColors.text,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Try changing the date range or search criteria',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: TColors.grey,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCards() {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final visible = _computeVisibleBookings();
            final booking = visible[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildCollapsibleBookingCard(booking),
            );
          },
          childCount: _computeVisibleBookings().length,
        ),
      ),
    );
  }

  Widget _buildCollapsibleBookingCard(BookingModel booking) {
    return _CollapsibleBookingCard(booking: booking, controller: controller);
  }
}

class _CollapsibleBookingCard extends StatefulWidget {
  final BookingModel booking;
  final AllFlightBookingController controller;

  const _CollapsibleBookingCard({
    required this.booking,
    required this.controller,
  });

  @override
  State<_CollapsibleBookingCard> createState() =>
      _CollapsibleBookingCardState();
}

// Collapsible Filter Section Widget (like hotel bookings)
class _CollapsibleFilterSection extends StatefulWidget {
  final AllFlightBookingController controller;
  final String? selectedStatus;
  final void Function(String? value) onStatusChanged;
  final String selectedAirline;
  final void Function(String value) onAirlineChanged;

  const _CollapsibleFilterSection({
    required this.controller,
    required this.selectedStatus,
    required this.onStatusChanged,
    required this.selectedAirline,
    required this.onAirlineChanged,
  });

  @override
  State<_CollapsibleFilterSection> createState() => _CollapsibleFilterSectionState();
}

class _CollapsibleFilterSectionState extends State<_CollapsibleFilterSection> {
  bool _isExpanded = false;

  final List<String> _statusOptions = const [
    'All',
    'Confirmed',
    'On Hold',
    'Cancelled',
    'Error',
  ];

  final List<String> _airlineOptions = const [
    'All Airlines',
    'PIA',
    'AIRBLUE',
    'FLY JINNAH',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TColors.background4,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Always visible date filters
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: _buildDateSelector(
                    label: 'From',
                    date: widget.controller.fromDate,
                    onTap: () => widget.controller.selectFromDate(Get.context!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDateSelector(
                    label: 'To',
                    date: widget.controller.toDate,
                    onTap: () => widget.controller.selectToDate(Get.context!),
                  ),
                ),
                const SizedBox(width: 12),
                // Expand/collapse button
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.filter_list_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Expandable filters
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _isExpanded
                ? Container(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      children: [
                        const Divider(color: Colors.white24),
                        const SizedBox(height: 12),
                        // Dropdowns: Status and Airline
                        Row(
                          children: [
                            Expanded(child: _buildStatusFilter()),
                            const SizedBox(width: 12),
                            Expanded(child: _buildAirlineFilter()),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Filter button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await widget.controller.loadBookings();
                              if (mounted) setState(() {});
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: TColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: const Icon(Icons.search_rounded, color: Colors.white),
                            label: const Text(
                              'Apply Filters',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
    final current = widget.selectedStatus;
    final display = current ?? 'All';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: display,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 16),
          style: const TextStyle(color: TColors.text, fontSize: 13),
          items: _statusOptions.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: (value) {
            if (value == null) return;
            widget.onStatusChanged(value == 'All' ? null : value);
          },
        ),
      ),
    );
  }

  Widget _buildAirlineFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: widget.selectedAirline,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 16),
          style: const TextStyle(color: TColors.text, fontSize: 14),
          items: _airlineOptions.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: (value) {
            if (value == null) return;
            widget.onAirlineChanged(value);
          },
        ),
      ),
    );
  }

  Widget _buildDateSelector({
    required String label,
    required Rx<DateTime> date,
    required VoidCallback onTap,
  }) {
    return Obx(
      () => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 16,
                color: TColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 10,
                        color: TColors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('dd/MM/yyyy').format(date.value),
                      style: const TextStyle(
                        color: TColors.text,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CollapsibleBookingCardState extends State<_CollapsibleBookingCard> {
  bool _isExpanded = false;

  Color _getStatusColor() {
    switch (widget.booking.status) {
      case 'Confirmed':
        return const Color(0xFF10B981);
      case 'On Hold':
      case 'On Request':
        return const Color(0xFFF59E0B);
      case 'Cancelled':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            // Header - always visible
            InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      TColors.background4,
                      TColors.background4.withOpacity(0.9),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    // Booking ID and basic info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.booking.bookingId,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.flight_rounded,
                                size: 14,
                                color: Colors.white.withOpacity(0.7),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  widget.booking.trip,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.booking.status,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Expand/collapse icon
                    Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
            // Expanded content
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _isExpanded
                  ? Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoRow(
                      'Booking Date',
                      DateFormat('E, dd MMM yyyy HH:mm')
                          .format(widget.booking.creationDate),
                      Icons.calendar_today_rounded,
                    ),
                    const Divider(height: 24),
                    _buildInfoRow(
                      'PNR',
                      widget.booking.pnr,
                      Icons.confirmation_number_rounded,
                    ),
                    const Divider(height: 24),
                    _buildInfoRow(
                      'Airline',
                      widget.booking.supplier,
                      Icons.airlines_rounded,
                    ),
                    const Divider(height: 24),
                    _buildInfoRow(
                      'Passenger',
                      widget.booking.passengerNames,
                      Icons.person_rounded,
                    ),
                    const Divider(height: 24),
                    _buildInfoRow(
                      'Travel Date',
                      DateFormat('E, dd MMM yyyy')
                          .format(widget.booking.departureDate),
                      Icons.flight_takeoff_rounded,
                    ),
                    const Divider(height: 24),
                    _buildInfoRow(
                      'Total Price',
                      '${widget.booking.currency.isNotEmpty ? widget.booking.currency : "PKR"} ${widget.booking.totalSell.toStringAsFixed(0)}',
                      Icons.payments_rounded,
                      isHighlighted: true,
                    ),
                    if (widget.booking.deadlineTime != null) ...[
                      const Divider(height: 24),
                      _buildInfoRow(
                        'Deadline',
                        DateFormat('E, dd MMM yyyy HH:mm')
                            .format(widget.booking.deadlineTime!),
                        Icons.access_time_rounded,
                        isHighlighted: true,
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => widget.controller
                                .viewBookingDetails(widget.booking),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                              side: BorderSide(color: TColors.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: Icon(
                              Icons.visibility_rounded,
                              color: TColors.primary,
                              size: 18,
                            ),
                            label: Text(
                              'View',
                              style: TextStyle(
                                color: TColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => widget.controller.printTicket(
                              widget.booking,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: TColors.primary,
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: const Icon(
                              Icons.print_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            label: const Text(
                              'Print',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon, {
    bool isHighlighted = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: isHighlighted ? TColors.primary : TColors.grey,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: TColors.grey,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
                  color: isHighlighted ? TColors.primary : TColors.text,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
// flight_pdf_generator.dart

class FlightPdfGenerator {
  // Generate and print a PDF for the given booking
  static Future<void> generateAndPrintPdf(BookingModel booking) async {
    final pdf = await generatePdf(booking);
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf);
  }

  // Generate PDF document for the booking
  static Future<Uint8List> generatePdf(BookingModel booking) async {
    // Create a PDF document
    final pdf = pw.Document();

    // Use default fonts
    final font = pw.Font.helvetica();
    final fontBold = pw.Font.helveticaBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        build: (pw.Context context) {
          return [
            _buildHeader(booking, font, fontBold),
            _buildDetailsTable(booking, font, fontBold),
            _buildPassengerDetails(booking, font, fontBold),
            _buildNoticeSection(font, fontBold),
            _buildRulesSection(font, fontBold),
          ];
        },
      ),
    );

    return pdf.save();
  }

  // Build the header section of the PDF
  static pw.Widget _buildHeader(
    BookingModel booking,
    pw.Font font,
    pw.Font fontBold,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Journey Online',
              style: pw.TextStyle(font: fontBold, fontSize: 18),
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'Pakistan',
                  style: pw.TextStyle(font: font, fontSize: 12),
                ),
                pw.Text(
                  '+92 333733 5222',
                  style: pw.TextStyle(font: font, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 20),
        pw.Text(
          'Itinerary Receipt',
          style: pw.TextStyle(font: fontBold, fontSize: 16),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          'Below are the details of your electronic ticket. Note: All timings are local',
          style: pw.TextStyle(font: font, fontSize: 10),
        ),
        pw.SizedBox(height: 10),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.SizedBox(),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'Booking Reference:',
                  style: pw.TextStyle(font: font, fontSize: 12),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'Agency PNR:',
                  style: pw.TextStyle(font: font, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Divider(color: PdfColors.grey700),
      ],
    );
  }

  // Build the flight details table section
  static pw.Widget _buildDetailsTable(
    BookingModel booking,
    pw.Font font,
    pw.Font fontBold,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 10),
        pw.Text(
          'FLIGHT INFORMATION',
          style: pw.TextStyle(font: fontBold, fontSize: 12),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          columnWidths: {
            0: const pw.FlexColumnWidth(1),
            1: const pw.FlexColumnWidth(2),
            2: const pw.FlexColumnWidth(2),
            3: const pw.FlexColumnWidth(1.5),
          },
          children: [
            // Table header
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                _headerCell('TO - LTO', font),
                _headerCell('FROM', font),
                _headerCell('TO', font),
                _headerCell('STATUS', font),
              ],
            ),
            // Flight details
            pw.TableRow(
              children: [
                _contentCell('', font),
                _contentCell(
                  '${booking.tripSector.split("-to-")[0]}\n(${_getAirportCode(booking.tripSector.split("-to-")[0])})',
                  font,
                ),
                _contentCell(
                  '${booking.tripSector.split("-to-")[1]}\n(${_getAirportCode(booking.tripSector.split("-to-")[1])})',
                  font,
                ),
                _contentCell(
                  'Status: ${booking.status}\nClass: Y (E)\nPNR: ${booking.pnr}',
                  font,
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 30),
      ],
    );
  }

  // Helper function to get airport code (mocked for demo)
  static String _getAirportCode(String cityName) {
    final codes = {
      'Dubai': 'DXB',
      'Quaid e Azam International': 'KHI',
      'Lahore': 'LHE',
      'Islamabad': 'ISB',
      'Karachi': 'KHI',
    };
    return codes[cityName] ?? 'XXX';
  }

  // Build the passenger details section
  static pw.Widget _buildPassengerDetails(
    BookingModel booking,
    pw.Font font,
    pw.Font fontBold,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'PASSENGER & TICKET DETAILS',
          style: pw.TextStyle(font: fontBold, fontSize: 12),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          columnWidths: {
            0: const pw.FlexColumnWidth(2),
            1: const pw.FlexColumnWidth(1.5),
            2: const pw.FlexColumnWidth(1.5),
          },
          children: [
            // Table header
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                _headerCell('TRAVELLER NAME', font),
                _headerCell('FREQUENT FLYER', font),
                _headerCell('TICKET NO.', font),
              ],
            ),
            // Passenger details
            pw.TableRow(
              children: [
                _contentCell(booking.passengerNames, font),
                _contentCell('-', font),
                _contentCell('-', font),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 30),
      ],
    );
  }

  // Build the notice section
  static pw.Widget _buildNoticeSection(pw.Font font, pw.Font fontBold) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Notice', style: pw.TextStyle(font: fontBold, fontSize: 12)),
        pw.SizedBox(height: 5),
        pw.Text(
          '1. Refund Policy All Refunds are governed by the rule published by the airline which is self explanatory and shown in the search results page.',
          style: pw.TextStyle(font: font, fontSize: 10),
        ),
        pw.SizedBox(height: 20),
      ],
    );
  }

  // Build the rules section
  static pw.Widget _buildRulesSection(pw.Font font, pw.Font fontBold) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Rules', style: pw.TextStyle(font: fontBold, fontSize: 12)),
        pw.SizedBox(height: 5),
        pw.Text(
          '1. Please Report Airline Check In Counter 4 Hour Before Flight Departure.',
          style: pw.TextStyle(font: font, fontSize: 10),
        ),
        pw.SizedBox(height: 3),
        pw.Text(
          '2. Please Reconfirm the Ticket Before 48 Hour of Flight Departure.',
          style: pw.TextStyle(font: font, fontSize: 10),
        ),
        pw.SizedBox(height: 3),
        pw.Text(
          '3. All Visa and Travel Documents are Traveler Own Responsibility.',
          style: pw.TextStyle(font: font, fontSize: 10),
        ),
        pw.SizedBox(height: 3),
        pw.Text(
          '4. Please Check in with all your Essential Travel Documents.',
          style: pw.TextStyle(font: font, fontSize: 10),
        ),
        pw.SizedBox(height: 3),
        pw.Text(
          '5. All NON-PK (market / LCC tickets are NON-Refundable / NON-Changeable.',
          style: pw.TextStyle(font: font, fontSize: 10),
        ),
      ],
    );
  }

  // Helper method to create header cells
  static pw.Widget _headerCell(String text, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(text, style: pw.TextStyle(font: font, fontSize: 10)),
    );
  }

  // Helper method to create content cells
  static pw.Widget _contentCell(String text, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(text, style: pw.TextStyle(font: font, fontSize: 10)),
    );
  }
}
