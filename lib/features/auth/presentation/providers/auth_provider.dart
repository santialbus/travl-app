import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travl/features/auth/domain/entities/user_avatar.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

// Data Source Provider
final authDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource();
});

// Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dataSource = ref.watch(authDataSourceProvider);
  return AuthRepositoryImpl(dataSource);
});

// Auth State Provider (stream of current user)
final authStateProvider = StreamProvider<UserEntity?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges();
});

// Current User Provider
final currentUserProvider = FutureProvider<UserEntity?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.getCurrentUser();
});

// Auth Controller
final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthController(repository);
});

// Auth State
class AuthState {
  final bool isLoading;
  final String? error;
  final UserEntity? user;

  AuthState({
    this.isLoading = false,
    this.error,
    this.user,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    UserEntity? user,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      user: user ?? this.user,
    );
  }
}

// Auth Controller
class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthController(this._repository) : super(AuthState());

  String _getErrorCode(Object error) {
    if (error is FirebaseAuthException) {
      return error.code;
    }

    return 'unknown';
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _repository.signInWithGoogle();
      state = state.copyWith(isLoading: false, user: user);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getErrorCode(e),
      );
    }
  }

  Future<void> signInWithEmailPassword(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _repository.signInWithEmailPassword(email, password);
      state = state.copyWith(isLoading: false, user: user);
    } catch (e) {
      print('AUTH ERROR TYPE: ${e.runtimeType}');
      print('AUTH ERROR VALUE: $e');
      state = state.copyWith(
        isLoading: false,
        error: _getErrorCode(e),
      );
    }
  }

  Future<void> signUpWithEmailPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _repository.signUpWithEmailPassword(
        email: email,
        password: password,
        name: name,
      );
      state = state.copyWith(isLoading: false, user: user);
    } catch (e) {
      print('AUTH ERROR TYPE: ${e.runtimeType}');
      print('AUTH ERROR VALUE: $e');
      state = state.copyWith(
        isLoading: false,
        error: _getErrorCode(e),
      );
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.signOut();
      state = AuthState();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> updateDisplayName(String name) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.updateDisplayName(name);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updatePreferredCurrency(String currency) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.updatePreferredCurrency(currency);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updatePassword(
      String currentPassword, String newPassword) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.updatePassword(currentPassword, newPassword);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updateAvatar(UserAvatar? avatar) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.updateAvatar(avatar);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}
