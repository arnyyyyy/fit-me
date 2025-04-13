import 'package:flutter/material.dart';

class CheckerboardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint lightPaint = Paint()..color = const Color(0xFFCCCCCC);
    final Paint darkPaint = Paint()..color = const Color(0xFFAAAAAA);
    const double cellSize = 20.0;
    
    for (int i = 0; i < (size.width / cellSize).ceil(); i++) {
      for (int j = 0; j < (size.height / cellSize).ceil(); j++) {
        final bool isLightCell = (i + j) % 2 == 0;
        final Paint paint = isLightCell ? lightPaint : darkPaint;
        
        canvas.drawRect(
          Rect.fromLTWH(
            i * cellSize,
            j * cellSize,
            cellSize,
            cellSize,
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}