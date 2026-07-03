import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/providers/auth_provider.dart';

enum AuthFormMode { login, register, forgotSend, forgotVerify }

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key, this.redirectTo, this.initialTab = 0});

  final String? redirectTo;
  final int initialTab;

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();
  final _forgotSendFormKey = GlobalKey<FormState>();
  final _forgotVerifyFormKey = GlobalKey<FormState>();

  // Form Mode
  AuthFormMode _mode = AuthFormMode.login;

  // Text Controllers
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _registerNameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerConfirmPasswordController = TextEditingController();
  final _forgotEmailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();

  bool _obscureLoginPassword = true;
  bool _obscureRegisterPassword = true;
  bool _obscureRegisterConfirmPassword = true;
  bool _obscureNewPassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 1),
    );
    _mode = widget.initialTab == 1 ? AuthFormMode.register : AuthFormMode.login;
    _tabController.addListener(() {
      setState(() {
        _errorMessage = null;
        if (_tabController.index == 0) {
          _mode = AuthFormMode.login;
        } else {
          _mode = AuthFormMode.register;
        }
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerNameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmPasswordController.dispose();
    _forgotEmailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });
  }

  Future<void> _handleLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final email = _loginEmailController.text;
    final password = _loginPasswordController.text;

    final success = await ref.read(authProvider.notifier).login(email, password);
    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome back, ${ref.read(authProvider).displayName}!'),
          backgroundColor: AppColors.successGreen,
        ),
      );
      if (widget.redirectTo != null) {
        context.go(widget.redirectTo!);
      } else {
        context.go('/home');
      }
    } else {
      _showError('Incorrect password or account not registered.');
    }
  }

  Future<void> _handleRegister() async {
    if (!_registerFormKey.currentState!.validate()) return;

    final name = _registerNameController.text;
    final email = _registerEmailController.text;
    final password = _registerPasswordController.text;
    final confirmPassword = _registerConfirmPasswordController.text;

    if (password != confirmPassword) {
      _showError('Passwords do not match');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await ref.read(authProvider.notifier).register(name, email, password);
    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Account created successfully! Welcome, $name.'),
          backgroundColor: AppColors.successGreen,
        ),
      );
      if (widget.redirectTo != null) {
        context.go(widget.redirectTo!);
      } else {
        context.go('/home');
      }
    } else {
      _showError('Registration failed. Ensure email ends with @gmail.com and password is >= 6 chars.');
    }
  }

  Future<void> _handleSendOtp() async {
    if (!_forgotSendFormKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final email = _forgotEmailController.text.trim();
    final otp = await ref.read(authProvider.notifier).generateAndSendOtp(email);
    
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _mode = AuthFormMode.forgotVerify;
    });

    // Show simulated OTP popup
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.primaryMid,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('[Simulated Email Server]', style: AppTypography.display(16, color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('To: $email', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
            const SizedBox(height: 8),
            Text(
              'Your NumiIT password verification OTP code is:\n',
              style: AppTypography.body(13, color: Colors.white),
            ),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.accent, width: 1.5),
                ),
                child: Text(
                  otp,
                  style: AppTypography.display(24, color: AppColors.accent),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Copy & Close', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleVerifyAndReset() async {
    if (!_forgotVerifyFormKey.currentState!.validate()) return;

    final email = _forgotEmailController.text.trim();
    final otp = _otpController.text.trim();
    final newPassword = _newPasswordController.text;

    final otpValid = ref.read(authProvider.notifier).verifyOtp(otp);
    if (!otpValid) {
      _showError('Invalid OTP code. Please check the simulated email and try again.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await ref.read(authProvider.notifier).resetPassword(email, newPassword);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password updated successfully! Log in with your new password.'),
          backgroundColor: AppColors.successGreen,
        ),
      );
      setState(() {
        _mode = AuthFormMode.login;
        _otpController.clear();
        _newPasswordController.clear();
        _loginEmailController.text = email;
        _loginPasswordController.clear();
      });
    } else {
      _showError('Failed to reset password.');
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final emailController = TextEditingController(text: 'researcher@gmail.com');
    final googleFormKey = GlobalKey<FormState>();

    final gmail = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.primaryMid,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Image.network(
              'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/24px-Google_%22G%22_logo.svg.png',
              height: 24,
              width: 24,
              errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, color: Colors.blue, size: 28),
            ),
            const SizedBox(width: 12),
            Text('Sign in with Google', style: AppTypography.display(18, color: Colors.white)),
          ],
        ),
        content: Form(
          key: googleFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose or enter Gmail account to continue to NumiIT:',
                style: AppTypography.body(13, color: Colors.white70),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Gmail Address',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.black12,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Email is required';
                  if (!val.trim().toLowerCase().endsWith('@gmail.com')) {
                    return 'Must be a valid Gmail account (@gmail.com)';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.primaryDark,
            ),
            onPressed: () {
              if (googleFormKey.currentState!.validate()) {
                Navigator.pop(ctx, emailController.text.trim());
              }
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    if (gmail != null && gmail.isNotEmpty) {
      setState(() => _isLoading = true);
      final success = await ref.read(authProvider.notifier).loginWithGoogle(gmail);
      setState(() => _isLoading = false);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Signed in as $gmail via Google'),
            backgroundColor: AppColors.successGreen,
          ),
        );
        if (widget.redirectTo != null) {
          context.go(widget.redirectTo!);
        } else {
          context.go('/home');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.primaryDark : AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : AppColors.textPrimary),
          onPressed: () {
            if (_mode == AuthFormMode.forgotSend || _mode == AuthFormMode.forgotVerify) {
              setState(() {
                _mode = AuthFormMode.login;
                _tabController.index = 0;
              });
            } else if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: isDark ? AppColors.primaryMid.withValues(alpha: 0.8) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo & Header
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_balance,
                      color: AppColors.accent,
                      size: 36,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'NumiIT Portal',
                    style: AppTypography.display(24, color: isDark ? Colors.white : AppColors.textPrimary),
                  ),
                ),
                Center(
                  child: Text(
                    _mode == AuthFormMode.forgotSend || _mode == AuthFormMode.forgotVerify
                        ? 'Password Recovery'
                        : 'Secure Numismatics Authentication',
                    style: AppTypography.body(12, color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(height: 24),

                // Conditional Tab Bar or Breadcrumb
                if (_mode == AuthFormMode.login || _mode == AuthFormMode.register)
                  TabBar(
                    controller: _tabController,
                    onTap: (_) => setState(() {
                      _errorMessage = null;
                      _mode = _tabController.index == 0
                          ? AuthFormMode.login
                          : AuthFormMode.register;
                    }),
                    indicatorColor: AppColors.accent,
                    labelColor: AppColors.accent,
                    unselectedLabelColor: isDark ? Colors.white54 : AppColors.textSecondary,
                    tabs: const [
                      Tab(text: 'Log In'),
                      Tab(text: 'Create Account'),
                    ],
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock_reset, size: 18, color: AppColors.accent),
                        const SizedBox(width: 8),
                        Text(
                          _mode == AuthFormMode.forgotSend ? 'Enter your Email' : 'Verify simulated OTP',
                          style: AppTypography.body(12, color: AppColors.accent, weight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),

                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: AppTypography.body(12, color: Colors.redAccent),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Conditional Form Bodies
                if (_mode == AuthFormMode.login || _mode == AuthFormMode.register)
                  IndexedStack(
                    index: _tabController.index,
                    children: [
                      _buildLoginForm(),
                      _buildRegisterForm(),
                    ],
                  )
                else
                  _buildFormContent(),

                if (_mode == AuthFormMode.login || _mode == AuthFormMode.register) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Expanded(child: Divider(color: Colors.white10)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('OR', style: AppTypography.body(11, color: AppColors.textSecondary)),
                      ),
                      const Expanded(child: Divider(color: Colors.white10)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Google sign-in button
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(
                        color: isDark ? Colors.white24 : Colors.black12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Image.network(
                      'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/24px-Google_%22G%22_logo.svg.png',
                      height: 20,
                      width: 20,
                      errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, color: Colors.blue),
                    ),
                    label: Text(
                      'Continue with Google',
                      style: AppTypography.body(14, color: isDark ? Colors.white : AppColors.textPrimary, weight: FontWeight.w600),
                    ),
                    onPressed: _isLoading ? null : _handleGoogleSignIn,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent() {
    switch (_mode) {
      case AuthFormMode.forgotSend:
        return _buildForgotSendForm();
      case AuthFormMode.forgotVerify:
        return _buildForgotVerifyForm();
      case AuthFormMode.login:
      case AuthFormMode.register:
        return const SizedBox.shrink();
    }
  }

  Widget _buildLoginForm() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Form(
      key: _loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _loginEmailController,
            style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
            decoration: _inputDecoration('Gmail Address', Icons.email_outlined),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Email is required';
              if (!val.trim().toLowerCase().endsWith('@gmail.com')) {
                return 'Must end with @gmail.com';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _loginPasswordController,
            obscureText: _obscureLoginPassword,
            style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
            decoration: _inputDecoration('Password', Icons.lock_outline).copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureLoginPassword ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.textSecondary,
                ),
                onPressed: () => setState(() => _obscureLoginPassword = !_obscureLoginPassword),
              ),
            ),
            validator: (val) {
              if (val == null || val.isEmpty) return 'Password is required';
              if (val.length < 6) return 'Password must be at least 6 characters';
              return null;
            },
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                setState(() {
                  _mode = AuthFormMode.forgotSend;
                  _errorMessage = null;
                  if (_loginEmailController.text.isNotEmpty) {
                    _forgotEmailController.text = _loginEmailController.text;
                  }
                });
              },
              child: const Text('Forgot Password?', style: TextStyle(color: AppColors.accent)),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.primaryDark,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: _isLoading ? null : _handleLogin,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryDark),
                  )
                : Text('Log In', style: AppTypography.body(15, weight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              context.go('/home');
            },
            child: const Text('Continue as Guest', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Form(
      key: _registerFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _registerNameController,
            style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
            decoration: _inputDecoration('Full Name', Icons.person_outline),
            validator: (val) => (val == null || val.trim().isEmpty) ? 'Name is required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _registerEmailController,
            style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
            decoration: _inputDecoration('Gmail Address', Icons.email_outlined),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Email is required';
              if (!val.trim().toLowerCase().endsWith('@gmail.com')) {
                return 'Must end with @gmail.com';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _registerPasswordController,
            obscureText: _obscureRegisterPassword,
            style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
            decoration: _inputDecoration('Password (min 6 chars)', Icons.lock_outline).copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureRegisterPassword ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.textSecondary,
                ),
                onPressed: () => setState(() => _obscureRegisterPassword = !_obscureRegisterPassword),
              ),
            ),
            validator: (val) {
              if (val == null || val.isEmpty) return 'Password is required';
              if (val.length < 6) return 'Password must be at least 6 characters';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _registerConfirmPasswordController,
            obscureText: _obscureRegisterConfirmPassword,
            style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
            decoration: _inputDecoration('Confirm Password', Icons.lock_outline).copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureRegisterConfirmPassword ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.textSecondary,
                ),
                onPressed: () => setState(() => _obscureRegisterConfirmPassword = !_obscureRegisterConfirmPassword),
              ),
            ),
            validator: (val) {
              if (val == null || val.isEmpty) return 'Please confirm your password';
              if (val != _registerPasswordController.text) return 'Passwords do not match';
              return null;
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.primaryDark,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: _isLoading ? null : _handleRegister,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryDark),
                  )
                : Text('Create Account', style: AppTypography.body(15, weight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildForgotSendForm() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Form(
      key: _forgotSendFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          Text(
            'We will generate and display a password reset verification code (OTP) for your Gmail address.',
            style: AppTypography.body(13, color: isDark ? Colors.white70 : AppColors.textPrimary),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _forgotEmailController,
            style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
            decoration: _inputDecoration('Your Gmail Address', Icons.email_outlined),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Email is required';
              if (!val.trim().toLowerCase().endsWith('@gmail.com')) {
                return 'Must end with @gmail.com';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.primaryDark,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: _isLoading ? null : _handleSendOtp,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryDark),
                  )
                : Text('Send OTP', style: AppTypography.body(15, weight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              setState(() {
                _mode = AuthFormMode.login;
                _errorMessage = null;
              });
            },
            child: const Text('Back to Login', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  Widget _buildForgotVerifyForm() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Form(
      key: _forgotVerifyFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
            decoration: _inputDecoration('6-Digit Verification Code (OTP)', Icons.onetwothree_outlined),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'OTP code is required';
              if (val.trim().length != 6) return 'OTP code must be 6 digits';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _newPasswordController,
            obscureText: _obscureNewPassword,
            style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
            decoration: _inputDecoration('New Password (min 6 chars)', Icons.lock_outline).copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.textSecondary,
                ),
                onPressed: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
              ),
            ),
            validator: (val) {
              if (val == null || val.isEmpty) return 'Password is required';
              if (val.length < 6) return 'Password must be at least 6 characters';
              return null;
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.primaryDark,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: _isLoading ? null : _handleVerifyAndReset,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryDark),
                  )
                : Text('Verify & Reset Password', style: AppTypography.body(15, weight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              setState(() {
                _mode = AuthFormMode.forgotSend;
                _errorMessage = null;
              });
            },
            child: const Text('Resend Verification Code', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData prefixIcon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      prefixIcon: Icon(prefixIcon, color: AppColors.accent, size: 20),
      filled: true,
      fillColor: isDark ? Colors.black12 : Colors.black.withValues(alpha: 0.02),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.05)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }
}
