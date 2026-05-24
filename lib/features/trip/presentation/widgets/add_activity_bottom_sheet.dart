import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/activity_entity.dart';
import '../providers/activities_provider.dart';

class AddActivityBottomSheet extends ConsumerStatefulWidget {
  final String tripId;
  final String dayId;
  final String userId;

  const AddActivityBottomSheet({
    super.key,
    required this.tripId,
    required this.dayId,
    required this.userId,
  });

  @override
  ConsumerState<AddActivityBottomSheet> createState() => _AddActivityBottomSheetState();
}

class _AddActivityBottomSheetState extends ConsumerState<AddActivityBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  ActivityType _selectedType = ActivityType.place;
  DateTime? _selectedTime;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.surface(context),
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

  Future<void> _createActivity() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(activityControllerProvider.notifier).createActivity(
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
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
    } else {
      final error = ref.read(activityControllerProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Failed to create activity'),
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
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Add Activity',
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

                // Activity Type Selector
                Text(
                  'Type',
                  style: AppTextStyles.labelLarge,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 70, // ✅ Aumentado de 60 a 70
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
                            width: 80, // ✅ Añadido ancho fijo
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12, // ✅ Reducido de 16 a 12
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
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
                              mainAxisSize: MainAxisSize.min, // ✅ Añadido
                              children: [
                                Text(
                                  type.emoji,
                                  style: const TextStyle(fontSize: 22), // ✅ Aumentado de 20 a 22
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  type.value,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.textSecondary(context),
                                    fontSize: 11, // ✅ Añadido tamaño específico
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
                  decoration: const InputDecoration(
                    labelText: 'Title *',
                    hintText: 'e.g., Lunch at Sushi Restaurant',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Title is required';
                    }
                    return null;
                  },
                  textCapitalization: TextCapitalization.sentences,
                ),

                const SizedBox(height: 16),

                // Location
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location (optional)',
                    hintText: 'e.g., Shibuya, Tokyo',
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
                                : 'Time (optional)',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: _selectedTime != null
                                  ? AppColors.textPrimary(context)
                                  : AppColors.textTertiary(context),
                            ),
                          ),
                        ),
                        if (_selectedTime != null)
                          IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () => setState(() => _selectedTime = null),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    hintText: 'Add any additional notes...',
                  ),
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                ),

                const SizedBox(height: 24),

                // Create Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: activityState.isLoading ? null : _createActivity,
                    child: activityState.isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Text('Add Activity'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}