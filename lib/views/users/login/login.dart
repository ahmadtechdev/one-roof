import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:oneroof/views/users/login/rejistration/register.dart';

import '../../../common/bottom_navbar.dart';
import '../../../sizes_helpers.dart';
import '../../../utility/colors.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive calculations
    final size = MediaQuery.of(context).size;
    final textScaleFactor =
        size.width / 375; // Base scale on standard device width

    return Material(
      child: Container(
        color: TColors.white,
        height: displaySize(context).height,
        child: Column(
          children: <Widget>[
            // Top image container
            Container(
              width: displaySize(context).width,
              height: displaySize(context).height * 0.5,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/lywing-slash-screen.png'),
                  fit: BoxFit.fill,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(
                      top: displaySize(context).height * 0.35,
                    ),
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: AutoSizeText(
                            "Login",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 36,
                              color: TColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            minFontSize: 24, // Increased minimum font size
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Email input field
            Container(
              margin: const EdgeInsets.only(left: 16, right: 16),
              child: Material(
                elevation: 10,
                shadowColor: TColors.white,
                borderRadius: BorderRadius.circular(15),
                child: TextField(
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
                      borderSide: BorderSide(color: TColors.white, width: 0.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: TColors.secondary,
                        width: 1.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Password input field
            Container(
              margin: const EdgeInsets.only(left: 16, right: 16, top: 20),
              child: Material(
                elevation: 10,
                shadowColor: TColors.white,
                borderRadius: BorderRadius.circular(15),
                child: TextField(
                  obscureText: true,
                  style: TextStyle(fontSize: 16 * textScaleFactor),
                  decoration: InputDecoration(
                    labelText: 'Enter Password?',
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
                      borderSide: BorderSide(color: TColors.white, width: 0.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: TColors.secondary,
                        width: 1.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Login button
            Container(
              margin: const EdgeInsets.only(top: 24, left: 16, right: 16),
              child: ElevatedButton(
                onPressed: () {
                  // Navigation logic
                  Get.off(() => BottomNavbar());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColors.secondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  minimumSize: Size(
                    double.infinity,
                    50, // Fixed height for button
                  ),
                ),
                child: Text(
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

            // Social login options
            Container(
              margin: EdgeInsets.only(
                left: 16,
                right: 16,
                top: displaySize(context).height * 0.05,
              ),
              width: displaySize(context).width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  // Google login button
                  Container(
                    width: displaySize(context).width * 0.45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          side: BorderSide(width: 0.5, color: TColors.grey),
                        ),
                        elevation: 0,
                        minimumSize: Size(
                          double.infinity,
                          45, // Fixed height for social buttons
                        ),
                      ),
                      onPressed: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(right: 8),
                            child: SvgPicture.asset(
                              ('assets/images/google.svg'),
                              width: 20,
                              height: 20,
                            ),
                          ),
                          Text(
                            'Google',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16 * textScaleFactor,
                              color: TColors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Facebook login button
                  Container(
                    width: displaySize(context).width * 0.45,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          side: BorderSide(width: 0.5, color: TColors.grey),
                        ),
                        elevation: 0,
                        minimumSize: Size(
                          double.infinity,
                          45, // Fixed height for social buttons
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(right: 8),
                            child: SvgPicture.asset(
                              ('assets/images/facebook.svg'),
                              width: 20,
                              height: 20,
                            ),
                          ),
                          Text(
                            'Facebook',
                            style: TextStyle(
                              fontSize: 16 * textScaleFactor,
                              color: TColors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Register account link
            Container(
              margin: EdgeInsets.only(top: 24, bottom: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "don\'t have an account?",
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
            ),
          ],
        ),
      ),
    );
  }
}
