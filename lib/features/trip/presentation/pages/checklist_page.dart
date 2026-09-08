import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travl/features/trip/domain/entities/trip_entity.dart';
import 'package:travl/features/trip/presentation/providers/users_provider.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../trip/presentation/providers/trip_provider.dart';
import '../../domain/entities/checklist_item_entity.dart';
import '../providers/checklist_provider.dart';

class ChecklistPage extends ConsumerWidget {
  final String tripId;
  final bool isReadOnly;

  const ChecklistPage({
    super.key,
    required this.tripId,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checklistAsync = ref.watch(tripChecklistProvider(tripId));
    final tripAsync = ref.watch(tripStreamProvider(tripId));

    return checklistAsync.when(
      data: (items) => tripAsync.when(
        data: (trip) => _ChecklistContent(
          tripId: tripId,
          items: items,
          trip: trip,
          isReadOnly: isReadOnly,
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorMessage(error: e),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorMessage(error: e),
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  final Object error;

  const _ErrorMessage({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        context.tr(
          'generic_error',
          params: {'error': error.toString()},
        ),
      ),
    );
  }
}

class _ChecklistContent extends StatelessWidget {
  final String tripId;
  final List<ChecklistItemEntity> items;
  final TripEntity trip;
  final bool isReadOnly;

  const _ChecklistContent({
    required this.tripId,
    required this.items,
    required this.trip,
    this.isReadOnly = false,
  });

  int get _doneCount => items.where((i) => i.isDone).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: items.isEmpty
          ? _EmptyChecklist(
              onAdd: isReadOnly ? null : () => _showAddSheet(context),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProgressHeader(
                    total: items.length,
                    done: _doneCount,
                  ),
                  ...ChecklistType.values.map((type) {
                    final typeItems =
                        items.where((item) => item.type == type).toList()
                          ..sort((a, b) {
                            if (a.isDone == b.isDone) {
                              return a.createdAt.compareTo(b.createdAt);
                            }
                            return a.isDone ? 1 : -1;
                          });

                    if (typeItems.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return _ChecklistSection(
                      type: type,
                      items: typeItems,
                      trip: trip,
                      isReadOnly: isReadOnly,
                    );
                  }),
                  const SizedBox(height: 100),
                ],
              ),
            ),
      floatingActionButton: isReadOnly
          ? null
          : FloatingActionButton(
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
      backgroundColor: AppColors.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddChecklistItemSheet(
        tripId: tripId,
        members: trip.members,
      ),
    );
  }
}

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
                isComplete
                    ? context.tr('all_done_check')
                    : context.tr(
                        'progress_done_check',
                        params: {
                          'done': done.toString(),
                          'total': total.toString(),
                        },
                      ),
                style: AppTextStyles.labelSmall.copyWith(
                  color: isComplete
                      ? AppColors.success
                      : AppColors.textTertiary(context),
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).toInt()}%',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textTertiary(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.card(context),
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

class _ChecklistSection extends StatelessWidget {
  final ChecklistType type;
  final List<ChecklistItemEntity> items;
  final TripEntity trip;
  final bool isReadOnly;

  const _ChecklistSection({
    required this.type,
    required this.items,
    required this.trip,
    required this.isReadOnly,
  });

  @override
  Widget build(BuildContext context) {
    final done = items.where((i) => i.isDone).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
          child: Row(
            children: [
              Text(
                '${type.emoji}  ${context.tr('checklist_type_${type.name}').toUpperCase()}',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textTertiary(context),
                  letterSpacing: 1.2,
                  fontSize: 11,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                context.tr(
                  'progress_fraction',
                  params: {
                    'done': done.toString(),
                    'total': items.length.toString(),
                  },
                ),
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textTertiary(context),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        ...items.map(
          (item) => _ChecklistRow(
            item: item,
            trip: trip,
            isReadOnly: isReadOnly,
          ),
        ),
      ],
    );
  }
}

class _ChecklistRow extends ConsumerWidget {
  final ChecklistItemEntity item;
  final TripEntity trip;
  final bool isReadOnly;

