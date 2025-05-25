import 'dart:ui' as ui;
import 'dart:async';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:io';

class ImageBounds {
  final double left;
  final double top;
  final double right;
  final double bottom;
  
  const ImageBounds({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });
  
  double get width => right - left;
  double get height => bottom - top;
  
  bool get isEmpty => width <= 0 || height <= 0;
  
  static ImageBounds fromSize(Size size) {
    return ImageBounds(
      left: 0,
      top: 0,
      right: size.width,
      bottom: size.height,
    );
  }
  Rect toRect() => Rect.fromLTRB(left, top, right, bottom);
}

class ErasePoint {
  final Offset point;
  final double size;
  
  ErasePoint(this.point, this.size);
}

class ErasableMask {
  final List<ErasePoint> erasePoints;
  final Size imageSize;
  
  const ErasableMask({
    this.erasePoints = const [],
    required this.imageSize,
  });
  
  ErasableMask addPoint(Offset point, double size) {
    final List<ErasePoint> updatedPoints = List.from(erasePoints)
      ..add(ErasePoint(point, size));
    
    return ErasableMask(
      erasePoints: updatedPoints,
      imageSize: imageSize,
    );
  }
  
  bool get isEmpty => erasePoints.isEmpty;
}

class ErasableImagePainter extends CustomPainter {
  final ui.Image image;
  final ErasableMask? mask;
  final double imageScale;
  final ImageBounds? cachedBounds;

  ErasableImagePainter({
    required this.image,
    this.mask,
    this.imageScale = 1.0,
    this.cachedBounds,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());
    
    final paint = Paint()
      ..filterQuality = FilterQuality.high;
    
    Rect srcRect;
    if (cachedBounds != null && !cachedBounds!.isEmpty) {
      srcRect = cachedBounds!.toRect();
    } else {
      srcRect = Rect.fromLTWH(
        0, 
        0, 
        image.width.toDouble(), 
        image.height.toDouble()
      );
    }
    
    final dstRect = Rect.fromLTWH(
      0, 
      0, 
      size.width, 
      size.height
    );
    
    canvas.drawImageRect(image, srcRect, dstRect, paint);
    
    if (mask != null && !mask!.isEmpty) {
      final eraserPaint = Paint()
        ..blendMode = BlendMode.dstOut
        ..style = PaintingStyle.fill
        ..color = Colors.white.withValues(alpha: 1.0);
      
      final scaleX = size.width / image.width;
      final scaleY = size.height / image.height;
      
      for (final point in mask!.erasePoints) {
        final scaledPoint = Offset(
          point.point.dx * scaleX,
          point.point.dy * scaleY,
        );
        
        final scaledSize = point.size * ((scaleX + scaleY) / 2);
        
        canvas.drawCircle(scaledPoint, scaledSize, eraserPaint);
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(ErasableImagePainter oldDelegate) {
    return oldDelegate.image != image || 
           oldDelegate.mask != mask ||
           oldDelegate.imageScale != imageScale;
  }
}

Future<ImageBounds> getImageBounds(ui.Image image, ErasableMask? mask) async {
  if (mask == null || mask.isEmpty) {
    return ImageBounds.fromSize(Size(image.width.toDouble(), image.height.toDouble()));
  }
  
  final maskedImage = await createImageWithMask(image, mask);
  final ByteData? byteData = await maskedImage.toByteData();
  if (byteData == null) {
    return ImageBounds.fromSize(Size(image.width.toDouble(), image.height.toDouble()));
  }
  
  final int alphaThreshold = 20;
  
  double left = double.infinity;
  double top = double.infinity;
  double right = -double.infinity;
  double bottom = -double.infinity;
  bool hasVisiblePixels = false;
  
  for (int y = 0; y < maskedImage.height; y++) {
    for (int x = 0; x < maskedImage.width; x++) {
      final int pixelIndex = (y * maskedImage.width + x) * 4;
      
      final int alpha = byteData.getUint8(pixelIndex + 3);
      
      if (alpha > alphaThreshold) {
        left = left.isFinite ? math.min(left, x.toDouble()) : x.toDouble();
        top = top.isFinite ? math.min(top, y.toDouble()) : y.toDouble();
        right = math.max(right, (x + 1).toDouble());
        bottom = math.max(bottom, (y + 1).toDouble());
        hasVisiblePixels = true;
      }
    }
  }
  
  if (!hasVisiblePixels) {
    return ImageBounds(left: 0, top: 0, right: 0, bottom: 0);
  }
  
  return ImageBounds(left: left, top: top, right: right, bottom: bottom);
}

Future<ui.Image> loadImageFromFile(File file) async {
  final bytes = await file.readAsBytes();
  final codec = await ui.instantiateImageCodec(bytes);
  final frame = await codec.getNextFrame();
  return frame.image;
}

Future<ui.Image> createImageWithMask(ui.Image image, ErasableMask? mask) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  
  canvas.saveLayer(
    Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()), 
    Paint()
  );
  
  final paint = Paint()
    ..filterQuality = FilterQuality.high;
  
  final srcRect = Rect.fromLTWH(
    0, 
    0, 
    image.width.toDouble(), 
    image.height.toDouble()
  );
  
  final dstRect = Rect.fromLTWH(
    0, 
    0, 
    image.width.toDouble(), 
    image.height.toDouble()
  );
  
  canvas.drawImageRect(image, srcRect, dstRect, paint);
  
  if (mask != null && !mask.isEmpty) {
    final eraserPaint = Paint()
      ..blendMode = BlendMode.dstOut
      ..style = PaintingStyle.fill
      ..color = Colors.white.withValues(alpha: 1.0);
    
    for (final point in mask.erasePoints) {
      canvas.drawCircle(point.point, point.size, eraserPaint);
    }
  }

  canvas.restore();
  
  final picture = recorder.endRecording();
  final renderedImage = await picture.toImage(
    image.width,
    image.height,
  );
  
  return renderedImage;
}

Future<ui.Image> cropImageByBounds(ui.Image image, ImageBounds bounds) async {
  if (bounds.isEmpty) {
    return image;
  }
  
  final cropRecorder = ui.PictureRecorder();
  final cropCanvas = Canvas(cropRecorder);
  
  final int cropWidth = bounds.width.round();
  final int cropHeight = bounds.height.round();
  
  if (cropWidth <= 0 || cropHeight <= 0) {
    return image;
  }
  
  cropCanvas.drawImageRect(
    image, 
    bounds.toRect(), 
    Rect.fromLTWH(0, 0, cropWidth.toDouble(), cropHeight.toDouble()),
    Paint()..filterQuality = FilterQuality.high
  );
  
  final cropPicture = cropRecorder.endRecording();
  return await cropPicture.toImage(cropWidth, cropHeight);
}

Future<Uint8List> imageWithMaskToBytes(ui.Image image, ErasableMask? mask) async {
  final maskedImage = await createImageWithMask(image, mask);
  
  final byteData = await maskedImage.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}
