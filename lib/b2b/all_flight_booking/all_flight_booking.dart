// all_flight_booking_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:oneroof/b2b/all_flight_booking/all_flight_booking_controler.dart';
import 'package:oneroof/b2b/all_flight_booking/model.dart';
import 'package:oneroof/utility/colors.dart';

class AllFlightBookingScreen extends StatelessWidget {
  final AllFlightBookingController controller = Get.put(
    AllFlightBookingController(),
  );

  AllFlightBookingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.background,
      appBar: AppBar(
        backgroundColor: TColors.background4,
        title: const Text(
          'All Flights Booking',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildDateFilter(),
          _buildStatCards(),
          Expanded(child: Obx(() => _buildBookingCards())),
        ],
      ),
    );
  }

  Widget _buildDateFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Date From',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => GestureDetector(
                        onTap: () => controller.selectFromDate(Get.context!),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat(
                                  'dd/MM/yyyy',
                                ).format(controller.fromDate.value),
                                style: const TextStyle(color: Colors.white),
                              ),
                              const Icon(
                                Icons.calendar_today,
                                color: Colors.white,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Date To',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => GestureDetector(
                        onTap: () => controller.selectToDate(Get.context!),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat(
                                  'dd/MM/yyyy',
                                ).format(controller.toDate.value),
                                style: const TextStyle(color: Colors.white),
                              ),
                              const Icon(
                                Icons.calendar_today,
                                color: Colors.white,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
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

  Widget _buildStatCards() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.black87,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Obx(
          () => Row(
            children: [
              _buildStatCard(
                'Total Bookings',
                controller.totalBookings.value,
                Colors.blue,
              ),
              _buildStatCard(
                'Confirmed',
                controller.confirmedBookings.value,
                Colors.green,
              ),
              _buildStatCard(
                'On Hold',
                controller.onHoldBookings.value,
                Colors.amber,
              ),
              _buildStatCard(
                'Cancelled',
                controller.cancelledBookings.value,
                Colors.red,
              ),
              _buildStatCard(
                'Error',
                controller.errorBookings.value,
                Colors.blueGrey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, int count, Color color) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCards() {
    return controller.filteredBookings.isEmpty
        ? const Center(child: Text('No bookings found'))
        : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.filteredBookings.length,
          itemBuilder: (context, index) {
            final booking = controller.filteredBookings[index];
            return _buildBookingCard(booking);
          },
        );
  }

  Widget _buildBookingCard(BookingModel booking) {
    Color statusColor;

    switch (booking.status) {
      case 'Confirmed':
        statusColor = Colors.green;
        break;
      case 'On Hold':
      case 'On Request':
        statusColor = Colors.orange;
        break;
      case 'Cancelled':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: TColors.background4,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Booking ID',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    Text(
                      booking.bookingId,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    booking.status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow(
                  'Booking Date',
                  DateFormat(
                    'E, dd MMM yyyy\nHH:mm:ss',
                  ).format(booking.bookingOn),
                ),
                const Divider(),
                _buildInfoRow('PNR', booking.pnr),
                const Divider(),
                _buildInfoRow('Supplier', booking.supplier),
                const Divider(),
                _buildInfoRow('Trip', booking.trip),
                const Divider(),
                _buildInfoRow('Passenger', booking.passengerName),
                const Divider(),
                _buildInfoRow(
                  'Travel Date',
                  DateFormat('E, dd MMM yyyy').format(booking.travelDate),
                ),
                const Divider(),
                _buildInfoRow('Total Price', '\$${booking.totalPrice}'),

                if (booking.deadline != null) ...[
                  const Divider(),
                  _buildInfoRow(
                    'Deadline',
                    DateFormat(
                      'E, dd MMM yyyy HH:mm',
                    ).format(booking.deadline!),
                    isHighlighted: true,
                  ),
                ],

                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => controller.viewBookingDetails(booking),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.visibility, color: Colors.white),
                      label: const Text(
                        'View',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => controller.printTicket(booking),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.print, color: Colors.white),
                      label: const Text(
                        'Print Ticket',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool isHighlighted = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: TColors.grey,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                color: isHighlighted ? TColors.third : TColors.text,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
