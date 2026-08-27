import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/trip_provider.dart';

class CreateTripPage extends ConsumerStatefulWidget {
  const CreateTripPage({super.key});

  @override
  ConsumerState<CreateTripPage> createState() => _CreateTripPageState();
}

class _CreateTripPageState extends ConsumerState<CreateTripPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _destinationController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _nameController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      builder: (context, child) {
        final theme = Theme.of(context);

        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      builder: (context, child) {
        final theme = Theme.of(context);

        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _createTrip() async {
    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('select_start_end_dates')),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final user = await ref.read(currentUserProvider.future);
    if (user == null) return;

    final trip = await ref.read(tripControllerProvider.notifier).createTrip(
      name: _nameController.text.trim(),
      destination: _destinationController.text.trim(),
      startDate: _startDate!,
      endDate: _endDate!,
      ownerId: user.id,
    );

    if (!mounted) return;

    if (trip != null) {
      context.go('/trip/${trip.id}');
    } else {
      final error = ref.read(tripControllerProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? context.tr('failed_create_trip')),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tripState = ref.watch(tripControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('create_trip')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Trip Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: context.tr('trip_name'),
                  hintText: context.tr('trip_name_hint'),
                  prefixIcon: Icon(Icons.luggage),
                ),
                validator: Validators.tripName,
                textCapitalization: TextCapitalization.words,
              ),

              const SizedBox(height: 16),

              // Destination
              TextFormField(
                controller: _destinationController,
                decoration: InputDecoration(
                  labelText: context.tr('destination'),
                  hintText: context.tr('destination_hint'),
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: Validators.destination,
                textCapitalization: TextCapitalization.words,
              ),

              const SizedBox(height: 24),

              // Dates Section
              Text(
                context.tr('dates'),
                style: AppTextStyles.labelLarge,
              ),
              const SizedBox(height: 16),

              // Start Date
              InkWell(
                onTap: _selectStartDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card(context),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.tr('start_date'),
                              style: AppTextStyles.labelSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _startDate != null
                                  ? AppDateUtils.formatDate(_startDate!)
                                  : context.tr('select_date'),
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: _startDate != null
                                    ? AppColors.textPrimary(context)
                                    : AppColors.textTertiary(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // End Date
              InkWell(
                onTap: _selectEndDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card(context),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.event, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.tr('end_date'),
                              style: AppTextStyles.labelSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _endDate != null
                                  ? AppDateUtils.formatDate(_endDate!)
                                  : context.tr('select_date'),
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: _endDate != null
                                    ? AppColors.textPrimary(context)
                                    : AppColors.textTertiary(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Create Button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: tripState.isLoading ? null : _createTrip,
                  child: tripState.isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : Text(context.tr('create_trip')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}