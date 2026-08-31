import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/offline_utils.dart';
import '../../domain/entities/activity_entity.dart';
import '../providers/activities_provider.dart';

class AddActivityBottomSheet extends ConsumerStatefulWidget {
  final String tripId;
  final String dayId;
  final String userId;
  final ActivityEntity? activityToEdit;
  final bool isOffline; // ✅

  const AddActivityBottomSheet({
    super.key,
    required this.tripId,
    required this.dayId,
    required this.userId,
    this.activityToEdit,
    this.isOffline = false,
  });

  @override
  ConsumerState<AddActivityBottomSheet> createState() =>
      _AddActivityBottomSheetState();
}

class _AddActivityBottomSheetState
    extends ConsumerState<AddActivityBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  final _flightNumberController = TextEditingController();
  final _trainNumberController = TextEditingController();
  final _transportCompanyController = TextEditingController();
  final _bookingReferenceController = TextEditingController();

  ActivityType _selectedType = ActivityType.place;
  DateTime? _selectedTime;

  bool get _isEditing => widget.activityToEdit != null;

  @override
  void initState() {
    super.initState();

    if (_isEditing) {
      final activity = widget.activityToEdit!;
      _titleController.text = activity.title;
      _descriptionController.text = activity.description ?? '';
      _locationController.text = activity.locationName ?? '';
      _selectedType = activity.type;
      _selectedTime = activity.time;
      _flightNumberController.text = activity.flightNumber ?? '';
      _trainNumberController.text = activity.trainNumber ?? '';
      _transportCompanyController.text = activity.transportCompany ?? '';
      _bookingReferenceController.text = activity.bookingReference ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _flightNumberController.dispose();
    _trainNumberController.dispose();
    _transportCompanyController.dispose();
    _bookingReferenceController.dispose();
    super.dispose();
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime != null
          ? TimeOfDay(
              hour: _selectedTime!.hour,
              minute: _selectedTime!.minute,
            )
          : TimeOfDay.now(),
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

    if (time != null) {
      setState(() {
        _selectedTime = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          time.hour,
          time.minute,
        );
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    bool success;

    if (_isEditing) {
      success = await ref
          .read(activityControllerProvider.notifier)
          .updateActivity(
            activityId: widget.activityToEdit!.id,
            title: _titleController.text.trim(),
            type: _selectedType,
            description: _descriptionController.text.trim().isNotEmpty
                ? _descriptionController.text.trim()
                : null,
            time: _selectedTime,
            locationName: _locationController.text.trim().isNotEmpty
                ? _locationController.text.trim()
                : null,
            flightNumber: _flightNumberController.text.trim().isNotEmpty
                ? _flightNumberController.text.trim()
                : null,
            trainNumber: _trainNumberController.text.trim().isNotEmpty
                ? _trainNumberController.text.trim()
                : null,
            transportCompany: _transportCompanyController.text.trim().isNotEmpty
                ? _transportCompanyController.text.trim()
                : null,
            bookingReference: _bookingReferenceController.text.trim().isNotEmpty
                ? _bookingReferenceController.text.trim()
                : null,
          );
    } else {
      success = await ref
          .read(activityControllerProvider.notifier)
          .createActivity(
            tripId: widget.tripId,
            dayId: widget.dayId,
            title: _titleController.text.trim(),
            type: _selectedType,
            description: _descriptionController.text.trim().isNotEmpty
                ? _descriptionController.text.trim()
                : null,
            time: _selectedTime,
            locationName: _locationController.text.trim().isNotEmpty
                ? _locationController.text.trim()
                : null,
            createdBy: widget.userId,
            flightNumber: _flightNumberController.text.trim().isNotEmpty
                ? _flightNumberController.text.trim()
                : null,
            trainNumber: _trainNumberController.text.trim().isNotEmpty
                ? _trainNumberController.text.trim()
                : null,
            transportCompany: _transportCompanyController.text.trim().isNotEmpty
                ? _transportCompanyController.text.trim()
                : null,
            bookingReference: _bookingReferenceController.text.trim().isNotEmpty
                ? _bookingReferenceController.text.trim()
                : null,
          );
    }

    if (!mounted) return;

    if (success) {
      if (!mounted) return;

      if (widget.isOffline) {
        Future.microtask(() {
          OfflineUtils.showSyncPendingMessage(context);
        });
      }

      Navigator.of(context).pop();
    } else {
      final error = ref.read(activityControllerProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? context.tr('something_wrong')),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final activityState = ref.watch(activityControllerProvider);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textTertiary(context),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Header
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _isEditing
                            ? context.tr('edit_activity')
                            : context.tr('add_activity'),
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

                // Justo después del Header en el build:
                if (widget.isOffline)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.warning.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.wifi_off,
                          size: 16,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            context.tr('offline_sync_message'),
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                // Type selector
                Text(
                  context.tr('type_label').toUpperCase(),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textTertiary(context),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 70,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: ActivityType.values.length,
                    itemBuilder: (context, index) {
                      final type = ActivityType.values[index];
                      final isSelected = _selectedType == type;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: () => setState(() => _selectedType = type),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 80,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withValues(alpha: 0.15)
                                  : AppColors.surface(context),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.borderColor(context),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  type.emoji,
                                  style: const TextStyle(fontSize: 22),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  context.tr(type.translationKey),
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textSecondary(context),
                                    fontSize: 11,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Title
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: context.tr('title_required_label'),
                    hintText: context.tr('activity_title_hint'),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return context.tr('title_required');
                    }
                    return null;
                  },
                  textCapitalization: TextCapitalization.sentences,
                ),

                const SizedBox(height: 16),

                // Location
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: context.tr('location_optional'),
                    hintText: context.tr('location_hint'),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),

                const SizedBox(height: 16),

                // Time
                InkWell(
                  onTap: _selectTime,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card(context),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _selectedTime != null
                                ? AppDateUtils.formatTime(_selectedTime!)
                                : context.tr('time_optional'),
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: _selectedTime != null
                                  ? AppColors.textPrimary(context)
                                  : AppColors.textTertiary(context),
                            ),
                          ),
                        ),
                        if (_selectedTime != null)
                          GestureDetector(
                            onTap: () => setState(() => _selectedTime = null),
                            child: const Icon(Icons.clear, size: 20),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Notes
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: context.tr('notes_optional'),
                    hintText: context.tr('notes_hint'),
                  ),
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                ),

                _buildTypeSpecificFields(),
                const SizedBox(height: 24),

                // Submit
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: activityState.isLoading ? null : _submit,
                    child: activityState.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            _isEditing
                                ? context.tr('save_changes')
                                : context.tr('add_activity'),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSpecificFields() {
    switch (_selectedType) {
      case ActivityType.flight:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              context.tr('flight_details'),
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textTertiary(context),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _flightNumberController,
              decoration: InputDecoration(
                labelText: context.tr('flight_number'),
                hintText: 'e.g., IB3456',
                prefixIcon: Icon(Icons.flight),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
          ],
        );

      case ActivityType.transport:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              context.tr('transport_details'),
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textTertiary(context),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _transportCompanyController,
              decoration: InputDecoration(
                labelText: context.tr('company'),
                hintText: 'e.g., Renfe, Blablacar',
                prefixIcon: Icon(Icons.train),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _trainNumberController,
              decoration: InputDecoration(
                labelText: context.tr('train_number'),
                hintText: 'e.g., AVE 02145',
                prefixIcon: Icon(Icons.confirmation_number),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
          ],
        );

      case ActivityType.hotel:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              context.tr('booking_details'),
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textTertiary(context),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _bookingReferenceController,
              decoration: InputDecoration(
                labelText: context.tr('booking_reference'),
                hintText: 'e.g., #ABC123456',
                prefixIcon: Icon(Icons.tag),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
