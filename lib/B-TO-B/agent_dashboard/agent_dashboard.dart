import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/utils.dart';
import 'package:oneroof/B-TO-B/all_flight_booking/all_flight_booking.dart';
import 'package:oneroof/B-TO-B/all_group_booking/all_group_booking.dart';
import 'package:oneroof/utility/colors.dart';

class AgentDashboard extends StatefulWidget {
  const AgentDashboard({Key? key}) : super(key: key);

  @override
  State<AgentDashboard> createState() => _AgentDashboardState();
}

class _AgentDashboardState extends State<AgentDashboard> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  final _agencyNameController = TextEditingController(text: "Journey Online");
  final _emailController = TextEditingController(text: "tech@sastayhotels.pk");
  final _contactPersonController = TextEditingController(
    text: "Journey Online",
  );
  final _phoneController = TextEditingController(text: "+92 3377513");
  final _cityController = TextEditingController(text: "Faisalabad");
  final _countryController = TextEditingController(text: "Pakistan");

  @override
  void dispose() {
    _agencyNameController.dispose();
    _emailController.dispose();
    _contactPersonController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.background,
      appBar: AppBar(
        backgroundColor: TColors.primary,
        elevation: 0,
        title: const Text(
          'Dashboard',
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
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Update Your Profile',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: TColors.secondary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Keep your agency information up to date',
            style: TextStyle(fontSize: 14, color: TColors.grey),
          ),
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
                hintText: 'Enter agency name',
              ),
            ),
            const SizedBox(height: 20),
            _buildFormRow(
              'Email',
              _buildTextField(
                controller: _emailController,
                hintText: 'Enter email address',
                keyboardType: TextInputType.emailAddress,
              ),
            ),
            const SizedBox(height: 20),
            _buildFormRow(
              'Contact Person Name',
              _buildTextField(
                controller: _contactPersonController,
                hintText: 'Enter contact person name',
              ),
            ),
            const SizedBox(height: 20),
            _buildFormRow(
              'Phone No.',
              _buildTextField(
                controller: _phoneController,
                hintText: 'Enter phone number',
                keyboardType: TextInputType.phone,
              ),
            ),
            const SizedBox(height: 20),
            _buildFormRow(
              'City',
              _buildTextField(
                controller: _cityController,
                hintText: 'Enter city',
              ),
            ),
            const SizedBox(height: 20),
            _buildFormRow(
              'Country',
              _buildTextField(
                controller: _countryController,
                hintText: 'Enter country',
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
                  const CircleAvatar(
                    backgroundColor: TColors.white,
                    radius: 30,
                    child: Icon(Icons.person, size: 30, color: TColors.primary),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Journey Online',
                    style: TextStyle(
                      color: TColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _emailController.text,
                    style: const TextStyle(color: TColors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(Icons.dashboard, 'Dashboard', true, () {}),
            _buildDrawerItem(Icons.flight, 'All Flight Bookings', false, () {
              Get.to(() => AllFlightBookingScreen());
            }),
            _buildDrawerItem(Icons.hotel, 'Hotel Bookings', false, () {
              ;
            }),
            _buildDrawerItem(Icons.group, 'All Group Bookings', false, () {
              Get.to(() => AllGroupBooking());
            }),
            _buildDrawerItem(Icons.account_balance, 'Accounts'),
            _buildDrawerItem(Icons.account_balance_wallet, 'Bank Details'),
            _buildDrawerItem(Icons.person, 'My Profile'),
            _buildDrawerItem(Icons.password, 'Change Password'),
            _buildDrawerItem(Icons.logout, 'Logout'),
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
      leading: Icon(icon, color: isSelected ? TColors.third : TColors.white),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? TColors.third : TColors.white,
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
