import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oneroof/utility/colors.dart';
import 'package:oneroof/views/group_ticket/booking_form_fields/model.dart';
import 'package:oneroof/views/group_ticket/booking_form_fields/print-voucher/print-voucher.dart';
import '../../../services/api_service_group_tickets.dart';
import '../flight_pkg/pkg_model.dart';

class GroupTicketBookingController extends GetxController {
  final Rx<BookingData> bookingData =
      BookingData(
        groupId: 0,
        groupName: '',
        sector: '',
        availableSeats: 1,
        adults: 1,
        children: 0,
        infants: 0,
        adultPrice: 0,
        childPrice: 0,
        infantPrice: 0,
        groupPriceDetailId: 0,
      ).obs;

  final GroupTicketingController apiController = Get.put(
    GroupTicketingController(),
  );
  final formKey = GlobalKey<FormState>();
  final RxBool isFormValid = false.obs;

  List<String> adultTitles = ['Mr', 'Mrs', 'Ms'];
  List<String> childTitles = ['Mstr', 'Miss'];
  List<String> infantTitles = ['INF'];

  /// Initializes booking data from flight model
  void initializeFromFlight(GroupFlightModel flight, int groupId) async {
    print("check 2");
    print(groupId);
    bookingData.update((val) {
      if (val == null) return;

      val.groupId = flight.group_id;
      val.groupName =
          '${flight.airline}-${flight.origin}-${flight.destination}';
      val.sector = '${flight.origin}-${flight.destination}';
      val.adultPrice = flight.price.toDouble();
      val.childPrice = flight.price.toDouble();
      val.infantPrice = flight.price.toDouble();
      val.groupPriceDetailId = flight.groupPriceDetailId;
      val.availableSeats = flight.seats;
    });
    //
    // // Then fetch and update available seats
    // await fetchAndUpdateAvailableSeats(groupId);
  }

  // Future<void> fetchAndUpdateAvailableSeats(int groupId) async {
  //   print("check 3");
  //   print(groupId);
  //   try {
  //     final availableSeats = await apiController.fetchAvailableSeats(groupId);
  //     bookingData.update((val) {
  //       if (val != null) {
  //         val.availableSeats = availableSeats;
  //       }
  //     });
  //   } catch (e) {
  //     showErrorSnackbar('Failed to fetch available seats');
  //     bookingData.update((val) {
  //       if (val != null) {
  //         val.availableSeats = 0; // Set to 0 if there's an error
  //       }
  //     });
  //   }
  // }

  /// Validates the form and updates isFormValid
  void validateForm() {
    isFormValid.value = formKey.currentState?.validate() ?? false;
  }

  final RxBool isLoading = false.obs;

  /// Submits the booking to the API
  Future<void> submitBooking() async {
    if (!isFormValid.value) {
      showErrorSnackbar('Please fill in all required fields correctly.');
      return;
    }

    try {
      // Show loading
      isLoading.value = true;

      final passengers =
          bookingData.value.passengers
              .map(
                (passenger) => {
                  'firstName': passenger.firstName,
                  'lastName': passenger.lastName,
                  'title': passenger.title,
                  'passportNumber': passenger.passportNumber,
                  'dateOfBirth': passenger.dateOfBirth?.toIso8601String(),
                  'passportExpiry': passenger.passportExpiry?.toIso8601String(),
                },
              )
              .toList();

      final result = await apiController.saveBooking(
        groupId: bookingData.value.groupId,
        agentName: 'ONE ROOF TRAVEL',
        agencyName: 'ONE ROOF TRAVEL',
        email: 'usama@travelnetwork.com',
        mobile: '03137358881',
        adults: bookingData.value.adults,
        children:
            bookingData.value.children > 0 ? bookingData.value.children : null,
        infants:
            bookingData.value.infants > 0 ? bookingData.value.infants : null,
        passengers: passengers,
        groupPriceDetailId: bookingData.value.groupPriceDetailId,
      );

      // Hide loading
      isLoading.value = false;

      if (result['success'] == true) {
        showSuccessSnackbar(result['message']);

        // Print full result data in chunks
        printLargeData("the data is ${jsonEncode(result)}");

        // Navigate to PDF print screen with the API response data
        Get.to(() => PDFPrintScreen(bookingData: result));
      } else {
        showErrorSnackbar(result['message']);
      }
    } catch (e) {
      // Hide loading on error
      isLoading.value = false;
      showErrorSnackbar('An error occurred while processing your booking');
    }
  }

