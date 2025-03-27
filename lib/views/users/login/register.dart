import 'package:flutter/material.dart';

import '../../../sizes_helpers.dart';
import '../../../utility/colors.dart';
import 'login.dart';

class registerNewAccount extends StatefulWidget {
  @override
  _registerNewAccountState createState() => _registerNewAccountState();
}

class _registerNewAccountState extends State<registerNewAccount> {
  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive calculations
    final size = MediaQuery.of(context).size;
    final textScaleFactor = size.width / 375; // Base scale on standard device width

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
                        top: displaySize(context).height * 0.34),
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            "Register",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: TColors.white,
                            ),
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
              margin: const EdgeInsets.only(
                left: 16,
                right: 16,
              ),
              child: Material(
                elevation: 10,
                shadowColor: TColors.white,
                borderRadius: BorderRadius.circular(15),
                child: TextField(
                  style: TextStyle(fontSize: 16 * textScaleFactor),
                  decoration: InputDecoration(
                    labelText: "Enter Your Email",
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
                      borderSide: BorderSide(color: TColors.secondary, width: 1.0),
                    ),
                  ),
                ),
              ),
            ),

            // Password input field
            Container(
              margin: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 20,
              ),
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
                      borderSide: BorderSide(color: TColors.secondary, width: 1.0),
                    ),
                  ),
                ),
              ),
            ),

            // Confirm Password input field
            Container(
              margin: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 20,
              ),
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
                      borderSide: BorderSide(color: TColors.secondary, width: 1.0),
                    ),
                  ),
                ),
              ),
            ),

            // Register button
            Container(
              margin: EdgeInsets.only(
                top: 24,
                left: 16,
                right: 16,
              ),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColors.secondary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)
                  ),
                  minimumSize: Size(
                    double.infinity,
                    50, // Fixed height for button
                  ),
                ),
                child: Text(
                  'Register',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18 * textScaleFactor,
                    fontWeight: FontWeight.bold,
                    color: TColors.white,
                  ),
                ),
              ),
            ),

            // Login link
            Container(
              margin: EdgeInsets.only(
                top: 24,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'already have an account?',
                    style: TextStyle(
                      fontSize: 16 * textScaleFactor,
                      color: TColors.grey,
                    ),
                  ),
                  SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Login()),
                      );
                    },
                    child: Text(
                      'Login',
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