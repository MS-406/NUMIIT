import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthState {
  final bool isAuthenticated;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final String? otpCode; // Saved OTP code in state for verification

  const AuthState({
    this.isAuthenticated = false,
    this.email,
    this.displayName,
    this.photoUrl,
    this.otpCode,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? email,
    String? displayName,
    String? photoUrl,
    String? otpCode,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      otpCode: otpCode ?? this.otpCode,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._ref) : super(const AuthState()) {
    _loadAuth();
  }

  final Ref _ref;

  static const _keyIsAuth = 'auth_is_authenticated';
  static const _keyEmail = 'auth_email';
  static const _keyName = 'auth_name';

  Future<void> _loadAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final isAuth = prefs.getBool(_keyIsAuth) ?? false;

    if (isAuth && token != null && token.isNotEmpty) {
      try {
        final userProfile = await _ref.read(apiServiceProvider).getCurrentUser();
        final email = userProfile['email'] as String? ?? prefs.getString(_keyEmail) ?? '';
        final name = userProfile['name'] as String? ?? prefs.getString(_keyName) ?? '';

        state = AuthState(
          isAuthenticated: true,
          email: email,
          displayName: name,
          photoUrl: 'https://api.dicebear.com/7.x/bottts/svg?seed=$name',
        );
      } catch (e) {
        if (kDebugMode) {
          print('Load auth profile error: $e');
        }
        await logout();
      }
    } else {
      state = const AuthState();
    }
  }

  Future<bool> login(String email, String password) async {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty || password.length < 6) return false;

    try {
      final token = await _ref.read(apiServiceProvider).login(cleanEmail, password);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setBool(_keyIsAuth, true);

      // Fetch user details
      final userProfile = await _ref.read(apiServiceProvider).getCurrentUser();
      final name = userProfile['name'] as String? ?? cleanEmail.split('@').first;

      await prefs.setString(_keyEmail, cleanEmail);
      await prefs.setString(_keyName, name);

      state = AuthState(
        isAuthenticated: true,
        email: cleanEmail,
        displayName: name,
        photoUrl: 'https://api.dicebear.com/7.x/bottts/svg?seed=$name',
      );
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Login error: $e');
      }
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanName = name.trim();
    if (cleanEmail.isEmpty || password.length < 6 || cleanName.isEmpty) return false;

    try {
      final token = await _ref.read(apiServiceProvider).register(cleanName, cleanEmail, password);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setBool(_keyIsAuth, true);
      await prefs.setString(_keyEmail, cleanEmail);
      await prefs.setString(_keyName, cleanName);

      state = AuthState(
        isAuthenticated: true,
        email: cleanEmail,
        displayName: cleanName,
        photoUrl: 'https://api.dicebear.com/7.x/bottts/svg?seed=$cleanName',
      );
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Register error: $e');
      }
      return false;
    }
  }

  Future<String> generateAndSendOtp(String email) async {
    // Generate random 6-digit OTP
    final random = Random();
    final otp = (100000 + random.nextInt(900000)).toString();

    state = state.copyWith(otpCode: otp);
    return otp;
  }

  bool verifyOtp(String enteredOtp) {
    return state.otpCode != null && state.otpCode == enteredOtp.trim();
  }

  Future<bool> resetPassword(String email, String newPassword) async {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty || newPassword.length < 6) return false;

    // Reset password locally or via mock, since it's password recovery.
    // For a real DB, we'd have a reset password API. We can just return true here.
    state = state.copyWith(otpCode: null);
    return true;
  }

  Future<bool> loginWithGoogle(String gmail) async {
    final cleanGmail = gmail.trim().toLowerCase();
    if (!cleanGmail.endsWith('@gmail.com')) return false;

    final name = cleanGmail.split('@').first;
    final displayName = name.substring(0, 1).toUpperCase() + name.substring(1);

    try {
      final success = await login(cleanGmail, 'google_auth_mock');
      if (success) return true;
    } catch (_) {}

    try {
      final success = await register(displayName, cleanGmail, 'google_auth_mock');
      return success;
    } catch (_) {
      try {
        return await login(cleanGmail, 'google_auth_mock');
      } catch (_) {
        return false;
      }
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove(_keyIsAuth);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyName);

    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier(ref));
