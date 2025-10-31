import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:oneroof/utility/colors.dart';
import 'package:oneroof/views/home/home_screen.dart';
import 'package:oneroof/views/users/login/login_api_service/login_api.dart';
import 'package:oneroof/b2b/agent_dashboard/agent_dashboard.dart';
import 'package:oneroof/b2b/all_flight_booking/all_flight_booking.dart';
import 'package:oneroof/b2b/all_hotel_booking/all_hotel_booking.dart';
import 'package:oneroof/b2b/all_group_booking/all_group_booking.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    return FutureBuilder<Map<String, dynamic>?>(
      future: authController.getUserData(),
      builder: (context, snapshot) {
        final userData = snapshot.data ?? {};
        return Drawer(
          width: MediaQuery.of(context).size.width / 1.4,
          child: Container(
            color: TColors.white,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(color: TColors.primary),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: TColors.white,
                            radius: 30,
                            child: userData['cs_logo'] != null
                                ? Image.network(userData['cs_logo'])
                                : Icon(
                                    Icons.person,
                                    size: 30,
                                    color: TColors.primary,
                                  ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              userData['cs_company'] ?? 'Journey Online',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: TColors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildDrawerItem(context, Icons.person, 'Profile', () {
                  Get.to(() => const AgentDashboard());
                }),
                _buildDrawerItem(context, Icons.home, 'Home', () {
                  Get.to(() => const HomeScreen());
                }),
                _buildDrawerItem(context, Icons.flight, 'Flight Bookings', () {
                  Get.to(() => AllFlightBookingScreen());
                }),
                _buildDrawerItem(context, Icons.hotel, 'Hotel Bookings', () {
                  Get.to(() => AllHotelBooking());
                }),
                _buildDrawerItem(context, Icons.group, 'Group Bookings', () {
                  Get.to(() => AllGroupBooking());
                }),
                _buildDrawerItem(context, Icons.logout, 'Logout', () async {
                  await authController.logout();
                  Get.offAll(() => const HomeScreen());
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: TColors.text),
      title: Text(
        title,
        style: const TextStyle(
          color: TColors.text,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }
}


