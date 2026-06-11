import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/providers/history_provider.dart';
import '../../shared/widgets/web_footer.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  String _dayName(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      case DateTime.sunday:
        return 'Sun';
      default:
        return '';
    }
  }

  Widget _buildPieLegend(Map<String, int> scriptCounts) {
    final total = scriptCounts.values.fold<int>(0, (sum, count) => sum + count);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: scriptCounts.entries.map((e) {
        final color = AppColors.scriptColor(e.key);
        final pct = total > 0 ? (e.value / total * 100).round() : 0;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                e.key,
                style: AppTypography.body(13, weight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              Text(
                '${e.value} ($pct%)',
                style: AppTypography.body(12, color: AppColors.textSecondary),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);
    final scans = history.scans;
    final isWide = MediaQuery.sizeOf(context).width > 600;

    // Show loading indicator while fetching data
    if (history.isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Loading statistics...',
                style: AppTypography.body(14, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    // Show error message if there's an error
    if (history.error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.warningOrange),
              const SizedBox(height: 16),
              Text(
                'Error loading statistics',
                style: AppTypography.body(16, color: AppColors.textPrimary, weight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                history.error ?? 'Unknown error',
                style: AppTypography.body(13, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final scriptCounts = <String, int>{};
    for (final s in scans) {
      scriptCounts[s.primaryScript] = (scriptCounts[s.primaryScript] ?? 0) + 1;
    }

    final weekly = List<int>.filled(7, 0);
    final now = DateTime.now();
    for (final s in scans) {
      final diff = now.difference(s.scannedAt).inDays;
      if (diff >= 0 && diff < 7) weekly[6 - diff]++;
    }

    final scripts = scans.map((s) => s.primaryScript).toList();
    final topScript = scripts.isEmpty
        ? '—'
        : scripts.fold<Map<String, int>>({}, (m, s) {
            m[s] = (m[s] ?? 0) + 1;
            return m;
          }).entries.reduce((a, b) => a.value >= b.value ? a : b).key;
    final avgConf = scans.isEmpty
        ? 0.0
        : scans.map((s) => s.primaryConfidence).reduce((a, b) => a + b) /
            scans.length;

    final totalScansCount = scriptCounts.values.fold<int>(0, (sum, count) => sum + count);

    Widget bodyContent;
    if (scans.isEmpty) {
      bodyContent = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bar_chart, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              'No scan data yet',
              style: AppTypography.body(16, color: AppColors.textSecondary, weight: FontWeight.w600),
            ),
          ],
        ),
      );
    } else if (isWide) {
      // Wide layout (Web / Desktop side-by-side grid)
      bodyContent = ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Row(
            children: [
              Expanded(
                child: _metricCard(
                  context: context,
                  title: 'Total Scans',
                  value: '${scans.length}',
                  icon: Icons.history,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _metricCard(
                  context: context,
                  title: 'Average Confidence',
                  value: '${(avgConf * 100).round()}%',
                  icon: Icons.insights,
                  color: AppColors.successGreen,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _metricCard(
                  context: context,
                  title: 'Top Script',
                  value: topScript,
                  icon: Icons.translate,
                  color: Colors.blueAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SizedBox(
                  height: 380,
                  child: _chartContainer(
                    context: context,
                    title: 'Scripts Breakdown',
                    expandChild: true,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Center(
                            child: PieChart(
                              PieChartData(
                                sections: scriptCounts.entries.map((e) {
                                  final color = AppColors.scriptColor(e.key);
                                  final pct = totalScansCount > 0 ? (e.value / totalScansCount * 100).round() : 0;
                                  return PieChartSectionData(
                                    value: e.value.toDouble(),
                                    title: pct > 8 ? '$pct%' : '',
                                    color: color,
                                    radius: 50,
                                    showTitle: true,
                                    titleStyle: AppTypography.body(10, color: Colors.white, weight: FontWeight.bold),
                                  );
                                }).toList(),
                                sectionsSpace: 3,
                                centerSpaceRadius: 50,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 2,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: SingleChildScrollView(
                              child: _buildPieLegend(scriptCounts),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 380,
                  child: _chartContainer(
                    context: context,
                    title: 'Scans this Week',
                    expandChild: true,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: (weekly.reduce((a, b) => a > b ? a : b) + 1).toDouble(),
                        barGroups: List.generate(7, (i) {
                          return BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: weekly[i].toDouble(),
                                color: AppColors.accent,
                                width: 18,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                              ),
                            ],
                          );
                        }),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (v, _) {
                                final idx = v.toInt();
                                if (idx < 0 || idx > 6) return const SizedBox.shrink();
                                final date = DateTime.now().subtract(Duration(days: 6 - idx));
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(_dayName(date), style: AppTypography.body(11, color: AppColors.textSecondary)),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 32,
                              getTitlesWidget: (v, _) {
                                return Text(
                                  v.toInt().toString(),
                                  style: AppTypography.body(11, color: AppColors.textSecondary),
                                );
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(),
                          rightTitles: const AxisTitles(),
                        ),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
          const WebFooter(),
        ],
      );
    } else {
      // Mobile Layout (Vertical stack)
      bodyContent = ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 80),
        children: [
          _metricCard(
            context: context,
            title: 'Total Scans',
            value: '${scans.length}',
            icon: Icons.history,
            color: AppColors.accent,
          ),
          const SizedBox(height: 12),
          _metricCard(
            context: context,
            title: 'Average Confidence',
            value: '${(avgConf * 100).round()}%',
            icon: Icons.insights,
            color: AppColors.successGreen,
          ),
          const SizedBox(height: 12),
          _metricCard(
            context: context,
            title: 'Top Script',
            value: topScript,
            icon: Icons.translate,
            color: Colors.blueAccent,
          ),
          const SizedBox(height: 24),
          _chartContainer(
            context: context,
            title: 'Scripts Breakdown',
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 160,
                  child: PieChart(
                    PieChartData(
                      sections: scriptCounts.entries.map((e) {
                        final color = AppColors.scriptColor(e.key);
                        final pct = totalScansCount > 0 ? (e.value / totalScansCount * 100).round() : 0;
                        return PieChartSectionData(
                          value: e.value.toDouble(),
                          title: pct > 10 ? '$pct%' : '',
                          color: color,
                          radius: 40,
                          showTitle: true,
                          titleStyle: AppTypography.body(9, color: Colors.white, weight: FontWeight.bold),
                        );
                      }).toList(),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildPieLegend(scriptCounts),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 260,
            child: _chartContainer(
              context: context,
              title: 'Scans this Week',
              expandChild: true,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (weekly.reduce((a, b) => a > b ? a : b) + 1).toDouble(),
                  barGroups: List.generate(7, (i) {
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: weekly[i].toDouble(),
                          color: AppColors.accent,
                          width: 16,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ],
                    );
                  }),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, _) {
                          final idx = v.toInt();
                          if (idx < 0 || idx > 6) return const SizedBox.shrink();
                          final date = DateTime.now().subtract(Duration(days: 6 - idx));
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(_dayName(date), style: AppTypography.body(11, color: AppColors.textSecondary)),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (v, _) {
                          return Text(
                            v.toInt().toString(),
                            style: AppTypography.body(11, color: AppColors.textSecondary),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      body: bodyContent,
    );
  }

  Widget _metricCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
        ),
      ),
      color: isDark ? AppColors.primaryMid.withOpacity(0.4) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: AppTypography.body(12, color: AppColors.textSecondary, weight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: AppTypography.display(20, color: isDark ? Colors.white : AppColors.textPrimary, weight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chartContainer({
    required BuildContext context,
    required String title,
    required Widget child,
    bool expandChild = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
        ),
      ),
      color: isDark ? AppColors.primaryMid.withOpacity(0.4) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTypography.display(16, color: isDark ? Colors.white : AppColors.textPrimary, weight: FontWeight.bold),
            ),
            const Divider(height: 20, color: Colors.white10),
            expandChild ? Expanded(child: child) : child,
          ],
        ),
      ),
    );
  }
}
