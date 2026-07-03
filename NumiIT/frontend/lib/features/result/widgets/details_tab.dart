import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/models/scan_result.dart';
import '../../../core/models/era_score.dart';
import '../../detection/widgets/era_confidence_panel.dart';

class DetailsTab extends StatelessWidget {
  const DetailsTab({super.key, required this.scan});

  final ScanResult scan;

  @override
  Widget build(BuildContext context) {
    final rawTransliteration = scan.regions.map((r) => r.transliteration).join('');
    var fullLegend = scan.regions.map((r) => r.transliteration).join('');

    // Auto-format the continuous string into proper words for readability
    fullLegend = fullLegend
        .replaceAll(RegExp(r'rajno', caseSensitive: false), 'Rajno ')
        .replaceAll(RegExp(r'mahaksatrapasa', caseSensitive: false), 'Mahaksatrapasa ')
        .replaceAll(RegExp(r'ksatrapasa', caseSensitive: false), 'Ksatrapasa ')
        .replaceAll(RegExp(r'putrasa', caseSensitive: false), 'putrasa ')
        .replaceAll(RegExp(r'svami', caseSensitive: false), 'Svami ')
        .replaceAll(RegExp(r'rudrasena', caseSensitive: false), 'Rudrasena ')
        .replaceAll(RegExp(r'rudrasimha', caseSensitive: false), 'Rudrasimha ')
        .replaceAll(RegExp(r'rudradaman', caseSensitive: false), 'Rudradaman ')
        .replaceAll(RegExp(r'damajadasri', caseSensitive: false), 'Damajadasri ')
        .replaceAll(RegExp(r'yasodaman', caseSensitive: false), 'Yasodaman ')
        .replaceAll(RegExp(r'vijayasena', caseSensitive: false), 'Vijayasena ')
        .replaceAll(RegExp(r'damasena', caseSensitive: false), 'Damasena ')
        .replaceAll(RegExp(r'bhartrdaman', caseSensitive: false), 'Bhartrdaman ')
        .replaceAll(RegExp(r'visvasena', caseSensitive: false), 'Visvasena ')
        .replaceAll(RegExp(r'nahapana', caseSensitive: false), 'Nahapana ')
        .replaceAll(RegExp(r'bhumaka', caseSensitive: false), 'Bhumaka ')
        .replaceAll(RegExp(r'jivadaman', caseSensitive: false), 'Jivadaman ')
        .replaceAll('  ', ' ')
        .trim();

    // If it couldn't match anything and is still a single giant string, just space-separate characters
    if (!fullLegend.contains(' ') && fullLegend.length > 10) {
      fullLegend = scan.regions.map((r) => r.transliteration).join(' ');
    }

    final detectedCharacters = scan.regions.map((r) => r.fontChar.isNotEmpty ? r.fontChar : r.originalText).where((t) => t.isNotEmpty).join(' ');

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (scan.regions.isNotEmpty) ...[
          Text('Detected Characters', style: AppTypography.display(16, color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 8),
          SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: scan.regions.length,
              itemBuilder: (context, index) {
                final region = scan.regions[index];
                final charText = region.fontChar.isNotEmpty ? region.fontChar : (region.originalText.isNotEmpty ? region.originalText : '?');
                return Container(
                  width: 85,
                  margin: const EdgeInsets.only(right: 12, bottom: 8, top: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: Theme.of(context).brightness == Brightness.dark
                          ? [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.03)]
                          : [Colors.black.withOpacity(0.03), Colors.black.withOpacity(0.01)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.accent.withOpacity(0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        charText,
                        style: AppTypography.script(26,
                            color: AppColors.accent, useCustomFont: region.fontChar.isNotEmpty),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        region.transliteration,
                        style: AppTypography.body(14,
                            color: Theme.of(context).colorScheme.onSurface,
                            weight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${(region.confidence * 100).toStringAsFixed(0)}%',
                        style: AppTypography.body(10,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.5)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
        if (detectedCharacters.isNotEmpty) ...[
          Text('Detected Character Text', style: AppTypography.display(16, color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(detectedCharacters, style: AppTypography.script(26, color: Theme.of(context).colorScheme.onSurface, useCustomFont: true)),
          ),
          const SizedBox(height: 24),
        ],
        if (rawTransliteration.isNotEmpty) ...[
          Text('Transliteration (Raw)', style: AppTypography.display(16, color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(rawTransliteration, style: AppTypography.body(16, color: Theme.of(context).colorScheme.onSurface)),
          ),
          const SizedBox(height: 24),
        ],
        if (fullLegend.isNotEmpty) ...[
          Text('Whole String Sentence (Formatted)', style: AppTypography.display(16, color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(fullLegend, style: AppTypography.body(16, color: Theme.of(context).colorScheme.onSurface)),
          ),
          const SizedBox(height: 32),
        ],

        Builder(
          builder: (context) {
            final primaryScore = scan.eraScores.firstWhere(
              (e) => e.isPrimary,
              orElse: () => scan.eraScores.isNotEmpty
                  ? scan.eraScores.first
                  : const EraScore(era: 'Unknown', className: 'unknown', confidence: 0.0, isPrimary: false),
            );
            
            if (primaryScore.className == 'unknown') {
              return const SizedBox.shrink();
            }
            
            return Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: Theme.of(context).brightness == Brightness.dark
                      ? [const Color(0xFF1E2648), const Color(0xFF151B38)]
                      : [const Color(0xFFF0F4FF), const Color(0xFFE6EDFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.accent.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.history_edu, color: AppColors.accent, size: 24),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Era Analysis: ${primaryScore.era}',
                          style: AppTypography.display(18,
                              color: Theme.of(context).colorScheme.onSurface),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (primaryScore.dynasty != null)
                    Text(
                      primaryScore.dynasty!,
                      style: AppTypography.body(14,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                          weight: FontWeight.bold),
                    ),
                  const Divider(height: 24, thickness: 1),
                  
                  if (primaryScore.transliteration != null) ...[
                    _buildEraDetailRow(
                      context,
                      label: 'Standard Transliteration',
                      value: primaryScore.transliteration!,
                      valueStyle: AppTypography.body(15,
                          color: Theme.of(context).colorScheme.onSurface,
                          weight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                  ],
                  
                  if (primaryScore.translation != null) ...[
                    _buildEraDetailRow(
                      context,
                      label: 'Standard Translation',
                      value: primaryScore.translation!,
                      valueStyle: AppTypography.body(15,
                          color: AppColors.accentAlt,
                          weight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                  ],
                  
                  if (primaryScore.father != null) ...[
                    _buildEraDetailRow(
                      context,
                      label: 'Father / Predecessor',
                      value: primaryScore.father!,
                      valueStyle: AppTypography.body(15,
                          color: Theme.of(context).colorScheme.onSurface),
                    ),
                    const SizedBox(height: 12),
                  ],
                  
                  if (primaryScore.legend != null) ...[
                    Text(
                      'Expected Legend Sentence Template',
                      style: AppTypography.body(12,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6)),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.black38
                            : Colors.black.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.1),
                        ),
                      ),
                      child: Text(
                        primaryScore.legend!,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.9),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  if (primaryScore.rules != null && primaryScore.rules!.isNotEmpty) ...[
                    Text(
                      'Era Identification Rules Applied',
                      style: AppTypography.body(14,
                          color: Theme.of(context).colorScheme.onSurface,
                          weight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...primaryScore.rules!.map((rule) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.check_circle_outline,
                                color: AppColors.successGreen,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  rule,
                                  style: AppTypography.body(13,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.8)),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ],
              ),
            );
          },
        ),
        if (scan.eraScores.isNotEmpty)
          EraConfidencePanel(
            eraScores: scan.eraScores,
            compact: false,
          )
        else
          Center(
            child: Text(
              'No ruler analysis available for this scan.',
              style: AppTypography.body(14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
            ),
          )
      ],
    );
  }

  Widget _buildEraDetailRow(
    BuildContext context, {
    required String label,
    required String value,
    TextStyle? valueStyle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.body(12,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: valueStyle ??
              AppTypography.body(15,
                  color: Theme.of(context).colorScheme.onSurface),
        ),
      ],
    );
  }
}
