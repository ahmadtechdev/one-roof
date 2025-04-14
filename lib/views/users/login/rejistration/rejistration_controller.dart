import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oneroof/utility/colors.dart';

class RegistrationModel {
  String agencyName;
  String contactName;
  String email;
  String countryCode;
  String cellNumber;
  String address;
  String cityName;

  RegistrationModel({
    required this.agencyName,
    required this.contactName,
    required this.email,
    required this.countryCode,
    required this.cellNumber,
    required this.address,
    required this.cityName,
  });

  // Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'agencyName': agencyName,
      'contactName': contactName,
      'email': email,
      'countryCode': countryCode,
      'cellNumber': cellNumber,
      'address': address,
      'cityName': cityName,
    };
  }

  // Create model from JSON
  factory RegistrationModel.fromJson(Map<String, dynamic> json) {
    return RegistrationModel(
      agencyName: json['agencyName'] ?? '',
      contactName: json['contactName'] ?? '',
      email: json['email'] ?? '',
      countryCode: json['countryCode'] ?? '',
      cellNumber: json['cellNumber'] ?? '',
      address: json['address'] ?? '',
      cityName: json['cityName'] ?? '',
    );
  }
}

class RegisterController extends GetxController {
  // Text controllers for form fields
  final TextEditingController agencyNameController = TextEditingController();
  final TextEditingController contactNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController cellController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityNameController = TextEditingController();

  // Observable variables
  var selectedCountryCode = ''.obs;
  var isRecaptchaChecked = false.obs;
  var isLoading = false.obs;

  // List of country codes
  final List<String> countryCodes = [
    '+1',
    '+44',
    '+92',
    '+61',
    '+49',
    '+81',
    '+86',
    '+971',
    '+966',
  ];

  // Form validation variables
  var agencyNameError = ''.obs;
  var contactNameError = ''.obs;
  var emailError = ''.obs;
  var countryCodeError = ''.obs;
  var cellError = ''.obs;
  var addressError = ''.obs;
  var cityNameError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Add listeners to clear errors when text changes
    agencyNameController.addListener(() => agencyNameError.value = '');
    contactNameController.addListener(() => contactNameError.value = '');
    emailController.addListener(() => emailError.value = '');
    cellController.addListener(() => cellError.value = '');
    addressController.addListener(() => addressError.value = '');
    cityNameController.addListener(() => cityNameError.value = '');
  }

  @override
  void onClose() {
    // Dispose all controllers
    agencyNameController.dispose();
    contactNameController.dispose();
    emailController.dispose();
    cellController.dispose();
    addressController.dispose();
    cityNameController.dispose();
    super.onClose();
  }

  // Navigation to login screen
  void navigateToLogin() {
    // Replace with your navigation logic to login screen
    Get.back(); // Example: Go back to previous screen
  }

  // Validate email format
  bool isEmailValid(String email) {
    final emailRegExp = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    return emailRegExp.hasMatch(email);
  }

  // Validate phone number format
  bool isPhoneValid(String phone) {
    final phoneRegExp = RegExp(
      r'^\d{6,15}$',
    ); // Basic validation for 6-15 digits
    return phoneRegExp.hasMatch(phone);
  }

  // Validate all fields
  bool validateFields() {
    bool isValid = true;

    // Validate Agency Name
    if (agencyNameController.text.isEmpty) {
      agencyNameError.value = 'Agency name is required';
      isValid = false;
    }

    // Validate Contact Name
    if (contactNameController.text.isEmpty) {
      contactNameError.value = 'Contact name is required';
      isValid = false;
    }

    // Validate Email
    if (emailController.text.isEmpty) {
      emailError.value = 'Email is required';
      isValid = false;
    } else if (!isEmailValid(emailController.text)) {
      emailError.value = 'Please enter a valid email';
      isValid = false;
    }

    // Validate Country Code
    if (selectedCountryCode.value.isEmpty) {
      countryCodeError.value = 'Please select country code';
      isValid = false;
    }

    // Validate Cell Number
    if (cellController.text.isEmpty) {
      cellError.value = 'Cell number is required';
      isValid = false;
    } else if (!isPhoneValid(cellController.text)) {
      cellError.value = 'Please enter a valid phone number';
      isValid = false;
    }

    // Validate Address
    if (addressController.text.isEmpty) {
      addressError.value = 'Address is required';
      isValid = false;
    }

    // Validate City Name
    if (cityNameController.text.isEmpty) {
      cityNameError.value = 'City name is required';
      isValid = false;
    }

    // Validate reCAPTCHA
    if (!isRecaptchaChecked.value) {
      Get.snackbar(
        'Verification Required',
        'Please complete the reCAPTCHA verification',
        backgroundColor: TColors.third.withOpacity(0.8),
        colorText: TColors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: EdgeInsets.all(10),
      );
      isValid = false;
    }

    return isValid;
  }

  // Register method
  void register() async {
    // Clear focus to hide keyboard
    FocusManager.instance.primaryFocus?.unfocus();

    // Validate fields
    if (!validateFields()) {
      return;
    }

    try {
      // Show loading indicator
      isLoading.value = true;

      // Prepare registration data
      final registrationData = {
        'agency_name': agencyNameController.text,
        'contact_name': contactNameController.text,
        'email': emailController.text,
        'phone': '${selectedCountryCode.value}${cellController.text}',
        'address': addressController.text,
        'city': cityNameController.text,
      };

      // Simulate API call with delay (replace with actual API call)
      await Future.delayed(Duration(seconds: 2));

      // Process registration (replace with actual API integration)
      print('Registration data: $registrationData');

      // Show success message
      Get.snackbar(
        'Success',
        'Registration completed successfully',
        backgroundColor: Colors.green,
        colorText: TColors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: EdgeInsets.all(10),
      );

      // Navigate to next screen or login screen
      // Example: Get.offAll(() => DashboardScreen());
    } catch (e) {
      // Handle error
      Get.snackbar(
        'Error',
        'Registration failed. Please try again.',
        backgroundColor: TColors.third,
        colorText: TColors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: EdgeInsets.all(10),
      );
      print('Registration error: $e');
    } finally {
      // Hide loading indicator
      isLoading.value = false;
    }
  }

  // Method to get error text for form fields
  String? getErrorText(RxString errorValue) {
    return errorValue.value.isEmpty ? null : errorValue.value;
  }

  // Method to update country code
  void updateCountryCode(String? code) {
    if (code != null) {
      selectedCountryCode.value = code;
      countryCodeError.value = '';
    }
  }
}

