import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/constants/app_colors.dart';
import 'core/constants/app_typography.dart';
import 'core/models/scan_result.dart';
import 'core/providers/settings_provider.dart';
import 'features/camera/camera_screen.dart';
import 'features/detection/detection_screen.dart';
import 'features/encyclopedia/encyclopedia_screen.dart';
import 'features/history/history_screen.dart';
import 'features/home/home_screen.dart';
import 'features/result/result_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/splash/splash_screen.dart';
import 'features/statistics/statistics_screen.dart';
import 'features/auth/auth_screen.dart';
import 'features/profile/profile_screen.dart';
import 'shared/widgets/app_layout_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
      GoRoute(
        path: '/login',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) {
          final extra = state.extra;
          if (extra is Map<String, dynamic>) {
            return AuthScreen(
              redirectTo: extra['redirect'] as String?,
              initialTab: extra['tab'] as int? ?? 0,
            );
          }
          return AuthScreen(redirectTo: extra as String?);
        },
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return AppLayoutShell(child: child, uri: state.uri.toString());
        },
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/camera', builder: (_, __) => const CameraScreen()),
          GoRoute(
            path: '/detection',
            builder: (_, state) {
              final extra = state.extra;
              if (extra is List<String>) {
                return DetectionScreen(imagePaths: extra);
              }
              return DetectionScreen(imagePath: extra as String? ?? '');
            },
          ),
          GoRoute(
            path: '/result',
            builder: (_, state) {
              final extra = state.extra;
              if (extra is ScanResult) {
                return ResultScreen(scanResult: extra);
              }
              return const ResultScreen();
            },
          ),
          GoRoute(
            path: '/result/:id',
            builder: (_, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '');
              return ResultScreen(scanId: id);
            },
          ),
          GoRoute(path: '/history', builder: (_, __) => const HistoryScreen()),
          GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
          GoRoute(
            path: '/encyclopedia',
            builder: (_, __) => const EncyclopediaScreen(),
          ),
          GoRoute(
            path: '/statistics',
            builder: (_, __) => const StatisticsScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (_, __) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
});

class NumiITApp extends ConsumerWidget {
  const NumiITApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final router = ref.watch(routerProvider);

    ThemeMode themeMode;
    switch (settings.themeMode) {
      case AppThemeMode.light:
        themeMode = ThemeMode.light;
      case AppThemeMode.dark:
        themeMode = ThemeMode.dark;
      case AppThemeMode.system:
        themeMode = ThemeMode.system;
    }

    return MaterialApp.router(
      title: 'NumiIT',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      locale: settings.locale,
      supportedLocales: const [
        Locale('en'),
        Locale('hi'),
        Locale('gu'),
      ],
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      routerConfig: router,
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.surface,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.accent,
        primary: AppColors.primaryDark,
        surface: AppColors.surface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        titleTextStyle: AppTypography.display(20),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceCard,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.primaryDark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.accent,
        surface: AppColors.primaryMid,
        onSurface: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: AppTypography.display(20, color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: AppColors.primaryMid,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
