import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_strings.dart';
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
      _showError(context.tr('enter_invite_code_error_join_trip'));
      return;
    }

    if (!InviteCodeGenerator.isValid(code)) {
      _showError(context.tr('invalid_invite_code_join_trip'));
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
      _showError(error ?? context.tr('failed_join_trip'));
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
                    context.tr('join_trip_join_trip'),
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
              context.tr('enter_invite_code_join_trip'),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _codeController,
              decoration: InputDecoration(
                hintText: context.tr('invite_code_hint_join_trip'),
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
                    : Text(context.tr('join_trip_join_trip')),
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();

                context.push(
                  '/qr-scanner',
                  extra: widget.userId, // 🔥 importante
                );
              },
              icon: const Icon(Icons.qr_code_scanner),
              label: Text(context.tr('scan_qr_join_trip')),
            ),
          ],
        ),
      ),
    );
  }
}