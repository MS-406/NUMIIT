import 'dart:ui';
import 'package:flutter/foundation.dart';
import '../models/detected_region.dart';
import '../models/scan_result.dart';
import '../services/dio_client.dart';
import 'db_helper.dart';

enum HistorySort { newest, oldest, highestConfidence, scriptAz }

class ScanRepository {
  ScanRepository({required DioClient dioClient, DbHelper? dbHelper})
      : _dioClient = dioClient,
        _dbHelper = dbHelper ?? DbHelper.instance;

  final DioClient _dioClient;
  final DbHelper _dbHelper;

  // In-memory fallback database for Web
  static final List<ScanResult> _inMemoryScans = [];

  Future<int> insertScan(ScanResult scan) async {
    final email = scan.userEmail ?? 'guest';
    if (email != 'guest') {
      try {
        final response = await _dioClient.dio.post(
          '/scans',
          data: {
            'image_path': scan.imageLocalPath,
            'thumbnail_path': scan.imageThumbnailPath,
            'primary_script': scan.primaryScript,
            'primary_confidence': scan.primaryConfidence,
            'notes': scan.notes,
            'is_saved': scan.isSaved,
            'is_starred': scan.isStarred,
            'regions': scan.regions.map((r) => r.toJson()).toList(),
          },
        );
        final data = response.data as Map<String, dynamic>;
        return data['id'] as int;
      } catch (e) {
        if (kDebugMode) {
          print('Failed to insert scan remotely, falling back to local database. Error: $e');
        }
      }
    }

    if (kIsWeb) {
      final newId = _inMemoryScans.isEmpty
          ? 1
          : (_inMemoryScans.map((s) => s.id ?? 0).reduce((a, b) => a > b ? a : b) + 1);
      final newScan = scan.copyWith(id: newId, isSaved: true);
      _inMemoryScans.add(newScan);
      return newId;
    }
    final db = await _dbHelper.database;
    return db.insert('scans', _toMap(scan));
  }

  Future<void> updateScan(ScanResult scan) async {
    if (scan.id == null) return;
    final email = scan.userEmail ?? 'guest';
    if (email != 'guest') {
      try {
        await _dioClient.dio.put(
          '/scans/${scan.id}',
          data: {
            'notes': scan.notes,
            'is_saved': scan.isSaved,
            'is_starred': scan.isStarred,
          },
        );
        return;
      } catch (e) {
        if (kDebugMode) {
          print('Failed to update scan remotely, falling back to local database. Error: $e');
        }
      }
    }

    if (kIsWeb) {
      final idx = _inMemoryScans.indexWhere((s) => s.id == scan.id);
      if (idx != -1) {
        _inMemoryScans[idx] = scan;
      }
      return;
    }
    final db = await _dbHelper.database;
    await db.update('scans', _toMap(scan), where: 'id = ?', whereArgs: [scan.id]);
  }

  Future<ScanResult?> getScanById(int id) async {
    try {
      final response = await _dioClient.dio.get(
        '/scans/$id',
        queryParameters: {'_t': DateTime.now().millisecondsSinceEpoch},
      );
      final data = response.data as Map<String, dynamic>;
      return _fromApiResponse(data);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to fetch scan $id remotely, checking local fallback. Error: $e');
      }
    }

    if (kIsWeb) {
      try {
        return _inMemoryScans.firstWhere((s) => s.id == id);
      } catch (_) {
        return null;
      }
    }
    final db = await _dbHelper.database;
    final rows = await db.query('scans', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return _fromMap(rows.first);
  }

