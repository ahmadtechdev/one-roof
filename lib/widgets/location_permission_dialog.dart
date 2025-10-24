import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:oneroof/utility/colors.dart';

class LocationPermissionDialog {
  static Future<bool?> showLocationPermissionDialog(BuildContext context) {
    return showDialog<bool>(
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
                Icons.location_on,
                color: TColors.primary,
                size: 28,
              ),
              const SizedBox(width: 8),
              const Text(
                'Location Permission Required',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: TColors.text,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This app needs location permission to:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: TColors.text,
                ),
              ),
              const SizedBox(height: 12),
              _buildFeatureItem(
                'Show hotel locations on maps',
                'Display precise locations of hotels you\'re viewing',
              ),
              const SizedBox(height: 8),
              _buildFeatureItem(
                'Improve location-based features',
                'Provide better recommendations based on your location',
              ),
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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: TColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your location data will only be used to enhance your travel experience and will not be shared with third parties.',
                        style: TextStyle(
                          fontSize: 14,
                          color: TColors.text.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text(
                'Not Now',
                style: TextStyle(
                  color: TColors.grey,
                  fontSize: 16,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(true);
                await _requestLocationPermissions();
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
                'Allow Location',
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

  static Widget _buildFeatureItem(String title, String description) {
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

  static Future<void> _requestLocationPermissions() async {
    try {
      // First request basic location permission
      PermissionStatus status = await Permission.location.request();
      
      if (status.isGranted) {
        // Then request background location permission
        PermissionStatus backgroundStatus = await Permission.locationAlways.request();
        
        if (backgroundStatus.isGranted) {
          Get.snackbar(
            'Success',
            'Location permission granted successfully',
            backgroundColor: TColors.primary,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        } else if (backgroundStatus.isDenied) {
          Get.snackbar(
            'Permission Denied',
            'Location permission was denied. You can enable it later in settings.',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        } else if (backgroundStatus.isPermanentlyDenied) {
          Get.snackbar(
            'Permission Required',
            'Location permission is permanently denied. Please enable it in app settings.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        Get.snackbar(
          'Permission Denied',
          'Location permission was denied. You can enable it later in settings.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to request location permission',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  static Future<bool> checkLocationPermission() async {
    PermissionStatus status = await Permission.location.status;
    return status.isGranted;
  }

  static Future<bool> checkBackgroundLocationPermission() async {
    PermissionStatus status = await Permission.locationAlways.status;
    return status.isGranted;
  }
}
