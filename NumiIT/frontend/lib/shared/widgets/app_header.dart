import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/providers/auth_provider.dart';

class AppHeader extends ConsumerWidget implements PreferredSizeWidget {
  const AppHeader({
    super.key,
    required this.title,
    this.actions,
    this.showAvatar = true,
    this.leading,
  });

  final String title;
  final List<Widget>? actions;
  final bool showAvatar;
  final Widget? leading;

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      backgroundColor: isDark ? AppColors.primaryDark : Colors.white,
      elevation: 0,
      leading: leading ??
          (context.canPop()
              ? IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    size: 24,
                  ),
                  onPressed: () {
                    context.pop();
                  },
                )
              : IconButton(
                  icon: Icon(
                    Icons.menu,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    size: 24,
                  ),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                )),
      title: Text(
        title,
        style: AppTypography.display(
          18,
          color: isDark ? Colors.white : AppColors.textPrimary,
          weight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: actions ??
          (showAvatar
              ? [
                  IconButton(
                    icon: CircleAvatar(
                      radius: 15,
                      backgroundColor: auth.isAuthenticated
                          ? AppColors.accent
                          : AppColors.accent.withOpacity(0.2),
                      foregroundColor: auth.isAuthenticated
                          ? AppColors.primaryDark
                          : AppColors.accent,
                      child: auth.isAuthenticated && auth.displayName?.isNotEmpty == true
                          ? Text(
                              auth.displayName![0].toUpperCase(),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                            )
                          : const Icon(Icons.person, size: 16),
                    ),
                    onPressed: () => context.go('/profile'),
                  ),
                  const SizedBox(width: 8),
                ]
              : null),
    );
  }
}
