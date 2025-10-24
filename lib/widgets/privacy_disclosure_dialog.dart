import 'package:flutter/material.dart';
import 'package:oneroof/utility/colors.dart';

class PrivacyDisclosureDialog {
  static Future<void> showPrivacyDisclosureDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.privacy_tip_outlined,
                color: TColors.primary,
                size: 28,
              ),
              const SizedBox(width: 8),
              const Text(
                'Privacy & Data Usage',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: TColors.text,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Data Collection & Usage',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: TColors.text,
                  ),
                ),
                const SizedBox(height: 12),
                
                _buildPrivacyItem(
                  'Location Data',
                  'We collect your location data to show hotel locations on maps and provide location-based recommendations. This data is used solely for enhancing your travel experience.',
                ),
                
                const SizedBox(height: 8),
                
                const SizedBox(height: 16),
                
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: TColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: TColors.primary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.security,
                            color: TColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Data Protection',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: TColors.text,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Your location data is encrypted and stored securely\n• We do not sell your location information\n• Location data is only used for app functionality\n• You can revoke permissions anytime in settings',
                        style: TextStyle(
                          fontSize: 13,
                          color: TColors.text.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                const Text(
                  'By using this app, you agree to our data collection and usage practices as described above.',
                  style: TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: TColors.grey,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Close',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static Widget _buildPrivacyItem(String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: TColors.primary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: TColors.text,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: TColors.text.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
