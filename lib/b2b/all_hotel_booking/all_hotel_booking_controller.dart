// controllers/booking_controller.dart
import 'package:get/get.dart';
import 'package:oneroof/b2b/all_hotel_booking/model.dart';

class AllHotelBookingController extends GetxController {
  var bookings = <HotelBookingModel>[].obs;
  var fromDate = DateTime.now().obs;
  var toDate = DateTime.now().add(Duration(days: 30)).obs;
  
  var totalReceipt = "1,979.00".obs;
  var totalPayment = "1,425.00".obs;
  var closingBalance = "554.00".obs;

  @override
  void onInit() {
    super.onInit();
    fetchBookings();
  }

  void fetchBookings() {
    // In a real app, you would fetch data from an API
    // Here we're using dummy data from the images
    var dummyBookings = [
      HotelBookingModel(
        serialNumber: "1",
        bookingNumber: "TOCBK-1281",
        date: "Mon, 14 Apr 2025",
        bookerName: "SHAHMEER",
        guestName: "Shahmeer Admin, Muhammad Ibrahim, Saleem Tayyab, Kashif",
        destination: "BAKU, AZERBAIJAN",
        hotel: "Passage Boutique Hotel",
        status: "Confirmed",
        checkinCheckout: "Tue, 15 Apr 2025 - Thu, 17 Apr 2025",
        price: "\$ 182.00 PKR: 52418",
        cancellationDeadline: "Non-Refundable",
      ),
      HotelBookingModel(
        serialNumber: "2",
        bookingNumber: "TOCBK-1280",
        date: "Mon, 14 Apr 2025",
        bookerName: "SHAHMEER",
        guestName: "Adel Majeed, Nabil Javed",
        destination: "DUBAI, UAE",
        hotel: "Signature Hotel - Al Barsha",
        status: "Confirmed",
        checkinCheckout: "Tue, 29 Apr 2025 - Sun, 04 May 2025",
        price: "\$ 462.00 PKR: 130178",
        cancellationDeadline: "Mon, 29 Apr 2025 (5 Days left)",
      ),
      HotelBookingModel(
        serialNumber: "3",
        bookingNumber: "TDBK-1298",
        date: "Sun, 13 Apr 2025",
        bookerName: "SHAHMEER FARRUKH",
        guestName: "Naveed Yousuf, Saphia Naveed",
        destination: "Dubai, United Arab Emirates",
        hotel: "Hilton Garden Inn Dubai Mall",
        status: "On Request",
        checkinCheckout: "Mon, 14 Apr 2025 - Wed, 16 Apr 2025",
        price: "\$ 285.00 PKR: 82005",
        cancellationDeadline: "Non-Refundable",
      ),
      HotelBookingModel(
        serialNumber: "4",
        bookingNumber: "TOCBK-1279",
        date: "Sat, 12 Apr 2025",
        bookerName: "SHAHMEER",
        guestName: "Nazish Awais",
        destination: "DUBAI, UAE",
        hotel: "Signature Hotel - Al Barsha",
        status: "Confirmed",
        checkinCheckout: "Fri, 25 Apr 2025 - Wed, 30 Apr 2025",
        price: "\$ 530.00 PKR: 152640",
        cancellationDeadline: "Fri, 18 Apr 2025 (3 Days left)",
      ),
    ];
    
    bookings.assignAll(dummyBookings);
  }

  void updateDateRange(DateTime from, DateTime to) {
    fromDate.value = from;
    toDate.value = to;
    // In a real app, you would re-fetch data based on the new date range
  }
}
