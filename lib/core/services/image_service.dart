import 'dart:io';
import 'dart:math';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';

class ImageService {

  Future<String> removeBackground(File imageFile) async {
    final imageBytes = await imageFile.readAsBytes();
    final originalImage = img.decodeImage(imageBytes);

    if (originalImage == null) {
      throw Exception('Failed to decode image');
    }

    final rgbImage = originalImage.convert(format: img.Format.uint8);

    final edgePoints = [
      rgbImage.getPixel(0, 0),
      rgbImage.getPixel(rgbImage.width - 1, 0),
      rgbImage.getPixel(0, rgbImage.height - 1),
      rgbImage.getPixel(rgbImage.width - 1, rgbImage.height - 1),
    ];

    int totalR = 0, totalG = 0, totalB = 0;
    for (final pixel in edgePoints) {
      totalR += pixel.r.toInt();
      totalG += pixel.g.toInt();
      totalB += pixel.b.toInt();
    }

    final bgR = totalR ~/ edgePoints.length;
    final bgG = totalG ~/ edgePoints.length;
    final bgB = totalB ~/ edgePoints.length;

    final resultImage = img.Image(
      width: rgbImage.width,
      height: rgbImage.height,
      numChannels: 4,
    );

    const threshold = 40;

    for (int y = 0; y < rgbImage.height; y++) {
      for (int x = 0; x < rgbImage.width; x++) {
        final pixel = rgbImage.getPixel(x, y);
        final r = pixel.r;
        final g = pixel.g;
        final b = pixel.b;

        final rDiff = (r - bgR).abs();
        final gDiff = (g - bgG).abs();
        final bDiff = (b - bgB).abs();

        final distance = sqrt(rDiff * rDiff + gDiff * gDiff + bDiff * bDiff);

        if (distance < threshold) {
          resultImage.setPixel(x, y, img.ColorRgba8(0, 0, 0, 0));
        } else {
          resultImage.setPixel(x, y, img.ColorRgba8(r.toInt(), g.toInt(), b.toInt(), 255));
        }
      }
    }

    final pngBytes = img.encodePng(resultImage);
    final appDir = await getApplicationDocumentsDirectory();
    final processedDir = Directory('${appDir.path}/processed_images');
    if (!await processedDir.exists()) {
      await processedDir.create(recursive: true);
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final originalName = path.basenameWithoutExtension(imageFile.path);
    final outputPath = '${processedDir.path}/${originalName}_nobg_$timestamp.png';

    await File(outputPath).writeAsBytes(pngBytes);

    debugPrint('Фон удалён! Сохранено: $outputPath');

    return outputPath;
  }
}