import 'dart:convert';

import 'package:share_plus/share_plus.dart';

import '../models/scan_result.dart';

class ShareService {
  Future<void> shareResult(ScanResult scan) async {
    final region = scan.primaryRegion;
    final text = '''
NumiIT — Coin Inscription Result
Script: ${scan.primaryScript}
Confidence: ${(scan.primaryConfidence * 100).round()}%
${region != null ? '''
Original: ${region.originalText}
Transliteration: ${region.transliteration}
Translation: ${region.translation}
Dynasty: ${region.dynastyContext}
''' : ''}
Scanned: ${scan.scannedAt.toIso8601String()}
''';
    await Share.share(text, subject: 'NumiIT Scan Result');
  }

  Future<void> exportCsv(List<ScanResult> scans) async {
    final buffer = StringBuffer(
      'id,scanned_at,script,confidence,transliteration,translation,dynasty,notes\n',
    );
    for (final s in scans) {
      final r = s.primaryRegion;
      buffer.writeln([
        s.id,
        s.scannedAt.toIso8601String(),
        _escape(s.primaryScript),
        s.primaryConfidence,
        _escape(r?.transliteration ?? ''),
        _escape(r?.translation ?? ''),
        _escape(r?.dynastyContext ?? ''),
        _escape(s.notes ?? ''),
      ].join(','));
    }
    await Share.shareXFiles(
      [],
      text: buffer.toString(),
      subject: 'NumiIT Export CSV',
    );
  }

  Future<void> exportJson(List<ScanResult> scans) async {
    final data = scans.map((s) {
      final r = s.primaryRegion;
      return {
        'id': s.id,
        'scannedAt': s.scannedAt.toIso8601String(),
        'primaryScript': s.primaryScript,
        'primaryConfidence': s.primaryConfidence,
        'transliteration': r?.transliteration,
        'translation': r?.translation,
        'dynasty': r?.dynastyContext,
        'notes': s.notes,
      };
    }).toList();
    await Share.share(
      const JsonEncoder.withIndent('  ').convert(data),
      subject: 'NumiIT Export JSON',
    );
  }

  String _escape(String v) => '"${v.replaceAll('"', '""')}"';
}
