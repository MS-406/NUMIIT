import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/scan_repository.dart';
import '../models/scan_result.dart';
import '../services/image_service.dart';
import '../services/ml_service.dart';
import '../services/share_service.dart';
import 'auth_provider.dart';

import '../services/dio_client.dart';

final scanRepositoryProvider = Provider<ScanRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ScanRepository(dioClient: dioClient);
});

final imageServiceProvider = Provider<ImageService>((ref) => ImageService());

final shareServiceProvider = Provider<ShareService>((ref) => ShareService());

final mlServiceProvider = Provider<MLService>((ref) => DioMLService(ref));

class HistoryState {
  const HistoryState({
    this.scans = const [],
    this.isLoading = true,
    this.error,
    this.searchQuery = '',
    this.selectedScripts = const [],
    this.sort = HistorySort.newest,
    this.minConfidenceFilter,
  });

  final List<ScanResult> scans;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final List<String> selectedScripts;
  final HistorySort sort;
  final double? minConfidenceFilter;

  int get totalScans => scans.length;

  int get scriptsDetected =>
      scans.map((s) => s.primaryScript).toSet().length;

  int get scansThisWeek {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return scans.where((s) => s.scannedAt.isAfter(weekAgo)).length;
  }

  HistoryState copyWith({
    List<ScanResult>? scans,
    bool? isLoading,
    String? error,
    String? searchQuery,
    List<String>? selectedScripts,
    HistorySort? sort,
    double? minConfidenceFilter,
    bool clearConfidenceFilter = false,
  }) {
    return HistoryState(
      scans: scans ?? this.scans,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedScripts: selectedScripts ?? this.selectedScripts,
      sort: sort ?? this.sort,
      minConfidenceFilter: clearConfidenceFilter
          ? null
          : (minConfidenceFilter ?? this.minConfidenceFilter),
    );
  }
}

class HistoryNotifier extends Notifier<HistoryState> {
  @override
  HistoryState build() {
    // Watch auth state changes, so we automatically reload history when a user logs in/out!
    ref.listen(authProvider, (previous, next) {
      load();
    });
    Future.microtask(load);
    return const HistoryState();
  }

  ScanRepository get _repo => ref.read(scanRepositoryProvider);
  String get _userEmail => ref.read(authProvider).email ?? 'guest';

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final scans = await _repo.getAllScans(
        email: _userEmail,
        sort: state.sort,
        scripts: state.selectedScripts.isEmpty ? null : state.selectedScripts,
        minConfidence: state.minConfidenceFilter,
        query: state.searchQuery.isEmpty ? null : state.searchQuery,
      );
      state = state.copyWith(scans: scans, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<List<ScanResult>> getRecent({int limit = 5}) =>
      _repo.getRecentScans(email: _userEmail, limit: limit);

  Future<void> refresh() => load();

  Future<void> setSearch(String query) async {
    state = state.copyWith(searchQuery: query);
    await load();
  }

  Future<void> setScripts(List<String> scripts) async {
    state = state.copyWith(selectedScripts: scripts);
    await load();
  }

  Future<void> setSort(HistorySort sort) async {
    state = state.copyWith(sort: sort);
    await load();
  }

  Future<void> setConfidenceFilter(double? min) async {
    state = state.copyWith(
      minConfidenceFilter: min,
      clearConfidenceFilter: min == null,
    );
    await load();
  }

  Future<int> saveScan(ScanResult scan) async {
    final updated = scan.copyWith(
      isSaved: true,
      userEmail: _userEmail,
    );
    
    int newId;
    if (updated.id == null) {
      newId = await _repo.insertScan(updated);
    } else {
      await _repo.updateScan(updated);
      newId = updated.id!;
    }
    
    await load();
    return newId;
  }

  Future<void> deleteScan(int id) async {
    await _repo.deleteScan(id);
    await load();
  }

  Future<void> toggleStar(ScanResult scan) async {
    final updated = scan.copyWith(
      isStarred: !scan.isStarred,
      userEmail: _userEmail,
    );
    await _repo.updateScan(updated);
    await load();
  }

  Future<void> clearAll() async {
    await _repo.clearAllForUser(_userEmail);
    await load();
  }
}

final historyProvider =
    NotifierProvider<HistoryNotifier, HistoryState>(HistoryNotifier.new);

final currentScanProvider = StateProvider<ScanResult?>((ref) => null);
