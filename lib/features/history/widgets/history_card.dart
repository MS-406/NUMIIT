import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/models/scan_result.dart';
import '../../../shared/utils/date_formatter.dart';
import '../../../shared/utils/scan_image.dart';
import '../../../shared/widgets/confidence_badge.dart';
import '../../../shared/widgets/script_tag.dart';

class HistoryCard extends StatelessWidget {
  const HistoryCard({
    super.key,
    required this.scan,
    this.onDelete,
    this.selected = false,
    this.onLongPress,
    this.onTap,
  });

  final ScanResult scan;
  final VoidCallback? onDelete;
  final bool selected;
  final VoidCallback? onLongPress;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final region = scan.primaryRegion;
    return Dismissible(
      key: ValueKey(scan.id ?? scan.scannedAt.millisecondsSinceEpoch),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red.shade400,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        onDelete?.call();
        return false;
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        color: selected ? AppColors.accent.withValues(alpha: 0.1) : null,
        child: InkWell(
          onTap: onTap ?? () => context.push('/result', extra: scan),
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ScanImage(
                  path: scan.imageThumbnailPath,
                  width: 64,
                  height: 64,
                  borderRadius: BorderRadius.circular(12),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ScriptTag(script: scan.primaryScript, small: true),
                          if (scan.isStarred) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.star, size: 14, color: AppColors.accent),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        region?.transliteration ?? '—',
                        style: AppTypography.body(15, weight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        region?.translation ?? '',
                        style: AppTypography.body(12, color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        region?.dynastyContext ?? '',
                        style: AppTypography.body(12, color: AppColors.textSecondary)
                            .copyWith(fontStyle: FontStyle.italic),
                      ),
                      Text(
                        DateFormatter.formatScanDate(scan.scannedAt),
                        style: AppTypography.body(11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ConfidenceBadge(confidence: scan.primaryConfidence),
                    const SizedBox(height: 8),
                    const Icon(Icons.chevron_right, color: AppColors.accent, size: 20),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
