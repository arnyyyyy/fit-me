import 'package:flutter/material.dart';
import 'dart:io';

class PositionedDraggableImage extends StatefulWidget {
  final File image;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const PositionedDraggableImage({
    required this.image,
    required this.onDelete,
    required this.onTap,
    super.key,
  });

  @override
  PositionedDraggableImageState createState() =>
      PositionedDraggableImageState();
}

class PositionedDraggableImageState extends State<PositionedDraggableImage> {
  double _scale = 1.0;
  double _previousScale = 1.0;
  Offset _offset = Offset.zero;
  String _currentImagePath = '';

  @override
  void initState() {
    super.initState();
    _currentImagePath = widget.image.path;
  }

  @override
  void didUpdateWidget(PositionedDraggableImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.image.path != _currentImagePath) {
      _currentImagePath = widget.image.path;
      // Force rebuild when image path changes
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    const double minSize = 150.0;
    const double maxSize = 450.0;
    final double imageSize = (minSize * _scale).clamp(minSize, maxSize);

    return Positioned(
      left: _offset.dx,
      top: _offset.dy,
      child: GestureDetector(
        onScaleStart: (details) {
          _previousScale = _scale;
        },
        onScaleUpdate: (details) {
          setState(() {
            _scale = (_previousScale * details.scale).clamp(0.001, 3.0);
            _offset += details.focalPointDelta;

            _offset = Offset(
              _offset.dx.clamp(0.0, screenSize.width - imageSize),
              _offset.dy
                  .clamp(0.0, screenSize.height - imageSize - kToolbarHeight),
            );
          });
        },
        onScaleEnd: (details) {},
        onTap: widget.onTap,
        onLongPress: widget.onDelete,
        child: Stack(
          children: [
            Transform.scale(
              scale: _scale,
              child: Container(
                width: imageSize,
                height: imageSize,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: FileImage(
                      widget.image,
                      scale: 1.0,
                    ),
                    fit: BoxFit.contain,
                  ),
                ),
                key: ValueKey(_currentImagePath), 
              ),
            ),
          ],
        ),
      ),
    );
  }
}