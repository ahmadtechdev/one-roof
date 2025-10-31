import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:oneroof/b2b/all_group_booking/all_group_booking_controller.dart';
import 'package:oneroof/b2b/all_group_booking/model.dart';
import 'package:oneroof/utility/colors.dart';
import 'package:oneroof/widgets/app_drawer.dart';

class AllGroupBooking extends StatelessWidget {
  AllGroupBooking({super.key});

  final AllGroupBookingController controller = Get.put(
    AllGroupBookingController(),
  );

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
          'Group Booking Reports',
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
                    onPressed: controller.fetchBookings,
                    tooltip: 'Refresh data',
                  ),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // Collapsible filter section
          _buildCollapsibleFilterSection(),
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
                  } else if (controller.filteredBookings.isEmpty) {
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

  Widget _buildCollapsibleFilterSection() {
    return _CollapsibleFilterSection(controller: controller);
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
                    'Total Bookings',
                    controller.filteredBookings.length,
                    const Color(0xFF6366F1),
                    Icons.group_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Confirmed',
                    controller.filteredBookings
                        .where((b) => b.status.toUpperCase() == 'CONFIRMED')
                        .length,
                    const Color(0xFF10B981),
                    Icons.check_circle_rounded,
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
                    controller.filteredBookings
                        .where((b) => b.status.toUpperCase() == 'HOLD')
                        .length,
                    const Color(0xFFF59E0B),
                    Icons.pause_circle_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildStatCard(
                    'Cancelled',
                    controller.filteredBookings
                        .where((b) => b.status.toUpperCase() == 'CANCELLED')
                        .length,
                    const Color(0xFFEF4444),
                    Icons.cancel_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'UAE',
                    controller.filteredBookings
                        .where((b) => b.country == 'UAE')
                        .length,
                    const Color(0xFF8B5CF6),
                    Icons.flag_rounded,
                      ),
                    ),
                  ],
              ),
            ],
          ),
      ),
    );
  }

  Widget _buildStatCard(String title, int count, Color color, IconData icon) {
    return Container(
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
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: controller.searchController,
        style: const TextStyle(color: TColors.text),
        decoration: InputDecoration(
          hintText: 'Search by booking ID, PNR, airline, country...',
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
              onPressed: controller.fetchBookings,
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
                Icons.group_rounded,
                color: TColors.primary,
                size: 60,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No group bookings found',
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
                'Try changing the date range or filter criteria',
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
            final booking = controller.filteredBookings[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildCollapsibleBookingCard(booking),
            );
          },
          childCount: controller.filteredBookings.length,
        ),
      ),
    );
  }

  Widget _buildCollapsibleBookingCard(BookingModel booking) {
    return _CollapsibleBookingCard(booking: booking);
  }

}

// Collapsible Filter Section Widget
class _CollapsibleFilterSection extends StatefulWidget {
  final AllGroupBookingController controller;

  const _CollapsibleFilterSection({required this.controller});

  @override
  State<_CollapsibleFilterSection> createState() =>
      _CollapsibleFilterSectionState();
}

class _CollapsibleFilterSectionState extends State<_CollapsibleFilterSection> {
  bool _isExpanded = false;

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
                    onTap: () => _selectFromDate(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDateSelector(
                    label: 'To',
                    date: widget.controller.toDate,
                    onTap: () => _selectToDate(),
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
                        // Dropdowns: Status and Group Category
                        Row(
                          children: [
                            Expanded(child: _buildStatusFilter()),
                            const SizedBox(width: 12),
                            Expanded(child: _buildGroupCategoryFilter()),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Filter button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: widget.controller.fetchBookings,
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
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: widget.controller.selectedStatus.value,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down, size: 16),
            style: const TextStyle(color: TColors.text, fontSize: 13),
            items: widget.controller.statusOptions.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: (value) => widget.controller.updateStatus(value!),
          ),
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
                      style: TextStyle(
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

  Widget _buildGroupCategoryFilter() {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: widget.controller.selectedGroupCategory.value,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down, size: 16),
            style: const TextStyle(color: TColors.text, fontSize: 14),
            items: widget.controller.groupCategories.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: (value) => widget.controller.updateGroupCategory(value!),
          ),
        ),
      ),
    );
  }

  Future<void> _selectFromDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.controller.fromDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: TColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      widget.controller.updateFromDate(picked);
    }
  }

  Future<void> _selectToDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.controller.toDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: TColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      widget.controller.updateToDate(picked);
    }
  }
}

// Collapsible Booking Card Widget
class _CollapsibleBookingCard extends StatefulWidget {
  final BookingModel booking;

  const _CollapsibleBookingCard({required this.booking});

  @override
  State<_CollapsibleBookingCard> createState() =>
      _CollapsibleBookingCardState();
}

