import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/invite_code_generator.dart';
import '../../../trip/presentation/providers/trip_provider.dart';

class JoinTripDialog extends ConsumerStatefulWidget {
  final String userId;

  const JoinTripDialog({
    super.key,
    required this.userId,
  });

  @override
  ConsumerState<JoinTripDialog> createState() => _JoinTripDialogState();
}

class _JoinTripDialogState extends ConsumerState<JoinTripDialog> {
  final _codeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _joinTrip() async {
    final code = _codeController.text.trim();

    if (code.isEmpty) {
      _showError('Please enter an invite code');
      return;
    }

    if (!InviteCodeGenerator.isValid(code)) {
      _showError('Invalid invite code format');
      return;
    }

    setState(() => _isLoading = true);

    final trip = await ref.read(tripControllerProvider.notifier).joinTripByCode(
      code,
      widget.userId,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (trip != null) {
      Navigator.of(context).pop();
      context.go('/trip/${trip.id}');
    } else {
      final error = ref.read(tripControllerProvider).error;
      _showError(error ?? 'Failed to join trip');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Join Trip',
                    style: AppTextStyles.h3,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Enter the invite code',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(
                hintText: 'TRVL-XXXXXX',
                prefixIcon: Icon(Icons.tag),
              ),
              textCapitalization: TextCapitalization.characters,
              onChanged: (value) {
                // Auto-format
                final formatted = InviteCodeGenerator.format(value);
                if (formatted != value) {
                  _codeController.value = _codeController.value.copyWith(
                    text: formatted,
                    selection: TextSelection.collapsed(offset: formatted.length),
                  );
                }
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _joinTrip,
                child: _isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text('Join Trip'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () async {
                final rootContext = context;
                // Guardar ref ANTES de cerrar el dialog
                final controller = ref.read(tripControllerProvider.notifier);

                Navigator.of(context).pop();
                await Future.delayed(const Duration(milliseconds: 150));

                if (!rootContext.mounted) return;

                final result = await rootContext.push('/qr-scanner');

                if (!rootContext.mounted) return;

                if (result != null && result is String) {
                  final code = InviteCodeGenerator.format(result);
                  HapticFeedback.selectionClick();

                  final trip = await controller.joinTripByCode(code, widget.userId);

                  if (!rootContext.mounted) return;

                  if (trip != null) {
                    rootContext.go('/trip/${trip.id}');
                  } else {
                    ScaffoldMessenger.of(rootContext).showSnackBar(
                      SnackBar(
                        content: const Text('Failed to join trip'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scan QR'),
            ),
          ],
        ),
      ),
    );
  }
}