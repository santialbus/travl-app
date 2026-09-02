import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/trip_entity.dart';

class TripHeader extends StatelessWidget {
  final TripEntity trip;

  const TripHeader({
    super.key,
    required this.trip,
  });

  @override
  Widget build(BuildContext context) {
    final initial =
        trip.destination.isNotEmpty ? trip.destination[0].toUpperCase() : '?';

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
      ),
      child: trip.coverImage != null && trip.coverImage!.isNotEmpty
          ? Image.network(
              trip.coverImage!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) =>
                  _buildPlaceholder(initial),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(
                    child: CircularProgressIndicator(color: Colors.white));
              },
            )
          : _buildPlaceholder(initial),
    );
  }

  Widget _buildPlaceholder(String initial) {
    return Center(
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 64,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
