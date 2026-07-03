import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/models/scan_result.dart';
import '../../../core/models/detected_region.dart';
import 'confidence_bar.dart';

class CharactersTab extends StatefulWidget {
  const CharactersTab({super.key, required this.scan, required this.onRegionSelected});

  final ScanResult scan;
  final ValueChanged<int> onRegionSelected;

  @override
  State<CharactersTab> createState() => _CharactersTabState();
}

class _CharactersTabState extends State<CharactersTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.scan.regions.length, vsync: this);
    _tabController.addListener(() {
      widget.onRegionSelected(_tabController.index);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scan = widget.scan;
    if (scan.regions.isEmpty) {
      return const Center(child: Text('No regions detected.'));
    }

    return Column(
        children: [
          Container(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.black12 
                : Colors.black.withOpacity(0.02),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: AppColors.accent,
              labelColor: AppColors.accent,
              unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              tabs: List.generate(
                scan.regions.length,
                (i) => Tab(text: 'Region ${i + 1}'),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: scan.regions.map((region) {
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (region.confidence < 0.6)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppColors.confMedBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: Theme.of(context).colorScheme.onPrimary, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Results may be inaccurate',
                                style: AppTypography.body(13, color: Theme.of(context).colorScheme.onPrimary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    _field(context, 'Detected Script', region.scriptName),
                    _field(context, 'Original Inscription', region.fontChar.isNotEmpty ? region.fontChar : region.originalText,
                        isScript: true, useCustomFont: region.fontChar.isNotEmpty),
                    _field(context, 'Transliteration', region.transliteration),
                    _field(context, 'English Translation', region.translation),
                    _field(context, 'Dynasty Context', region.dynastyContext),
                    _field(
                      context,
                      'Confidence',
                      '${(region.confidence * 100).round()}%',
                      trailing: ConfidenceBar(confidence: region.confidence),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      );
  }

  Widget _field(
    BuildContext context,
    String label,
    String value, {
    bool isScript = false,
    bool useCustomFont = false,
    Widget? trailing,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white10
              : Colors.black.withOpacity(0.05),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onLongPress: () {
          Clipboard.setData(ClipboardData(text: value));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Copied $label')),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.body(11, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), weight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              if (trailing != null) trailing else
                Text(
                  value,
                  style: isScript
                      ? AppTypography.script(22, useCustomFont: useCustomFont)
                      : AppTypography.body(15, weight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
