import 'package:universal_io/io.dart';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();
  final _uuid = const Uuid();

  Future<String?> pickFromGallery() async {
    final file = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 2048);
    if (file == null) return null;
    return _persistImage(file.path);
  }

  Future<List<String>> pickMultipleFromGallery() async {
    final files = await _picker.pickMultiImage(maxWidth: 2048);
    final paths = <String>[];
    for (final f in files) {
      paths.add(await _persistImage(f.path));
    }
    return paths;
  }

  Future<String> saveCapturedImage(String tempPath) => _persistImage(tempPath);

  Future<String> _persistImage(String sourcePath) async {
    if (kIsWeb) return sourcePath;
    final dir = await getApplicationDocumentsDirectory();
    final scansDir = Directory(p.join(dir.path, 'scans'));
    if (!await scansDir.exists()) {
      await scansDir.create(recursive: true);
    }
    final id = _uuid.v4();
    final destPath = p.join(scansDir.path, '$id.jpg');
    await File(sourcePath).copy(destPath);
    await _createThumbnail(destPath);
    return destPath;
  }

  Future<String> thumbnailPathFor(String imagePath) async {
    if (kIsWeb) return imagePath;
    final dir = p.dirname(imagePath);
    final base = p.basenameWithoutExtension(imagePath);
    return p.join(dir, '${base}_thumb.jpg');
  }

  Future<void> _createThumbnail(String imagePath) async {
    if (kIsWeb) return;
    final bytes = await File(imagePath).readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return;
    final thumb = img.copyResize(decoded, width: 200);
    final thumbPath = await thumbnailPathFor(imagePath);
    await File(thumbPath).writeAsBytes(img.encodeJpg(thumb, quality: 85));
  }

  Future<String> ensureThumbnail(String imagePath) async {
    if (kIsWeb) return imagePath;
    final thumb = await thumbnailPathFor(imagePath);
    if (await File(thumb).exists()) return thumb;
    await _createThumbnail(imagePath);
    return thumb;
  }

  /// Laplacian variance — higher = sharper. Threshold ~100 for blur warning.
  Future<double> sharpnessScore(String imagePath) async {
    if (kIsWeb) return 200;
    final bytes = await File(imagePath).readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return 0;
    final gray = img.grayscale(img.copyResize(decoded, width: 400));
    final w = gray.width;
    final h = gray.height;
    double sum = 0;
    int count = 0;
    for (var y = 1; y < h - 1; y++) {
      for (var x = 1; x < w - 1; x++) {
        final c = gray.getPixel(x, y).r.toInt();
        final lap = (4 * c -
                gray.getPixel(x - 1, y).r -
                gray.getPixel(x + 1, y).r -
                gray.getPixel(x, y - 1).r -
                gray.getPixel(x, y + 1).r)
            .abs();
        sum += lap * lap;
        count++;
      }
    }
    return count == 0 ? 0 : sum / count;
  }

  Future<bool> isBlurry(String imagePath, {double threshold = 80}) async {
    final score = await sharpnessScore(imagePath);
    return score < threshold;
  }

  Future<Uint8List?> loadBytes(String path) async {
    if (kIsWeb) return null;
    final file = File(path);
    if (!await file.exists()) return null;
    return file.readAsBytes();
  }
}
