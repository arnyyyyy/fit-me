import '../../features/wardrobe//model/saved_image.dart';

class FilterService {
  List<SavedImage> filterImages(List<SavedImage> images, String query) {
    if (query.isEmpty) {
      return images;
    }
    
    final normalizedQuery = query.toLowerCase();
    
    return images.where((image) {
      final nameMatches = image.name.toLowerCase().contains(normalizedQuery);
      final tagMatches = image.tags.any(
        (tag) => tag.toLowerCase().contains(normalizedQuery)
      );
      return nameMatches || tagMatches;
    }).toList();
  }
}