import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../b2b/agent_dashboard/agent_dashboard.dart';
import '../../../common/bottom_navbar.dart';
import 'login_api_service/login_api.dart';

class LoginController extends GetxController {
  final LoginApiService loginApiService = LoginApiService();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final errorMessage = ''.obs;

  void resetError() {
    errorMessage.value = '';
  }

  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      errorMessage.value = 'Email and password are required';
      return;
    }

    isLoading.value = true;

    try {
      final result = await loginApiService.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      isLoading.value = false;

      if (result['success']) {
        // Navigate to home screen on successful login
        Get.off(() => AgentDashboard());
      } else {
        errorMessage.value = result['message'];
      }
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'An unexpected error occurred';
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}