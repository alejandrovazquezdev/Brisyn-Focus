import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Desktop authentication service using Firebase REST API
/// 
/// This bypasses the native Firebase SDK's keychain dependency on macOS
/// by using the Firebase Auth REST API directly for authentication.
class DesktopAuthService {
  static final DesktopAuthService instance = DesktopAuthService._();
  DesktopAuthService._();

  SharedPreferences? _prefs;
  
  // Firebase Web API Key (from Firebase Console - Web app config)
  // This is the key needed for Firebase REST API authentication
  static const String _apiKey = 'AIzaSyCCn9IhFS5M8-HYB7eilyhXPEdAdW0-mR8';
  
  // Storage keys
  static const String _keyIdToken = 'desktop_auth_id_token';
  static const String _keyRefreshToken = 'desktop_auth_refresh_token';
  static const String _keyUserId = 'desktop_auth_user_id';
  static const String _keyEmail = 'desktop_auth_email';
  static const String _keyDisplayName = 'desktop_auth_display_name';
  static const String _keyEmailVerified = 'desktop_auth_email_verified';
  static const String _keyExpiresAt = 'desktop_auth_expires_at';

  /// Check if we're on desktop
  static bool get isDesktop {
    if (kIsWeb) return false;
    return Platform.isMacOS || Platform.isWindows || Platform.isLinux;
  }

  /// Initialize the service
  Future<void> initialize(SharedPreferences prefs) async {
    _prefs = prefs;
    debugPrint('DesktopAuthService: Initialized');
  }

  /// Sign in with email and password using REST API
  Future<DesktopAuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Success!
        final idToken = data['idToken'] as String;
        final refreshToken = data['refreshToken'] as String;
        final userId = data['localId'] as String;
        final userEmail = data['email'] as String;
        final displayName = data['displayName'] as String? ?? '';
        final emailVerified = data['emailVerified'] as bool? ?? false;
        final expiresIn = int.parse(data['expiresIn'] as String);

        // Save session locally
        await _saveSession(
          idToken: idToken,
          refreshToken: refreshToken,
          userId: userId,
          email: userEmail,
          displayName: displayName,
          emailVerified: emailVerified,
          expiresIn: expiresIn,
        );

        // Now sign into Firebase SDK using the custom token approach
        // This allows using other Firebase services
        try {
          await FirebaseAuth.instance.signInWithCustomToken(idToken);
        } catch (e) {
          // Keychain error expected - but we have the session saved
          debugPrint('DesktopAuthService: Firebase SDK sign-in failed (expected): $e');
        }

