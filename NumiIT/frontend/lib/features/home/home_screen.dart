import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/models/scan_result.dart';
import '../../core/constants/app_typography.dart';
import '../../core/providers/history_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../shared/utils/date_formatter.dart';
import 'widgets/quick_action_grid.dart';
import 'widgets/recent_scans_list.dart';
import 'widgets/scan_hero_card.dart';
import '../../shared/widgets/web_footer.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  List<ScanResult> _recent = [];
  bool _loadingRecent = true;

  @override
  void initState() {
    super.initState();
    _loadRecent();
  }

  Future<void> _loadRecent() async {
    setState(() => _loadingRecent = true);
    final recent = await ref.read(historyProvider.notifier).getRecent();
    if (mounted) {
      setState(() {
        _recent = recent;
        _loadingRecent = false;
      });
    }
    await ref.read(historyProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final isWide = MediaQuery.sizeOf(context).width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadRecent,
        child: CustomScrollView(
          slivers: [
            if (!isWide)
              SliverAppBar(
                expandedHeight: 100,
                floating: true,
                pinned: false,
                toolbarHeight: 60,
                backgroundColor: isDark ? AppColors.primaryDark : Colors.white,
                foregroundColor: isDark ? Colors.white : AppColors.textPrimary,
                leading: IconButton(
                  icon: Icon(
                    Icons.menu,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auth.isAuthenticated
                            ? 'Hello, ${auth.displayName ?? "Researcher"} 👋'
                            : 'Welcome, Researcher 👋',
                        style: AppTypography.body(16, weight: FontWeight.w600),
                      ),
                      Text(
                        DateFormatter.formatHeaderDate(DateTime.now()),
                        style: AppTypography.body(12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                    icon: CircleAvatar(
                      radius: 20,
                      backgroundColor: auth.isAuthenticated 
                          ? AppColors.accent 
                          : AppColors.accent.withOpacity(0.3),
                      child: Text(
                        auth.isAuthenticated && auth.displayName?.isNotEmpty == true
                            ? auth.displayName![0].toUpperCase()
                            : 'G',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    onPressed: auth.isAuthenticated 
                        ? () => context.go('/profile')
                        : () => context.push('/login', extra: '/home'),
                  ),
                ],
              )
            else
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auth.isAuthenticated
                            ? 'Welcome, ${auth.displayName ?? "Researcher"} 👋'
                            : 'Welcome, Guest Researcher 👋',
                        style: AppTypography.display(28),
                      ),
                      Text(
                        DateFormatter.formatHeaderDate(DateTime.now()),
                        style: AppTypography.body(13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            if (!auth.isAuthenticated)
              SliverToBoxAdapter(
                child: _buildGuestModeBanner(context, isDark),
              ),
            const SliverToBoxAdapter(child: ScanHeroCard()),
            const SliverToBoxAdapter(child: QuickActionGrid()),
            SliverToBoxAdapter(
              child: RecentScansList(
                scans: _recent,
                isLoading: _loadingRecent,
                onSeeAll: () => context.go('/history'),
              ),
            ),
            if (isWide)
              const SliverToBoxAdapter(child: WebFooter())
            else
              const SliverToBoxAdapter(child: SizedBox(height: 72)),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestModeBanner(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: AppColors.accent.withOpacity(0.3),
            width: 2,
          ),
        ),
        color: isDark 
            ? AppColors.primaryMid.withOpacity(0.5)
            : AppColors.accent.withOpacity(0.08),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.lock_outlined,
                    color: AppColors.accent,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Guest Mode Active',
                    style: AppTypography.body(
                      13,
                      color: AppColors.accent,
                      weight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to save your scans, access scan history, and unlock advanced features like statistics and research exports.',
                style: AppTypography.body(12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.primaryDark,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    context.push('/login', extra: '/home');
                  },
                  icon: const Icon(Icons.login, size: 18),
                  label: const Text(
                    'Sign In / Register',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