class _CollapsibleBookingCardState extends State<_CollapsibleBookingCard> {
  bool _isExpanded = false;

  Color _getStatusColor() {
    switch (widget.booking.status.toUpperCase()) {
      case 'CONFIRMED':
        return const Color(0xFF10B981);
      case 'HOLD':
        return const Color(0xFFF59E0B);
      case 'CANCELLED':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color _getCountryColor(String country) {
    switch (country) {
      case 'UAE':
        return Colors.red;
      case 'KSA':
        return Colors.green;
      case 'Oman':
        return Colors.blue;
      case 'UK':
        return Colors.indigo;
      case 'UMRAH':
        return Colors.purple;
      default:
        return Colors.grey;
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
                            '#${widget.booking.id}',
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
                                Icons.group_rounded,
                                size: 14,
                                color: Colors.white.withOpacity(0.7),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  widget.booking.route,
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
                    // Country badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getCountryColor(widget.booking.country),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.booking.country,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
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
                            'Booking Codes',
                            '${widget.booking.bkf}\n${widget.booking.agt}',
                            Icons.confirmation_number_rounded,
                          ),
                          const Divider(height: 24),
                          _buildInfoRow(
                            'Airline',
                            widget.booking.airline,
                            Icons.airlines_rounded,
                          ),
                          const Divider(height: 24),
                          _buildInfoRow(
                            'Flight Date',
                            DateFormat('EEE, dd MMM yyyy')
                                .format(widget.booking.flightDate),
                            Icons.flight_takeoff_rounded,
                          ),
                          const Divider(height: 24),
                          _buildInfoRow(
                            'Created',
                            DateFormat('dd MMM yyyy HH:mm')
                                .format(widget.booking.createdDate),
                            Icons.calendar_today_rounded,
                          ),
                          const Divider(height: 24),
                          _buildInfoRow(
                    'Total Price',
                            'PKR ${NumberFormat('#,###').format(widget.booking.price)} x ${widget.booking.passengerStatus.holdTotal + widget.booking.passengerStatus.confirmTotal + widget.booking.passengerStatus.cancelledTotal}',
                            Icons.payments_rounded,
                            isHighlighted: true,
                          ),
                          const SizedBox(height: 16),
                          // Passenger status table
                          _buildPassengerStatusTable(widget.booking.passengerStatus),
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

  Widget _buildPassengerStatusTable(PassengerStatus passengerStatus) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Table(
          defaultColumnWidth: const IntrinsicColumnWidth(),
          border: TableBorder.all(color: Colors.grey.shade300, width: 1),
          children: [
            // Header row
            TableRow(
              decoration: BoxDecoration(color: Colors.grey.shade100),
              children: [
                _buildTableCell('Status', const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                _buildTableCell('Adults', const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                _buildTableCell('Child', const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                _buildTableCell('Infant', const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                _buildTableCell('Total', const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
            // Hold row
            TableRow(
              children: [
                _buildTableCell('Hold', const TextStyle(fontSize: 12), textColor: Colors.orange),
                _buildTableCell('${passengerStatus.holdAdults}', const TextStyle(fontSize: 12)),
                _buildTableCell('${passengerStatus.holdChild}', const TextStyle(fontSize: 12)),
                _buildTableCell('${passengerStatus.holdInfant}', const TextStyle(fontSize: 12)),
                _buildTableCell('${passengerStatus.holdTotal}', const TextStyle(fontSize: 12)),
              ],
            ),
            // Confirm row
            TableRow(
              children: [
                _buildTableCell('Confirm', const TextStyle(fontSize: 12), textColor: Colors.green),
                _buildTableCell('${passengerStatus.confirmAdults}', const TextStyle(fontSize: 12)),
                _buildTableCell('${passengerStatus.confirmChild}', const TextStyle(fontSize: 12)),
                _buildTableCell('${passengerStatus.confirmInfant}', const TextStyle(fontSize: 12)),
                _buildTableCell('${passengerStatus.confirmTotal}', const TextStyle(fontSize: 12)),
              ],
            ),
            // Cancelled row
            TableRow(
              children: [
                _buildTableCell('Cancelled', const TextStyle(fontSize: 12), textColor: Colors.red),
                _buildTableCell('${passengerStatus.cancelledAdults}', const TextStyle(fontSize: 12)),
                _buildTableCell('${passengerStatus.cancelledChild}', const TextStyle(fontSize: 12)),
                _buildTableCell('${passengerStatus.cancelledInfant}', const TextStyle(fontSize: 12)),
                _buildTableCell('${passengerStatus.cancelledTotal}', const TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableCell(String text, TextStyle style, {Color? textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(
        text,
        style: textColor != null ? style.copyWith(color: textColor) : style,
        textAlign: TextAlign.center,
      ),
    );
  }
}
