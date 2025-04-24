import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../services/api_service_flight.dart';
import '../../../../../utility/colors.dart';
import '../../../../../widgets/travelers_selection_bottom_sheet.dart';
import '../../../form/controllers/flight_date_controller.dart';
import '../../search_flight_utils/airblue_flight_controller.dart';
import '../../search_flight_utils/models/airblue_flight_model.dart';
import '../../search_flight_utils/widgets/airblue_flight_card.dart';


class AirBluePackageSelectionDialog extends StatelessWidget {
  final AirBlueFlight flight;
  final bool isAnyFlightRemaining;
  final RxBool isLoading = false.obs;

  // Cache for margin data and calculated prices
  final Rx<Map<String, dynamic>> marginData = Rx<Map<String, dynamic>>({});
  final Map<String, RxDouble> finalPrices = {};

  AirBluePackageSelectionDialog({
    super.key,
    required this.flight,
    required this.isAnyFlightRemaining,
  });

  final PageController _pageController = PageController(viewportFraction: 0.9);
  final airBlueController = Get.find<AirBlueFlightController>();
  final flightDateController = Get.find<FlightDateController>();
  late final travelersController = Get.find<TravelersController>();

  @override
  Widget build(BuildContext context) {
    // Pre-fetch margin data when dialog opens
    _prefetchMarginData();

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
          isAnyFlightRemaining
              ? 'Select Return Flight Package'
              : 'Select Flight Package',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          _buildFlightInfo(),
          Expanded(
            child: _buildPackagesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFlightInfo() {
    return AirBlueFlightCard(flight: flight, showReturnFlight: false);
  }

  Future<void> _prefetchMarginData() async {
    try {
      if (marginData.value.isEmpty) {
        final apiService = Get.find<ApiServiceFlight>();
        marginData.value = await apiService.getMargin();
      }

      // Pre-calculate prices for all fare options
      final fareOptions = airBlueController.getFareOptionsForFlight(flight);
      for (var option in fareOptions) {
        final String packageKey = '${option.cabinCode}-${option.brandName}';
        if (!finalPrices.containsKey(packageKey)) {
          final apiService = Get.find<ApiServiceFlight>();
          final price = apiService.calculatePriceWithMargin(
            option.price,
            marginData.value,
          );
          finalPrices[packageKey] = price.obs;
        }
      }
    } catch (e) {
      print('Error prefetching margin data: $e');
    }
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

  Widget _buildPackagesList() {
    // Get fare options for the selected flight based on RPH
    final List<AirBlueFareOption> fareOptions = airBlueController.getFareOptionsForFlight(flight);

    // Handle empty state
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
                        color: value.abs() < 0.5
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

  Widget _buildPackageCard(AirBlueFareOption package, int index) {
    final headerColor = package.seatsAvailable <= 0 ? Colors.grey : TColors.primary;
    final isSoldOut = package.seatsAvailable <= 0;

    // Generate unique key for this package
    final String packageKey = '${package.cabinCode}-${package.brandName}';

    // Initialize price for this package if not already done
    if (!finalPrices.containsKey(packageKey)) {
      final apiService = Get.find<ApiServiceFlight>();
      try {
        final price = apiService.calculatePriceWithMargin(
          package.price,
          marginData.value,
        );
        finalPrices[packageKey] = price.obs;
      } catch (e) {
        finalPrices[packageKey] = package.price.obs;
      }
    }

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
          // Header section with package name and price
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        package.brandName.isNotEmpty
                            ? package.brandName
                            : package.cabinName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: TColors.background,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (!isSoldOut)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Obx(() => Text(
                        finalPrices[packageKey]?.value.toStringAsFixed(2) ?? package.price.toStringAsFixed(2),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: TColors.background,
                        ),
                      )),
                      Text(
                        package.currency,
                        style: TextStyle(
                          fontSize: 14,
                          color: TColors.background.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                if (isSoldOut)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: TColors.background.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'SOLD OUT',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: TColors.background,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Package details section
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildPackageDetail(
                      Icons.airline_seat_recline_normal,
                      'Cabin',
                      package.cabinName,
                    ),
                    const SizedBox(height: 12),
                    _buildPackageDetail(
                      Icons.luggage,
                      'Baggage',
                      isSoldOut
                          ? 'Not available'
                          : package.baggageAllowance,
                    ),
                    const SizedBox(height: 12),
                    _buildPackageDetail(
                      Icons.restaurant,
                      'Meal',
                      isSoldOut
                          ? 'Not available'
                          : getMealInfo(package.mealCode),
                    ),
                    const SizedBox(height: 12),
                    _buildPackageDetail(
                      Icons.event_seat,
                      'Seats Available',
                      isSoldOut
                          ? '0'
                          : package.seatsAvailable.toString(),
                    ),
                    _buildPackageDetail(
                      Icons.currency_exchange,
                      'Refundable',
                      isSoldOut
                          ? 'Not applicable'
                          : (package.isRefundable
                          ? 'Refundable'
                          : 'Non-Refundable'),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Button section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Obx(
                  () => ElevatedButton(
                onPressed: isSoldOut || isLoading.value
                    ? null
                    : () => onSelectPackage(index),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSoldOut ? Colors.grey : TColors.primary,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 2,
                ),
                child: isLoading.value
                    ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      TColors.background,
                    ),
                  ),
                )
                    : Text(
                  isSoldOut
                      ? 'Not Available'
                      : (isAnyFlightRemaining
                      ? 'Select Return Package'
                      : 'Select Package'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSoldOut
                        ? Colors.white70
                        : TColors.background,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildPackageDetail(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: TColors.secondary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: TColors.primary, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: TColors.grey),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
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

  void onSelectPackage(int selectedPackageIndex) async {
    try {
      isLoading.value = true;

      // Get all fare options for this flight
      final List<AirBlueFareOption> fareOptions = airBlueController.getFareOptionsForFlight(flight);

      // Get the selected fare option
      final selectedFareOption = fareOptions[selectedPackageIndex];

      // // Navigate to review page
      // Get.to(
      //       () => ReviewAirBlueTripPage(
      //     isMulti: false,
      //     flight: flight,
      //     selectedFareOption: selectedFareOption,
      //   ),
      // );
    } catch (e) {
      print('Error selecting AirBlue flight package: $e');
      Get.snackbar(
        'Error',
        'This flight package is no longer available. Please select another option.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false; // Hide loader
    }
  }
}