  Future<List<ScanResult>> getAllScans({
    required String email,
    HistorySort sort = HistorySort.newest,
    List<String>? scripts,
    double? minConfidence,
    String? query,
  }) async {
    if (email != 'guest') {
      try {
        final params = <String, dynamic>{};
        if (sort == HistorySort.oldest) {
          params['sort'] = 'oldest';
        } else if (sort == HistorySort.highestConfidence) {
          params['sort'] = 'highest_confidence';
        } else if (sort == HistorySort.scriptAz) {
          params['sort'] = 'script_az';
        } else {
          params['sort'] = 'newest';
        }

        if (scripts != null && scripts.isNotEmpty) {
          params['scripts'] = scripts;
        }
        if (minConfidence != null) {
          params['min_confidence'] = minConfidence;
        }
        if (query != null && query.isNotEmpty) {
          params['query'] = query;
        }
        params['_t'] = DateTime.now().millisecondsSinceEpoch;

        final response = await _dioClient.dio.get(
          '/scans',
          queryParameters: params,
        );
        final list = response.data as List<dynamic>;
        return list.map((e) => _fromApiResponse(e as Map<String, dynamic>)).toList();
      } catch (e) {
        if (kDebugMode) {
          print('Failed to fetch scans list remotely, checking local fallback. Error: $e');
        }
      }
    }

    // Local Fallback (SQLite or memory)
    if (kIsWeb) {
      var list = _inMemoryScans.where((s) => s.userEmail == email).toList();

      if (scripts != null && scripts.isNotEmpty) {
        list = list.where((s) => scripts.any((script) =>
            s.primaryScript.toLowerCase().contains(script.toLowerCase()))).toList();
      }

      if (minConfidence != null) {
        list = list.where((s) => s.primaryConfidence >= minConfidence).toList();
      }

      if (query != null && query.trim().isNotEmpty) {
        final q = query.trim().toLowerCase();
        list = list.where((s) {
          final scriptMatch = s.primaryScript.toLowerCase().contains(q);
          final notesMatch = s.notes?.toLowerCase().contains(q) ?? false;
          final regionMatch = s.regions.any((r) =>
              r.originalText.toLowerCase().contains(q) ||
              r.transliteration.toLowerCase().contains(q) ||
              r.translation.toLowerCase().contains(q) ||
              r.dynastyContext.toLowerCase().contains(q));
          return scriptMatch || notesMatch || regionMatch;
        }).toList();
      }

      switch (sort) {
        case HistorySort.oldest:
          list.sort((a, b) => a.scannedAt.compareTo(b.scannedAt));
        case HistorySort.highestConfidence:
          list.sort((a, b) => b.primaryConfidence.compareTo(a.primaryConfidence));
        case HistorySort.scriptAz:
          list.sort((a, b) => a.primaryScript.toLowerCase().compareTo(b.primaryScript.toLowerCase()));
        case HistorySort.newest:
          list.sort((a, b) => b.scannedAt.compareTo(a.scannedAt));
      }
      return list;
    }

    final db = await _dbHelper.database;
    final where = <String>[];
    final args = <dynamic>[];

    // Filter by email. For guest users, we also include local DB scans where user_email is guest
    where.add('(user_email = ?)');
    args.add(email);

    if (scripts != null && scripts.isNotEmpty) {
      where.add(
        '(' + scripts.map((s) => "primary_script LIKE '%$s%'").join(' OR ') + ')',
      );
    }
    if (minConfidence != null) {
      where.add('primary_confidence >= ?');
      args.add(minConfidence);
    }
    if (query != null && query.trim().isNotEmpty) {
      final q = '%${query.trim()}%';
      where.add(
        "(primary_script LIKE ? OR regions_json LIKE ? OR notes LIKE ?)",
      );
      args.addAll([q, q, q]);
    }

    var orderBy = 'scanned_at DESC';
    switch (sort) {
      case HistorySort.oldest:
        orderBy = 'scanned_at ASC';
      case HistorySort.highestConfidence:
        orderBy = 'primary_confidence DESC';
      case HistorySort.scriptAz:
        orderBy = 'primary_script ASC';
      case HistorySort.newest:
        orderBy = 'scanned_at DESC';
    }

    final rows = await db.query(
      'scans',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: orderBy,
    );
    return rows.map(_fromMap).toList();
  }

