import 'dart:io' show Platform;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import '../../../../core/services/desktop_auth_service.dart';
import '../models/app_user.dart';

// iOS/macOS Client ID for Google Sign-In (uses same iOS client for macOS)
const _iosClientId = '150222395140-i35k566eods32brujsudb2s1mjkubur4.apps.googleusercontent.com';

/// Check if we're on desktop platform
bool get _isDesktop {
  if (kIsWeb) return false;
  return Platform.isMacOS || Platform.isWindows || Platform.isLinux;
}

/// Authentication result wrapper
class AuthResult {
  final AppUser? user;
  final String? error;
  final bool success;
  final bool needsEmailVerification;

  const AuthResult({
    this.user,
    this.error,
    required this.success,
    this.needsEmailVerification = false,
  });

  factory AuthResult.success(AppUser user) {
    return AuthResult(user: user, success: true);
  }

  factory AuthResult.failure(String error) {
    return AuthResult(error: error, success: false);
  }

  factory AuthResult.needsVerification(AppUser user) {
    return AuthResult(
      user: user,
      success: true,
      needsEmailVerification: true,
    );
  }
}

/// Authentication service handling Firebase Auth
class AuthService {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  AuthService({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
              scopes: ['email', 'profile'],
              // Use iOS client ID for macOS (same bundle, no secret required)
              clientId: !kIsWeb && (Platform.isMacOS || Platform.isIOS) ? _iosClientId : null,
            );

  /// Get current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Check if user is logged in
  bool get isLoggedIn {
    // On desktop, check our custom auth service
    if (_isDesktop) {
      return DesktopAuthService.instance.isLoggedIn;
    }
    return currentUser != null;
  }

  /// Check if email is verified
  bool get isEmailVerified {
    if (_isDesktop) {
      return DesktopAuthService.instance.isEmailVerified;
    }
    return currentUser?.emailVerified ?? false;
  }

  /// Convert Firebase User to AppUser
  AppUser? get currentAppUser {
    // On desktop, use our custom service
    if (_isDesktop && DesktopAuthService.instance.isLoggedIn) {
      return AppUser(
        uid: DesktopAuthService.instance.currentUserId!,
        email: DesktopAuthService.instance.currentEmail,
        displayName: DesktopAuthService.instance.currentDisplayName,
        emailVerified: DesktopAuthService.instance.isEmailVerified,
        createdAt: DateTime.now(),
      );
    }
    
    final user = currentUser;
    if (user == null) return null;
    return AppUser.fromFirebaseUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      emailVerified: user.emailVerified,
    );
  }

  // ============================================
  // EMAIL/PASSWORD AUTH
  // ============================================

  /// Sign up with email and password
  Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    // Use desktop auth service on macOS/Windows/Linux
    if (_isDesktop) {
      final result = await DesktopAuthService.instance.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
      
      if (result.success) {
        return AuthResult.needsVerification(
          AppUser(
            uid: result.userId!,
            email: result.email,
            displayName: result.displayName,
            emailVerified: false,
            createdAt: DateTime.now(),
          ),
        );
      } else {
        return AuthResult.failure(result.error ?? 'Sign up failed');
      }
    }

