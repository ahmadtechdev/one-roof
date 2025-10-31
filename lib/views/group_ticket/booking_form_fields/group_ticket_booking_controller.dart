// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oneroof/utility/colors.dart';
import 'package:oneroof/views/group_ticket/booking_form_fields/model.dart';
import 'package:oneroof/views/users/login/login_api_service/login_api.dart';
import '../../../services/api_service_group_tickets.dart';
import '../flight_pkg/pkg_model.dart';
import 'print_voucher/print_voucher.dart';

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
  @override
  void onInit() {
    super.onInit();
    // Initialize with existing GuestsController data
    loadUserEmail();
  }

  Future<void> loadUserEmail() async {
    try {
      // Import the AuthController to access user data
      final authController = Get.find<AuthController>();

      // First check if user is actually logged in (this will validate token)
      final isLoggedIn = await authController.isLoggedIn();

      if (!isLoggedIn) {
        // Token is expired or invalid - clear all fields
        booker_email.value = '';
        booker_name.value = '';
        booker_num.value = '';

        if (kDebugMode) {
          print("User token expired or invalid - cleared user data");
        }

        
        return;
      }

      // Token is valid - get user data
      final userData = await authController.getUserData();

      if (userData != null) {
        // Set the email controller with the user's email
        if (userData['cs_email'] != null) {
          booker_email.value = userData['cs_email'];
          if (kDebugMode) {
            print("user email ${booker_email.value}");
          }
        }

        // Set the name controller with the user's name
        if (userData['cs_fname'] != null) {
          booker_name.value = userData['cs_fname'];
          if (kDebugMode) {
            print("user name ${booker_name.value}");
          }
        }

        // Set the phone controller with the user's phone
        if (userData['cs_phone'] != null) {
          booker_num.value = userData['cs_phone'];
          if (kDebugMode) {
            print("user phone ${booker_num.value}");
          }
        }

        if (kDebugMode) {
          print("All user data loaded successfully");
          print("Name: ${booker_name.value}");
          print("Email: ${booker_email.value}");
          print("Phone: ${booker_num.value}");
        }
      } else {
        // No user data found - clear fields
        booker_email.value = '';
        booker_name.value = '';
        booker_num.value = '';

        if (kDebugMode) {
          print("No user data found - fields cleared");
        }
      }
    } catch (e) {
      // On error, clear all fields
      booker_email.value = '';
      booker_name.value = '';
      booker_num.value = '';

      if (kDebugMode) {
        print('Error loading user data: $e');
      }

      // Optional: Show error message
      Get.snackbar(
        'Error',
        'Failed to load user data. Please try again.',
        backgroundColor: TColors.red.withOpacity(0.1),
        colorText: TColors.red,
      );
    }
  }

  // Also add this method to refresh user data when needed
  Future<void> refreshUserData() async {
    await loadUserEmail();
  }

  // Add this method to check authentication status before critical operations
  Future<bool> validateUserSession() async {
    try {
      final authController = Get.find<AuthController>();
      final isLoggedIn = await authController.isLoggedIn();

      if (!isLoggedIn) {
        // Clear user data fields
        booker_email.value = '';
        booker_name.value = '';
        booker_num.value = '';

        // Show session expired message

        return false;
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error validating user session: $e');
      }
      return false;
    }
  }

  var totelfare = 0.obs;
  // bookerdata
  var booker_name = "".obs;
  var booker_email = "".obs;

  var booker_num = "".obs;

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
    bookingData.update((val) {
      if (val == null) return;

      val.groupId = flight.group_id;
      val.groupName =
          '${flight.airline}-${flight.segments.first.origin}-${flight.segments.last.destination}';
      val.sector = '${flight.segments.first.origin}-${flight.segments.last.destination}';
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

  final RxBool isLoading = false.obs;

  /// Submits the booking to the API
  /// Updated submitBooking method in GroupTicketBookingController
  Future<void> submitBooking() async {
    // if (!isFormValid.value) {
    //   showErrorSnackbar('Please fill in all required fields correctly.');
    //   return;
    // }

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

      // First API call - saveBooking
      final result = await apiController.saveBooking(
        groupId: bookingData.value.groupId,
        agentName: booker_name.value,
        agencyName: 'ONE ROOF TRAVEL',
        email: booker_email.value,
        mobile: booker_num.value,
        adults: bookingData.value.adults,
        children:
            bookingData.value.children > 0 ? bookingData.value.children : null,
        infants:
            bookingData.value.infants > 0 ? bookingData.value.infants : null,
        passengers: passengers,
        groupPriceDetailId: bookingData.value.groupPriceDetailId,
      );

      // Check if first API call was successful
      if (result['success'] != true) {
        isLoading.value = false;
        showErrorSnackbar(result['message'] ?? 'Failed to save booking');
        return;
      }

      // Second API call - saveBooking_into_database (pass the first result)
      final result2 = await apiController.saveBooking_into_database(
        groupId: bookingData.value.groupId,

        adults: bookingData.value.adults,
        children:
            bookingData.value.children > 0 ? bookingData.value.children : null,
        infants:
            bookingData.value.infants > 0 ? bookingData.value.infants : null,
        passengers: passengers,
        groupPriceDetailId: bookingData.value.groupPriceDetailId,
        bookername:
            booker_name.value.isNotEmpty ? booker_name.value : "OneRoofTravel",
        bookername_num:
            booker_num.value.isNotEmpty ? booker_num.value : "03001232412",
        booker_email:
            booker_email.value.isNotEmpty
                ? booker_email.value
                : "resOneroof@gmail.com",
        // Additional parameters
        noOfSeats: bookingData.value.totalPassengers,
        fares: bookingData.value.totalPrice,
        airlineName:
            bookingData.value.groupName.split(
              '-',
            )[0], // Extract airline from group name
        // Pass the saveBooking response data
        saveBookingResponse: result,
      );

      // Hide loading
      isLoading.value = false;

      // Check results from both API calls
      if (result['success'] == true) {
        String successMessage =
            result['message'] ?? 'Booking saved successfully';

        // Add database save status to message
        if (result2['success'] == true) {
          successMessage += ' and saved to database.';
        } else {
          successMessage +=
              ', but failed to save to database: ${result2['message']}';
        }

        showSuccessSnackbar(successMessage);

        // Print full result data in chunks
        printLargeData("Booking API Result: ${jsonEncode(result)}");
        printLargeData("Database API Result: ${jsonEncode(result2)}");

        // Navigate to PDF print screen with the API response data
        Get.to(() => PDFPrintScreen(bookingData: result));
      } else {
        showErrorSnackbar(result['message'] ?? 'Booking failed');
      }
    } catch (e) {
      // Hide loading on error
      isLoading.value = false;
      showErrorSnackbar('An error occurred while processing your booking: $e');

      if (kDebugMode) {
        print('submitBooking error: $e');
      }
    }
  } // Helper function to print large data in chunks

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
      return SizedBox(
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
        groupPriceDetailId: bookingData.value.groupPriceDetailId,
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
        groupPriceDetailId: bookingData.value.groupPriceDetailId,
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