        return DesktopAuthResult.success(
          userId: userId,
          email: userEmail,
          displayName: displayName,
          emailVerified: emailVerified,
          idToken: idToken,
        );
      } else {
        // Error
        final errorMessage = _parseFirebaseError(data);
        return DesktopAuthResult.failure(errorMessage);
      }
    } catch (e) {
      debugPrint('DesktopAuthService: Sign in error - $e');
      return DesktopAuthResult.failure('Network error. Please check your connection.');
    }
  }

  /// Sign up with email and password using REST API
  Future<DesktopAuthResult> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final idToken = data['idToken'] as String;
        final refreshToken = data['refreshToken'] as String;
        final userId = data['localId'] as String;
        final userEmail = data['email'] as String;
        final expiresIn = int.parse(data['expiresIn'] as String);

        // Update display name if provided
        if (displayName != null && displayName.isNotEmpty) {
          await _updateProfile(idToken: idToken, displayName: displayName);
        }

        // Send email verification
        await _sendEmailVerification(idToken);

        // Save session
        await _saveSession(
          idToken: idToken,
          refreshToken: refreshToken,
          userId: userId,
          email: userEmail,
          displayName: displayName ?? '',
          emailVerified: false,
          expiresIn: expiresIn,
        );

        return DesktopAuthResult.success(
          userId: userId,
          email: userEmail,
          displayName: displayName ?? '',
          emailVerified: false,
          idToken: idToken,
          needsEmailVerification: true,
        );
      } else {
        final errorMessage = _parseFirebaseError(data);
        return DesktopAuthResult.failure(errorMessage);
      }
    } catch (e) {
      debugPrint('DesktopAuthService: Sign up error - $e');
      return DesktopAuthResult.failure('Network error. Please check your connection.');
    }
  }

  /// Send password reset email
  Future<DesktopAuthResult> sendPasswordResetEmail(String email) async {
    try {
      final response = await http.post(
        Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'requestType': 'PASSWORD_RESET',
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        return DesktopAuthResult.success(
          userId: '',
          email: email,
          displayName: '',
          emailVerified: false,
          idToken: '',
        );
      } else {
        final data = jsonDecode(response.body);
        return DesktopAuthResult.failure(_parseFirebaseError(data));
      }
    } catch (e) {
      return DesktopAuthResult.failure('Network error. Please check your connection.');
    }
  }

  /// Resend email verification
  Future<bool> resendEmailVerification() async {
    final idToken = _prefs?.getString(_keyIdToken);
    if (idToken == null) return false;

    try {
      await _sendEmailVerification(idToken);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Check if user is logged in (has valid session)
  bool get isLoggedIn {
    if (_prefs == null) return false;
    final userId = _prefs!.getString(_keyUserId);
    final expiresAt = _prefs!.getInt(_keyExpiresAt);
    
    if (userId == null || userId.isEmpty) return false;
    if (expiresAt == null) return false;
    
    // Check if token is still valid (with 5 minute buffer)
    final now = DateTime.now().millisecondsSinceEpoch;
    return now < (expiresAt - 300000);
  }

  /// Get current user ID
  String? get currentUserId => _prefs?.getString(_keyUserId);
  
  /// Get current user email
  String? get currentEmail => _prefs?.getString(_keyEmail);
  
  /// Get current user display name
  String? get currentDisplayName => _prefs?.getString(_keyDisplayName);
  
  /// Get current user email verified status
  bool get isEmailVerified => _prefs?.getBool(_keyEmailVerified) ?? false;
  
  /// Get current ID token
  String? get currentIdToken => _prefs?.getString(_keyIdToken);

  /// Check if email has been verified (queries Firebase)
  Future<bool> checkEmailVerified() async {
    if (_prefs == null) return false;
    
    // First, refresh the token to get latest user data
    final idToken = await refreshTokenIfNeeded() ?? _prefs!.getString(_keyIdToken);
    if (idToken == null) return false;

    try {
      // Get user data from Firebase
      final response = await http.post(
        Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final users = data['users'] as List?;
        if (users != null && users.isNotEmpty) {
          final user = users[0];
          final emailVerified = user['emailVerified'] as bool? ?? false;
          
          // Update local storage
          await _prefs!.setBool(_keyEmailVerified, emailVerified);
          
          debugPrint('DesktopAuthService: Email verified status: $emailVerified');
          return emailVerified;
        }
      }
    } catch (e) {
      debugPrint('DesktopAuthService: Error checking email verification - $e');
    }
    
    return _prefs!.getBool(_keyEmailVerified) ?? false;
  }

  /// Sign out
  Future<void> signOut() async {
    await _clearSession();
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      // Ignore errors
    }
  }

  /// Refresh the token if needed
  Future<String?> refreshTokenIfNeeded() async {
    if (_prefs == null) return null;
    
    final refreshToken = _prefs!.getString(_keyRefreshToken);
    if (refreshToken == null) return null;

    try {
      final response = await http.post(
        Uri.parse('https://securetoken.googleapis.com/v1/token?key=$_apiKey'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'grant_type=refresh_token&refresh_token=$refreshToken',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newIdToken = data['id_token'] as String;
        final newRefreshToken = data['refresh_token'] as String;
        final expiresIn = int.parse(data['expires_in'] as String);

        await _prefs!.setString(_keyIdToken, newIdToken);
        await _prefs!.setString(_keyRefreshToken, newRefreshToken);
        await _prefs!.setInt(
          _keyExpiresAt,
          DateTime.now().millisecondsSinceEpoch + (expiresIn * 1000),
        );

        return newIdToken;
      }
    } catch (e) {
      debugPrint('DesktopAuthService: Token refresh failed - $e');
    }
    return null;
  }

  // ============================================
  // PRIVATE METHODS
  // ============================================

  Future<void> _saveSession({
    required String idToken,
    required String refreshToken,
    required String userId,
    required String email,
    required String displayName,
    required bool emailVerified,
    required int expiresIn,
  }) async {
    if (_prefs == null) return;
    
    await _prefs!.setString(_keyIdToken, idToken);
    await _prefs!.setString(_keyRefreshToken, refreshToken);
    await _prefs!.setString(_keyUserId, userId);
    await _prefs!.setString(_keyEmail, email);
    await _prefs!.setString(_keyDisplayName, displayName);
    await _prefs!.setBool(_keyEmailVerified, emailVerified);
    await _prefs!.setInt(
      _keyExpiresAt,
      DateTime.now().millisecondsSinceEpoch + (expiresIn * 1000),
    );
    
    debugPrint('DesktopAuthService: Session saved for $email');
  }

  Future<void> _clearSession() async {
    if (_prefs == null) return;
    
    await _prefs!.remove(_keyIdToken);
    await _prefs!.remove(_keyRefreshToken);
    await _prefs!.remove(_keyUserId);
    await _prefs!.remove(_keyEmail);
    await _prefs!.remove(_keyDisplayName);
    await _prefs!.remove(_keyEmailVerified);
    await _prefs!.remove(_keyExpiresAt);
    
    debugPrint('DesktopAuthService: Session cleared');
  }

  Future<void> _updateProfile({
    required String idToken,
    String? displayName,
  }) async {
    await http.post(
      Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:update?key=$_apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'idToken': idToken,
        if (displayName != null) 'displayName': displayName,
      }),
    );
  }

  Future<void> _sendEmailVerification(String idToken) async {
    await http.post(
      Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=$_apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'requestType': 'VERIFY_EMAIL',
        'idToken': idToken,
      }),
    );
  }

  String _parseFirebaseError(Map<String, dynamic> data) {
    final error = data['error'];
    if (error == null) return 'An unknown error occurred';
    
    final message = error['message'] as String? ?? 'An unknown error occurred';
    
    switch (message) {
      case 'EMAIL_NOT_FOUND':
        return 'No account found with this email.';
      case 'INVALID_PASSWORD':
      case 'INVALID_LOGIN_CREDENTIALS':
        return 'Invalid email or password.';
      case 'USER_DISABLED':
        return 'This account has been disabled.';
      case 'EMAIL_EXISTS':
        return 'This email is already registered.';
      case 'OPERATION_NOT_ALLOWED':
        return 'Email/password sign-in is not enabled.';
      case 'TOO_MANY_ATTEMPTS_TRY_LATER':
        return 'Too many attempts. Please try again later.';
      case 'WEAK_PASSWORD':
        return 'Password is too weak. Use at least 6 characters.';
      default:
        if (message.contains('WEAK_PASSWORD')) {
          return 'Password is too weak. Use at least 6 characters.';
        }
        return message;
    }
  }
}

/// Result of desktop authentication operation
class DesktopAuthResult {
  final bool success;
  final String? userId;
  final String? email;
  final String? displayName;
  final bool emailVerified;
  final String? idToken;
  final String? error;
  final bool needsEmailVerification;

  const DesktopAuthResult({
    required this.success,
    this.userId,
    this.email,
    this.displayName,
    this.emailVerified = false,
    this.idToken,
    this.error,
    this.needsEmailVerification = false,
  });

  factory DesktopAuthResult.success({
    required String userId,
    required String email,
    required String displayName,
    required bool emailVerified,
    required String idToken,
    bool needsEmailVerification = false,
  }) {
    return DesktopAuthResult(
      success: true,
      userId: userId,
      email: email,
      displayName: displayName,
      emailVerified: emailVerified,
      idToken: idToken,
      needsEmailVerification: needsEmailVerification,
    );
  }

  factory DesktopAuthResult.failure(String error) {
    return DesktopAuthResult(
      success: false,
      error: error,
    );
  }
}