  Future<List<ScanResult>> getRecentScans({required String email, int limit = 5}) async {
    if (email != 'guest') {
      try {
        final scans = await getAllScans(email: email);
        scans.sort((a, b) {
          if (a.isStarred && !b.isStarred) return -1;
          if (!a.isStarred && b.isStarred) return 1;
          return b.scannedAt.compareTo(a.scannedAt);
        });
        return scans.take(limit).toList();
      } catch (e) {
        if (kDebugMode) {
          print('Failed to get recent scans remotely. Error: $e');
        }
      }
    }

    if (kIsWeb) {
      final list = _inMemoryScans.where((s) => s.userEmail == email).toList();
      list.sort((a, b) {
        if (a.isStarred && !b.isStarred) return -1;
        if (!a.isStarred && b.isStarred) return 1;
        return b.scannedAt.compareTo(a.scannedAt);
      });
      return list.take(limit).toList();
    }

    final db = await _dbHelper.database;
    final rows = await db.query(
      'scans',
      where: 'user_email = ?',
      whereArgs: [email],
      orderBy: 'is_starred DESC, scanned_at DESC',
      limit: limit,
    );
    return rows.map(_fromMap).toList();
  }

  Future<void> deleteScan(int id) async {
    try {
      await _dioClient.dio.delete('/scans/$id');
    } catch (e) {
      if (kDebugMode) {
        print('Failed to delete scan remotely. Error: $e');
      }
    }

    if (kIsWeb) {
      _inMemoryScans.removeWhere((s) => s.id == id);
      return;
    }
    final db = await _dbHelper.database;
    await db.delete('scans', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAllForUser(String email) async {
    if (email != 'guest') {
      try {
        await _dioClient.dio.delete('/scans');
      } catch (e) {
        if (kDebugMode) {
          print('Failed to clear scans remotely. Error: $e');
        }
      }
    }

    if (kIsWeb) {
      _inMemoryScans.removeWhere((s) => s.userEmail == email);
      return;
    }
    final db = await _dbHelper.database;
    await db.delete('scans', where: 'user_email = ?', whereArgs: [email]);
  }

  Map<String, dynamic> _toMap(ScanResult scan) => {
        if (scan.id != null) 'id': scan.id,
        'image_path': scan.imageLocalPath,
        'thumbnail_path': scan.imageThumbnailPath,
        'scanned_at': scan.scannedAt.toIso8601String(),
        'primary_script': scan.primaryScript,
        'primary_confidence': scan.primaryConfidence,
        'regions_json': DetectedRegion.encodeList(scan.regions),
        'notes': scan.notes,
        'is_saved': scan.isSaved ? 1 : 0,
        'is_starred': scan.isStarred ? 1 : 0,
        'user_email': scan.userEmail ?? 'guest',
      };

  ScanResult _fromMap(Map<String, dynamic> row) => ScanResult(
        id: row['id'] as int?,
        imageLocalPath: row['image_path'] as String,
        imageThumbnailPath: row['thumbnail_path'] as String,
        scannedAt: DateTime.parse(row['scanned_at'] as String),
        regions: DetectedRegion.decodeList(row['regions_json'] as String),
        primaryScript: row['primary_script'] as String? ?? 'Unknown',
        primaryConfidence: (row['primary_confidence'] as num?)?.toDouble() ?? 0,
        notes: row['notes'] as String?,
        isSaved: (row['is_saved'] as int? ?? 0) == 1,
        isStarred: (row['is_starred'] as int? ?? 0) == 1,
        userEmail: row['user_email'] as String? ?? 'guest',
      );

  ScanResult _fromApiResponse(Map<String, dynamic> json) {
    final regionsRaw = json['regions'] as List<dynamic>? ?? [];
    final regions = regionsRaw
        .map((e) => DetectedRegion.fromJson(e as Map<String, dynamic>))
        .toList();

    return ScanResult(
      id: json['id'] as int?,
      imageLocalPath: json['image_path'] as String? ?? '',
      imageThumbnailPath: json['thumbnail_path'] as String? ?? '',
      scannedAt: DateTime.parse(json['scanned_at'] as String),
      regions: regions,
      primaryScript: json['primary_script'] as String? ?? 'Unknown',
      primaryConfidence: (json['primary_confidence'] as num?)?.toDouble() ?? 0,
      notes: json['notes'] as String?,
      isSaved: json['is_saved'] as bool? ?? false,
      isStarred: json['is_starred'] as bool? ?? false,
      userEmail: json['user_email'] as String? ?? 'guest',
    );
  }
}
