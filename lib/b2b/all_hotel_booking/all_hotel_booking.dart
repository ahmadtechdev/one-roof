import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:oneroof/b2b/all_hotel_booking/all_hotel_booking_controller.dart';
import 'package:oneroof/b2b/all_hotel_booking/model.dart';
import 'package:oneroof/utility/colors.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:oneroof/widgets/app_drawer.dart';

class AllHotelBooking extends StatelessWidget {
  final AllHotelBookingController bookingController = Get.put(
    AllHotelBookingController(),
  );

  AllHotelBooking({super.key});
  void _handlePrintAction(HotelBookingModel booking) async {
    try {
      final bookingData = await bookingController.getBookingDataForPdf(
        booking.bookingNumber,
      );

      // Create a PDF generator instance (you'll need to create this class)
      final pdfGenerator = HotelBookingPdfGenerator();
      final pdfBytes = await pdfGenerator.generatePdf(bookingData);

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
        name: 'Booking_Voucher_${booking.bookingNumber}',
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to generate PDF: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
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
          'Hotel Bookings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          Obx(
            () => bookingController.isLoading.value
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
                    onPressed: bookingController.fetchHotelBookings,
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
                  if (bookingController.isLoading.value) {
                    return const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else if (bookingController.errorMessage.value.isNotEmpty) {
                    return SliverFillRemaining(
                      child: _buildErrorWidget(),
                    );
                  } else if (bookingController.filteredBookings.isEmpty) {
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
    return _CollapsibleFilterSection(controller: bookingController);
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
                    bookingController.filteredBookings.length,
                    const Color(0xFF6366F1),
                    Icons.hotel_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Confirmed',
                    bookingController.filteredBookings
                        .where((b) => b.status.toLowerCase() == 'confirmed')
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
                    'On Request',
                    bookingController.filteredBookings
                        .where((b) => b.status.toLowerCase() == 'on request')
                        .length,
                    const Color(0xFFF59E0B),
                    Icons.pending_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Cancelled',
                    bookingController.filteredBookings
                        .where((b) => b.status.toLowerCase() == 'cancelled')
                        .length,
                    const Color(0xFFEF4444),
                    Icons.cancel_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Pending',
                    bookingController.filteredBookings
                        .where((b) => b.status.toLowerCase() == 'pending')
                        .length,
                    const Color(0xFF8B5CF6),
                    Icons.schedule_rounded,
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
        controller: bookingController.searchController,
        style: const TextStyle(color: TColors.text),
        decoration: InputDecoration(
          hintText: 'Search by booking number, hotel, destination, guest...',
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
                bookingController.errorMessage.value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: TColors.grey,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: bookingController.fetchHotelBookings,
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
                Icons.hotel_rounded,
                color: TColors.primary,
                size: 60,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No hotel bookings found',
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
            final booking = bookingController.filteredBookings[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildCollapsibleBookingCard(booking),
            );
          },
          childCount: bookingController.filteredBookings.length,
        ),
      ),
    );
  }

  Widget _buildCollapsibleBookingCard(HotelBookingModel booking) {
    return _CollapsibleBookingCard(booking: booking, controller: bookingController);
  }

}

// Collapsible Filter Section Widget
class _CollapsibleFilterSection extends StatefulWidget {
  final AllHotelBookingController controller;

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
                        // Dropdowns: Status and Destination
                        Row(
                          children: [
                            Expanded(child: _buildStatusFilter()),
                            const SizedBox(width: 12),
                            Expanded(child: _buildDestinationFilter()),
                          ],
                         ),
                        const SizedBox(height: 16),
                        // Filter button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: widget.controller.fetchHotelBookings,
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

  Widget _buildDestinationFilter() {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: widget.controller.selectedDestination.value,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down, size: 16),
            style: const TextStyle(color: TColors.text, fontSize: 14),
            items: widget.controller.destinationOptions.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: (value) => widget.controller.updateDestination(value!),
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
      widget.controller.updateDateRange(picked, widget.controller.toDate.value);
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
      widget.controller.updateDateRange(widget.controller.fromDate.value, picked);
    }
  }
}

