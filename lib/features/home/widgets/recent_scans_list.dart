import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/models/scan_result.dart';
import '../../../shared/utils/scan_image.dart';
import '../../../shared/widgets/confidence_badge.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/script_tag.dart';

class RecentScansList extends StatelessWidget {
  const RecentScansList({
    super.key,
    required this.scans,
    required this.isLoading,
    this.onSeeAll,
  });

  final List<ScanResult> scans;
  final bool isLoading;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Scans', style: AppTypography.display(18)),
              TextButton(
                onPressed: onSeeAll,
                child: const Text('See All →'),
              ),
            ],
          ),
        ),
        if (isLoading)
          _shimmerList()
        else if (scans.isEmpty)
          const EmptyState(
            icon: '🪙',
            message: 'No scans yet. Tap Scan Now to start!',
          )
        else
          ...scans.map((s) => _RecentScanCard(scan: s)),
      ],
    );
  }

  Widget _shimmerList() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        children: List.generate(
          3,
          (_) => Container(
            height: 72,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}

class _RecentScanCard extends StatelessWidget {
  const _RecentScanCard({required this.scan});

  final ScanResult scan;

  @override
  Widget build(BuildContext context) {
    final region = scan.primaryRegion;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: InkWell(
        onTap: () => context.push('/result', extra: scan),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ScanImage(
                path: scan.imageThumbnailPath,
                width: 48,
                height: 48,
                borderRadius: BorderRadius.circular(10),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ScriptTag(script: scan.primaryScript, small: true),
                    const SizedBox(height: 4),
                    Text(
                      region?.transliteration ?? '—',
                      style: AppTypography.body(13, weight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      region?.dynastyContext ?? '',
                      style: AppTypography.body(11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              ConfidenceBadge(confidence: scan.primaryConfidence),
            ],
          ),
        ),
      ),
    );
  }
}