  // Helper function to print large data in chunks
  void printLargeData(String data) {
    const int chunkSize = 800;
    for (int i = 0; i < data.length; i += chunkSize) {
      final end = (i + chunkSize < data.length) ? i + chunkSize : data.length;
      debugPrint(data.substring(i, end));
    }
  }

  // Update your save button in the UI to show loading state
  Widget buildSaveButton() {
    return Obx(() {
      return Container(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isLoading.value ? null : submitBooking,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade800,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child:
              isLoading.value
                  ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text('Processing...'),
                    ],
                  )
                  : const Text(
                    'Save Booking',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
        ),
      );
    });
  }
  // Update your save button in the UI to show loading state

  void incrementAdults() {
    if (bookingData.value.totalPassengers < bookingData.value.availableSeats) {
      var updatedData = BookingData(
        groupId: bookingData.value.groupId,
        groupName: bookingData.value.groupName,
        sector: bookingData.value.sector,
        availableSeats: bookingData.value.availableSeats,
        adults: bookingData.value.adults + 1,
        children: bookingData.value.children,
        infants: bookingData.value.infants,
        adultPrice: bookingData.value.adultPrice,
        childPrice: bookingData.value.childPrice,
        infantPrice: bookingData.value.infantPrice,
        groupPriceDetailId: bookingData.value.groupPriceDetailId,
      );
      bookingData.value = updatedData;
    } else {
      Get.snackbar(
        'Error',
        'Cannot add more passengers. Available seats limit reached.',
        backgroundColor: TColors.red.withOpacity(0.1),
        colorText: TColors.red,
      );
    }
  }

  void decrementAdults() {
    if (bookingData.value.adults > 1) {
      // At least one adult required
      var updatedData = BookingData(
        groupId: bookingData.value.groupId,
        groupName: bookingData.value.groupName,
        sector: bookingData.value.sector,
        availableSeats: bookingData.value.availableSeats,
        adults: bookingData.value.adults - 1,
        children: bookingData.value.children,
        infants: bookingData.value.infants,
        adultPrice: bookingData.value.adultPrice,
        childPrice: bookingData.value.childPrice,
        infantPrice: bookingData.value.infantPrice,
        groupPriceDetailId: bookingData.value.groupId,
      );
      bookingData.value = updatedData;
    }
  }

  void incrementChildren() {
    if (bookingData.value.totalPassengers < bookingData.value.availableSeats) {
      var updatedData = BookingData(
        groupId: bookingData.value.groupId,
        groupName: bookingData.value.groupName,
        sector: bookingData.value.sector,
        availableSeats: bookingData.value.availableSeats,
        adults: bookingData.value.adults,
        children: bookingData.value.children + 1,
        infants: bookingData.value.infants,
        adultPrice: bookingData.value.adultPrice,
        childPrice: bookingData.value.childPrice,
        infantPrice: bookingData.value.infantPrice,
        groupPriceDetailId: bookingData.value.groupPriceDetailId,
      );
      bookingData.value = updatedData;
    } else {
      Get.snackbar(
        'Error',
        'Cannot add more passengers. Available seats limit reached.',
        backgroundColor: TColors.red.withOpacity(0.1),
        colorText: TColors.red,
      );
    }
  }

  void decrementChildren() {
    if (bookingData.value.children > 0) {
      var updatedData = BookingData(
        groupId: bookingData.value.groupId,
        groupName: bookingData.value.groupName,
        sector: bookingData.value.sector,
        availableSeats: bookingData.value.availableSeats,
        adults: bookingData.value.adults,
        children: bookingData.value.children - 1,
        infants: bookingData.value.infants,
        adultPrice: bookingData.value.adultPrice,
        childPrice: bookingData.value.childPrice,
        infantPrice: bookingData.value.infantPrice,
        groupPriceDetailId: bookingData.value.groupPriceDetailId,
      );
      bookingData.value = updatedData;
    }
  }

  void incrementInfants() {
    if (bookingData.value.totalPassengers < bookingData.value.availableSeats) {
      var updatedData = BookingData(
        groupId: bookingData.value.groupId,
        groupName: bookingData.value.groupName,
        sector: bookingData.value.sector,
        availableSeats: bookingData.value.availableSeats,
        adults: bookingData.value.adults,
        children: bookingData.value.children,
        infants: bookingData.value.infants + 1,
        adultPrice: bookingData.value.adultPrice,
        childPrice: bookingData.value.childPrice,
        infantPrice: bookingData.value.infantPrice,
        groupPriceDetailId: bookingData.value.groupPriceDetailId,
      );
      bookingData.value = updatedData;
    } else {
      Get.snackbar(
        'Error',
        'Cannot add more passengers. Available seats limit reached.',
        backgroundColor: TColors.red.withOpacity(0.1),
        colorText: TColors.red,
      );
    }
  }

  void decrementInfants() {
    if (bookingData.value.infants > 0) {
      var updatedData = BookingData(
        groupId: bookingData.value.groupId,
        groupName: bookingData.value.groupName,
        sector: bookingData.value.sector,
        availableSeats: bookingData.value.availableSeats,
        adults: bookingData.value.adults,
        children: bookingData.value.children,
        infants: bookingData.value.infants - 1,
        adultPrice: bookingData.value.adultPrice,
        childPrice: bookingData.value.childPrice,
        infantPrice: bookingData.value.infantPrice,
        groupPriceDetailId: bookingData.value.groupId,
      );
      bookingData.value = updatedData;
    }
  }

  /// Updates passenger count for a given type (adult/child/infant)
  void updatePassengerCount(String type, {bool increment = true}) {
    if (increment && _isSeatLimitReached()) {
      _showSeatLimitError();
      return;
    }

    bookingData.update((val) {
      if (val == null) return;

      switch (type) {
        case 'adult':
          _updateAdultCount(val, increment);
          break;
        case 'child':
          _updateChildCount(val, increment);
          break;
        case 'infant':
          _updateInfantCount(val, increment);
          break;
      }
    });
  }

  bool _isSeatLimitReached() {
    return bookingData.value.totalPassengers >=
        bookingData.value.availableSeats;
  }

  void _updateAdultCount(BookingData val, bool increment) {
    if (increment) {
      val.adults++;
      val.passengers.add(Passenger(title: 'Mr'));
    } else if (val.adults > 1) {
      val.adults--;
      val.passengers.removeWhere((p) => adultTitles.contains(p.title));
    }
  }

  void _updateChildCount(BookingData val, bool increment) {
    if (increment) {
      val.children++;
      val.passengers.add(Passenger(title: 'Mstr'));
    } else if (val.children > 0) {
      val.children--;
      val.passengers.removeWhere((p) => childTitles.contains(p.title));
    }
  }

  void _updateInfantCount(BookingData val, bool increment) {
    if (increment) {
      val.infants++;
      val.passengers.add(Passenger(title: 'INF'));
    } else if (val.infants > 0) {
      val.infants--;
      val.passengers.removeWhere((p) => infantTitles.contains(p.title));
    }
  }

  void showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: TColors.red.withOpacity(0.1),
      colorText: TColors.red,
    );
  }

  void showSuccessSnackbar(String message) {
    Get.snackbar(
      'Success',
      message,
      backgroundColor: Colors.green.withOpacity(0.1),
      colorText: Colors.green,
    );
  }

  void _showSeatLimitError() {
    showErrorSnackbar(
      'Cannot add more passengers. Available seats limit reached.',
    );
  }
}
