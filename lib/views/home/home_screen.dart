import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:oneroof/views/group_ticket/group_ticket.dart';
import 'package:oneroof/views/hotel/hotel/hotel_form.dart';
import 'package:oneroof/views/users/login/login.dart';
import 'package:oneroof/views/users/login/login_api_service/login_api.dart';
import 'package:oneroof/b2b/agent_dashboard/agent_dashboard.dart';

import '../../b2b/all_flight_booking/all_flight_booking.dart';
import '../../b2b/all_group_booking/all_group_booking.dart';
import '../../b2b/all_hotel_booking/all_hotel_booking.dart';
import '../../utility/colors2.dart';
import '../flight/form/flight_form.dart';
import '../group_ticket/airline/data_controller.dart';

class CustomerServiceSection extends StatelessWidget {
  const CustomerServiceSection({super.key});

  final String mobileNumber = "923137358881";

  Future<void> launchWhatsApp() async {
    String message = "OneRoof ";
    final url = "https://wa.me/$mobileNumber?text=${Uri.encodeComponent(message)}";

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> launchCall() async {
    final url = "tel:$mobileNumber";

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
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
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: TColors.primary.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.headset_mic,
                  color: TColors.primary,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '24/7 Customer Service',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'Speak to travel experts',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => launchCall(),
                  icon: const Icon(Icons.phone, size: 20),
                  label: const Text('Call'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: TColors.primary, width: 1),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => launchWhatsApp(),
                  icon: Icon(Icons.chat, size: 20, color: Colors.green),
                  label: const Text('WhatsApp'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: TColors.primary, width: 1),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final authController = Get.find<AuthController>();
  Map<String, dynamic> userData = {};
  bool isLoggedIn = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final loginStatus = await authController.isLoggedIn();
    if (loginStatus) {
      final data = await authController.getUserData();
      if (data != null) {
        setState(() {
          isLoggedIn = true;
          userData = data;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: TColors.background,
      drawer: isLoggedIn ? _buildDrawer() : null,
        appBar: AppBar(
          title: isLoggedIn 
            ? Center(
                child: Container(
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
              )
            : Row(
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
          automaticallyImplyLeading: isLoggedIn, // Show leading icon when logged in
          leading: isLoggedIn 
            ? IconButton(
                icon: Icon(Icons.menu, color: TColors.primary),
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
              )
            : null,
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
                  if (isLoggedIn) {
                    Get.to(() => AgentDashboard());
                  } else {
                    Get.to(() => Login());
                  }
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
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                childAspectRatio: 1.3,
                children: [
                  _buildGridItem('Umrah Package', Icons.mosque, TColors.third),
                  _buildGridItem('Visa', Icons.assignment_turned_in, TColors.third),
                  _buildGridItem('Insurance', Icons.health_and_safety, TColors.third),
                  _buildGridItem('Discount Sheet', Icons.receipt_long, TColors.third),
                  _buildGridItem('Upcoming Flights', Icons.flight_takeoff, TColors.third),
                  _buildGridItem('Transportation', Icons.directions_car, TColors.third),
                ],
              ),

            ),
            const SizedBox(height: 16),
            // Customer Service Section
            const CustomerServiceSection(),
            const SizedBox(height: 16),

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
                    Icons.security,
                    'Secure and Easy Booking Process',
                    'Feel safe during your booking process using the latest encryption',
                    TColors.primary,
                  ),
                  SizedBox(height: 16),
                  _buildReasonCard(
                    Icons.support_agent,
                    'Expert Staff',
                    'Our experienced team ensures personalized support and expert guidance at every step.',
                    TColors.primary,
                  ),
                  SizedBox(height: 16),
                  _buildReasonCard(
                    Icons.verified_user,
                    'Trusted by Members',
                    'Over thousands of people worldwide trust us as their travel partner',
                    TColors.primary,
                  ),
                  SizedBox(height: 16),
                  _buildReasonCard(
                    Icons.location_on,
                    'Meet and Assist (Address)',
                    'Enjoy hassle-free travel with our meet and assist service right at your provided address.',
                    TColors.primary,
                  ),


                ],
              ),
            ),
            SizedBox(height: 16),
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

  Widget _buildDrawer() {
    return Drawer(
      width: MediaQuery.of(context).size.width/1.4,
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
                      Text(
                        userData['cs_company'] ?? 'Journey Online',
                        style: TextStyle(
                          color: TColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  // Text(
                  //   userData['cs_email'] ?? 'tech@sastayhotels.pk',
                  //   style: TextStyle(color: TColors.white, fontSize: 12),
                  // ),
                ],
              ),
            ),
            _buildDrawerItem(Icons.person, 'Profile', false, () {
              Get.to(() => AgentDashboard());
            }),
            _buildDrawerItem(Icons.home, 'Home', true, () {
              Get.to(() => HomeScreen());
            }),
            _buildDrawerItem(Icons.flight, 'Flight Bookings', false, () {
              Get.to(() => AllFlightBookingScreen());
            }),
            _buildDrawerItem(Icons.hotel, 'Hotel Bookings', false, () {
              Get.to(() => AllHotelBooking());
            }),
            _buildDrawerItem(Icons.group, 'Group Bookings', false, () {
              Get.to(() => AllGroupBooking());
            }),
            _buildDrawerItem(Icons.logout, 'Logout', false, () async {
              await authController.logout();
              setState(() {
                isLoggedIn = false;
                userData = {};
              });
              Get.offAll(() => HomeScreen());
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    IconData icon,
    String title, [
    bool isSelected = false,
    Function()? onTapFunction,
  ]) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? TColors.third : TColors.text),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? TColors.third : TColors.text,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        Navigator.pop(context); // Close the drawer first
        if (onTapFunction != null) {
          onTapFunction(); // Then navigate to the appropriate screen
        }
      },
      selected: isSelected,
    );
  }
}