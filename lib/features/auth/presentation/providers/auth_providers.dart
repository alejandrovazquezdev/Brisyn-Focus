import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/app_user.dart';
import '../../domain/services/auth_service.dart';

/// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Firebase auth state stream provider
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

/// Current app user provider
final currentUserProvider = Provider<AppUser?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.whenOrNull(
    data: (user) {
      if (user == null) return null;
      return AppUser.fromFirebaseUser(
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
        photoUrl: user.photoURL,
        emailVerified: user.emailVerified,
      );
    },
  );
});

/// Is user logged in provider
final isLoggedInProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.whenOrNull(data: (user) => user != null) ?? false;
});

/// Is email verified provider
final isEmailVerifiedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.whenOrNull(
        data: (user) => user?.emailVerified ?? false,
      ) ??
      false;
});

/// Auth state for UI
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  needsEmailVerification,
  error,
}

/// Auth state notifier for managing auth UI state
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState());

  /// Sign up with email
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);

    final result = await _authService.signUpWithEmail(
      email: email,
      password: password,
      displayName: displayName,
    );

    if (result.success) {
      if (result.needsEmailVerification) {
        state = state.copyWith(
          status: AuthStatus.needsEmailVerification,
          user: result.user,
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: result.user,
        );
      }
    } else {
      state = state.copyWith(
        status: AuthStatus.error,
        error: result.error,
      );
    }
  }

  /// Sign in with email
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);

    final result = await _authService.signInWithEmail(
      email: email,
      password: password,
    );

    if (result.success) {
      if (result.needsEmailVerification) {
        state = state.copyWith(
          status: AuthStatus.needsEmailVerification,
          user: result.user,
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: result.user,
        );
      }
    } else {
      state = state.copyWith(
        status: AuthStatus.error,
        error: result.error,
      );
    }
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading, error: null);

    final result = await _authService.signInWithGoogle();

    if (result.success) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: result.user,
      );
    } else {
      state = state.copyWith(
        status: AuthStatus.error,
        error: result.error,
      );
    }
  }

  /// Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);

    final result = await _authService.sendPasswordResetEmail(email);

    if (result.success) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return true;
    } else {
      state = state.copyWith(
        status: AuthStatus.error,
        error: result.error,
      );
      return false;
    }
  }

  /// Resend email verification
  Future<bool> resendEmailVerification() async {
    final result = await _authService.resendEmailVerification();
    if (!result.success && result.error != null) {
      state = state.copyWith(error: result.error);
    }
    return result.success;
  }

  /// Check if email is verified
  Future<bool> checkEmailVerified() async {
    final isVerified = await _authService.checkEmailVerified();
    if (isVerified) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: _authService.currentAppUser,
      );
    }
    return isVerified;
  }

  /// Sign out
  Future<void> signOut() async {
    await _authService.signOut();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Reset state
  void reset() {
    state = const AuthState();
  }
}

/// Auth state
class AuthState {
  final AuthStatus status;
  final AppUser? user;
  final String? error;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
  });

  AuthState copyWith({
    AuthStatus? status,
    AppUser? user,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
    );
  }
}

/// Auth notifier provider
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});
