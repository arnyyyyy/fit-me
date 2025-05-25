import 'dart:ui' as ui;
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:io';

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

  ErasableImagePainter({
    required this.image,
    this.mask,
    this.imageScale = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());
    
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

Future<ui.Image> loadImageFromFile(File file) async {
  final bytes = await file.readAsBytes();
  final codec = await ui.instantiateImageCodec(bytes);
  final frame = await codec.getNextFrame();
  return frame.image;
}

Future<Uint8List> imageWithMaskToBytes(ui.Image image, ErasableMask? mask) async {
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
  
  final byteData = await renderedImage.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}