final agencyNameController = TextEditingController();
final contactNameController = TextEditingController();
final emailController = TextEditingController();
final cellController = TextEditingController();
final addressController = TextEditingController();
final cityNameController = TextEditingController();

var selectedCountryCode = ''.obs;
var isRecaptchaChecked = false.obs;

// List of country codes - add more as needed
final List<String> countryCodes = ['+1', '+44', '+91', '+61', '+81'];

@override
void onClose() {
  agencyNameController.dispose();
  contactNameController.dispose();
  emailController.dispose();
  cellController.dispose();
  addressController.dispose();
  cityNameController.dispose();
}

void register() {
  // Validate fields
  if (agencyNameController.text.isEmpty ||
      contactNameController.text.isEmpty ||
      emailController.text.isEmpty ||
      cellController.text.isEmpty ||
      addressController.text.isEmpty ||
      cityNameController.text.isEmpty ||
      selectedCountryCode.value.isEmpty ||
      !isRecaptchaChecked.value) {
    Get.snackbar(
      'Error',
      'Please fill in all fields and complete the reCAPTCHA',
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
    return;
  }

  // Perform registration logic
  print('Registration form submitted:');
  print('Agency Name: ${agencyNameController.text}');
  print('Contact Name: ${contactNameController.text}');
  print('Email: ${emailController.text}');
  print('Phone: ${selectedCountryCode.value} ${cellController.text}');
  print('Address: ${addressController.text}');
  print('City: ${cityNameController.text}');

  // Here you would typically call an API to register the user
  Get.snackbar(
    'Success',
    'Registration submitted successfully',
    backgroundColor: Colors.green,
    colorText: Colors.white,
    snackPosition: SnackPosition.BOTTOM,
  );
}

void navigateToLogin() {
  // Navigate to login page
  print('Navigating to login page');
  // Replace with your actual navigation logic
  // Get.to(() => LoginScreen());
}
