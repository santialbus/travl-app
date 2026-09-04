import '../entities/user_entity.dart';

abstract class AuthRepository {
  // Get current user
  Future<UserEntity?> getCurrentUser();

  // Sign in with Google
  Future<UserEntity> signInWithGoogle();

  // Sign in with Email/Password
  Future<UserEntity> signInWithEmailPassword(String email, String password);

  // Sign up with Email/Password
  Future<UserEntity> signUpWithEmailPassword({
    required String email,
    required String password,
    required String name,
  });

  // Sign out
  Future<void> signOut();

  // Stream of auth state changes
  Stream<UserEntity?> authStateChanges();

  // Update display name
  Future<void> updateDisplayName(String name);

// Update password
  Future<void> updatePassword(String currentPassword, String newPassword);
}
