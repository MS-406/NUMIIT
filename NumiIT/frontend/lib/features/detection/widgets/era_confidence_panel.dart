import 'package:flutter/material.dart';
import '../../../core/models/era_score.dart';

/// Animated bar-chart panel showing ALL era confidence scores including
/// negative (0%) ones. This implements the "negative calling" feature:
/// if a non-Rudrasena coin is scanned the primary era shows 0%,
/// and the actual matching era (if any) rises to the top.
class EraConfidencePanel extends StatefulWidget {
  const EraConfidencePanel({
    super.key,
    required this.eraScores,
    this.compact = false,
  });

  final List<EraScore> eraScores;

  /// Compact mode shows fewer rows — used inside result Details tab.
  final bool compact;

  @override
  State<EraConfidencePanel> createState() => _EraConfidencePanelState();
}

class _EraConfidencePanelState extends State<EraConfidencePanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _barAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _buildAnimations();
    _controller.forward();
  }

  void _buildAnimations() {
    final scores = _displayScores;
    _barAnimations = List.generate(scores.length, (i) {
      final start = (i * 0.08).clamp(0.0, 0.6);
      final end = (start + 0.5).clamp(start, 1.0);
      return Tween<double>(
        begin: 0.0,
        end: scores[i].confidence,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Interval(start, end, curve: Curves.easeOut),
      ));
    });
  }

  @override
  void didUpdateWidget(EraConfidencePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.eraScores != widget.eraScores) {
      _buildAnimations();
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<EraScore> get _displayScores {
    final scores = List<EraScore>.from(widget.eraScores);
    if (widget.compact && scores.length > 5) {
      // In compact mode show top 4 + squeeze rest into "Others"
      final top = scores.take(4).toList();
      final othersConf = scores
          .skip(4)
          .fold(0.0, (sum, s) => sum + s.confidence);
      if (othersConf > 0) {
        top.add(EraScore(
          era: 'Others',
          className: 'others',
          confidence: othersConf,
          isPrimary: false,
        ));
      }
      return top;
    }
    return scores;
  }

  @override
  Widget build(BuildContext context) {
    final scores = _displayScores;
    if (scores.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFFD4AF37); // gold
    final negativeColor = isDark
        ? Colors.white.withValues(alpha: 0.18)
        : Colors.black.withValues(alpha: 0.12);
    final lowColor = isDark
        ? const Color(0xFF4A7C8E)
        : const Color(0xFF6AADCC);

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.bar_chart_rounded,
                size: 16,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
              const SizedBox(width: 6),
              Text(
                'Ruler Analysis',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: primaryColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  'NEGATIVE CALLING',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Column(
                children: List.generate(scores.length, (i) {
                  final score = scores[i];
                  final anim = _barAnimations[i];
                  final pct = (score.confidence * 100).toStringAsFixed(1);
                  final isZero = score.confidence == 0.0;
                  final isPrimary = score.isPrimary;

                  Color barColor;
                  if (isPrimary && !isZero) {
                    barColor = primaryColor;
                  } else if (isZero) {
                    barColor = negativeColor;
                  } else if (score.confidence < 0.15) {
                    barColor = lowColor;
                  } else {
                    barColor = lowColor;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (isPrimary && !isZero)
                              Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Icon(Icons.star_rounded,
                                    size: 12, color: primaryColor),
                              ),
                            Expanded(
                              child: Text(
                                score.era,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isPrimary && !isZero
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                  color: isPrimary && !isZero
                                      ? (isDark ? Colors.white : Colors.black87)
                                      : (isDark
                                          ? Colors.white54
                                          : Colors.black45),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 44,
                              child: Text(
                                isZero ? '0%' : '$pct%',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isPrimary && !isZero
                                      ? primaryColor
                                      : (isDark
                                          ? Colors.white38
                                          : Colors.black38),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: SizedBox(
                            height: 7,
                            child: LinearProgressIndicator(
                              value: isZero ? 0.004 : anim.value,
                              backgroundColor: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Colors.black.withValues(alpha: 0.06),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isZero
                                    ? negativeColor
                                    : barColor.withValues(
                                        alpha: isPrimary ? 1.0 : 0.65),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              );
            },
          ),
          if (!widget.compact)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Scores below 10% indicate the model rules out these eras.',
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? Colors.white30 : Colors.black38,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
