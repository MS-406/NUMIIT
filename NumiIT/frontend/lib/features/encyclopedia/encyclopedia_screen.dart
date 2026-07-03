import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/data/encyclopedia_data.dart';
import '../../core/models/coin_inscription.dart';
import '../../shared/widgets/web_footer.dart';

class EncyclopediaScreen extends StatelessWidget {
  const EncyclopediaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 720;

          if (isWide) {
            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _buildCard(context, kEncyclopediaEntries[i], isWide: true),
                      childCount: kEncyclopediaEntries.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: WebFooter(),
                ),
              ],
            );
          } else {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: kEncyclopediaEntries.length,
              itemBuilder: (context, i) => _buildCard(context, kEncyclopediaEntries[i], isWide: false),
            );
          }
        },
      ),
    );
  }

  Widget _buildCard(BuildContext context, CoinInscription e, {required bool isWide}) {
    final color = AppColors.scriptColor(e.scriptName);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardContent = Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 36,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.scriptName,
                      style: AppTypography.display(18, weight: FontWeight.w700),
                    ),
                    Text(
                      e.nativeName,
                      style: AppTypography.body(12, color: AppColors.textSecondary, weight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 12, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  e.historicalPeriod,
                  style: AppTypography.body(11, color: AppColors.textSecondary, weight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: Colors.white10),
          Text(
            'Sample Inscription:',
            style: AppTypography.body(10, color: color, weight: FontWeight.w700).copyWith(letterSpacing: 0.5),
          ),
          const SizedBox(height: 6),
          Text(
            e.sampleText,
            style: AppTypography.script(26, color: isDark ? Colors.white : AppColors.primaryDark),
          ),
          const SizedBox(height: 6),
          Text(
            '“${e.sampleTranslation}”',
            style: AppTypography.body(13, color: isDark ? Colors.white70 : AppColors.textPrimary, weight: FontWeight.w500).copyWith(fontStyle: FontStyle.italic),
          ),
          if (isWide) const Spacer() else const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Unicode: ${e.unicodeBlock}',
              style: AppTypography.body(9, color: AppColors.textSecondary, weight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    return Card(
      margin: isWide ? EdgeInsets.zero : const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: isWide ? SizedBox(height: 320, child: cardContent) : cardContent,
    );
  }
}
