import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oneroof/b2b/all_flight_booking/all_flight_booking.dart';
import 'package:oneroof/b2b/all_group_booking/all_group_booking.dart';
import 'package:oneroof/utility/colors.dart';
import 'package:oneroof/views/home/home_screen.dart';
import 'package:oneroof/views/users/login/login_api_service/login_api.dart';

import '../all_hotel_booking/all_hotel_booking.dart';

class AgentDashboard extends StatefulWidget {
  const AgentDashboard({super.key});

  @override
  State<AgentDashboard> createState() => _AgentDashboardState();
}

class _AgentDashboardState extends State<AgentDashboard> {
  final _formKey = GlobalKey<FormState>();
  final authController = Get.find<AuthController>();

  // Initialize with empty map
  Map<String, dynamic> userData = {};
  bool isLoading = true;

  // Controllers for form fields
  late TextEditingController _agencyNameController;
  late TextEditingController _emailController;
  late TextEditingController _contactPersonController;
  late TextEditingController _phoneController;
  late TextEditingController _whatsappController;
  late TextEditingController _cityController;
  late TextEditingController _countryController;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final data = await authController.getUserData();
    if (data != null) {
      setState(() {
        userData = data;
        _initializeControllers();
        isLoading = false;
      });
    } else {
      setState(() {
        _initializeControllers();
        isLoading = false;
      });
    }
  }

  void _initializeControllers() {
    _agencyNameController = TextEditingController(
      text: userData['cs_company'] ?? "Journey Online",
    );
    _emailController = TextEditingController(
      text: userData['cs_email'] ?? "tech@sastayhotels.pk",
    );
    _contactPersonController = TextEditingController(
      text: userData['cs_fname'] ?? "Journey Online",
    );
    _phoneController = TextEditingController(
      text: userData['cs_phone'] ?? "+92 3377513",
    );
    _whatsappController = TextEditingController(
      text: userData['cs_whatsapp'] ?? "",
    );
    _cityController = TextEditingController(
      text: userData['cs_city'] ?? "Faisalabad",
    );
    _countryController = TextEditingController(
      text: userData['cs_country'] ?? "Pakistan",
    );
  }

  @override
  void dispose() {
    _agencyNameController.dispose();
    _emailController.dispose();
    _contactPersonController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: TColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: TColors.background,
      appBar: AppBar(
        backgroundColor: TColors.primary,
        elevation: 0,
        title: const Text(
          'My Profile',
          style: TextStyle(color: TColors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      drawer: _buildDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_buildHeader(), _buildProfileForm()],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Profile',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: TColors.secondary,
            ),
          ),
          // const SizedBox(height: 8),
          // Text(
          //   'Keep your agency information up to date',
          //   style: TextStyle(fontSize: 14, color: TColors.grey),
          // ),
        ],
      ),
    );
  }

  Widget _buildProfileForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFormRow(
              'Agency Name',
              _buildTextField(
                controller: _agencyNameController,
                hintText: 'Agency name',
              ),
            ),
            const SizedBox(height: 20),
            _buildFormRow(
              'Contact Name',
              _buildTextField(
                controller: _contactPersonController,
                hintText: 'Contact name',
              ),
            ),
            const SizedBox(height: 20),
            _buildFormRow(
              'Email',
              _buildTextField(
                controller: _emailController,
                hintText: 'Email address',
                keyboardType: TextInputType.emailAddress,
              ),
            ),
            const SizedBox(height: 20),
            _buildFormRow(
              'Phone Number',
              _buildTextField(
                controller: _phoneController,
                hintText: 'Phone number',
                keyboardType: TextInputType.phone,
              ),
            ),
            const SizedBox(height: 20),
            _buildFormRow(
              'WhatsApp Number',
              _buildTextField(
                controller: _whatsappController,
                hintText: 'WhatsApp number',
                keyboardType: TextInputType.phone,
              ),
            ),
            const SizedBox(height: 20),
            _buildFormRow(
              'City/District',
              _buildTextField(
                controller: _cityController,
                hintText: 'City/District',
              ),
            ),
            const SizedBox(height: 20),
            _buildFormRow(
              'Country',
              _buildTextField(
                controller: _countryController,
                hintText: 'Country',
              ),
            ),
            const SizedBox(height: 30),
            _buildLogoUploadSection(),
            const SizedBox(height: 30),
            _buildUpdateButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ... rest of your existing methods remain the same ...

  Widget _buildFormRow(String label, Widget field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: TColors.secondary,
          ),
        ),
        const SizedBox(height: 8),
        field,
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: true,
        enableInteractiveSelection: false,
        showCursor: false,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: TColors.placeholder),
          filled: true,
          fillColor: TColors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: TColors.primary, width: 1.5),
          ),
        ),
        style: const TextStyle(fontSize: 16, color: TColors.text),
      ),
    );
  }

  Widget _buildLogoUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upload New Logo',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: TColors.secondary,
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () {
            // Handle file selection
          },
          child: Container(
            decoration: BoxDecoration(
              color: TColors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.cloud_upload_outlined, color: TColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Choose File',
                    style: TextStyle(
                      color: TColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  'No file chosen',
                  style: TextStyle(color: TColors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUpdateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            // Handle form submission
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile updated successfully')),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: TColors.primary,
          foregroundColor: TColors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 1,
        ),
        child: const Text(
          'Update',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      width: MediaQuery.of(context).size.width/1.4,
      child: Container(
        color: TColors.secondary,
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
            _buildDrawerItem(Icons.person, 'Profile', true, () {}),
            _buildDrawerItem(Icons.home, 'Home', false, () {
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
      leading: Icon(icon, color: isSelected ? TColors.primary : TColors.white),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? TColors.primary : TColors.white,
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
