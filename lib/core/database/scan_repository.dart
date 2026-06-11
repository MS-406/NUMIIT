import 'dart:ui';
import 'package:flutter/foundation.dart';
import '../models/detected_region.dart';
import '../models/scan_result.dart';
import 'db_helper.dart';

enum HistorySort { newest, oldest, highestConfidence, scriptAz }

class ScanRepository {
  ScanRepository({DbHelper? dbHelper}) : _dbHelper = dbHelper ?? DbHelper.instance;

  final DbHelper _dbHelper;

  // In-memory fallback database for Web
  static final List<ScanResult> _inMemoryScans = [
    ScanResult(
      id: 1,
      imageLocalPath: 'https://images.unsplash.com/photo-1621972750749-0fbb1abb7736?w=400',
      imageThumbnailPath: 'https://images.unsplash.com/photo-1621972750749-0fbb1abb7736?w=200',
      scannedAt: DateTime.now().subtract(const Duration(days: 1)),
      primaryScript: 'Brahmi',
      primaryConfidence: 0.94,
      notes: 'Silver Karshapana showing five punch marks including sun and six-arm symbol from Mauryan Empire.',
      isSaved: true,
      isStarred: true,
      userEmail: 'guest',
      regions: [
        const DetectedRegion(
          regionIndex: 0,
          boundingBox: Rect.fromLTRB(0.1, 0.1, 0.9, 0.9),
          scriptName: 'Brahmi',
          originalText: '𑀤𑀾𑀠𑀫𑀺𑀢𑀺',
          transliteration: 'Dṛḍhamiti',
          translation: 'Firm in devotion / Strong friend',
          dynastyContext: 'Mauryan Dynasty (Ashoka the Great, c. 268–232 BCE)',
          confidence: 0.94,
          glyphCount: 4,
        ),
      ],
    ),
    ScanResult(
      id: 2,
      imageLocalPath: 'https://images.unsplash.com/photo-1599420186946-7b6fb4e297f0?w=400',
      imageThumbnailPath: 'https://images.unsplash.com/photo-1599420186946-7b6fb4e297f0?w=200',
      scannedAt: DateTime.now().subtract(const Duration(days: 3)),
      primaryScript: 'Kharoshthi',
      primaryConfidence: 0.86,
      notes: 'Bilingual silver drachm of Indo-Greek King Menander I Soter.',
      isSaved: true,
      isStarred: false,
      userEmail: 'guest',
      regions: [
        const DetectedRegion(
          regionIndex: 0,
          boundingBox: Rect.fromLTRB(0.15, 0.15, 0.85, 0.85),
          scriptName: 'Kharoshthi',
          originalText: '𐨨𐨂𐨢𐨿𐨪𐨌 𐨣𐨨𐨆 𐨨𐨅𐨣𐨡𐨿𐨪𐨯𐨿𐨩',
          transliteration: 'Maharajasa tratarasa Menadrasa',
          translation: 'Of King Menander the Savior',
          dynastyContext: 'Indo-Greek Kingdom (Menander I, c. 165–130 BCE)',
          confidence: 0.86,
          glyphCount: 8,
        ),
      ],
    ),
    ScanResult(
      id: 3,
      imageLocalPath: 'https://images.unsplash.com/photo-1508962914676-134849a727f0?w=400',
      imageThumbnailPath: 'https://images.unsplash.com/photo-1508962914676-134849a727f0?w=200',
      scannedAt: DateTime.now().subtract(const Duration(days: 5)),
      primaryScript: 'Persian',
      primaryConfidence: 0.79,
      notes: 'Copper Dam minted at Urdu Zafar Qarin in the reign of Akbar the Great.',
      isSaved: true,
      isStarred: true,
      userEmail: 'guest',
      regions: [
        const DetectedRegion(
          regionIndex: 0,
          boundingBox: Rect.fromLTRB(0.2, 0.2, 0.8, 0.8),
          scriptName: 'Persian',
          originalText: 'فلس اکبر شاهی ضرب اردو ظفر قرین',
          transliteration: 'Fals Akbar Shahi Zarb Urdu Zafar Qarin',
          translation: 'Copper coin of Shah Akbar, struck at the Camp associated with Victory',
          dynastyContext: 'Mughal Empire (Jalal-ud-din Muhammad Akbar, c. 1556–1605 CE)',
          confidence: 0.79,
          glyphCount: 12,
        ),
      ],
    ),
  ];

  Future<int> insertScan(ScanResult scan) async {
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
    if (kIsWeb) {
      // Mock scans (id <= 3) are visible to everyone; user scans are filtered by userEmail
      var list = _inMemoryScans.where((s) => s.id! <= 3 || s.userEmail == email).toList();

      // Filter by scripts
      if (scripts != null && scripts.isNotEmpty) {
        list = list.where((s) => scripts.any((script) =>
            s.primaryScript.toLowerCase().contains(script.toLowerCase()))).toList();
      }

      // Filter by confidence
      if (minConfidence != null) {
        list = list.where((s) => s.primaryConfidence >= minConfidence).toList();
      }

      // Filter by search query
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

      // Sort
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

    // Filter by user email
    where.add('user_email = ?');
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
    if (kIsWeb) {
      final list = _inMemoryScans.where((s) => s.id! <= 3 || s.userEmail == email).toList();
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
    if (kIsWeb) {
      _inMemoryScans.removeWhere((s) => s.id == id);
      return;
    }
    final db = await _dbHelper.database;
    await db.delete('scans', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAllForUser(String email) async {
    if (kIsWeb) {
      _inMemoryScans.removeWhere((s) => s.id! > 3 && s.userEmail == email);
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
}

