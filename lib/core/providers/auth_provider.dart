import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  AuthNotifier() : super(const AuthState()) {
    _loadAuth();
  }

  static const _keyIsAuth = 'auth_is_authenticated';
  static const _keyEmail = 'auth_email';
  static const _keyName = 'auth_name';

  Future<void> _loadAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final isAuth = prefs.getBool(_keyIsAuth) ?? false;
    if (isAuth) {
      final email = prefs.getString(_keyEmail);
      final name = prefs.getString(_keyName);
      state = AuthState(
        isAuthenticated: true,
        email: email,
        displayName: name,
        photoUrl: 'https://api.dicebear.com/7.x/bottts/svg?seed=${name ?? "User"}',
      );
    }
  }

  Future<bool> login(String email, String password) async {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty || password.length < 6) return false;

    final prefs = await SharedPreferences.getInstance();
    
    // Auto-register mock researcher credentials if first run
    if (cleanEmail == 'researcher@gmail.com' && prefs.getString('auth_pwd_$cleanEmail') == null) {
      await prefs.setString('auth_pwd_$cleanEmail', '123456');
      await prefs.setString('auth_name_$cleanEmail', 'Researcher');
    }

    final savedPwd = prefs.getString('auth_pwd_$cleanEmail');
    if (savedPwd == password) {
      final name = prefs.getString('auth_name_$cleanEmail') ?? cleanEmail.split('@').first;
      final displayName = name.substring(0, 1).toUpperCase() + name.substring(1);

      await prefs.setBool(_keyIsAuth, true);
      await prefs.setString(_keyEmail, cleanEmail);
      await prefs.setString(_keyName, displayName);

      state = AuthState(
        isAuthenticated: true,
        email: cleanEmail,
        displayName: displayName,
        photoUrl: 'https://api.dicebear.com/7.x/bottts/svg?seed=$displayName',
      );
      return true;
    }
    return false;
  }

  Future<bool> register(String name, String email, String password) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanName = name.trim();
    if (cleanEmail.isEmpty || password.length < 6 || cleanName.isEmpty) return false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_pwd_$cleanEmail', password);
    await prefs.setString('auth_name_$cleanEmail', cleanName);

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

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_pwd_$cleanEmail', newPassword);

    state = state.copyWith(otpCode: null);
    return true;
  }

  Future<bool> loginWithGoogle(String gmail) async {
    final cleanGmail = gmail.trim().toLowerCase();
    if (!cleanGmail.endsWith('@gmail.com')) return false;

    final name = cleanGmail.split('@').first;
    final displayName = name.substring(0, 1).toUpperCase() + name.substring(1);

    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('auth_pwd_$cleanGmail') == null) {
      await prefs.setString('auth_pwd_$cleanGmail', 'google_auth_mock');
      await prefs.setString('auth_name_$cleanGmail', displayName);
    }

    await prefs.setBool(_keyIsAuth, true);
    await prefs.setString(_keyEmail, cleanGmail);
    await prefs.setString(_keyName, displayName);

    state = AuthState(
      isAuthenticated: true,
      email: cleanGmail,
      displayName: displayName,
      photoUrl: 'https://api.dicebear.com/7.x/bottts/svg?seed=$displayName',
    );
    return true;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsAuth);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyName);

    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier());
