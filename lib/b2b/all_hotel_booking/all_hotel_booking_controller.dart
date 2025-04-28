// controllers/all_hotel_booking_controller.dart
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:oneroof/b2b/all_hotel_booking/model.dart';
import 'package:oneroof/views/users/login/login_api_service/login_api.dart';

class AllHotelBookingController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  var bookings = <HotelBookingModel>[].obs;
  var isLoading = true.obs;
  var errorMessage = ''.obs;

  var fromDate = DateTime.now().subtract(Duration(days: 30)).obs;
  var toDate = DateTime.now().obs;

  var totalReceipt = "0.00".obs;
  var totalPayment = "0.00".obs;
  var closingBalance = "0.00".obs;

  @override
  void onInit() {
    super.onInit();
    fetchHotelBookings();
  }

  Future<void> fetchHotelBookings() async {
    isLoading.value = true;
    errorMessage.value = '';
    bookings.clear();

    try {
      final result = await _authController.getHotelBookings();

      if (result['success'] == true && result['data'] != null) {
        // Process the API response data
        final responseData = result['data'] as List<dynamic>;

        double totalReceiptValue = 0.0;
        double totalPaymentValue = 0.0;

        final List<HotelBookingModel> processedBookings = [];

        for (int i = 0; i < responseData.length; i++) {
          final booking = responseData[i];
          final bookingDetail = booking['BookingDetail'];
          final guestsDetail = booking['GuestsDetail'] as List<dynamic>;

          // Calculate serial number
          final serialNumber = (i + 1).toString();

          // Generate booking number (using om_id or another identifier)
          final bookingId = bookingDetail['om_id']?.toString() ?? '';
          final bookingNumber = "ONETRVL-${bookingId.padLeft(4, '0')}";

          // Format booking date
          DateTime bookingDate;
          try {
            bookingDate = DateTime.parse(bookingDetail['om_ordate'] ?? '');
          } catch (e) {
            bookingDate = DateTime.now();
          }
          final formattedDate = DateFormat(
            'EEE, dd MMM yyyy',
          ).format(bookingDate);

          // Process guests
          final List<String> guestNames = [];
          for (final guest in guestsDetail) {
            final String title = guest['od_gtitle'] ?? '';
            final String firstName = guest['od_gfname'] ?? '';
            final String lastName = guest['od_glname'] ?? '';
            guestNames.add('$title $firstName $lastName');
          }
          final guestName = guestNames.join(', ');

          // Get destination and hotel name
          final destination =
              bookingDetail['om_destination'] ?? 'Unknown Location';
          final hotel = bookingDetail['om_hname'] ?? 'Unknown Hotel';

          // Get status
          String status = 'Pending';
          if (bookingDetail['om_status'] == '1') {
            status = 'Confirmed';
          } else if (bookingDetail['om_status'] == '2') {
            status = 'Cancelled';
          } else if (bookingDetail['om_status'] == '0') {
            status = 'On Request';
          }

          // Format check-in/check-out dates
          DateTime checkInDate;
          DateTime checkOutDate;
          try {
            checkInDate = DateTime.parse(bookingDetail['om_chindate'] ?? '');
            checkOutDate = DateTime.parse(bookingDetail['om_choutdate'] ?? '');
          } catch (e) {
            checkInDate = DateTime.now();
            checkOutDate = DateTime.now().add(Duration(days: 1));
          }

          final formattedCheckIn = DateFormat(
            'EEE, dd MMM yyyy',
          ).format(checkInDate);
          final formattedCheckOut = DateFormat(
            'EEE, dd MMM yyyy',
          ).format(checkOutDate);
          final checkinCheckout = '$formattedCheckIn - $formattedCheckOut';

          // Format price
          final buyingPrice =
              double.tryParse(bookingDetail['buying_price'] ?? '0') ?? 0.0;
          final sellingPrice =
              double.tryParse(bookingDetail['selling_price'] ?? '0') ?? 0.0;
          final currencySymbol = '\$';
          final localCurrency = 'PKR';
          final price =
              '$currencySymbol ${buyingPrice.toStringAsFixed(2)} $localCurrency: ${sellingPrice.toStringAsFixed(0)}';

          totalReceiptValue += sellingPrice;
          totalPaymentValue += buyingPrice;

          // Calculate cancellation deadline based on check-in date
          String cancellationDeadline;
          final currentDate = DateTime.now();
          final daysUntilCheckin = checkInDate.difference(currentDate).inDays;

          if (daysUntilCheckin < 0) {
            cancellationDeadline = 'Non-Refundable';
          } else if (daysUntilCheckin <= 1) {
            cancellationDeadline = 'Non-Refundable';
          } else {
            final cancellationDate = checkInDate.subtract(Duration(days: 1));
            final formattedCancellation = DateFormat(
              'EEE, dd MMM yyyy',
            ).format(cancellationDate);
            cancellationDeadline =
                '$formattedCancellation ($daysUntilCheckin Days left)';
          }

          final hotelBooking = HotelBookingModel(
            serialNumber: serialNumber,
            bookingNumber: bookingNumber,
            date: formattedDate,
            bookerName: bookingDetail['om_bfname'] ?? 'Unknown',
            guestName: guestName,
            destination: destination,
            hotel: hotel,
            status: status,
            checkinCheckout: checkinCheckout,
            price: price,
            cancellationDeadline: cancellationDeadline,
          );

          processedBookings.add(hotelBooking);
        }

        // Update the bookings list and financial summary
        bookings.assignAll(processedBookings);

        // Format financial summary
        final formatter = NumberFormat('#,##0.00', 'en_US');
        totalReceipt.value = formatter.format(totalReceiptValue);
        totalPayment.value = formatter.format(totalPaymentValue);
        closingBalance.value = formatter.format(
          totalReceiptValue - totalPaymentValue,
        );
      } else {
        errorMessage.value =
            result['message'] ?? 'Failed to load hotel bookings';
      }
    } catch (e) {
      errorMessage.value =
          'An error occurred while fetching hotel bookings: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void updateDateRange(DateTime from, DateTime to) {
    fromDate.value = from;
    toDate.value = to;
    // You could implement date filtering here
    // For now, we'll just refresh the data
    fetchHotelBookings();
  }

  // Helper method to filter bookings by date if needed
  List<HotelBookingModel> getFilteredBookings() {
    // This would filter the bookings based on from/to dates
    // For now, we'll return all bookings
    return bookings;
  }
}
