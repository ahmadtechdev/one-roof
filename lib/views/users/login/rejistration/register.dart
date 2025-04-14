import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utility/colors.dart';
import 'rejistration_controller.dart';

class RegisterAccount extends StatelessWidget {
  final RegisterController controller = Get.put(RegisterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            color: TColors.white, // White background as requested
            child: Obx(
              () => Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Header
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 14,
                          left: 16,
                          right: 16,
                          bottom: 30,
                        ),
                        child: Text(
                          'Sign in or create an account',
                          style: TextStyle(
                            color: TColors.text,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // "Already have an account? Log in" text
                      Padding(
                        padding: const EdgeInsets.only(left: 16, bottom: 20),
                        child: Row(
                          children: [
                            Text(
                              'Already have an account? ',
                              style: TextStyle(
                                color: TColors.text.withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                            GestureDetector(
                              onTap: controller.navigateToLogin,
                              child: Text(
                                'Log in',
                                style: TextStyle(
                                  color: TColors.primary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Agency Name field
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: TextField(
                          controller: controller.agencyNameController,
                          style: TextStyle(color: TColors.text),
                          decoration: InputDecoration(
                            labelText: 'Agency Name',
                            labelStyle: TextStyle(
                              color: TColors.text.withOpacity(0.7),
                            ),
                            errorText: controller.getErrorText(
                              controller.agencyNameError,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: TColors.grey.withOpacity(0.3),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(color: TColors.primary),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(color: TColors.third),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(color: TColors.third),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                        ),
                      ),

                      // Contact Name field
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: TextField(
                          controller: controller.contactNameController,
                          style: TextStyle(color: TColors.text),
                          decoration: InputDecoration(
                            labelText: 'Contact Name',
                            labelStyle: TextStyle(
                              color: TColors.text.withOpacity(0.7),
                            ),
                            errorText: controller.getErrorText(
                              controller.contactNameError,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: TColors.grey.withOpacity(0.3),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(color: TColors.primary),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(color: TColors.third),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(color: TColors.third),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                        ),
                      ),

                      // Email field
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: TextField(
                          controller: controller.emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(color: TColors.text),
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(
                              color: TColors.text.withOpacity(0.7),
                            ),
                            errorText: controller.getErrorText(
                              controller.emailError,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: TColors.grey.withOpacity(0.3),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(color: TColors.primary),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(color: TColors.third),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(color: TColors.third),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                        ),
                      ),

                      // Country Code and Cell
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Country Code dropdown
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      border: Border.all(
                                        color:
                                            controller
                                                    .countryCodeError
                                                    .value
                                                    .isNotEmpty
                                                ? TColors.third
                                                : TColors.grey.withOpacity(0.3),
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value:
                                            controller
                                                    .selectedCountryCode
                                                    .value
                                                    .isEmpty
                                                ? null
                                                : controller
                                                    .selectedCountryCode
                                                    .value,
                                        dropdownColor: Colors.white,
                                        icon: Icon(
                                          Icons.arrow_drop_down,
                                          color: TColors.text,
                                        ),
                                        style: TextStyle(color: TColors.text),
                                        isExpanded: true,
                                        hint: Padding(
                                          padding: const EdgeInsets.only(
                                            left: 12,
                                          ),
                                          child: Text(
                                            'Country Code',
                                            style: TextStyle(
                                              color: TColors.text.withOpacity(
                                                0.7,
                                              ),
                                            ),
                                          ),
                                        ),
                                        items:
                                            controller.countryCodes.map((
                                              String code,
                                            ) {
                                              return DropdownMenuItem<String>(
                                                value: code,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        left: 12,
                                                      ),
                                                  child: Text(code),
                                                ),
                                              );
                                            }).toList(),
                                        onChanged: controller.updateCountryCode,
                                      ),
                                    ),
                                  ),
                                  if (controller
                                      .countryCodeError
                                      .value
                                      .isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 12,
                                        top: 6,
                                      ),
                                      child: Text(
                                        controller.countryCodeError.value,
                                        style: TextStyle(
                                          color: TColors.third,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            SizedBox(width: 10),
                            // Cell field
                            Expanded(
                              flex: 3,
                              child: TextField(
                                controller: controller.cellController,
                                keyboardType: TextInputType.phone,
                                style: TextStyle(color: TColors.text),
                                decoration: InputDecoration(
                                  labelText: 'Cell',
                                  labelStyle: TextStyle(
                                    color: TColors.text.withOpacity(0.7),
                                  ),
                                  errorText: controller.getErrorText(
                                    controller.cellError,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(
                                      color: TColors.grey.withOpacity(0.3),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(
                                      color: TColors.primary,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(
                                      color: TColors.third,
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(
                                      color: TColors.third,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Address field
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: TextField(
                          controller: controller.addressController,
                          style: TextStyle(color: TColors.text),
                          decoration: InputDecoration(
                            labelText: 'Address',
                            labelStyle: TextStyle(
                              color: TColors.text.withOpacity(0.7),
                            ),
                            errorText: controller.getErrorText(
                              controller.addressError,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: TColors.grey.withOpacity(0.3),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(color: TColors.primary),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(color: TColors.third),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(color: TColors.third),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                        ),
                      ),

                      // City Name field
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: TextField(
                          controller: controller.cityNameController,
                          style: TextStyle(color: TColors.text),
                          decoration: InputDecoration(
                            labelText: 'City Name',
                            labelStyle: TextStyle(
                              color: TColors.text.withOpacity(0.7),
                            ),
                            errorText: controller.getErrorText(
                              controller.cityNameError,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: TColors.grey.withOpacity(0.3),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(color: TColors.primary),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(color: TColors.third),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(color: TColors.third),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                        ),
                      ),

                      // Sign In button
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        child: ElevatedButton(
                          onPressed:
                              controller.isLoading.value
                                  ? null
                                  : controller.register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TColors.primary,
                            disabledBackgroundColor: TColors.primary
                                .withOpacity(0.5),
                            minimumSize: Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child:
                              controller.isLoading.value
                                  ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: TColors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : Text(
                                    'Sign In',
                                    style: TextStyle(
                                      color: TColors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                        ),
                      ),

                      SizedBox(height: 20),
                    ],
                  ),

                  // Loading overlay
                  if (controller.isLoading.value)
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.black.withOpacity(0.3),
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(color: TColors.primary),
                              SizedBox(height: 16),
                              Text(
                                'Processing...',
                                style: TextStyle(color: TColors.text),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
