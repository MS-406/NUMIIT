import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/database/scan_repository.dart';
import '../../core/models/scan_result.dart';
import '../../core/providers/history_provider.dart';
import '../../shared/utils/date_formatter.dart';
import '../../shared/widgets/empty_state.dart';
import 'widgets/history_card.dart';
import 'widgets/script_filter_chips.dart';
import 'widgets/search_bar.dart' as history_search;
import '../../core/providers/auth_provider.dart';
import '../../shared/widgets/web_footer.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  bool _multiSelect = false;
  final Set<int> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(historyProvider.notifier).refresh());
  }

  Map<String, List<ScanResult>> _grouped(List<ScanResult> scans) {
    final map = <String, List<ScanResult>>{};
    for (final s in scans) {
      final key = DateFormatter.groupLabel(s.scannedAt);
      map.putIfAbsent(key, () => []).add(s);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(historyProvider);
    final isWide = MediaQuery.sizeOf(context).width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.read(historyProvider.notifier).refresh(),
        child: CustomScrollView(
          slivers: [
            if (!isWide)
              SliverAppBar(
                pinned: true,
                toolbarHeight: 60,
                backgroundColor: isDark ? AppColors.primaryDark : Colors.white,
                foregroundColor: isDark ? Colors.white : AppColors.textPrimary,
                leading: IconButton(
                  icon: Icon(
                    Icons.menu,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
                title: Text(
                  'Scan History',
                  style: AppTypography.display(
                    18,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    weight: FontWeight.bold,
                  ),
                ),
                centerTitle: true,
                actions: [
                  if (_multiSelect)
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        for (final id in _selectedIds) {
                          await ref.read(historyProvider.notifier).deleteScan(id);
                        }
                        setState(() {
                          _multiSelect = false;
                          _selectedIds.clear();
                        });
                      },
                    )
                  else ...[
                    IconButton(
                      icon: CircleAvatar(
                        radius: 14,
                        backgroundColor: ref.watch(authProvider).isAuthenticated
                            ? AppColors.accent
                            : AppColors.accent.withOpacity(0.3),
                        foregroundColor: ref.watch(authProvider).isAuthenticated
                            ? AppColors.primaryDark
                            : AppColors.accent,
                        child: ref.watch(authProvider).isAuthenticated
                            ? Text(
                                ref.watch(authProvider).displayName?.isNotEmpty == true
                                    ? ref.watch(authProvider).displayName![0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                              )
                            : const Icon(Icons.person, size: 14),
                      ),
                      onPressed: () => context.go('/profile'),
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(52),
                  child: history_search.HistorySearchBar(
                    onSearch: (q) =>
                        ref.read(historyProvider.notifier).setSearch(q),
                  ),
                ),
              )
            else
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Scan History', style: AppTypography.display(28)),
                          const SizedBox(width: 12),
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: AppColors.accent,
                            child: Text(
                              '${history.totalScans}',
                              style: AppTypography.body(12,
                                  color: AppColors.primaryDark,
                                  weight: FontWeight.bold),
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                      const SizedBox(height: 16),
                      history_search.HistorySearchBar(
                        onSearch: (q) =>
                            ref.read(historyProvider.notifier).setSearch(q),
                      ),
                    ],
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: ScriptFilterChips(
                selected: history.selectedScripts,
                onChanged: (s) =>
                    ref.read(historyProvider.notifier).setScripts(s),
              ),
            ),
            SliverToBoxAdapter(child: _sortRow(history)),
            SliverToBoxAdapter(child: _statsSummary(history)),
            if (history.isLoading)
              SliverToBoxAdapter(child: _shimmer())
            else if (history.scans.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: '🪙',
                  message: 'No Coins Stored',
                  subtitle: 'Start scanning ancient coins to build your personal numismatic research archives.',
                  actionLabel: 'Scan First Coin',
                  onAction: () => context.go('/camera'),
                ),
              )
            else
              ..._buildGroupedSlivers(history.scans),
            if (isWide)
              const SliverToBoxAdapter(child: WebFooter())
            else
              const SliverToBoxAdapter(child: SizedBox(height: 72)),
          ],
        ),
      ),
    );
  }

  Widget _sortRow(HistoryState history) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: DropdownButton<HistorySort>(
              isExpanded: true,
              value: history.sort,
              items: const [
                DropdownMenuItem(value: HistorySort.newest, child: Text('Newest')),
                DropdownMenuItem(value: HistorySort.oldest, child: Text('Oldest')),
                DropdownMenuItem(
                  value: HistorySort.highestConfidence,
                  child: Text('Highest Confidence'),
                ),
                DropdownMenuItem(value: HistorySort.scriptAz, child: Text('Script A-Z')),
              ],
              onChanged: (v) {
                if (v != null) ref.read(historyProvider.notifier).setSort(v);
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: DropdownButton<double?>(
              isExpanded: true,
              value: history.minConfidenceFilter,
              hint: const Text('Confidence'),
              items: const [
                DropdownMenuItem(child: Text('All'), value: null),
                DropdownMenuItem(child: Text('High (>80%)'), value: 0.8),
                DropdownMenuItem(child: Text('Medium (60-80%)'), value: 0.6),
              ],
              onChanged: (v) =>
                  ref.read(historyProvider.notifier).setConfidenceFilter(v),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statsSummary(HistoryState history) {
    if (history.scans.isEmpty) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scripts = history.scans.map((s) => s.primaryScript).toList();
    final topScript = scripts.isEmpty
        ? '—'
        : scripts.fold<Map<String, int>>({}, (m, s) {
            m[s] = (m[s] ?? 0) + 1;
            return m;
          }).entries.reduce((a, b) => a.value >= b.value ? a : b).key;
    final avgConf = history.scans.isEmpty
        ? 0.0
        : history.scans.map((s) => s.primaryConfidence).reduce((a, b) => a + b) /
            history.scans.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: _statCard(
                  'Total Scans',
                  '${history.totalScans}',
                  Icons.history,
                  AppColors.accent,
                  isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard(
                  'Top Script',
                  topScript,
                  Icons.translate,
                  Colors.blueAccent,
                  isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard(
                  'Avg Confidence',
                  '${(avgConf * 100).round()}%',
                  Icons.insights,
                  AppColors.successGreen,
                  isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color, bool isDark) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
        ),
      ),
      color: isDark ? AppColors.primaryMid.withOpacity(0.6) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTypography.display(16, color: isDark ? Colors.white : AppColors.textPrimary, weight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTypography.body(10, color: AppColors.textSecondary, weight: FontWeight.w500),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: AppTypography.display(18, color: isDark ? Colors.white : AppColors.textPrimary, weight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.body(11, color: AppColors.textSecondary, weight: FontWeight.w500),
        ),
      ],
    );
  }

  List<Widget> _buildGroupedSlivers(List<ScanResult> scans) {
    final grouped = _grouped(scans);
    return grouped.entries.expand((entry) {
      return [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
            child: Text(entry.key, style: AppTypography.body(13, weight: FontWeight.w600)),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, i) {
              final scan = entry.value[i];
              final id = scan.id;
              final allScans = ref.read(historyProvider).scans;
              final coinNumber = allScans.length - allScans.indexOf(scan);
              
              return HistoryCard(
                scan: scan,
                coinNumber: coinNumber,
                selected: id != null && _selectedIds.contains(id),
                onLongPress: () {
                  setState(() => _multiSelect = true);
                  if (id != null) _selectedIds.add(id);
                },
                onTap: _multiSelect && id != null
                    ? () {
                        setState(() {
                          if (_selectedIds.contains(id)) {
                            _selectedIds.remove(id);
                          } else {
                            _selectedIds.add(id);
                          }
                        });
                      }
                    : null,
                onDelete: () async {
                  if (id == null) return;
                  await ref.read(historyProvider.notifier).deleteScan(id);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Scan deleted'),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () async {
                            await ref.read(scanRepositoryProvider).insertScan(scan);
                            ref.read(historyProvider.notifier).refresh();
                          },
                        ),
                      ),
                    );
                  }
                },
              );
            },
            childCount: entry.value.length,
          ),
        ),
      ];
    }).toList();
  }

  Widget _shimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        children: List.generate(
          5,
          (_) => Container(
            height: 80,
            margin: const EdgeInsets.all(16),
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