    // Standard Firebase Auth for mobile/web
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        return AuthResult.failure('Failed to create account');
      }

      // Update display name if provided
      if (displayName != null && displayName.isNotEmpty) {
        await user.updateDisplayName(displayName);
      }

      // Send email verification
      await user.sendEmailVerification();

      return AuthResult.needsVerification(
        AppUser.fromFirebaseUser(
          uid: user.uid,
          email: user.email,
          displayName: displayName ?? user.displayName,
          photoUrl: user.photoURL,
          emailVerified: false,
        ),
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure('An unexpected error occurred');
    }
  }

  /// Sign in with email and password
  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    // Use desktop auth service on macOS/Windows/Linux
    if (_isDesktop) {
      debugPrint('AuthService: Using DesktopAuthService for sign in');
      final result = await DesktopAuthService.instance.signInWithEmail(
        email: email,
        password: password,
      );
      
      if (result.success) {
        final user = AppUser(
          uid: result.userId!,
          email: result.email,
          displayName: result.displayName,
          emailVerified: result.emailVerified,
          createdAt: DateTime.now(),
        );
        
        if (!result.emailVerified) {
          return AuthResult.needsVerification(user);
        }
        return AuthResult.success(user);
      } else {
        return AuthResult.failure(result.error ?? 'Sign in failed');
      }
    }

    // Standard Firebase Auth for mobile/web
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        return AuthResult.failure('Failed to sign in');
      }

      // Check if email is verified
      if (!user.emailVerified) {
        return AuthResult.needsVerification(
          AppUser.fromFirebaseUser(
            uid: user.uid,
            email: user.email,
            displayName: user.displayName,
            photoUrl: user.photoURL,
            emailVerified: false,
          ),
        );
      }

      return AuthResult.success(
        AppUser.fromFirebaseUser(
          uid: user.uid,
          email: user.email,
          displayName: user.displayName,
          photoUrl: user.photoURL,
          emailVerified: user.emailVerified,
        ),
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error: ${e.code} - ${e.message}');
      return AuthResult.failure(_getErrorMessage(e.code));
    } catch (e) {
      debugPrint('Sign in error: $e');
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('invalid-credential') || 
          errorStr.contains('invalid_login_credentials') ||
          errorStr.contains('wrong-password')) {
        return AuthResult.failure('Invalid email or password.');
      }
      return AuthResult.failure('An unexpected error occurred. Please try again.');
    }
  }

  /// Send password reset email
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    // Use desktop service on desktop
    if (_isDesktop) {
      final result = await DesktopAuthService.instance.sendPasswordResetEmail(email);
      if (result.success) {
        return const AuthResult(success: true);
      } else {
        return AuthResult.failure(result.error ?? 'Failed to send reset email');
      }
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      return const AuthResult(success: true);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure('An unexpected error occurred');
    }
  }

  /// Resend email verification
  Future<AuthResult> resendEmailVerification() async {
    // Use desktop service on desktop
    if (_isDesktop) {
      final success = await DesktopAuthService.instance.resendEmailVerification();
      if (success) {
        return const AuthResult(success: true);
      } else {
        return AuthResult.failure('Failed to resend verification email');
      }
    }

    try {
      final user = currentUser;
      if (user == null) {
        return AuthResult.failure('No user logged in');
      }
      await user.sendEmailVerification();
      return const AuthResult(success: true);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure('An unexpected error occurred');
    }
  }

  /// Reload user to check email verification status
  Future<bool> checkEmailVerified() async {
    // Use desktop service on desktop
    if (_isDesktop) {
      return await DesktopAuthService.instance.checkEmailVerified();
    }

    try {
      await currentUser?.reload();
      return currentUser?.emailVerified ?? false;
    } catch (e) {
      return false;
    }
  }

  // ============================================
  // GOOGLE SIGN IN
  // ============================================

  /// Sign in with Google
  Future<AuthResult> signInWithGoogle() async {
    try {
      UserCredential credential;

      if (kIsWeb) {
        // Web: Use popup
        final googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        credential = await _auth.signInWithPopup(googleProvider);
      } else {
        // Mobile/Desktop: Use GoogleSignIn package
        try {
          final googleUser = await _googleSignIn.signIn();
          if (googleUser == null) {
            return AuthResult.failure('Google sign in was cancelled');
          }

          final googleAuth = await googleUser.authentication;
          final authCredential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );

          credential = await _auth.signInWithCredential(authCredential);
        } catch (e) {
          // Google Sign-In may fail on simulator or if not configured
          debugPrint('Google Sign-In error: $e');
          return AuthResult.failure(
            'Google Sign-In is not available. Please use email sign-in or try on a real device.',
          );
        }
      }

      final user = credential.user;
      if (user == null) {
        return AuthResult.failure('Failed to sign in with Google');
      }

      return AuthResult.success(
        AppUser.fromFirebaseUser(
          uid: user.uid,
          email: user.email,
          displayName: user.displayName,
          photoUrl: user.photoURL,
          emailVerified: user.emailVerified,
        ),
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure('Google Sign-In failed: ${e.toString()}');
    }
  }

  // ============================================
  // SIGN OUT
  // ============================================

  /// Sign out
  Future<void> signOut() async {
    // Use desktop service on desktop
    if (_isDesktop) {
      await DesktopAuthService.instance.signOut();
      return;
    }
    
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  // ============================================
  // ACCOUNT MANAGEMENT
  // ============================================

  /// Update display name
  Future<AuthResult> updateDisplayName(String displayName) async {
    try {
      await currentUser?.updateDisplayName(displayName);
      await currentUser?.reload();
      return const AuthResult(success: true);
    } catch (e) {
      return AuthResult.failure('Failed to update display name');
    }
  }

  /// Update password
  Future<AuthResult> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = currentUser;
      if (user == null || user.email == null) {
        return AuthResult.failure('No user logged in');
      }

      // Re-authenticate
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);
      return const AuthResult(success: true);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure('Failed to update password');
    }
  }

  /// Delete account
  Future<AuthResult> deleteAccount(String password) async {
    try {
      final user = currentUser;
      if (user == null || user.email == null) {
        return AuthResult.failure('No user logged in');
      }

      // Re-authenticate
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      // Delete account
      await user.delete();
      return const AuthResult(success: true);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure('Failed to delete account');
    }
  }

  // ============================================
  // HELPERS
  // ============================================

  /// Convert Firebase error codes to user-friendly messages
  String _getErrorMessage(String code) {
    switch (code.toLowerCase()) {
      case 'email-already-in-use':
        return 'This email is already registered. Try signing in instead.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
      case 'invalid_login_credentials':
        return 'Invalid email or password.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      case 'requires-recent-login':
        return 'Please sign in again to complete this action.';
      default:
        debugPrint('Unknown Firebase error code: $code');
        return 'An error occurred. Please try again.';
    }
  }
}
