class FirebaseConstants {
  FirebaseConstants._();

  // Collections
  static const String usersCollection = 'users';
  static const String tripsCollection = 'trips';
  static const String daysCollection = 'days';
  static const String activitiesCollection = 'activities';
  static const String expensesCollection = 'expenses';
  static const String checklistCollection = 'checklist';
  static const String filesCollection = 'files';

  // Storage Paths
  static const String tripCoverImages = 'trip_covers';
  static const String activityImages = 'activity_images';
  static const String userProfiles = 'user_profiles';
  static const String tripFiles = 'trip_files';

  // Fields - User
  static const String userIdField = 'id';
  static const String userNameField = 'name';
  static const String userEmailField = 'email';
  static const String userPhotoUrlField = 'photoUrl';
  static const String userTripsOwnedField = 'tripsOwned';
  static const String userTripsJoinedField = 'tripsJoined';
  static const String userCreatedAtField = 'createdAt';

  // Fields - Trip
  static const String tripIdField = 'id';
  static const String tripNameField = 'name';
  static const String tripDestinationField = 'destination';
  static const String tripStartDateField = 'startDate';
  static const String tripEndDateField = 'endDate';
  static const String tripOwnerIdField = 'ownerId';
  static const String tripMembersField = 'members';
  static const String tripInviteCodeField = 'inviteCode';
  static const String tripCoverImageField = 'coverImage';
  static const String tripCreatedAtField = 'createdAt';

  // Fields - Activity
  static const String activityTripIdField = 'tripId';
  static const String activityDayIdField = 'dayId';
  static const String activityTypeField = 'type';
  static const String activityTimeField = 'time';
  static const String activityOrderIndexField = 'orderIndex';
  static const String activityIsCompletedField = 'isCompleted';
  static const String activityCreatedByField = 'createdBy';
}