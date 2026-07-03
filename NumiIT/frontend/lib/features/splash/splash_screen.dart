import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/providers/settings_provider.dart';
import '../../shared/widgets/ghost_button.dart';
import '../../shared/widgets/gold_button.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = ref.read(settingsProvider);
      if (!settings.onboardingDone) {
        _showOnboarding();
      }
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void _showOnboarding() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _OnboardingSheet(
        onDone: () {
          ref.read(settingsProvider.notifier).completeOnboarding();
          Navigator.pop(ctx);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final locale = settings.locale.languageCode;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryDark, AppColors.primaryMid],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              RotationTransition(
                turns: Tween<double>(begin: 0, end: 1).animate(
                  CurvedAnimation(
                    parent: _rotationController,
                    curve: Curves.easeOut,
                  ),
                ),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: AppColors.accent,
                      width: 2,
                      strokeAlign: BorderSide.strokeAlignInside,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'N',
                      style: AppTypography.display(52, color: AppColors.accent),
                    ),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 300.ms)
                  .scale(begin: const Offset(0.8, 0.8)),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'NumiIT',
                style: AppTypography.display(38, color: Colors.white).copyWith(
                  letterSpacing: -1,
                ),
              ).animate().fadeIn(delay: 600.ms),
              const SizedBox(height: AppSpacing.md),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  "Decoding India's Numismatic Heritage\n"
                  'AI-powered coin inscription recognition',
                  textAlign: TextAlign.center,
                  style: AppTypography.body(
                    14,
                    color: Colors.white60,
                  ).copyWith(height: 1.6),
                ),
              ).animate().fadeIn(delay: 900.ms),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: GoldButton(
                  label: 'Scan a Coin',
                  icon: Icons.camera_alt,
                  onTap: () => context.push('/camera'),
                ),
              ).animate().fadeIn(delay: 1200.ms),
              const SizedBox(height: AppSpacing.md),
              GhostButton(
                label: 'Browse History',
                onTap: () => context.go('/history'),
              ).animate().fadeIn(delay: 1200.ms),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _langChip('English', 'en', locale),
                  Text(' · ', style: TextStyle(color: Colors.white38)),
                  _langChip('हिन्दी', 'hi', locale),
                  Text(' · ', style: TextStyle(color: Colors.white38)),
                  _langChip('ગુજરાતી', 'gu', locale),
                ],
              ),
              const Spacer(flex: 1),
              Text(
                'v1.0.0 · NumiIT',
                style: AppTypography.body(11, color: Colors.white30),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  Widget _langChip(String label, String code, String current) {
    final active = code == current;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        if (code == 'hi' || code == 'gu') {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Language Unavailable'),
              content: const Text('Only available in English now, may be available in later updates with other languages.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else {
          ref.read(settingsProvider.notifier).setLocale(Locale(code));
        }
      },
      child: Text(
        label,
        style: AppTypography.body(
          13,
          color: active ? AppColors.accent : Colors.white54,
          weight: active ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

class _OnboardingSheet extends StatefulWidget {
  const _OnboardingSheet({required this.onDone});

  final VoidCallback onDone;

  @override
  State<_OnboardingSheet> createState() => _OnboardingSheetState();
}

class _OnboardingSheetState extends State<_OnboardingSheet> {
  final _pageController = PageController();
  int _page = 0;

  static const _steps = [
    ('Scan', Icons.camera_alt, 'Capture coin inscriptions with your camera'),
    ('Detect', Icons.crop_free, 'AI finds script regions on the coin'),
    ('Translate', Icons.translate, 'Get transliteration and English translation'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 160,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _page = i),
              itemCount: 3,
              itemBuilder: (_, i) {
                final step = _steps[i];
                return Column(
                  children: [
                    Icon(step.$2, size: 48, color: AppColors.accent),
                    const SizedBox(height: 12),
                    Text(step.$1, style: AppTypography.display(22)),
                    const SizedBox(height: 8),
                    Text(
                      step.$3,
                      textAlign: TextAlign.center,
                      style: AppTypography.body(13, color: AppColors.textSecondary),
                    ),
                  ],
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
              (i) => Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i == _page ? AppColors.accent : Colors.grey.shade300,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          GoldButton(
            label: _page < 2 ? 'Next' : 'Got It',
            onTap: () {
              if (_page < 2) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              } else {
                widget.onDone();
              }
            },
          ),
        ],
      ),
    );
  }
}
