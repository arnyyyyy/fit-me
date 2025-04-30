import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/wardrobe/model/saved_image.dart';
import '../services/filter_service.dart';
import 'hive_providers.dart';

final filterServiceProvider = Provider<FilterService>((ref) {
  return FilterService();
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredImagesProvider = Provider<AsyncValue<List<SavedImage>>>((ref) {
  final imagesAsync = ref.watch(imagesProvider);
  final query = ref.watch(searchQueryProvider);
  final filterService = ref.watch(filterServiceProvider);
  
  return imagesAsync.whenData(
    (images) => filterService.filterImages(images, query)
  );
});