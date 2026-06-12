import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travl/features/trip/presentation/providers/trip_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/trip_entity.dart';

final currentMemberProvider = Provider.family<MemberEntity?, String>(
      (ref, tripId) {
    final tripAsync = ref.watch(tripStreamProvider(tripId));
    final authAsync = ref.watch(authStateProvider);

    final userId = authAsync.maybeWhen(
      data: (user) => user?.id,
      orElse: () => null,
    );

    if (userId == null) return null;

    return tripAsync.maybeWhen(
      data: (trip) {
        try {
          return trip.members.firstWhere((m) => m.userId == userId);
        } catch (_) {
          return null;
        }
      },
      orElse: () => null,
    );
  },
);

final canEditActivitiesProvider = Provider.family<bool, String>((ref, tripId) {
  return ref.watch(currentMemberProvider(tripId))?.canEditActivities ?? false;
});

final canDeleteActivitiesProvider =
Provider.family<bool, String>((ref, tripId) {
  return ref.watch(currentMemberProvider(tripId))?.canDeleteActivities ?? false;
});

final canInviteMembersProvider = Provider.family<bool, String>((ref, tripId) {
  return ref.watch(currentMemberProvider(tripId))?.canInviteMembers ?? false;
});

final canManageRolesProvider = Provider.family<bool, String>((ref, tripId) {
  return ref.watch(currentMemberProvider(tripId))?.canManageRoles ?? false;
});