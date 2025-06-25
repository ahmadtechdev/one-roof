import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';

import 'package:oneroof/views/group_ticket/group_ticket.dart';
import 'package:oneroof/views/hotel/hotel/hotel_form.dart';
import 'package:oneroof/views/users/login/login.dart';

import '../../utility/colors2.dart';
import '../flight/form/flight_form.dart';
import '../group_ticket/airline/data_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.background,

        appBar: AppBar(
          title: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Image.asset(
                  "assets/images/oneroof.png",
                  height: 170,
                  width: 100,
                  fit: BoxFit.cover,
                  scale: 1.0,
                ),
              ),
            ],
          ),
          automaticallyImplyLeading: false, // 👈 back arrow will not be shown
          backgroundColor: Colors.white,
          elevation: 2,
          shadowColor: TColors.primary.withOpacity(0.1),
          actions: [
            Container(
              margin: EdgeInsets.only(right: 12),
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: TColors.primary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: TColors.third.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(Icons.person, color: Colors.white),
                onPressed: () {
                  Get.to(() => Login());
                },
              ),
            ),
          ],
        ),

      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // First Section - Main Travel Options
            Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: TColors.primary.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.to(() => FlightBookingScreen());
                    },
                    child: _buildTravelOption(
                      'Flights',
                      Icons.flight,
                      TColors.primary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.to(() => HotelFormScreen());
                    },
                    child: _buildTravelOption(
                      'Hotels',
                      Icons.hotel,
                      TColors.secondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      TravelDataController().loadAirlines();
                      Get.to(() => GroupTicket());
                    },
                    child: _buildTravelOption(
                      'Group Tickets',
                      Icons.train,
                      TColors.third,
                    ),
                  ),
                ],
              ),
            ),

            // Second Section - 8 Options Grid
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                childAspectRatio: 1.0,
                children: [
                  _buildGridItem('Flight + Hotel', Icons.card_travel, TColors.third),
                  _buildGridItem('Bus', Icons.directions_bus, TColors.third),
                  _buildGridItem('Activities', Icons.local_activity, TColors.third),
                  _buildGridItem('Forex', Icons.currency_exchange, TColors.third),
                  _buildGridItem('Activities', Icons.celebration, TColors.third),
                  _buildGridItem('Gift Card', Icons.card_giftcard, TColors.third),
                  _buildGridItem('Trains', Icons.train, TColors.third),
                  _buildGridItem('Experiences', Icons.explore, TColors.third),
                ],
              ),
            ),

            Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Why Book With Us?',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  _buildReasonCard(
                    Icons.headset_mic,
                    '24/7 Customer Support',
                    'Our concierge team is on standby to help you out in any situation',
                    TColors.primary,
                  ),
                  SizedBox(height: 16),
                  _buildReasonCard(
                    Icons.security,
                    'Secure Booking Process',
                    'Feel safe during your booking process using the latest encryption',
                    TColors.primary,
                  ),
                  SizedBox(height: 16),
                  _buildReasonCard(
                    Icons.verified_user,
                    'Trusted by Members',
                    'Over millions of people worldwide trust us as their travel partner',
                    TColors.primary,
                  ),
                  SizedBox(height: 16),
                  _buildReasonCard(
                    Icons.people,
                    '20 Million Happy Members',
                    'Join our family of travelers for a friendly flight experience',
                    TColors.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTravelOption(String title, IconData icon, Color color) {
    return Container(
      width: 80,
      height: 100,
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem(String title, IconData icon, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        SizedBox(height: 4),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildReasonCard(IconData icon, String title, String description, Color color) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}