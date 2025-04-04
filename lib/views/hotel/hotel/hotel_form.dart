import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oneroof/widgets/date_range_slector.dart';
import 'package:flutter_animate/flutter_animate.dart'; // Add this package for animations

import '../../../../services/api_service_hotel.dart';
import '../../../../widgets/loading_dailog.dart';
import '../../../utility/colors.dart';
import '../../../widgets/hotel_custom_textfield.dart';
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
              title: const Text(
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
    final searchHotelController = Get.find<SearchHotelController>();

    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Decorative travel elements
          _buildDecorativeHeader()
              .animate()
              .fadeIn(duration: const Duration(milliseconds: 600))
              .slideY(
            begin: -0.2,
            end: 0,
            duration: const Duration(milliseconds: 600),
          ),

          const SizedBox(height: 30),

          // Field Title
          _buildSectionTitle('Where would you like to go?', Icons.location_on)
              .animate()
              .fadeIn(delay: const Duration(milliseconds: 200))
              .slideX(begin: -0.1, end: 0),

          const SizedBox(height: 12),

          // City Input Field
          _buildFormField(
            child: CustomTextField(
              hintText: 'Enter city or destination',
              icon: Icons.location_on,
              controller: cityController,
              onCitySelected: (city) async {
                // Show loading indicator
                Get.dialog(
                  const LoadingDialog(),
                  barrierDismissible: false,
                );

                try {
                  final hotelIds = await ApiServiceHotel().fetchHotelIds(
                    countryCode: city.countryCode,
                    zoneCode: city.zoneCode,
                    cityStateCode: city.cityStateCode,
                  );
                  searchHotelController.hotel_ids.value = hotelIds;
                  // Store the hotel IDs or use them as needed
                  print(
                    "Fetched hotel IDs: ${searchHotelController.hotel_ids}",
                  );

                  Get.back(); // Close loading dialog
                } catch (e) {
                  Get.back(); // Close loading dialog
                  Get.snackbar('Error', 'Failed to fetch hotel IDs');
                }
              },
            ),
          )
              .animate()
              .fadeIn(delay: const Duration(milliseconds: 300))
              .slideX(begin: 0.1, end: 0),

          const SizedBox(height: 24),

          // Field Title
          _buildSectionTitle(
            'When are you planning to travel?',
            Icons.calendar_today,
          )
              .animate()
              .fadeIn(delay: const Duration(milliseconds: 400))
              .slideX(begin: -0.1, end: 0),

          const SizedBox(height: 12),

          // Date Range Selector
          _buildFormField(
            child: Obx(
                  () => CustomDateRangeSelector(
                dateRange: hotelDateController.dateRange.value,
                onDateRangeChanged: hotelDateController.updateDateRange,
                nights: hotelDateController.nights.value,
                onNightsChanged: hotelDateController.updateNights,
              ),
            ),
          )
              .animate()
              .fadeIn(delay: const Duration(milliseconds: 500))
              .slideX(begin: 0.1, end: 0),

          const SizedBox(height: 24),

          // Field Title
          _buildSectionTitle('How many guests?', Icons.person)
              .animate()
              .fadeIn(delay: const Duration(milliseconds: 600))
              .slideX(begin: -0.1, end: 0),

          const SizedBox(height: 12),

          // Guests Field
          _buildFormField(child: const GuestsField())
              .animate()
              .fadeIn(delay: const Duration(milliseconds: 700))
              .slideX(begin: 0.1, end: 0),

          const SizedBox(height: 40),

          // Search Button
          Center(
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: _buildSearchButton(),
            ),
          )
              .animate()
              .fadeIn(delay: const Duration(milliseconds: 800))
              .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDecorativeHeader() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: TColors.primary.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.hotel, color: TColors.third, size: 30),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Find Your Dream Stay',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: TColors.text,
                    ),
                  ),
                  Text(
                    'Best prices guaranteed',
                    style: TextStyle(fontSize: 12, color: TColors.grey),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 7,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              children: [
                Container(
                  width: 120,
                  height: 7,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [TColors.primary, TColors.third],
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 5),
      child: Row(
        children: [
          Icon(icon, size: 18, color: TColors.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: TColors.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSearchButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [TColors.primary, TColors.secondary],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(27),
        boxShadow: [
          BoxShadow(
            color: TColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () async {
          // Show loading dialog
          Get.dialog(const LoadingDialog(), barrierDismissible: false);

          final hotelDateController = Get.find<HotelDateController>();
          final guestsController = Get.find<GuestsController>();

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
          print('the rooms is $rooms');

          try {
            var apiService = Get.put(ApiServiceHotel());

            // Call the API
            await apiService.fetchHotel(
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
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.white, Colors.grey.shade50],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: TColors.red,
                        size: 50,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Something went wrong',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: TColors.secondary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'We couldn\'t process your request. Please try again later.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 25),
                      ElevatedButton(
                        onPressed: () => Get.back(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TColors.primary,
                          minimumSize: const Size(200, 45),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                          elevation: 3,
                        ),
                        child: const Text(
                          'Try Again',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
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
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(27),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search, color: TColors.white),
            const SizedBox(width: 8),
            const Text(
              'Find Hotels',
              style: TextStyle(
                color: TColors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}