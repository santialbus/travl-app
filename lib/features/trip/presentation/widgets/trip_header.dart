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
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
      ),
      child: trip.coverImage != null
          ? Image.network(
        trip.coverImage!,
        fit: BoxFit.cover,
      )
          : Center(
        child: Text(
          trip.destination[0].toUpperCase(),
          style: const TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}