import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oneroof/widgets/date_range_slector.dart';
import '../../../../services/api_service_hotel.dart';
import '../../../../widgets/colors.dart';
import '../../../../widgets/custom_textfield.dart';
import '../../../../widgets/loading_dailog.dart';
import '../search_hotels/search_hotel.dart';
import '../search_hotels/search_hotel_controller.dart';
import 'guests/guests_controller.dart';
import 'hotel_date_controller.dart';
import 'guests/guests_field.dart';

class HotelFormScreen extends StatelessWidget {
  const HotelFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  TColors.primary.withOpacity(0.9),
                  TColors.secondary.withOpacity(0.9),
                ],
              ),
            ),
          ),

          // Curved white background
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: TColors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 15,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
            ),
          ),

          // App Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: Text(
                'Find Your Perfect Hotel',
                style: TextStyle(
                  color: TColors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 70),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: HotelForm(),
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
}

class HotelForm extends StatelessWidget {
  HotelForm({super.key}) {
    // Initialize both controllers
    Get.find<HotelDateController>();
    Get.find<SearchHotelController>();
  }

  @override
  Widget build(BuildContext context) {
    final cityController = TextEditingController();
    final hotelDateController = Get.find<HotelDateController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          hintText: 'Enter City Name',
          icon: Icons.location_on,
          controller: cityController,
        ),
        const SizedBox(height: 16),
        Obx(
          () => CustomDateRangeSelector(
            dateRange: hotelDateController.dateRange.value,
            onDateRangeChanged: hotelDateController.updateDateRange,
            nights: hotelDateController.nights.value,
            onNightsChanged: hotelDateController.updateNights,
          ),
        ),
        const SizedBox(height: 16),
        const GuestsField(),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () async {
            // Show loading dialog
            Get.dialog(const LoadingDialog(), barrierDismissible: false);

            final hotelDateController = Get.find<HotelDateController>();
            final guestsController = Get.find<GuestsController>();

            // Prepare API parameters
            String destinationCode = "160-0";
            String countryCode = "AE";
            String nationality = "AE";
            String currency = "USD";
            String checkInDate =
                hotelDateController.checkInDate.value.toIso8601String();
            String checkOutDate =
                hotelDateController.checkOutDate.value.toIso8601String();

            // Create rooms array with the new structure
            List<Map<String, dynamic>> rooms = List.generate(
              guestsController.roomCount.value,
              (index) => {
                "RoomIdentifier": index + 1,
                "Adult": guestsController.rooms[index].adults.value,
                "Children": guestsController.rooms[index].children.value,
                if (guestsController.rooms[index].children.value > 0)
                  "ChildrenAges":
                      guestsController.rooms[index].childrenAges.toList(),
              },
            );

            try {
              // Call the API
              await ApiServiceHotel().fetchHotels(
                destinationCode: destinationCode,
                countryCode: countryCode,
                nationality: nationality,
                currency: currency,
                checkInDate: checkInDate,
                checkOutDate: checkOutDate,
                rooms: rooms,
              );

              // Close loading dialog
              Get.back();

              // Navigate to the hotel listing screen
              Get.to(() => const HotelScreen());
            } catch (e) {
              // Close loading dialog
              Get.back();

              // Show error dialog
              Get.dialog(
                Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Something went wrong',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please try again later.',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => Get.back(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TColors.primary,
                            minimumSize: const Size(200, 45),
                          ),
                          child: const Text(
                            'OK',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                barrierDismissible: false,
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: TColors.primary,
            minimumSize: const Size.fromHeight(48),
          ),
          child: const Text(
            'Search Hotels',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
