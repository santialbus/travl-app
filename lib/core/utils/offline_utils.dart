import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class OfflineUtils {
  OfflineUtils._();

  /// Muestra un snackbar informando que la acción
  /// se sincronizará cuando haya conexión
  static void showSyncPendingMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.sync,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 8),
            const Text(
              'Saved locally · Will sync when online',
            ),
          ],
        ),
        backgroundColor: AppColors.surfaceDark,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}