import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../utility/colors.dart';
import '../../search_flight_utils/widgets/pia_flight_card.dart';
import 'pia_flight_model.dart';
import 'pia_flight_controller.dart';
import 'pia_return_flight_page.dart';

class PIAPackageSelectionDialog extends StatelessWidget {
  final PIAFlight flight;
  final bool isReturnFlight;
  final RxBool isLoading = false.obs;

  PIAPackageSelectionDialog({
    super.key,
    required this.flight,
    required this.isReturnFlight,
  });

  final PageController _pageController = PageController(viewportFraction: 0.9);
  final piaController = Get.find<PIAFlightController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.background,
      appBar: AppBar(
        backgroundColor: TColors.background,
        surfaceTintColor: TColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Text(
          isReturnFlight
              ? 'Select Return Flight Package'
              : 'Select Flight Package',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [_buildFlightInfo(), Expanded(child: _buildPackagesList())],
      ),
    );
  }

  Widget _buildFlightInfo() {
    return PIAFlightCard(flight: flight);
  }

  Widget _buildPackagesList() {
    final List<PIAFareOption> fareOptions = piaController
        .getFareOptionsForFlight(flight);

    if (fareOptions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber_rounded, size: 48, color: Colors.amber),
            SizedBox(height: 16),
            Text(
              'No packages available for this flight',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Text(
              'Please select another flight',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
          child: Text(
            'Available Packages',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: TColors.text,
            ),
          ),
        ),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            padEnds: false,
            itemCount: fareOptions.length,
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double value = 1.0;
                  if (_pageController.position.haveDimensions) {
                    value = _pageController.page! - index;
                    value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
                  }
                  return Transform.scale(
                    scale: Curves.easeOutQuint.transform(value),
                    child: _buildPackageCard(fareOptions[index], index),
                  );
                },
              );
            },
          ),
        ),
        SizedBox(
          height: 50,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                fareOptions.length,
                (index) => AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    double value = 0;
                    if (_pageController.position.haveDimensions) {
                      value = _pageController.page! - index;
                    }
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: value.abs() < 0.5 ? 24 : 8,
                      decoration: BoxDecoration(
                        color:
                            value.abs() < 0.5
                                ? TColors.primary
                                : TColors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPackageCard(PIAFareOption package, int index) {
    final headerColor = TColors.primary;
    final isSoldOut = false;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: TColors.background,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with package name
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [headerColor, headerColor.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Center(
              child: Text(
                package.fareName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: TColors.background,
                ),
              ),
            ),
          ),

          // Package details
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildPackageDetail(
                      Icons.luggage,
                      'Hand Baggage',
                      '7 KG', // Standard for PIA
                    ),
                    const SizedBox(height: 8),
                    _buildPackageDetail(
                      Icons.luggage,
                      'Checked Baggage',
                      package.baggageAllowance.weight > 0
                          ? '${package.baggageAllowance.weight} ${package.baggageAllowance.unit}'
                          : '${package.baggageAllowance.pieces} piece(s)',
                    ),
                    const SizedBox(height: 8),
                    _buildPackageDetail(
                      Icons.restaurant,
                      'Meal',
                      getMealInfo(
                        package.rawData['flightSegment']?['flightNotes']?['note'] ??
                            'N',
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildPackageDetail(
                      Icons.airline_seat_recline_normal,
                      'Cabin Class',
                      package.cabinClass,
                    ),
                    const SizedBox(height: 8),
                    _buildPackageDetail(
                      Icons.change_circle,
                      'Change Fee',
                      package.changeFee,
                    ),
                    const SizedBox(height: 8),
                    _buildPackageDetail(
                      Icons.currency_exchange,
                      'Refund Fee',
                      package.refundFee,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Price and button
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  '${package.currency} ${package.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: TColors.text,
                  ),
                ),
                const SizedBox(height: 12),
                Obx(
                  () => ElevatedButton(
                    onPressed:
                        isSoldOut || isLoading.value
                            ? null
                            : () => onSelectPackage(index),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isSoldOut ? Colors.grey : TColors.primary,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 2,
                    ),
                    child:
                        isLoading.value
                            ? const CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                TColors.background,
                              ),
                            )
                            : Text(
                              isReturnFlight
                                  ? 'Select Return Package'
                                  : 'Select Package',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: TColors.background,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageDetail(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: TColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, color: TColors.grey),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: TColors.text,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String getMealInfo(String mealCode) {
    switch (mealCode.toUpperCase()) {
      case 'P':
        return 'Alcoholic beverages for purchase';
      case 'C':
        return 'Complimentary alcoholic beverages';
      case 'B':
        return 'Breakfast';
      case 'K':
        return 'Continental breakfast';
      case 'D':
        return 'Dinner';
      case 'F':
        return 'Food for purchase';
      case 'G':
        return 'Food/Beverages for purchase';
      case 'M':
        return 'Meal';
      case 'N':
        return 'No meal service';
      case 'R':
        return 'Complimentary refreshments';
      case 'V':
        return 'Refreshments for purchase';
      case 'S':
        return 'Snack';
      default:
        return 'No Meal';
    }
  }

  void onSelectPackage(int selectedPackageIndex) async {
    try {
      isLoading.value = true;

      final List<PIAFareOption> fareOptions = piaController
          .getFareOptionsForFlight(flight);
      final selectedFareOption = fareOptions[selectedPackageIndex];

      if (piaController.isRoundTrip.value) {
        if (!isReturnFlight) {
          // Store outbound selection and show return flights
          piaController.selectedOutboundFareOption = selectedFareOption;
          Get.back(); // Close package dialog
          piaController.showReturnFlights.value = true;
          Get.to(
            () => PIAReturnFlightsPage(
              returnFlights: piaController.inboundFlights,
            ),
          );
        } else {
          // Store return selection and proceed to booking
          piaController.selectedReturnFareOption = selectedFareOption;
          Get.back(); // Close package dialog
          Get.snackbar(
            'Success',
            'Round trip package selected successfully',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            icon: const Icon(Icons.check_circle, color: Colors.white),
            duration: const Duration(seconds: 3),
          );
          // TODO: Navigate to booking page
        }
      } else {
        // For one-way or multi-city
        piaController.selectedOutboundFareOption = selectedFareOption;
        Get.back(); // Close package dialog
        Get.snackbar(
          'Success',
          piaController.isMultiCity.value
              ? 'Multi-city package selected successfully'
              : 'One-way package selected successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
          duration: const Duration(seconds: 3),
        );
        // TODO: Navigate to booking page
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to select package. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error_outline, color: Colors.white),
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
