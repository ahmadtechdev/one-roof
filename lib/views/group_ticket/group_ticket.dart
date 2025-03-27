import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/api_service_group_tickets.dart';
import 'package:oneroof/utility/colors.dart';
import 'package:oneroof/views/group_ticket/flight_pkg/booking_page.dart';

class GroupTicket extends StatelessWidget {
  const GroupTicket({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/sky.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    alignment: const Alignment(-1, 0),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
                // Header
                const Text(
                  'Airline Groups',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black38,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
                // Subheader
                const Text(
                  'Groups you need...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 5.0,
                        color: Colors.black38,
                        offset: Offset(1.0, 1.0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // First row of cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: DestinationCard(
                          image: 'assets/images/1.png',
                          title: 'UAE One Way Groups',
                          onTap: () {
                            GroupTicketingController().fetchGroups('UAE');

                            Get.snackbar(
                              "Tapped!",
                              "UAE One Way Groups selected",
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DestinationCard(
                          image: 'assets/images/2.png',
                          title: 'KSA One Way Groups',
                          onTap: () {
                            GroupTicketingController().fetchGroups('KSA');
                            Get.to(() => SelectPkgScreen());
                            Get.snackbar(
                              "Tapped!",
                              "KSA One Way Groups selected",
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Second row of cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: DestinationCard(
                          image: 'assets/images/4.png',
                          title: 'OMAN One Way Groups',
                          onTap: () {
                            GroupTicketingController().fetchGroups('OMAN');

                            Get.snackbar(
                              "Tapped!",
                              "OMAN One Way Groups selected",
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DestinationCard(
                          image: 'assets/images/4.png',
                          title: 'UK One Way Groups',
                          onTap: () {
                            GroupTicketingController().fetchGroups('UK');

                            Get.snackbar(
                              "Tapped!",
                              "UK One Way Groups selected",
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Third row of cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: DestinationCard(
                          image: 'assets/images/5.png',
                          title: 'UMRAH',
                          onTap: () {
                            GroupTicketingController().fetchGroups('UMRAH');

                            Get.snackbar(
                              "Tapped!",
                              "UMRAH selected",
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DestinationCard(
                          image: 'assets/images/6.png',
                          title: 'All Types',
                          onTap: () {
                            GroupTicketingController().fetchGroups('');

                            Get.snackbar(
                              "Tapped!",
                              "All Types selected",
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DestinationCard extends StatelessWidget {
  final String image;
  final String title;
  final VoidCallback onTap;

  const DestinationCard({
    Key? key,
    required this.image,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: TColors.secondary, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              Positioned.fill(child: Image.asset(image, fit: BoxFit.cover)),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: TColors.secondary, width: 1),
                    ),
                  ),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
