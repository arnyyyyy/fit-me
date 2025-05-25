import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:ui' as ui;
import '../utils/app_colors.dart';
import 'erasable_image.dart';

class PositionedDraggableImage extends StatefulWidget {
  final File image;
  final VoidCallback onDelete;
  final VoidCallback onTap;
  final bool isEraseMode;
  final double eraserSize;
  final Function(String, ErasableMask)? onMaskUpdated;

  const PositionedDraggableImage({
    required this.image,
    required this.onDelete,
    required this.onTap,
    this.isEraseMode = false,
    this.eraserSize = 20.0,
    this.onMaskUpdated,
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
  ui.Image? _image;
  ErasableMask? _mask;
  bool _isLoading = true;
  bool _isErasing = false;
  final GlobalKey _imageKey = GlobalKey();
  
  final double _baseSize = 150.0;

  @override
  void initState() {
    super.initState();
    _currentImagePath = widget.image.path;
    _loadImage();
  }

  @override
  void didUpdateWidget(PositionedDraggableImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.image.path != _currentImagePath) {
      _currentImagePath = widget.image.path;
      _mask = null;
      _loadImage();
    }
  }
  
  Future<void> _loadImage() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final image = await loadImageFromFile(widget.image);
      if (mounted) {
        setState(() {
          _image = image;
          _mask ??= ErasableMask(
              imageSize: Size(image.width.toDouble(), image.height.toDouble()),
            );
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Offset _getLocalPosition(Offset globalPosition) {
    if (_imageKey.currentContext == null || _image == null) return Offset.zero;
    
    final RenderBox renderBox = _imageKey.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.globalToLocal(globalPosition);
    
    final double imageDisplayWidth = renderBox.size.width;
    final double imageDisplayHeight = renderBox.size.height;
    
    final double scaleX = _image!.width / imageDisplayWidth;
    final double scaleY = _image!.height / imageDisplayHeight;
    
    return Offset(
      position.dx * scaleX,
      position.dy * scaleY,
    );
  }
  
  void _handleErase(Offset position) {
    if (_mask != null && _image != null) {
      final localPosition = _getLocalPosition(position);
      
      setState(() {
        _mask = _mask!.addPoint(localPosition, widget.eraserSize);
        
        if (widget.onMaskUpdated != null) {
          widget.onMaskUpdated!(_currentImagePath, _mask!);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    double width = _baseSize;
    double height = _baseSize;
    
    if (_image != null) {
      final imageAspectRatio = _image!.width / _image!.height;
      
      if (imageAspectRatio > 1) {
        height = width / imageAspectRatio;
      } else {
        width = height * imageAspectRatio;
      }
    }
    
    final scaledWidth = width * _scale;
    final scaledHeight = height * _scale;

    if (_isLoading || _image == null) {
      return Positioned(
        left: _offset.dx,
        top: _offset.dy,
        child: SizedBox(
          width: _baseSize,
          height: _baseSize,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    Widget imageWidget = ClipRect(
      child: CustomPaint(
        key: _imageKey,
        painter: ErasableImagePainter(
          image: _image!,
          mask: _mask,
          imageScale: 1.0,
        ),
        size: Size(scaledWidth, scaledHeight),
      ),
    );

    if (widget.isEraseMode) {
      imageWidget = GestureDetector(
        onPanStart: (details) {
          _isErasing = true;
          _handleErase(details.globalPosition);
        },
        onPanUpdate: (details) {
          if (_isErasing) {
            _handleErase(details.globalPosition);
          }
        },
        onPanEnd: (details) {
          _isErasing = false;
        },
        child: imageWidget,
      );
    }

    return Positioned(
      left: _offset.dx,
      top: _offset.dy,
      child: GestureDetector(
        onScaleStart: widget.isEraseMode ? null : (details) {
          _previousScale = _scale;
        },
        onScaleUpdate: widget.isEraseMode ? null : (details) {
          setState(() {
            _scale = (_previousScale * details.scale).clamp(0.5, 2.0);
            _offset += details.focalPointDelta;

            _offset = Offset(
              _offset.dx.clamp(0.0, screenSize.width - scaledWidth),
              _offset.dy.clamp(0.0, screenSize.height - scaledHeight - kToolbarHeight),
            );
          });
        },
        onScaleEnd: widget.isEraseMode ? null : (details) {},
        onTap: widget.isEraseMode ? null : widget.onTap,
        onLongPress: widget.isEraseMode ? null : widget.onDelete,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: widget.isEraseMode ? AppColors.primary : Colors.transparent,
              width: widget.isEraseMode ? 2.0 : 0.0,
            ),
          ),
          child: imageWidget,
        ),
      ),
    );
  }
}