// ignore_for_file: library_private_types_in_public_api

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:oneroof/views/users/rejistration/register.dart';

import '../../../sizes_helpers.dart';
import '../../../utility/colors.dart';
import 'ligin_controller.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final LoginController controller = Get.put(LoginController());
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive calculations
    final size = MediaQuery.of(context).size;
    final textScaleFactor = size.width / 375;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        color: TColors.white,
        height: displaySize(context).height,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              // Top image container
              Container(
                width: displaySize(context).width,
                height: displaySize(context).height * 0.4,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/lywing-slash-screen.png'),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(bottom: 20),
                      child: AutoSizeText(
                        "Login",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 36,
                          color: TColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        minFontSize: 24,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),

              // Form content with padding
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    SizedBox(height: 20),

                    // Error message
                    Obx(
                      () => controller.errorMessage.value.isNotEmpty
                          ? Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                controller.errorMessage.value,
                                style: TextStyle(
                                  color: Colors.red.shade800,
                                  fontSize: 14 * textScaleFactor,
                                ),
                              ),
                            )
                          : SizedBox.shrink(),
                    ),

                    // Email input field
                    Material(
                      elevation: 10,
                      shadowColor: TColors.white,
                      borderRadius: BorderRadius.circular(15),
                      child: TextField(
                        controller: controller.emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(fontSize: 16 * textScaleFactor),
                        decoration: InputDecoration(
                          labelText: 'Enter Your Email',
                          labelStyle: TextStyle(
                            fontSize: 16 * textScaleFactor,
                            color: TColors.grey,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 16,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: TColors.white,
                              width: 0.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: TColors.secondary,
                              width: 1.0,
                            ),
                          ),
                        ),
                        onChanged: (_) => controller.resetError(),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Password input field with eye icon
                    Material(
                      elevation: 10,
                      shadowColor: TColors.white,
                      borderRadius: BorderRadius.circular(15),
                      child: TextField(
                        controller: controller.passwordController,
                        obscureText: _obscurePassword,
                        style: TextStyle(fontSize: 16 * textScaleFactor),
                        decoration: InputDecoration(
                          labelText: 'Enter Password',
                          labelStyle: TextStyle(
                            fontSize: 16 * textScaleFactor,
                            color: TColors.grey,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 16,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: TColors.white,
                              width: 0.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: TColors.secondary,
                              width: 1.0,
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: TColors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        onChanged: (_) => controller.resetError(),
                      ),
                    ),

                    SizedBox(height: 24),

                    // Login button
                    Obx(
                      () => ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TColors.secondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          minimumSize: Size(double.infinity, 50),
                        ),
                        child: controller.isLoading.value
                            ? SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: TColors.white,
                                  strokeWidth: 3,
                                ),
                              )
                            : Text(
                                "Login",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18 * textScaleFactor,
                                  fontWeight: FontWeight.bold,
                                  color: TColors.white,
                                ),
                              ),
                      ),
                    ),

                    SizedBox(height: 30),

                    // Register account link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "don't have an account?",
                          style: TextStyle(
                            fontSize: 16 * textScaleFactor,
                            color: TColors.grey,
                          ),
                        ),
                        SizedBox(width: 8),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RegisterAccount(),
                              ),
                            );
                          },
                          child: Text(
                            "Register",
                            style: TextStyle(
                              color: TColors.secondary,
                              fontSize: 16 * textScaleFactor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}