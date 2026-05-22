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
  Future<UserEntity> signInWithEmailPassword(String email, String password) async {
    try {
      return await _remoteDataSource.signInWithEmailPassword(email, password);
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
}