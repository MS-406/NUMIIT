import 'dart:convert';

import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_io/io.dart';

import '../models/scan_result.dart';

class ShareService {
  Future<void> shareResult(ScanResult scan) async {
    final region = scan.primaryRegion;
    // Find the primary era score, or fallback to the first one if available
    final primaryScore = scan.eraScores.where((e) => e.isPrimary).firstOrNull ?? 
                         (scan.eraScores.isNotEmpty ? scan.eraScores.first : null);
    
    final textBuffer = StringBuffer();
    textBuffer.writeln('NumiIT — Coin Inscription Result');
    textBuffer.writeln('Script: ${scan.primaryScript}');
    
    if (primaryScore != null) {
      textBuffer.writeln('\nRuler Analysis:');
      textBuffer.writeln('Era: ${primaryScore.era}');
      if (primaryScore.dynasty != null) textBuffer.writeln('Dynasty: ${primaryScore.dynasty}');
      if (primaryScore.translation != null) textBuffer.writeln('Translation: ${primaryScore.translation}');
    }
    
    if (region != null) {
      textBuffer.writeln('\nCharacter Details:');
      textBuffer.writeln('Original: ${region.originalText}');
      if (region.transliteration.isNotEmpty) textBuffer.writeln('Transliteration: ${region.transliteration}');
      if (region.translation.isNotEmpty && (primaryScore == null || primaryScore.translation != region.translation)) {
        textBuffer.writeln('Translation: ${region.translation}');
      }
    }
    textBuffer.writeln('\nConfidence: ${(scan.primaryConfidence * 100).round()}%');

    if (scan.imageLocalPath.isNotEmpty) {
       try {
         await Share.shareXFiles([XFile(scan.imageLocalPath)], text: textBuffer.toString(), subject: 'NumiIT Scan Result');
       } catch (e) {
         await Share.share(textBuffer.toString(), subject: 'NumiIT Scan Result');
       }
    } else {
       await Share.share(textBuffer.toString(), subject: 'NumiIT Scan Result');
    }
  }

  Future<void> exportCsv(List<ScanResult> scans) async {
    final buffer = StringBuffer(
      'id,scanned_at,script,confidence,era,dynasty,ruler_translation,transliteration,translation,notes\n',
    );
    for (final s in scans) {
      final r = s.primaryRegion;
      final primaryScore = s.eraScores.where((e) => e.isPrimary).firstOrNull ?? 
                           (s.eraScores.isNotEmpty ? s.eraScores.first : null);
      buffer.writeln([
        s.id,
        s.scannedAt.toIso8601String(),
        _escape(s.primaryScript),
        s.primaryConfidence,
        _escape(primaryScore?.era ?? ''),
        _escape(primaryScore?.dynasty ?? r?.dynastyContext ?? ''),
        _escape(primaryScore?.translation ?? ''),
        _escape(r?.transliteration ?? ''),
        _escape(r?.translation ?? ''),
        _escape(s.notes ?? ''),
      ].join(','));
    }
    if (kIsWeb) {
      try {
        final xfile = XFile.fromData(
          utf8.encode(buffer.toString()),
          mimeType: 'text/csv',
          name: 'numiit_history.csv',
        );
        await Share.shareXFiles([xfile], subject: 'NumiIT Export CSV');
      } catch (e) {
        await Share.share(buffer.toString(), subject: 'NumiIT Export CSV');
      }
      return;
    }

    try {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/numiit_history.csv');
      await file.writeAsString(buffer.toString());
      
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'text/csv')],
        subject: 'NumiIT Export CSV',
      );
    } catch (e) {
      await Share.share(buffer.toString(), subject: 'NumiIT Export CSV');
    }
  }

  Future<void> exportJson(List<ScanResult> scans) async {
    final data = scans.map((s) {
      final r = s.primaryRegion;
      final primaryScore = s.eraScores.where((e) => e.isPrimary).firstOrNull ?? 
                           (s.eraScores.isNotEmpty ? s.eraScores.first : null);
      return {
        'id': s.id,
        'scannedAt': s.scannedAt.toIso8601String(),
        'primaryScript': s.primaryScript,
        'primaryConfidence': s.primaryConfidence,
        'era': primaryScore?.era,
        'dynasty': primaryScore?.dynasty ?? r?.dynastyContext,
        'rulerTranslation': primaryScore?.translation,
        'transliteration': r?.transliteration,
        'translation': r?.translation,
        'notes': s.notes,
      };
    }).toList();
    try {
      await Share.share(
        const JsonEncoder.withIndent('  ').convert(data),
        subject: 'NumiIT Export JSON',
      );
    } catch (e) {
      debugPrint('Error exporting JSON: $e');
    }
  }

  String _escape(String v) => '"${v.replaceAll('"', '""')}"';
}