  const _ChecklistRow({
    required this.item,
    required this.trip,
    required this.isReadOnly,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key(item.id),
      direction:
          isReadOnly ? DismissDirection.none : DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          await _showEditSheet(context);
          return false;
        }

        return _confirmDelete(context);
      },
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        color: AppColors.primary.withValues(alpha: 0.15),
        child: Icon(
          Icons.edit_outlined,
          color: AppColors.primary,
        ),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.error.withValues(alpha: 0.15),
        child: Icon(
          Icons.delete_outline,
          color: AppColors.error,
        ),
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          ref
              .read(checklistControllerProvider.notifier)
              .toggleItem(item.id, !item.isDone);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: item.isDone
                        ? AppColors.success
                        : AppColors.textTertiary(context)
                            .withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                  color: item.isDone
                      ? AppColors.success.withValues(alpha: 0.15)
                      : Colors.transparent,
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: item.isDone
                      ? const Icon(
                          Icons.check,
                          key: ValueKey('done'),
                          size: 13,
                          color: AppColors.success,
                        )
                      : const SizedBox(
                          key: ValueKey('pending'),
                        ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: item.isDone
                            ? AppColors.textTertiary(context)
                            : AppColors.textPrimary(context),
                        decoration:
                            item.isDone ? TextDecoration.lineThrough : null,
                        decorationColor: AppColors.textTertiary(context),
                      ),
                      child: Text(item.title),
                    ),
                    if (item.assignedTo != null) ...[
                      const SizedBox(height: 4),
                      _AssignedMember(
                        userId: item.assignedTo!,
                        trip: trip,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showEditSheet(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddChecklistItemSheet(
        tripId: trip.id,
        members: trip.members,
        item: item,
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.tr('delete_item')),
        content: Text(context.tr('delete_item_description')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.tr('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              context.tr('delete'),
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return false;
    }

    return true;
  }
}

class _AssignedMember extends ConsumerWidget {
  final String userId;
  final TripEntity trip;

  const _AssignedMember({
    required this.userId,
    required this.trip,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userNameAsync = ref.watch(userNameProvider(userId));

    return userNameAsync.when(
      data: (name) => Row(
        children: [
          Icon(
            Icons.person_outline,
            size: 13,
            color: AppColors.textTertiary(context),
          ),
          const SizedBox(width: 4),
          Text(
            name,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textTertiary(context),
              fontSize: 11,
            ),
          ),
        ],
      ),
      loading: () => const SizedBox(
        height: 14,
        width: 14,
        child: CircularProgressIndicator(strokeWidth: 1.5),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _EmptyChecklist extends StatelessWidget {
  final VoidCallback? onAdd;

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
            Text(
              context.tr('no_items_yet'),
              style: AppTextStyles.h4,
            ),
            const SizedBox(height: 8),
            Text(
              context.tr('checklist_empty_description'),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: Text(context.tr('add_item_check')),
            ),
          ],
        ),
      ),
    );
  }
}

class AddChecklistItemSheet extends ConsumerStatefulWidget {
  final String tripId;
  final List<MemberEntity> members;
  final ChecklistItemEntity? item;

  const AddChecklistItemSheet({
    super.key,
    required this.tripId,
    required this.members,
    this.item,
  });

  @override
  ConsumerState<AddChecklistItemSheet> createState() =>
      _AddChecklistItemSheetState();
}

class _AddChecklistItemSheetState extends ConsumerState<AddChecklistItemSheet> {
  late final TextEditingController _titleController;
  late ChecklistType _selectedType;
  String? _assignedTo;

  bool get _isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(
      text: widget.item?.title ?? '',
    );
    _selectedType = widget.item?.type ?? ChecklistType.preTip;
    _assignedTo = widget.item?.assignedTo;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();

    if (title.isEmpty) {
      return;
    }

    final controller = ref.read(checklistControllerProvider.notifier);

    final success = _isEditing
        ? await controller.updateItem(
            itemId: widget.item!.id,
            title: title,
            type: _selectedType,
            assignedTo: _assignedTo,
          )
        : await controller.createItem(
            tripId: widget.tripId,
            title: title,
            type: _selectedType,
            assignedTo: _assignedTo,
          );

    if (mounted && success) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(checklistControllerProvider);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      context.tr(
                        _isEditing ? 'edit_item' : 'add_item',
                      ),
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
                context.tr('when').toUpperCase(),
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textTertiary(context),
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
                        onTap: () => setState(
                          () => _selectedType = type,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.15)
                                : AppColors.card(context),
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
                                context.tr(
                                  'checklist_type_${type.name}',
                                ),
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textSecondary(context),
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
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: context.tr('item'),
                  hintText: context.tr('item_hint'),
                ),
                textCapitalization: TextCapitalization.sentences,
                autofocus: true,
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 20),
              _AssignmentSelector(
                members: widget.members,
                assignedTo: _assignedTo,
                onChanged: (value) {
                  setState(() => _assignedTo = value);
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: state.isLoading ? null : _submit,
                  child: state.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          context.tr(
                            _isEditing ? 'save' : 'add_item',
                          ),
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

class _AssignmentSelector extends ConsumerWidget {
  final List<MemberEntity> members;
  final String? assignedTo;
  final ValueChanged<String?> onChanged;

  const _AssignmentSelector({
    required this.members,
    required this.assignedTo,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('assigned_to').toUpperCase(),
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textTertiary(context),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.card(context),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: assignedTo,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              icon: const Icon(Icons.keyboard_arrow_down),
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text(context.tr('unassigned')),
                ),
                ...members.map(
                  (member) => DropdownMenuItem<String?>(
                    value: member.userId,
                    child: _MemberDropdownItem(
                      userId: member.userId,
                      role: member.role,
                      ref: ref,
                    ),
                  ),
                ),
              ],
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class _MemberDropdownItem extends StatelessWidget {
  final String userId;
  final String role;
  final WidgetRef ref;

  const _MemberDropdownItem({
    required this.userId,
    required this.role,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final userNameAsync = ref.watch(userNameProvider(userId));

    return userNameAsync.when(
      data: (name) => Text(name),
      loading: () => Text(userId),
      error: (_, __) => Text(userId),
    );
  }
}
