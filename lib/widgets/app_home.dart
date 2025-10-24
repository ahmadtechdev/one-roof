import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:oneroof/views/introduce.dart';
import 'package:oneroof/widgets/privacy_disclosure_dialog.dart';

class AppHome extends StatefulWidget {
  const AppHome({super.key});

  @override
  State<AppHome> createState() => _AppHomeState();
}

class _AppHomeState extends State<AppHome> {
  bool _isLoading = true;
  bool _showPrivacyDisclosure = false;

  @override
  void initState() {
    super.initState();
    _checkPrivacyDisclosure();
  }

  Future<void> _checkPrivacyDisclosure() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSeenPrivacyDisclosure = prefs.getBool('has_seen_privacy_disclosure') ?? false;
      
      if (!hasSeenPrivacyDisclosure) {
        setState(() {
          _showPrivacyDisclosure = true;
          _isLoading = false;
        });
        
        // Show privacy disclosure dialog
        await PrivacyDisclosureDialog.showPrivacyDisclosureDialog(context);
        
        // Mark as seen
        await prefs.setBool('has_seen_privacy_disclosure', true);
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return const Introduce();
  }
}
