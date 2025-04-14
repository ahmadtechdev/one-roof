// all_flight_booking_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oneroof/B-TO-B/all_flight_booking/model.dart';

class AllFlightBookingController extends GetxController {
  // Date filter variables
  final Rx<DateTime> fromDate = DateTime(2025, 4, 1).obs;
  final Rx<DateTime> toDate = DateTime(2025, 4, 11).obs;

  // Search and pagination
  final TextEditingController searchController = TextEditingController();
  final RxInt entriesPerPage = 50.obs;

  // Statistics
  final RxInt totalBookings = 1.obs;
  final RxInt confirmedBookings = 0.obs;
  final RxInt onHoldBookings = 1.obs;
  final RxInt cancelledBookings = 0.obs;
  final RxInt errorBookings = 0.obs;

  // Financial summary
  final RxInt totalReceipt = 1800.obs;
  final RxInt totalPayment = 800.obs;
  final RxInt closingBalance = 1000.obs;

  // Booking data
  final RxList<BookingModel> allBookings = <BookingModel>[].obs;
  final RxList<BookingModel> filteredBookings = <BookingModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize with dummy data
    _loadDummyData();
    filterBookings();
  }

  void _loadDummyData() {
    allBookings.value = [
      BookingModel(
        bookingOn: DateTime(2025, 3, 28, 5, 54, 32),
        bookingId: 'BK-49',
        pnr: 'GDS',
        airline: 'Airline',
        supplier: 'OMAN AIR',
        trip: 'KHI to MCT, MCT to DOH, DOH to DUB',
        passengerName: 'Mr ef fsd',
        travelDate: DateTime(2025, 3, 28),
        totalPrice: 0,
        status: 'On Request',
        deadline: DateTime(2025, 3, 28, 13, 54),
      ),
      BookingModel(
        bookingOn: DateTime(2025, 4, 3, 8, 20, 15),
        bookingId: 'BK-50',
        pnr: 'AMS',
        airline: 'Airline',
        supplier: 'EMIRATES',
        trip: 'LHR to DXB, DXB to SYD',
        passengerName: 'Ms Jane Smith',
        travelDate: DateTime(2025, 4, 10),
        totalPrice: 1250,
        status: 'Confirmed',
        deadline: DateTime(2025, 4, 5, 18, 30),
      ),
      BookingModel(
        bookingOn: DateTime(2025, 4, 5, 12, 45, 22),
        bookingId: 'BK-51',
        pnr: 'XTZ',
        airline: 'Airline',
        supplier: 'QATAR AIRWAYS',
        trip: 'JFK to DOH, DOH to BKK',
        passengerName: 'Mr John Doe',
        travelDate: DateTime(2025, 4, 15),
        totalPrice: 1800,
        status: 'On Hold',
        deadline: DateTime(2025, 4, 7, 23, 59),
      ),
    ];

    // Update statistics
    updateStats();
  }

  // Update statistics based on the current bookings
  void updateStats() {
    int confirmed = 0;
    int onHold = 0;
    int cancelled = 0;
    int error = 0;

    for (var booking in allBookings) {
      if (booking.status == 'Confirmed') {
        confirmed++;
      } else if (booking.status == 'On Hold' ||
          booking.status == 'On Request') {
        onHold++;
      } else if (booking.status == 'Cancelled') {
        cancelled++;
      } else if (booking.status == 'Error') {
        error++;
      }
    }

    confirmedBookings.value = confirmed;
    onHoldBookings.value = onHold;
    cancelledBookings.value = cancelled;
    errorBookings.value = error;
    totalBookings.value = allBookings.length;
  }

  // Filter bookings based on date range and search term
  void filterBookings() {
    String searchTerm = searchController.text.toLowerCase();

    filteredBookings.value =
        allBookings.where((booking) {
          // Check if booking is within date range
          bool isInDateRange =
              booking.bookingOn.isAfter(
                fromDate.value.subtract(const Duration(days: 1)),
              ) &&
              booking.bookingOn.isBefore(
                toDate.value.add(const Duration(days: 1)),
              );

          // Check if booking matches search term
          bool matchesSearch =
              searchTerm.isEmpty ||
              booking.bookingId.toLowerCase().contains(searchTerm) ||
              booking.pnr.toLowerCase().contains(searchTerm) ||
              booking.supplier.toLowerCase().contains(searchTerm) ||
              booking.passengerName.toLowerCase().contains(searchTerm) ||
              booking.status.toLowerCase().contains(searchTerm);

          return isInDateRange && matchesSearch;
        }).toList();
  }

  // Date picker for from date
  Future<void> selectFromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fromDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null && picked != fromDate.value) {
      fromDate.value = picked;
      filterBookings();
    }
  }

  // Date picker for to date
  Future<void> selectToDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: toDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null && picked != toDate.value) {
      toDate.value = picked;
      filterBookings();
    }
  }

  // View details of a booking
  void viewBookingDetails(BookingModel booking) {
    // Navigate to booking details screen
    Get.snackbar(
      'View Booking',
      'Viewing details for booking ${booking.bookingId}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Print ticket
  void printTicket(BookingModel booking) {
    // Print ticket logic
    Get.snackbar(
      'Print Ticket',
      'Printing ticket for booking ${booking.bookingId}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
