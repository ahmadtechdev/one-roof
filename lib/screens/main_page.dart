import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utility/colors.dart';
import '../views/home/home_screen.dart';
import '../views/users/login/login.dart';
import '../views/users/rejistration/register.dart';
import '../views/users/login/login_api_service/login_api.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeLogo;
  late final Animation<double> _fadeButtons;

  final authController = Get.put(AuthController());

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeLogo = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _fadeButtons = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    );

    _animationController.forward();

    _redirectIfLoggedIn();
  }

  Future<void> _redirectIfLoggedIn() async {
    final loggedIn = await authController.isLoggedIn();
    if (loggedIn) {
      // Navigate to Home if already logged in
      if (mounted) Get.offAll(() => const HomeScreen());
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onContinueAsGuest() {
    Get.offAll(() => const HomeScreen());
  }

  void _onLoginAsAgent() {
    Get.to(() => const Login());
  }

  void _onRegister() {
    Get.to(() => RegisterAccount());
  }

  @override
  Widget build(BuildContext context) {
    const Color beigeBackground = Color(0xFFF5F0E6);

    return Scaffold(
      backgroundColor: beigeBackground,
      body: SafeArea(
        child: Stack(
          children: [
            // Gradient background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFFFF8F0), // light beige
                    beigeBackground,
                    beigeBackground
                  ],
                ),
              ),
            ),

            // Decorative soft shapes
            Positioned(
              top: -40,
              left: -30,
              child: _SoftBlob(
                size: 220,
                color: TColors.secondary.withOpacity(0.15),
              ),
            ),
            Positioned(
              bottom: -50,
              right: -40,
              child: _SoftBlob(
                size: 260,
                color: TColors.third.withOpacity(0.12),
              ),
            ),

            // Content
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FadeTransition(
                      opacity: _fadeLogo,
                      child: Column(
                        children: [
                          // Company logo
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              // color: Colors.white.withOpacity(0.65),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/images/logo1.png',
                              height: 220,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),

                    FadeTransition(
                      opacity: _fadeButtons,
                      child: Column(
                        children: [
                          _PrimaryButton(
                            label: 'CONTINUE AS GUEST',
                            onPressed: _onContinueAsGuest,
                            backgroundColor: TColors.primary,
                          ),
                          const SizedBox(height: 12),
                          _PrimaryButton(
                            label: 'LOGIN AS AGENT',
                            onPressed: _onLoginAsAgent,
                            backgroundColor: TColors.secondary,
                          ),
                          const SizedBox(height: 12),
                          _PrimaryButton(
                            label: 'REGISTER',
                            onPressed: _onRegister,
                            backgroundColor: TColors.third,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;

  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(16);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0,horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 42,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                backgroundColor.withOpacity(0.95),
                backgroundColor,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: backgroundColor.withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPressed,
                splashColor: Colors.white.withOpacity(0.15),
                highlightColor: Colors.white.withOpacity(0.05),
                child: Center(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SoftBlob extends StatelessWidget {
  final double size;
  final Color color;

  const _SoftBlob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withOpacity(0.0)],
          stops: const [0.0, 1.0],
        ),
      ),
    );
  }
}


