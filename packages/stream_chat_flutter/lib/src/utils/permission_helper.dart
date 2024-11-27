import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Signature for a function that's called when the user taps on an attachment.
typedef PermissionRequestResult = ({
  bool allGranted,
  Map<Permission, bool> permanentlyDenied,
  Map<Permission, bool> denied,
});

/// Helper class to request permissions and show dialogs if permissions are denied.
class PermissionHelper {
  static Future<Map<Permission, PermissionStatus>> _requestPermissions(
      List<Permission> permissions) async {
    final statuses = await permissions.request();
    return statuses;
  }

  /// Requests permissions and shows a dialog if any of the permissions are denied.
  static Future<void> requestMultiplePermissionsWithCallback({
    required List<Permission> permissions,
    VoidCallback? onPermissionDenied,
    required VoidCallback onPermissionGranted,
    VoidCallback? onPermissionPermanentlyDenied,
    required BuildContext context,
    bool mentionPermissions = false,
  }) async {
    Map<Permission, PermissionStatus> statuses =
        await _requestPermissions(permissions);

    bool allGranted = statuses.values.every((status) => status.isGranted);
    bool anyPermanentlyDenied =
        statuses.values.any((status) => status.isPermanentlyDenied);

    if (allGranted) {
      onPermissionGranted();
    } else {
      if (anyPermanentlyDenied) {
        await _showPermanentlyDeniedDialog(
          context,
          permissions,
          onPermissionPermanentlyDenied,
          mentionPermissions: mentionPermissions,
        );
      } else {
        await _showPermissionsDeniedDialog(
          context,
          permissions,
          onPermissionDenied,
          onPermissionPermanentlyDenied,
          mentionPermissions: mentionPermissions,
        );
      }
    }
  }

  /// Requests permissions and shows a dialog if any of the permissions are denied.
  /// Returns true if all permissions are granted, false otherwise.
  static Future<bool> requestMultiplePermissions({
    required List<Permission> permissions,
    required BuildContext context,
  }) async {
    Map<Permission, PermissionStatus> statuses =
        await _requestPermissions(permissions);

    bool allGranted = statuses.values.every((status) => status.isGranted);
    bool anyPermanentlyDenied =
        statuses.values.any((status) => status.isPermanentlyDenied);

    if (allGranted) {
      return true;
    } else {
      if (anyPermanentlyDenied) {
        await _showPermanentlyDeniedDialog(context, permissions, null);
        return false;
      } else {
        await _showPermissionsDeniedDialog(context, permissions, () {}, null);
        return false;
      }
    }
  }

  /// Requests permissions and shows a dialog if any of the permissions are denied.
  static Future<bool> requestSinglePermission({
    required Permission permission,
    required VoidCallback? onPermissionDenied,
    required VoidCallback? onPermissionGranted,
    required VoidCallback? onPermissionPermanentlyDenied,
    required BuildContext context,
  }) async {
    final status = await permission.request();

    bool granted = status.isGranted;
    bool permanentlyDenied = status.isPermanentlyDenied;

    if (granted) {
      onPermissionGranted?.call();
      return true;
    } else {
      if (permanentlyDenied) {
        await _showPermanentlyDeniedDialog(
            context, [permission], onPermissionPermanentlyDenied);
        return false;
      } else {
        return await requestPermissionsAgain(context, [permission],
            onPermissionDenied, onPermissionPermanentlyDenied);
      }
    }
  }

  // Shows a dialog if any of the permissions are denied.
  // @todo Taking permissions here so that I can show the permissions
  //  name in the dialog description to make the user aware of which permissions are denied.
  static Future<void> _showPermissionsDeniedDialog(
    BuildContext context,
    List<Permission> permissions,
    VoidCallback? onPermissionDenied,
    VoidCallback? onPermissionPermanentlyDenied, {
    bool mentionPermissions = false,
  }) async {
    String message =
        'Some permissions were denied. Please grant all the required permissions for the app to function properly.';

    if (mentionPermissions) {
      String permissionNames = permissions
          .map((permission) => permission.toString().split('.').last)
          .join(', ');

      message =
          'Some permissions($permissionNames) were denied. Please grant all the required permissions for the app to function properly.';
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permissions Denied'),
        content: Text(
          message,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onPermissionDenied?.call();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              bool granted = await requestPermissionsAgain(context, permissions,
                  onPermissionDenied, onPermissionPermanentlyDenied);
              if (!granted) {
                onPermissionDenied?.call();
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Shows a dialog if any of the permissions are permanently denied.
  // @todo Taking permissions here so that I can show the permissions
  //  name in the dialog description to make the user aware of which permissions are denied.
  static Future<void> _showPermanentlyDeniedDialog(
    BuildContext context,
    List<Permission> permissions,
    VoidCallback? onPermissionPermanentlyDenied, {
    bool mentionPermissions = false,
  }) async {
    String message =
        'One or more permissions have been permanently denied. Please enable them in the app settings.';

    if (mentionPermissions) {
      String permissionNames = permissions
          .map((permission) => permission.toString().split('.').last)
          .join(', ');

      message =
          'One or more permissions($permissionNames) have been permanently denied. Please enable them in the app settings.';
    }

    await showDialog(
      context: context,
      builder: (context) => Builder(builder: (context) {
        return AlertDialog(
          title: const Text('Permissions Permanently Denied'),
          content: Text(
            message,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onPermissionPermanentlyDenied?.call();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      }),
    );
  }

  // Requests permissions again if any of the permissions are denied.
  static Future<bool> requestPermissionsAgain(
      BuildContext context,
      List<Permission> permissions,
      VoidCallback? onPermissionDenied,
      VoidCallback? onPermissionPermanentlyDenied) async {
    Map<Permission, PermissionStatus> statuses =
        await _requestPermissions(permissions);

    bool allGranted = statuses.values.every((status) => status.isGranted);
    bool anyPermanentlyDenied =
        statuses.values.any((status) => status.isPermanentlyDenied);

    if (allGranted) {
      return true;
    } else {
      if (anyPermanentlyDenied) {
        await _showPermanentlyDeniedDialog(
            context, permissions, onPermissionPermanentlyDenied);
      } else {
        await _showPermissionsDeniedDialog(context, permissions,
            onPermissionDenied, onPermissionPermanentlyDenied);
      }
      return false;
    }
  }
}
