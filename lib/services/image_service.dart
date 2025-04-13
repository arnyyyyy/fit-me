import 'dart:io';
import 'dart:math';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';

class ImageService {
  Future<String> removeBackground(File imageFile) async {
    final imageBytes = await imageFile.readAsBytes();
    final image = img.decodeImage(imageBytes);
    
    if (image == null) {
      throw Exception('Failed to decode image');
    }
    
    final rgbImage = image.format != img.Format.uint8 ?
        image.convert(format: img.Format.uint8) : image;
    
    final edgePoints = [
      rgbImage.getPixel(0, 0),
      rgbImage.getPixel(rgbImage.width - 1, 0),
      rgbImage.getPixel(0, rgbImage.height - 1),
      rgbImage.getPixel(rgbImage.width - 1, rgbImage.height - 1),
      rgbImage.getPixel(rgbImage.width ~/ 2, 0),
      rgbImage.getPixel(rgbImage.width ~/ 2, rgbImage.height - 1),
      rgbImage.getPixel(0, rgbImage.height ~/ 2),
      rgbImage.getPixel(rgbImage.width - 1, rgbImage.height ~/ 2),
    ];
    
    var totalR = 0, totalG = 0, totalB = 0;
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
      format: img.Format.uint8,
      numChannels: 4,
    );
    
    var transparentPixels = 0;
    var totalPixels = 0;
    var sensitivityThreshold = 40;
    
    for (int y = 0; y < rgbImage.height; y++) {
      for (int x = 0; x < rgbImage.width; x++) {
        totalPixels++;
        final pixel = rgbImage.getPixel(x, y);
        final r = pixel.r;
        final g = pixel.g;
        final b = pixel.b;
        
        final rDiff = (r - bgR).abs();
        final gDiff = (g - bgG).abs();
        final bDiff = (b - bgB).abs();
        final distance = sqrt(rDiff * rDiff + gDiff * gDiff + bDiff * bDiff);
        
        final distFromEdge = min(
          min(x, rgbImage.width - x),
          min(y, rgbImage.height - y)
        );
        
        final adjustedThreshold = distFromEdge < 10 ?
            sensitivityThreshold * 1.5 : sensitivityThreshold;
        
        var alpha = 255;
        if (distance < adjustedThreshold) {
          alpha = 0;
          transparentPixels++;
        } else if (distance < adjustedThreshold * 1.5) {
          alpha = ((distance - adjustedThreshold) / (adjustedThreshold * 0.5) * 255).clamp(0, 255).toInt();
        }
        
        resultImage.setPixel(x, y, img.ColorRgba8(r.toInt(), g.toInt(), b.toInt(), alpha));
      }
    }
    
    final percentage = (transparentPixels / totalPixels * 100).toStringAsFixed(1);
    print('Made $transparentPixels pixels transparent ($percentage% of image)');
    
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

    debugPrint('Фон удалён! Сделано прозрачными $transparentPixels пикселей ($percentage%)');
    
    return outputPath;
  }
}