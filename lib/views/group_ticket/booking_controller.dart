// booking_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oneroof/utility/colors.dart';
import 'package:oneroof/views/group_ticket/model.dart';

class BookingController extends GetxController {
  final bookingData = BookingData(
    groupName: 'saudi airline-LAHORE-RIYADH',
    sector: 'KSA',
    availableSeats: 8,
    adults: 1, // Default: 1 adult
    children: 0,
    infants: 0,
    adultPrice: 92500,
    childPrice: 92500,
    infantPrice: 92500,
  ).obs;

  List<String> adultTitles = ['Mr', 'Mrs', 'Ms'];
  List<String> childTitles = ['Mstr', 'Miss'];
  List<String> infantTitles = ['INF'];

  void incrementAdults() {
    if (bookingData.value.totalPassengers < bookingData.value.availableSeats) {
      var updatedData = BookingData(
        groupName: bookingData.value.groupName,
        sector: bookingData.value.sector,
        availableSeats: bookingData.value.availableSeats,
        adults: bookingData.value.adults + 1,
        children: bookingData.value.children,
        infants: bookingData.value.infants,
        adultPrice: bookingData.value.adultPrice,
        childPrice: bookingData.value.childPrice,
        infantPrice: bookingData.value.infantPrice,
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
        groupName: bookingData.value.groupName,
        sector: bookingData.value.sector,
        availableSeats: bookingData.value.availableSeats,
        adults: bookingData.value.adults - 1,
        children: bookingData.value.children,
        infants: bookingData.value.infants,
        adultPrice: bookingData.value.adultPrice,
        childPrice: bookingData.value.childPrice,
        infantPrice: bookingData.value.infantPrice,
      );
      bookingData.value = updatedData;
    }
  }

  void incrementChildren() {
    if (bookingData.value.totalPassengers < bookingData.value.availableSeats) {
      var updatedData = BookingData(
        groupName: bookingData.value.groupName,
        sector: bookingData.value.sector,
        availableSeats: bookingData.value.availableSeats,
        adults: bookingData.value.adults,
        children: bookingData.value.children + 1,
        infants: bookingData.value.infants,
        adultPrice: bookingData.value.adultPrice,
        childPrice: bookingData.value.childPrice,
        infantPrice: bookingData.value.infantPrice,
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
        groupName: bookingData.value.groupName,
        sector: bookingData.value.sector,
        availableSeats: bookingData.value.availableSeats,
        adults: bookingData.value.adults,
        children: bookingData.value.children - 1,
        infants: bookingData.value.infants,
        adultPrice: bookingData.value.adultPrice,
        childPrice: bookingData.value.childPrice,
        infantPrice: bookingData.value.infantPrice,
      );
      bookingData.value = updatedData;
    }
  }

  void incrementInfants() {
    if (bookingData.value.totalPassengers < bookingData.value.availableSeats) {
      var updatedData = BookingData(
        groupName: bookingData.value.groupName,
        sector: bookingData.value.sector,
        availableSeats: bookingData.value.availableSeats,
        adults: bookingData.value.adults,
        children: bookingData.value.children,
        infants: bookingData.value.infants + 1,
        adultPrice: bookingData.value.adultPrice,
        childPrice: bookingData.value.childPrice,
        infantPrice: bookingData.value.infantPrice,
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
        groupName: bookingData.value.groupName,
        sector: bookingData.value.sector,
        availableSeats: bookingData.value.availableSeats,
        adults: bookingData.value.adults,
        children: bookingData.value.children,
        infants: bookingData.value.infants - 1,
        adultPrice: bookingData.value.adultPrice,
        childPrice: bookingData.value.childPrice,
        infantPrice: bookingData.value.infantPrice,
      );
      bookingData.value = updatedData;
    }
  }

  // VALIDATION AND SUBMISSION
  final formKey = GlobalKey<FormState>();
  final isFormValid = false.obs;

  void validateForm() {
    isFormValid.value = formKey.currentState?.validate() ?? false;
  }

  void submitBooking() {
    if (formKey.currentState?.validate() ?? false) {
      // Process booking data
      Get.snackbar(
        'Success',
        'Booking submitted successfully!',
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );
      // Get.to(() => BookingSuccessScreen());
    } else {
      Get.snackbar(
        'Error',
        'Please fill in all required fields correctly.',
        backgroundColor: TColors.red.withOpacity(0.1),
        colorText: TColors.red,
      );
    }
  }
}