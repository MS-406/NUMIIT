import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/models/detected_region.dart';
import '../../core/models/scan_result.dart';
import '../../core/providers/history_provider.dart';
import '../../shared/utils/scan_image.dart';
import '../../shared/widgets/confidence_badge.dart';
import '../../shared/widgets/gold_button.dart';
import '../../shared/widgets/ghost_button.dart';
import '../../shared/widgets/app_drawer.dart';
import 'fullscreen_image.dart';
import 'widgets/details_tab.dart';
import 'widgets/translation_tab.dart';
import 'widgets/transliteration_tab.dart';

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({super.key, this.scanResult, this.scanId});

  final ScanResult? scanResult;
  final int? scanId;

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  ScanResult? _scan;
  int _regionIndex = 0;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _scan = widget.scanResult;
    _saved = _scan?.isSaved ?? false;
    if (_scan == null && widget.scanId != null) {
      _loadById(widget.scanId!);
    }
  }

  Future<void> _loadById(int id) async {
    final loaded = await ref.read(scanRepositoryProvider).getScanById(id);
    if (mounted && loaded != null) {
      setState(() {
        _scan = loaded;
        _saved = loaded.isSaved;
      });
    }
  }

  DetectedRegion? get _region {
    final s = _scan;
    if (s == null || s.regions.isEmpty) return null;
    return s.regions[_regionIndex.clamp(0, s.regions.length - 1)];
  }

  Future<void> _save() async {
    final s = _scan;
    if (s == null) return;
    s.isSaved = true;
    final id = await ref.read(historyProvider.notifier).saveScan(s);
    setState(() {
      _saved = true;
      _scan = s.copyWith(id: id, isSaved: true);
    });
    HapticFeedback.lightImpact();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Saved to history')),
      );
    }
  }

  void _copyAll() {
    final region = _region;
    if (region == null) return;
    final text = 'Script: ${region.scriptName}\n'
        'Original: ${region.originalText}\n'
        'Transliteration: ${region.transliteration}\n'
        'Translation: ${region.translation}\n'
        'Dynasty: ${region.dynastyContext}\n'
        'Confidence: ${(region.confidence * 100).round()}%';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied all region details to clipboard')),
    );
  }

  void _showNotesSheet() {
    final controller = TextEditingController(text: _scan?.notes ?? '');
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.primaryMid
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Researcher Notes', style: AppTypography.display(18)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: 'Add notes about this coin...',
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black26
                    : Colors.black.withValues(alpha: 0.02),
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
              onPressed: () async {
                setState(() {
                  _scan = _scan?.copyWith(notes: controller.text);
                });
                if (_scan?.id != null) {
                  await ref.read(historyProvider.notifier).saveScan(_scan!);
                }
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Save Notes', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegionSelector(ScanResult scan) {
    if (scan.regions.length <= 1) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Container(
        height: 36,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(8),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(scan.regions.length, (i) {
              final isSelected = _regionIndex == i;
              return GestureDetector(
                onTap: () => setState(() => _regionIndex = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.accent : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Region ${i + 1}',
                    style: AppTypography.body(
                      11,
                      color: isSelected
                          ? AppColors.primaryDark
                          : (isDark ? Colors.white70 : AppColors.textPrimary),
                      weight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_scan == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final scan = _scan!;
    final region = _region;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final imageHeight = screenHeight < 700 ? 140.0 : 180.0;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        drawer: AppNavigationDrawer(),
        appBar: AppBar(
          title: const Text('Translation Result'),
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.note_add_outlined),
              tooltip: 'Add Notes',
              onPressed: _showNotesSheet,
            ),
            IconButton(
              icon: const Icon(Icons.copy_all_outlined),
              tooltip: 'Copy All Results',
              onPressed: _copyAll,
            ),
            IconButton(
              icon: Icon(
                scan.isStarred ? Icons.star : Icons.star_border,
                color: scan.isStarred ? AppColors.accent : null,
              ),
              onPressed: () async {
                await ref.read(historyProvider.notifier).toggleStar(scan);
                setState(() {
                  _scan = scan.copyWith(isStarred: !scan.isStarred);
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.share_outlined),
              tooltip: 'Share',
              onPressed: () => ref.read(shareServiceProvider).shareResult(scan),
            ),
          ],
        ),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Flexible(
                flex: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => openFullscreenImage(context, scan.imageLocalPath),
                      child: Stack(
                        children: [
                          ScanImage(
                            path: scan.imageLocalPath,
                            height: imageHeight,
                            width: double.infinity,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          Positioned(
                            top: 12,
                            right: 12,
                            child: ConfidenceBadge(confidence: scan.primaryConfidence),
                          ),
                        ],
                      ),
                    ),
                    _buildRegionSelector(scan),
                    TabBar(
                      labelColor: Theme.of(context).colorScheme.onSurface,
                      unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      tabs: const [
                        Tab(text: 'Translation'),
                        Tab(text: 'Transliteration'),
                        Tab(text: 'Details'),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: region == null
                    ? const Center(child: Text('No regions'))
                    : TabBarView(
                        children: [
                          TranslationTab(region: region),
                          TransliterationTab(region: region),
                          DetailsTab(region: region),
                        ],
                      ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.primaryDark : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GoldButton(
                    label: _saved ? 'Saved ✓' : 'Save to History',
                    onTap: _saved ? null : _save,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GhostButton(
                    label: 'Scan Again',
                    light: isDark,
                    onTap: () => context.go('/camera'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