// Collapsible Booking Card Widget
class _CollapsibleBookingCard extends StatefulWidget {
  final HotelBookingModel booking;
  final AllHotelBookingController controller;

  const _CollapsibleBookingCard({
    required this.booking,
    required this.controller,
  });

  @override
  State<_CollapsibleBookingCard> createState() =>
      _CollapsibleBookingCardState();
}

class _CollapsibleBookingCardState extends State<_CollapsibleBookingCard> {
  bool _isExpanded = false;

  Color _getStatusColor() {
    switch (widget.booking.status.toLowerCase()) {
      case 'confirmed':
        return const Color(0xFF10B981);
      case 'on request':
        return const Color(0xFFF59E0B);
      case 'cancelled':
        return const Color(0xFFEF4444);
      case 'pending':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color _getPortalColor() {
    String portalCode = widget.booking.bookingNumber.split('-')[0];
    switch (portalCode) {
      case 'ONETRVL':
        return Colors.blue;
      case 'TOCBK':
        return Colors.teal;
      case 'TDBK':
        return Colors.red;
      default:
        return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final portalColor = _getPortalColor();

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
                      portalColor.withOpacity(0.1),
                      portalColor.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    // Serial number and booking info
                    CircleAvatar(
                      backgroundColor: portalColor,
                      radius: 16,
                      child: Text(
                        widget.booking.serialNumber,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.booking.bookingNumber,
                            style: const TextStyle(
                              color: TColors.text,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.hotel_rounded,
                                size: 14,
                                color: TColors.grey,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  widget.booking.hotel,
                                  style: TextStyle(
                                    color: TColors.grey,
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
                      color: TColors.grey,
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
                            widget.booking.date,
                            Icons.calendar_today_rounded,
                          ),
                          const Divider(height: 24),
                          _buildInfoRow(
                            'Booker',
                            widget.booking.bookerName,
                            Icons.person_rounded,
                          ),
                          const Divider(height: 24),
                          _buildInfoRow(
                            'Guest',
                            widget.booking.guestName,
                            Icons.people_rounded,
                          ),
                          const Divider(height: 24),
                          _buildInfoRow(
                            'Destination',
                            widget.booking.destination,
                            Icons.location_on_rounded,
                          ),
                          const Divider(height: 24),
                          _buildInfoRow(
                            'Check-in/Check-out',
                            widget.booking.checkinCheckout,
                            Icons.calendar_month_rounded,
                          ),
                          const Divider(height: 24),
                          _buildInfoRow(
                            'Price',
                            widget.booking.price,
                            Icons.payments_rounded,
                            isHighlighted: true,
                          ),
                          const Divider(height: 24),
                          _buildInfoRow(
                            'Cancellation',
                            widget.booking.cancellationDeadline,
                            Icons.event_busy_rounded,
                            valueColor: widget.booking.cancellationDeadline
                                    .contains("Non-Refundable")
                                ? Colors.red
                                : null,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _handlePrintAction(widget.booking),
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
                                    'Print Voucher',
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
    Color? valueColor,
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
                  color: valueColor ?? (isHighlighted ? TColors.primary : TColors.text),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handlePrintAction(HotelBookingModel booking) async {
    try {
      final bookingData = await widget.controller.getBookingDataForPdf(
        booking.bookingNumber,
      );

      final pdfGenerator = HotelBookingPdfGenerator();
      final pdfBytes = await pdfGenerator.generatePdf(bookingData);

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
        name: 'Booking_Voucher_${booking.bookingNumber}',
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to generate PDF: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}

class HotelBookingPdfGenerator {
  Future<Uint8List> generatePdf(Map<String, dynamic> bookingData) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(bookingData),
            pw.SizedBox(height: 20),
            _buildHotelInformation(bookingData),
            pw.SizedBox(height: 20),
            _buildGuestInformation(bookingData),
            pw.SizedBox(height: 20),
            _buildRoomDetailsTable(bookingData),
            pw.SizedBox(height: 20),
            _buildBookingPolicy(),
            pw.SizedBox(height: 20),
            _buildRefundPolicy(),
            pw.SizedBox(height: 20),
            _buildImportantNote(),
          ];
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader(Map<String, dynamic> bookingData) {
    return pw.Container(
      padding: pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 1, color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Stayinhotels.ae',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Container(
                padding: pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  color: PdfColors.green50,
                  borderRadius: pw.BorderRadius.circular(5),
                ),
                child: pw.Text(
                  bookingData['status'] ?? 'CONFIRMED',
                  style: pw.TextStyle(
                    color: PdfColors.green800,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Booking No#: ${bookingData['bookingNumber']}',
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.Text(
                'Support Contact No:\n+923219667909',
                style: pw.TextStyle(fontSize: 12),
                textAlign: pw.TextAlign.right,
              ),
            ],
          ),
          pw.Divider(),
          pw.Text(
            'HOTEL VOUCHER',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  pw.Widget _buildHotelInformation(Map<String, dynamic> bookingData) {
    return pw.Container(
      padding: pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 1, color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'HOTEL INFORMATION',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              pw.Expanded(
                flex: 2,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'HOTEL NAME',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.Text(
                      bookingData['hotelName'] ?? 'Unknown Hotel',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      'LOCATION',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.Text(
                      bookingData['destination'] ?? 'Unknown Location',
                      style: pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              pw.Expanded(
                flex: 1,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'SPECIAL REQUESTS',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.Text(
                      bookingData['specialRequests'] ?? 'None',
                      style: pw.TextStyle(fontSize: 12),
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

  pw.Widget _buildGuestInformation(Map<String, dynamic> bookingData) {
    // Parse dates for better formatting
    DateTime checkInDate;
    DateTime checkOutDate;
    try {
      checkInDate = DateTime.parse(bookingData['checkInDate']);
      checkOutDate = DateTime.parse(bookingData['checkOutDate']);
    } catch (e) {
      checkInDate = DateTime.now();
      checkOutDate = DateTime.now().add(Duration(days: 1));
    }

    final formattedCheckIn = DateFormat('dd MMM yyyy').format(checkInDate);
    final formattedCheckOut = DateFormat('dd MMM yyyy').format(checkOutDate);

    return pw.Container(
      padding: pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 1, color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'RESERVATION INFORMATION',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'LEAD GUEST',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.Text(
                      bookingData['bookerName'] ?? 'Unknown',
                      style: pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'CHECK-IN',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.Text(
                      formattedCheckIn,
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'CHECK-OUT',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.Text(
                      formattedCheckOut,
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'ROOMS',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.Text(
                      bookingData['rooms'] ?? '1',
                      style: pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'NIGHTS',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.Text(
                      bookingData['nights'] ?? '1',
                      style: pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'PRICE',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.Text(
                      bookingData['price'] ?? 'N/A',
                      style: pw.TextStyle(fontSize: 12),
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

  pw.Widget _buildRoomDetailsTable(Map<String, dynamic> bookingData) {
    final List<dynamic> guestDetails = bookingData['guestDetails'] ?? [];

    // Group guests by room number
    Map<String, List<Map<String, dynamic>>> guestsByRoom = {};
    for (var guest in guestDetails) {
      String roomNo = guest['od_rno']?.toString() ?? '1';
      if (!guestsByRoom.containsKey(roomNo)) {
        guestsByRoom[roomNo] = [];
      }
      guestsByRoom[roomNo]!.add(guest);
    }

    return pw.Container(
      padding: pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 1, color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'ROOM DETAILS',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            columnWidths: {
              0: pw.FlexColumnWidth(1),
              1: pw.FlexColumnWidth(3),
              2: pw.FlexColumnWidth(3),
              3: pw.FlexColumnWidth(1),
              4: pw.FlexColumnWidth(1),
            },
            children: [
              // Header
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _buildTableCell('Room No.', isHeader: true),
                  _buildTableCell('Room Type / Board Basis', isHeader: true),
                  _buildTableCell('Guest Name', isHeader: true),
                  _buildTableCell('Adults', isHeader: true),
                  _buildTableCell('Children', isHeader: true),
                ],
              ),
              // Data rows
              ...guestsByRoom.entries.map((entry) {
                String roomNo = entry.key;
                List<Map<String, dynamic>> roomGuests = entry.value;

                // Count adults and children in this room
                int adultCount = 0;
                int childCount = 0;

                List<String> guestNames = [];

                for (var guest in roomGuests) {
                  String guestFor = guest['od_gfor']?.toString() ?? '';
                  String guestTitle = guest['od_gtitle']?.toString() ?? '';
                  String firstName = guest['od_gfname']?.toString() ?? '';
                  String lastName = guest['od_glname']?.toString() ?? '';

                  guestNames.add('$guestTitle $firstName $lastName');

                  if (guestFor.toLowerCase().contains('adult')) {
                    adultCount++;
                  } else if (guestFor.toLowerCase().contains('child')) {
                    childCount++;
                  }
                }

                return pw.TableRow(
                  children: [
                    _buildTableCell(roomNo),
                    _buildTableCell('Premium Room / Bed & Breakfast'),
                    _buildTableCell(guestNames.join(', ')),
                    _buildTableCell(adultCount.toString()),
                    _buildTableCell(childCount.toString()),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildBookingPolicy() {
    return pw.Container(
      padding: pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 1, color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Booking Policy',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            '• The usual check-in time is 12:00-14:00 PM (this may vary).',
            style: pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '• Rooms may not be available for early check-in unless requested.',
            style: pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '• Hotel reservation may be cancelled automatically after 18:00 hours if hotel is not informed about the appointment time of the arrival.',
            style: pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            '• The total cost is between 10-12.00 hours between the high-way (non-toll) & the toll road with different destinations.',
            style: pw.TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildRefundPolicy() {
    return pw.Container(
      padding: pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 1, color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Booking Refund Policy',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'Booking payable as per reservation details. Please collect all extras directly from (sleep in) departure. All matters issued are on the condition that all persons acknowledge that in person to taking part must be made, as people for which we shall not be held preliminary. Some may apply, delay or misconnection caused to passenger as a result of any such arrangements. We will not accept any responsibility for additional expenses due to tax changes or delay in air, road, rail, sea or indeed any form of transport.',
            style: pw.TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildImportantNote() {
    return pw.Container(
      padding: pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.pink50,
        border: pw.Border.all(width: 1, color: PdfColors.pink100),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'IMPORTANT NOTE',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.red900,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'Check your Reservation details carefully and inform us immediately if you need any further clarification, please do not hesitate to contact us.',
            style: pw.TextStyle(fontSize: 10, color: PdfColors.red900),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: isHeader ? pw.FontWeight.bold : null,
        ),
      ),
    );
  }
}

Future<Uint8List> generatePdf(Map<String, dynamic> bookingData) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (pw.Context context) {
        return [
          _buildHeader(bookingData),
          pw.SizedBox(height: 20),
          // _buildHotelInformation(bookingData),
          pw.SizedBox(height: 20),
          _buildGuestInformation(bookingData),
          pw.SizedBox(height: 20),
          _buildBookingPolicy(),
          pw.SizedBox(height: 20),
          _buildRefundPolicy(),
          pw.SizedBox(height: 20),
          _buildImportantNote(),
        ];
      },
    ),
  );

  return pdf.save();
}

pw.Widget _buildHeader(Map<String, dynamic> bookingData) {
  return pw.Container(
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Stayinhotels.ae',
          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
        ),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Booking No#: ${bookingData['bookingNumber']}',
              style: pw.TextStyle(fontSize: 12),
            ),
            pw.Text(
              'Support Contact No:\n+923219667909',
              style: pw.TextStyle(fontSize: 12),
              textAlign: pw.TextAlign.right,
            ),
          ],
        ),
      ],
    ),
  );
}


pw.Widget _buildGuestInformation(Map<String, dynamic> bookingData) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('LEAD GUEST'),
              pw.Text(bookingData['bookerName']),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [pw.Text('ROOM(S)'), pw.Text(bookingData['rooms'])],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [pw.Text('NIGHT(S)'), pw.Text(bookingData['nights'])],
          ),
        ],
      ),
      pw.SizedBox(height: 15),
      _buildDateInformation(bookingData),
      pw.SizedBox(height: 15),
      _buildRoomDetailsTable(bookingData),
    ],
  );
}

pw.Widget _buildDateInformation(Map<String, dynamic> bookingData) {
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('CHECK-IN'),
          pw.Text(
            DateFormat(
              'dd MMM yyyy',
            ).format(DateTime.parse(bookingData['checkInDate'])),
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Text('CHECK-OUT'),
          pw.Text(
            DateFormat(
              'dd MMM yyyy',
            ).format(DateTime.parse(bookingData['checkOutDate'])),
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    ],
  );
}

pw.Widget _buildRoomDetailsTable(Map<String, dynamic> bookingData) {
  return pw.Table(
    border: pw.TableBorder.all(color: PdfColors.grey300),
    children: [
      // Header
      pw.TableRow(
        decoration: pw.BoxDecoration(color: PdfColors.grey200),
        children: [
          _buildTableCell('Room No'),
          _buildTableCell('Room Type / Board Basis'),
          _buildTableCell('Guest Name'),
          _buildTableCell('Adult(s)'),
          _buildTableCell('Children'),
        ],
      ),
      // Data rows from bookingData['guestDetails']
      ...List<pw.TableRow>.generate(
        (bookingData['guestDetails'] as List).length,
        (index) => pw.TableRow(
          children: [
            _buildTableCell((index + 1).toString()),
            _buildTableCell('Standard Room / Bed & Breakfast'),
            _buildTableCell(
              '${bookingData['guestDetails'][index]['od_gtitle']} ${bookingData['guestDetails'][index]['od_gfname']} ${bookingData['guestDetails'][index]['od_glname']}',
            ),
            _buildTableCell('2'),
            _buildTableCell('0'),
          ],
        ),
      ),
    ],
  );
}

pw.Widget _buildBookingPolicy() {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        'Booking Policy',
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      ),
      pw.SizedBox(height: 5),
      pw.Text('• The usual check-in time is 12:00-14:00 PM (this may vary).'),
      pw.Text(
        '• Rooms may not be available for early check-in unless requested.',
      ),
      pw.Text(
        '• Hotel reservation may be cancelled automatically after 18:00 hours if hotel is not informed about the appointment time of the arrival.',
      ),
      pw.Text(
        '• The total cost is between 10-12.00 hours between the high-way (non-toll) & the toll road with different destinations.',
      ),
    ],
  );
}

pw.Widget _buildRefundPolicy() {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        'Booking Refund Policy',
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      ),
      pw.SizedBox(height: 5),
      pw.Text(
        'Booking payable as per reservation details. Please collect all extras directly from (sleep in) departure. All matters issued are on the condition that all persons acknowledge that in person to taking part must be made, as people for which we shall not be held preliminary. Some may apply, delay or misconnection caused to passenger as a result of any such arrangements. We will not accept any responsibility for additional expenses due to tax changes or delay in air, road, rail, sea or indeed any form of transport.',
        style: pw.TextStyle(fontSize: 10),
      ),
    ],
  );
}

pw.Widget _buildImportantNote() {
  return pw.Container(
    padding: pw.EdgeInsets.all(10),
    decoration: pw.BoxDecoration(
      color: PdfColors.pink50,
      borderRadius: pw.BorderRadius.circular(5),
    ),
    child: pw.Text(
      'Important Note - Check your Reservation details carefully and inform us immediately if you need any further clarification, please do not hesitate to contact us.',
      style: pw.TextStyle(fontSize: 10, color: PdfColors.red900),
    ),
  );
}

pw.Widget _buildTableCell(String text) {
  return pw.Padding(
    padding: pw.EdgeInsets.all(5),
    child: pw.Text(text, style: pw.TextStyle(fontSize: 10)),
  );
}
