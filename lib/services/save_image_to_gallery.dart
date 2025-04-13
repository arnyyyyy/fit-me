import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:typed_data';


Future<void> saveImageToGallery(Uint8List pngBytes) async {
  if (await Permission.storage.request().isGranted) {
    final directory = Directory('/storage/emulated/0/Pictures/fit_me');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    final fileName = 'fitme_${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File('${directory.path}/$fileName');

    await file.writeAsBytes(pngBytes);

    print('Saved to ${file.path}');
  } else {
    print('Storage permission denied');
  }
}
