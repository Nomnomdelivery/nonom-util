import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

/// Image optimization utility for chat applications
class ImageOptimizer {
  /// Optimize image before sending in chat
  ///
  /// Returns optimized image file with:
  /// - Max width: 500px
  /// - JPEG quality: 85
  /// - File size reduction: ~70-80%
  static Future<File> optimizeForChat(File imageFile) async {
    try {
      // Read the image file
      final bytes = await imageFile.readAsBytes();
      var image = img.decodeImage(bytes);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // 1. RESIZE: Constrain to max width 500px, maintain aspect ratio
      if (image.width > 500) {
        final ratio = 500 / image.width;
        image = img.copyResize(
          image,
          width: 500,
          height: (image.height * ratio).toInt(),
          interpolation: img.Interpolation.linear,
        );
      }

      // 2. COMPRESS & REDUCE QUALITY: JPEG format with 85 quality
      final compressedBytes = Uint8List.fromList(
        img.encodeJpg(image, quality: 85),
      );

      // 3. SAVE to temporary location
      final tempDir = await getTemporaryDirectory();
      final optimizedFile = File(
        '${tempDir.path}/optimized_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await optimizedFile.writeAsBytes(compressedBytes);

      // Log reduction
      final originalSize = bytes.length;
      final optimizedSize = compressedBytes.length;
      final reduction = ((1 - optimizedSize / originalSize) * 100)
          .toStringAsFixed(1);

      debugLog(
        'Image optimized: ${(originalSize / 1024 / 1024).toStringAsFixed(2)}MB → ${(optimizedSize / 1024 / 1024).toStringAsFixed(2)}MB (${reduction}% reduction)',
      );

      return optimizedFile;
    } catch (e) {
      debugLog('Error optimizing image: $e');
      // Return original if optimization fails
      return imageFile;
    }
  }

  /// Advanced optimization with custom parameters
  static Future<File> optimizeAdvanced({
    required File imageFile,
    int maxWidth = 500,
    int quality = 85,
  }) async {
    try {
      final bytes = await imageFile.readAsBytes();
      var image = img.decodeImage(bytes);

      if (image == null) throw Exception('Failed to decode image');

      // Resize if needed
      if (image.width > maxWidth) {
        final ratio = maxWidth / image.width;
        image = img.copyResize(
          image,
          width: maxWidth,
          height: (image.height * ratio).toInt(),
          interpolation: img.Interpolation.linear,
        );
      }

      // Compress with specified quality
      final compressedBytes = Uint8List.fromList(
        img.encodeJpg(image, quality: quality),
      );

      final tempDir = await getTemporaryDirectory();
      final optimizedFile = File(
        '${tempDir.path}/optimized_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await optimizedFile.writeAsBytes(compressedBytes);

      return optimizedFile;
    } catch (e) {
      debugLog('Error in advanced optimization: $e');
      return imageFile;
    }
  }

  /// Get file size in MB for display
  static Future<String> getFileSizeFormatted(File file) async {
    final bytes = await file.length();
    return '${(bytes / 1024 / 1024).toStringAsFixed(2)} MB';
  }

  /// Check if image needs optimization
  static Future<bool> shouldOptimize(
    File imageFile, {
    int threshold = 2,
  }) async {
    final bytes = await imageFile.length();
    final sizeMB = bytes / 1024 / 1024;
    return sizeMB > threshold; // Optimize if > 2MB
  }
}

void debugLog(String message) {
  // Replace with your logging solution
  print('[ImageOptimizer] $message');
}
