import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:oneroof/utility/colors.dart';
import 'package:oneroof/widgets/location_permission_dialog.dart';

class LocationPermissionService {
  static LocationPermissionService? _instance;
  static LocationPermissionService get instance => _instance ??= LocationPermissionService._();
  LocationPermissionService._();

  /// Check if location permission is granted
  Future<bool> hasLocationPermission() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }

  /// Check if background location permission is granted
  Future<bool> hasBackgroundLocationPermission() async {
    final status = await Permission.locationAlways.status;
    return status.isGranted;
  }

  /// Request location permission with prominent disclosure
  Future<bool> requestLocationPermission(BuildContext context) async {
    // Check if we already have permission
    if (await hasLocationPermission()) {
      return true;
    }

    // Show prominent disclosure dialog
    final granted = await LocationPermissionDialog.showLocationPermissionDialog(context);
    return granted ?? false;
  }

  /// Handle location permission for Google Maps usage
  Future<bool> handleLocationPermissionForMaps(BuildContext context) async {
    try {
      // Check if we have basic location permission
      if (await hasLocationPermission()) {
        return true;
      }

      // Show prominent disclosure dialog
      final userGranted = await LocationPermissionDialog.showLocationPermissionDialog(context);
      
      if (userGranted == true) {
        // Request the permission
        final status = await Permission.location.request();
        
        if (status.isGranted) {
          Get.snackbar(
            'Success',
            'Location permission granted. You can now view hotel locations on maps.',
            backgroundColor: TColors.primary,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 3),
          );
          return true;
        } else if (status.isDenied) {
          Get.snackbar(
            'Permission Denied',
            'Location permission was denied. You can enable it later in settings.',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
          return false;
        } else if (status.isPermanentlyDenied) {
          Get.snackbar(
            'Permission Required',
            'Location permission is permanently denied. Please enable it in app settings to view hotel locations.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
          return false;
        }
      }
      
      return false;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to request location permission. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  /// Check and handle background location permission if needed
  Future<bool> handleBackgroundLocationPermission(BuildContext context) async {
    try {
      // Check if we have background location permission
      if (await hasBackgroundLocationPermission()) {
        return true;
      }

      // First ensure we have basic location permission
      if (!await hasLocationPermission()) {
        final basicGranted = await requestLocationPermission(context);
        if (!basicGranted) {
          return false;
        }
      }

      // Request background location permission
      final status = await Permission.locationAlways.request();
      
      if (status.isGranted) {
        Get.snackbar(
          'Success',
          'Background location permission granted.',
          backgroundColor: TColors.primary,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      } else if (status.isDenied) {
        Get.snackbar(
          'Permission Denied',
          'Background location permission was denied. You can enable it later in settings.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      } else if (status.isPermanentlyDenied) {
        Get.snackbar(
          'Permission Required',
          'Background location permission is permanently denied. Please enable it in app settings.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
      
      return false;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to request background location permission. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  /// Get permission status summary
  Future<Map<String, bool>> getPermissionStatus() async {
    return {
      'location': await hasLocationPermission(),
      'backgroundLocation': await hasBackgroundLocationPermission(),
    };
  }
}
