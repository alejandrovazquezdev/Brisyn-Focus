import 'dart:io' show Platform;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/desktop_auth_service.dart';
import '../../../../core/services/purchase_service.dart';
import '../../domain/models/app_user.dart';
import '../../domain/services/auth_service.dart';

/// Check if we're on desktop platform
bool get _isDesktop {
  if (kIsWeb) return false;
  return Platform.isMacOS || Platform.isWindows || Platform.isLinux;
}

/// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Firebase auth state stream provider
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

/// Current app user provider - works on all platforms including desktop
final currentUserProvider = Provider<AppUser?>((ref) {
  // On desktop, use DesktopAuthService
  if (_isDesktop) {
    final authState = ref.watch(authNotifierProvider);
    return authState.user;
  }
  
  // On mobile/web, use Firebase stream
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

/// Is user logged in provider - works on all platforms including desktop
final isLoggedInProvider = Provider<bool>((ref) {
  // On desktop, use DesktopAuthService
  if (_isDesktop) {
    final authState = ref.watch(authNotifierProvider);
    return authState.status == AuthStatus.authenticated;
  }
  
  // On mobile/web, use Firebase stream
  final authState = ref.watch(authStateProvider);
  return authState.whenOrNull(data: (user) => user != null) ?? false;
});

/// Is email verified provider - works on all platforms including desktop
final isEmailVerifiedProvider = Provider<bool>((ref) {
  // On desktop, use DesktopAuthService
  if (_isDesktop) {
    return DesktopAuthService.instance.isEmailVerified;
  }
  
  // On mobile/web, use Firebase stream
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
    debugPrint('AuthNotifier: Starting sign in...');
    state = state.copyWith(status: AuthStatus.loading, error: null);

    final result = await _authService.signInWithEmail(
      email: email,
      password: password,
    );

    debugPrint('AuthNotifier: Sign in result - success: ${result.success}, needsVerification: ${result.needsEmailVerification}');

    if (result.success) {
      if (result.needsEmailVerification) {
        debugPrint('AuthNotifier: Setting status to needsEmailVerification');
        state = state.copyWith(
          status: AuthStatus.needsEmailVerification,
          user: result.user,
        );
      } else {
        debugPrint('AuthNotifier: Setting status to authenticated');
        
        // Update PurchaseService with user ID for subscription tracking
        if (result.user != null) {
          await PurchaseService.instance.setUserId(result.user!.uid);
        }
        
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: result.user,
        );
        debugPrint('AuthNotifier: New state status: ${state.status}');
      }
    } else {
      debugPrint('AuthNotifier: Sign in failed - ${result.error}');
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
      // Update PurchaseService with user ID for subscription tracking
      final user = _authService.currentAppUser;
      if (user != null) {
        await PurchaseService.instance.setUserId(user.uid);
      }
      
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      );
    }
    return isVerified;
  }

  /// Sign out
  Future<void> signOut() async {
    await _authService.signOut();
    await PurchaseService.instance.logout();
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
