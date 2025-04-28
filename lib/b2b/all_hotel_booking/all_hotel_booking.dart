import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:oneroof/b2b/all_hotel_booking/all_hotel_booking_controller.dart';
import 'package:oneroof/b2b/all_hotel_booking/model.dart';
import 'package:oneroof/utility/colors.dart';

class AllHotelBooking extends StatelessWidget {
  final AllHotelBookingController bookingController = Get.put(AllHotelBookingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.background,
      appBar: AppBar(
        backgroundColor: TColors.background4,
        title: Text(
          'International Bookings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: () => bookingController.fetchHotelBookings(),
          ),
          IconButton(
            icon: Icon(Icons.print, color: Colors.white),
            onPressed: () {
              // Handle print action
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDateFilter(),
          Expanded(
            child: _buildBookingsList(),
          ),
          _buildSummarySection(),
        ],
      ),
    );
  }

  Widget _buildDateFilter() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: TColors.background3,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'All International Bookings',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: TColors.text,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Obx(() => _buildDateSelector(
                  'From Date',
                  bookingController.fromDate.value,
                  (newDate) {
                    if (newDate != null) {
                      bookingController.updateDateRange(
                        newDate,
                        bookingController.toDate.value,
                      );
                    }
                  },
                )),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Obx(() => _buildDateSelector(
                  'To Date',
                  bookingController.toDate.value,
                  (newDate) {
                    if (newDate != null) {
                      bookingController.updateDateRange(
                        bookingController.fromDate.value,
                        newDate,
                      );
                    }
                  },
                )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector(String label, DateTime selectedDate, Function(DateTime?) onDateSelected) {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: Get.context!,
          initialDate: selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime(2026),
          builder: (context, child) {
            return Theme(
              data: ThemeData.light().copyWith(
                colorScheme: ColorScheme.light(
                  primary: TColors.primary,
                ),
              ),
              child: child!,
            );
          },
        );
        onDateSelected(picked);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: TColors.grey.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: TColors.grey,
                fontSize: 12,
              ),
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: TColors.primary),
                SizedBox(width: 8),
                Text(
                  DateFormat('dd MMM yyyy').format(selectedDate),
                  style: TextStyle(
                    color: TColors.text,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingsList() {
    return Obx(() {
      // Show loading indicator
      if (bookingController.isLoading.value) {
        return Center(
          child: CircularProgressIndicator(),
        );
      }
      
      // Show error message if any
      if (bookingController.errorMessage.value.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              SizedBox(height: 16),
              Text(
                bookingController.errorMessage.value,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => bookingController.fetchHotelBookings(),
                child: Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      }
      
      // Show empty state
      if (bookingController.bookings.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.hotel_outlined,
                color: TColors.grey,
                size: 64,
              ),
              SizedBox(height: 16),
              Text(
                'No bookings found for the selected date range',
                textAlign: TextAlign.center,
                style: TextStyle(color: TColors.grey),
              ),
            ],
          ),
        );
      }
      
      // Show bookings list
      return ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: bookingController.bookings.length,
        itemBuilder: (context, index) {
          final booking = bookingController.bookings[index];
          return _buildBookingCard(booking);
        },
      );
    });
  }

  Widget _buildBookingCard(HotelBookingModel booking) {
    Color statusColor;
    
    switch (booking.status.toLowerCase()) {
      case 'confirmed':
        statusColor = Colors.green;
        break;
      case 'on request':
        statusColor = Colors.orange;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.blue;
    }

    // Determine booking source color based on booking number prefix
    String portalCode = booking.bookingNumber.split('-')[0];
    Color portalColor;
    
    switch (portalCode) {
      case 'ONETRVL':
        portalColor = Colors.blue;
        break;
      case 'TOCBK':
        portalColor = Colors.teal;
        break;
      case 'TDBK':
        portalColor = Colors.red;
        break;
      default:
        portalColor = Colors.purple;
    }

    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Header with Serial Number and Booking Number
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: portalColor.withOpacity(0.2),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: portalColor,
                  radius: 14,
                  child: Text(
                    booking.serialNumber,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  booking.bookingNumber,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: TColors.text,
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    booking.status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Booking Details
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date
                _buildInfoRow(Icons.event, "Date", booking.date),
                SizedBox(height: 12),
                
                // Booker and Guest
                _buildInfoRow(Icons.person, "Booker", booking.bookerName),
                SizedBox(height: 8),
                _buildInfoRow(Icons.people, "Guest", booking.guestName),
                SizedBox(height: 12),
                
                // Hotel and Location
                _buildInfoRow(Icons.hotel, "Hotel", booking.hotel),
                SizedBox(height: 8),
                _buildInfoRow(Icons.location_on, "Destination", booking.destination),
                SizedBox(height: 12),
                
                // Check-in/Check-out
                _buildInfoRow(Icons.calendar_month, "Check-in/Check-out", booking.checkinCheckout),
                SizedBox(height: 12),
                
                Divider(),
                SizedBox(height: 12),
                
                // Bottom Row with Price and Cancellation
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildInfoRow(Icons.attach_money, "Price", booking.price),
                    ),
                    Expanded(
                      child: _buildInfoRow(
                        Icons.event_busy,
                        "Cancellation",
                        booking.cancellationDeadline,
                        valueColor: booking.cancellationDeadline.contains("Non-Refundable") 
                            ? Colors.red 
                            : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Print Button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.print),
                  label: Text('Print'),
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: TColors.grey),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: TColors.grey,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: valueColor ?? TColors.text,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummarySection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: Offset(0, -2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Obx(() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildSummaryItem(
            "Total Receipt",
            "\$${bookingController.totalReceipt.value}",
            Colors.green,
          ),
          Container(
            height: 40,
            width: 1,
            color: Colors.grey.withOpacity(0.3),
          ),
          _buildSummaryItem(
            "Total Payment",
            "\$${bookingController.totalPayment.value}",
            Colors.red,
          ),
          Container(
            height: 40,
            width: 1,
            color: Colors.grey.withOpacity(0.3),
          ),
          _buildSummaryItem(
            "Closing Balance",
            "\$${bookingController.closingBalance.value}",
            TColors.primary,
          ),
        ],
      )),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: TColors.grey,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}