import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/checklist_item_entity.dart';
import '../providers/checklist_provider.dart';

class ChecklistPage extends ConsumerWidget {
  final String tripId;

  const ChecklistPage({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checklistAsync = ref.watch(tripChecklistProvider(tripId));

    return checklistAsync.when(
      data: (items) => _ChecklistContent(
        tripId: tripId,
        items: items,
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _ChecklistContent extends StatelessWidget {
  final String tripId;
  final List<ChecklistItemEntity> items;

  const _ChecklistContent({
    required this.tripId,
    required this.items,
  });

  int get _doneCount => items.where((i) => i.isDone).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: items.isEmpty
          ? _EmptyChecklist(
        onAdd: () => _showAddSheet(context),
      )
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress header
            _ProgressHeader(
              total: items.length,
              done: _doneCount,
            ),

            // Sections por tipo
            ...ChecklistType.values.map((type) {
              final typeItems =
              items.where((i) => i.type == type).toList();
              if (typeItems.isEmpty) return const SizedBox.shrink();
              return _ChecklistSection(
                type: type,
                items: typeItems,
              );
            }),

            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSheet(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddChecklistItemSheet(tripId: tripId),
    );
  }
}

// Progress header
class _ProgressHeader extends StatelessWidget {
  final int total;
  final int done;

  const _ProgressHeader({
    required this.total,
    required this.done,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : done / total;
    final isComplete = done == total;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                isComplete ? 'All done! 🎉' : '$done of $total done',
                style: AppTextStyles.labelSmall.copyWith(
                  color: isComplete
                      ? AppColors.success
                      : AppColors.textTertiary,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).toInt()}%',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.cardDark,
              valueColor: AlwaysStoppedAnimation(
                isComplete ? AppColors.success : AppColors.primary,
              ),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}

// Section por tipo
class _ChecklistSection extends ConsumerWidget {
  final ChecklistType type;
  final List<ChecklistItemEntity> items;

  const _ChecklistSection({
    required this.type,
    required this.items,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final done = items.where((i) => i.isDone).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Separador tipo Timeline
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
          child: Row(
            children: [
              Text(
                '${type.emoji}  ${type.value.toUpperCase()}',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textTertiary,
                  letterSpacing: 1.2,
                  fontSize: 11,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '· $done/${items.length}',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textTertiary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),

        // Items
        ...items.map((item) => _ChecklistRow(item: item)),
      ],
    );
  }
}

// Checklist row — estilo minimalista tipo Timeline
class _ChecklistRow extends ConsumerWidget {
  final ChecklistItemEntity item;

  const _ChecklistRow({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        ref.read(checklistControllerProvider.notifier).deleteItem(item.id);
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.error.withOpacity(0.15),
        child: Icon(Icons.delete_outline, color: AppColors.error),
      ),
      child: InkWell(
        onTap: () => ref
            .read(checklistControllerProvider.notifier)
            .toggleItem(item.id, !item.isDone),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              // Checkbox circular
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: item.isDone
                        ? AppColors.success
                        : AppColors.textTertiary.withOpacity(0.4),
                    width: 1.5,
                  ),
                  color: item.isDone
                      ? AppColors.success.withOpacity(0.15)
                      : Colors.transparent,
                ),
                child: item.isDone
                    ? const Icon(
                  Icons.check,
                  size: 13,
                  color: AppColors.success,
                )
                    : null,
              ),

              const SizedBox(width: 14),

              // Title
              Expanded(
                child: Text(
                  item.title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: item.isDone
                        ? AppColors.textTertiary
                        : AppColors.textPrimary,
                    decoration: item.isDone
                        ? TextDecoration.lineThrough
                        : null,
                    decorationColor: AppColors.textTertiary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Empty state
class _EmptyChecklist extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyChecklist({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📋', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text('No items yet', style: AppTextStyles.h4),
            const SizedBox(height: 8),
            Text(
              'Add things to pack or tasks\nto complete before your trip',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add Item'),
            ),
          ],
        ),
      ),
    );
  }
}

// Add item bottom sheet
class AddChecklistItemSheet extends ConsumerStatefulWidget {
  final String tripId;

  const AddChecklistItemSheet({super.key, required this.tripId});

  @override
  ConsumerState<AddChecklistItemSheet> createState() =>
      _AddChecklistItemSheetState();
}

class _AddChecklistItemSheetState
    extends ConsumerState<AddChecklistItemSheet> {
  final _titleController = TextEditingController();
  ChecklistType _selectedType = ChecklistType.preTip;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty) return;

    final success = await ref
        .read(checklistControllerProvider.notifier)
        .createItem(
      tripId: widget.tripId,
      title: _titleController.text.trim(),
      type: _selectedType,
    );

    if (mounted && success) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(checklistControllerProvider);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
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
                  color: AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Header
            Row(
              children: [
                Expanded(
                  child: Text('Add Item', style: AppTextStyles.h3),
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

            // Type selector — igual que Timeline
            Text(
              'WHEN',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textTertiary,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: ChecklistType.values.map((type) {
                final isSelected = _selectedType == type;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () => setState(() => _selectedType = type),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withOpacity(0.15)
                              : AppColors.cardDark,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              type.emoji,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              type.value,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Input
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Item',
                hintText: 'e.g., Pack sunscreen',
              ),
              textCapitalization: TextCapitalization.sentences,
              autofocus: true,
              onSubmitted: (_) => _submit(),
            ),

            const SizedBox(height: 24),

            // Submit
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: state.isLoading ? null : _submit,
                child: state.isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text('Add Item'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}