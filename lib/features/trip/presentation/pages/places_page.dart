import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/place_entity.dart';
import '../providers/places_provider.dart';

class PlacesPage extends ConsumerWidget {
  final String tripId;

  const PlacesPage({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placesAsync = ref.watch(tripPlacesProvider(tripId));

    return placesAsync.when(
      data: (places) => _PlacesContent(
        tripId: tripId,
        places: places,
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _PlacesContent extends ConsumerWidget {
  final String tripId;
  final List<PlaceEntity> places;

  const _PlacesContent({
    required this.tripId,
    required this.places,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = places.where((p) => p.status == PlaceStatus.pending).toList();
    final visited = places.where((p) => p.status == PlaceStatus.visited).toList();

    return Scaffold(
      body: places.isEmpty
          ? _EmptyPlaces(onAdd: () => _showAddSheet(context, ref))
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats header
            _StatsHeader(
              total: places.length,
              visited: visited.length,
            ),

            // Pending section
            if (pending.isNotEmpty) ...[
              _SectionSeparator(
                label: 'PENDING',
                count: pending.length,
              ),
              ...pending.map((place) => _PlaceRow(
                place: place,
                onToggle: () => ref
                    .read(placeControllerProvider.notifier)
                    .toggleStatus(place.id, place.status),
                onDelete: () => ref
                    .read(placeControllerProvider.notifier)
                    .deletePlace(place.id),
              )),
            ],

            // Visited section
            if (visited.isNotEmpty) ...[
              _SectionSeparator(
                label: 'VISITED',
                count: visited.length,
              ),
              ...visited.map((place) => _PlaceRow(
                place: place,
                onToggle: () => ref
                    .read(placeControllerProvider.notifier)
                    .toggleStatus(place.id, place.status),
                onDelete: () => ref
                    .read(placeControllerProvider.notifier)
                    .deletePlace(place.id),
              )),
            ],

            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSheet(context, ref),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddPlaceBottomSheet(tripId: tripId),
    );
  }
}

// Stats Header
class _StatsHeader extends StatelessWidget {
  final int total;
  final int visited;

  const _StatsHeader({required this.total, required this.visited});

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : visited / total;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '$visited of $total visited',
                style: AppTextStyles.labelSmall.copyWith(
                  color: visited == total && total > 0
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
                visited == total && total > 0
                    ? AppColors.success
                    : AppColors.primary,
              ),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}

// Section Separator — igual que Timeline
class _SectionSeparator extends StatelessWidget {
  final String label;
  final int count;

  const _SectionSeparator({
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Row(
        children: [
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textTertiary(context),
              letterSpacing: 1.2,
              fontSize: 11,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '· $count',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textTertiary(context),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// Place Row — estilo minimalista tipo Timeline
class _PlaceRow extends StatelessWidget {
  final PlaceEntity place;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _PlaceRow({
    required this.place,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isVisited = place.status == PlaceStatus.visited;

    return Dismissible(
      key: Key(place.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.error.withOpacity(0.15),
        child: Icon(Icons.delete_outline, color: AppColors.error),
      ),
      child: InkWell(
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              // Category emoji con fondo
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isVisited
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    place.category.emoji,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isVisited
                            ? AppColors.textTertiary(context)
                            : AppColors.textPrimary(context),
                        decoration: isVisited
                            ? TextDecoration.lineThrough
                            : null,
                        decorationColor: AppColors.textTertiary(context),
                      ),
                    ),
                    if (place.address != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          place.address!,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textTertiary(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Maps button
              if (place.mapsUrl != null)
                GestureDetector(
                  onTap: () => _openMaps(place.mapsUrl!),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.map_outlined,
                      size: 18,
                      color: AppColors.textTertiary(context),
                    ),
                  ),
                ),

              const SizedBox(width: 8),

              // Status toggle
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isVisited
                        ? AppColors.success
                        : AppColors.textTertiary(context).withOpacity(0.4),
                    width: 1.5,
                  ),
                  color: isVisited
                      ? AppColors.success.withOpacity(0.15)
                      : Colors.transparent,
                ),
                child: isVisited
                    ? const Icon(
                  Icons.check,
                  size: 13,
                  color: AppColors.success,
                )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openMaps(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

// Empty State
class _EmptyPlaces extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyPlaces({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📍', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text('No places yet', style: AppTextStyles.h4),
            const SizedBox(height: 8),
            Text(
              'Save restaurants, bars, museums\nand more for your trip',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add Place'),
            ),
          ],
        ),
      ),
    );
  }
}

// Add Place Bottom Sheet
class AddPlaceBottomSheet extends ConsumerStatefulWidget {
  final String tripId;

  const AddPlaceBottomSheet({super.key, required this.tripId});

  @override
  ConsumerState<AddPlaceBottomSheet> createState() =>
      _AddPlaceBottomSheetState();
}

class _AddPlaceBottomSheetState extends ConsumerState<AddPlaceBottomSheet> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  PlaceCategory _selectedCategory = PlaceCategory.restaurant;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty) return;

    final success = await ref.read(placeControllerProvider.notifier).createPlace(
      tripId: widget.tripId,
      name: _nameController.text.trim(),
      category: _selectedCategory,
      address: _addressController.text.trim().isNotEmpty
          ? _addressController.text.trim()
          : null,
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
    );

    if (mounted && success) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(placeControllerProvider);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
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
                  child: Text('Add Place', style: AppTextStyles.h3),
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

            // Category selector
            Text(
              'CATEGORY',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textTertiary(context),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: PlaceCategory.values.map((cat) {
                final isSelected = _selectedCategory == cat;
                return InkWell(
                  onTap: () => setState(() => _selectedCategory = cat),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.15)
                          : AppColors.card(context),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(cat.emoji),
                        const SizedBox(width: 6),
                        Text(
                          cat.value,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Name
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name *',
                hintText: 'e.g., Sushi Saito',
              ),
              textCapitalization: TextCapitalization.words,
              autofocus: true,
            ),

            const SizedBox(height: 16),

            // Address
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address (optional)',
                hintText: 'e.g., 1-1 Nishi, Shibuya',
                prefixIcon: Icon(Icons.location_on),
              ),
              textCapitalization: TextCapitalization.words,
            ),

            const SizedBox(height: 16),

            // Notes
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'e.g., Reserva recomendada',
              ),
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
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
                    : const Text('Add Place'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}