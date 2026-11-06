import 'package:firebase_auth/firebase_auth.dart';
import 'package:travl/features/auth/domain/entities/user_avatar.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      return await _remoteDataSource.getCurrentUser();
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    try {
      return await _remoteDataSource.signInWithGoogle();
    } catch (e) {
      throw Exception('Google sign in failed: $e');
    }
  }

  @override
  Future<UserEntity> signInWithEmailPassword(
      String email, String password) async {
    try {
      return await _remoteDataSource.signInWithEmailPassword(email, password);
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw Exception('Email sign in failed: $e');
    }
  }

  @override
  Future<UserEntity> signUpWithEmailPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      return await _remoteDataSource.signUpWithEmailPassword(
        email: email,
        password: password,
        name: name,
      );
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _remoteDataSource.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  @override
  Stream<UserEntity?> authStateChanges() {
    return _remoteDataSource.authStateChanges();
  }

  @override
  Future<void> updateDisplayName(String name) async {
    try {
      await _remoteDataSource.updateDisplayName(name);
    } catch (e) {
      throw Exception('Failed to update name: $e');
    }
  }

  @override
  Future<void> updatePreferredCurrency(String currency) async {
    try {
      await _remoteDataSource.updatePreferredCurrency(currency);
    } catch (e) {
      throw Exception('Failed to update preferred currency: $e');
    }
  }

  @override
  Future<void> updatePassword(
      String currentPassword, String newPassword) async {
    try {
      await _remoteDataSource.updatePassword(currentPassword, newPassword);
    } catch (e) {
      throw Exception('Failed to update password: $e');
    }
  }

  @override
  Future<void> updateAvatar(UserAvatar? avatar) {
    return _remoteDataSource.updateAvatar(avatar);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _remoteDataSource.sendPasswordResetEmail(email);
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }
}
