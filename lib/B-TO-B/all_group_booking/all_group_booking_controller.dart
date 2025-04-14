
import 'package:get/get.dart';
import 'package:oneroof/B-TO-B/all_group_booking/model.dart';

class AllGroupBookingController extends GetxController {
  final fromDate = DateTime.now().obs;
  final toDate = DateTime.now().add(const Duration(days: 30)).obs;
  final selectedGroupCategory = 'All'.obs;
  final selectedStatus = 'All'.obs;

  final totalReceipt = 177500.0.obs;
  final totalPayment = 85000.0.obs;

  double get closingBalance => totalReceipt.value - totalPayment.value;

  final bookings = <BookingModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDummyData();
  }

  void loadDummyData() {
    bookings.value = [
      BookingModel(
        id: 1,
        pnr: 'PNR# G2025031813180611526',
        bkf: 'BKF 2631',
        agt: 'AGT# 1155',
        createdDate: DateTime(2025, 4, 9, 19, 36),
        airline: 'SERENE AIR',
        route: 'ISB-DXB',
        country: 'UAE',
        flightDate: DateTime(2025, 4, 24),
        passengerStatus: PassengerStatus(
          holdAdults: 1,
          holdChild: 0,
          holdInfant: 0,
          holdTotal: 1,
          confirmAdults: 1,
          confirmChild: 0,
          confirmInfant: 0,
          confirmTotal: 1,
          cancelledAdults: 0,
          cancelledChild: 0,
          cancelledInfant: 0,
          cancelledTotal: 0,
        ),
        price: 84000.0,
        status: 'CONFIRMED',
      ),
      BookingModel(
        id: 2,
        pnr: 'PNR# G2025040421120012128',
        bkf: 'BK# 2630',
        agt: 'AGT# 6157',
        createdDate: DateTime(2025, 4, 9, 17, 41),
        airline: '06. SERENE AIR LHE-DXB',
        route: 'LAHORE TO DUBAI',
        country: 'UAE',
        flightDate: DateTime(2025, 4, 15),
        passengerStatus: PassengerStatus(
          holdAdults: 1,
          holdChild: 0,
          holdInfant: 0,
          holdTotal: 1,
          confirmAdults: 0,
          confirmChild: 0,
          confirmInfant: 0,
          confirmTotal: 0,
          cancelledAdults: 0,
          cancelledChild: 0,
          cancelledInfant: 0,
          cancelledTotal: 0,
        ),
        price: 96000.0,
        status: 'CANCELLED',
      ),
      BookingModel(
        id: 3,
        pnr: 'PNR# G2025022614133710464',
        bkf: 'BK# 2617',
        agt: 'AGT# 6030',
        createdDate: DateTime(2025, 4, 8, 9, 38),
        airline: '20. SERENE AIR LHE-JED',
        route: 'LAHORE TO JEDDAH',
        country: 'KSA',
        flightDate: DateTime(2025, 4, 11),
        passengerStatus: PassengerStatus(
          holdAdults: 1,
          holdChild: 0,
          holdInfant: 0,
          holdTotal: 1,
          confirmAdults: 0,
          confirmChild: 0,
          confirmInfant: 0,
          confirmTotal: 0,
          cancelledAdults: 1,
          cancelledChild: 0,
          cancelledInfant: 0,
          cancelledTotal: 1,
        ),
        price: 70000.0,
        status: 'CANCELLED',
      ),
    ];
  }

  void updateFromDate(DateTime date) {
    fromDate.value = date;
  }

  void updateToDate(DateTime date) {
    toDate.value = date;
  }

  void updateGroupCategory(String category) {
    selectedGroupCategory.value = category;
  }

  void updateStatus(String status) {
    selectedStatus.value = status;
  }

  void filterBookings() {
    // Filter logic would go here
  }
}
