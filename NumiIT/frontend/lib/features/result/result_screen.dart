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
import '../../shared/widgets/bounding_box_painter.dart';
import 'fullscreen_image.dart';
import 'widgets/details_tab.dart';
import 'widgets/characters_tab.dart';

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
  bool _imageError = false;

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
    final scan = _scan;
    if (scan == null) return;
    
    final primaryScore = scan.eraScores.isNotEmpty 
        ? scan.eraScores.firstWhere((e) => e.isPrimary, orElse: () => scan.eraScores.first)
        : null;
        
    final text = 'NumiIT Scan Result\n\n'
        'Era/Ruler: ${primaryScore?.era ?? "Unknown"}\n'
        'Dynasty: ${primaryScore?.dynasty ?? "N/A"}\n'
        'Translation: ${primaryScore?.translation ?? "N/A"}\n'
        'Transliteration: ${primaryScore?.transliteration ?? "N/A"}\n'
        'Confidence: ${(scan.primaryConfidence * 100).round()}%\n'
        'Script: ${scan.primaryScript}';
        
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied overall scan details to clipboard')),
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
      length: 2,
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
                      onTap: _imageError ? null : () => openFullscreenImage(context, scan, _regionIndex),
                      child: Container(
                        height: imageHeight,
                        width: double.infinity,
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: isDark ? Colors.black26 : Colors.black12,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CustomPaint(
                              foregroundPainter: _imageError ? null : BoundingBoxPainter(
                                regions: scan.regions,
                                selectedIndex: scan.regions.length > 1 ? _regionIndex : null,
                              ),
                              child: ScanImage(
                                path: scan.imageLocalPath,
                                height: imageHeight,
                                onImageError: () {
                                  if (mounted && !_imageError) {
                                    setState(() {
                                      _imageError = true;
                                    });
                                  }
                                },
                              ),
                            ),
                            Positioned(
                              top: 12,
                              right: 12,
                              child: ConfidenceBadge(confidence: scan.primaryConfidence),
                            ),
                          ],
                        ),
                      ),
                    ),
                    TabBar(
                      labelColor: Theme.of(context).colorScheme.onSurface,
                      unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      tabs: const [
                        Tab(text: 'Characters'),
                        Tab(text: 'Ruler Details'),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    CharactersTab(
                      scan: scan,
                      onRegionSelected: (index) {
                        setState(() {
                          _regionIndex = index;
                        });
                      },
                    ),
                    DetailsTab(scan: scan),
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
