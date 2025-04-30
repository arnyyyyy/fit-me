import '../model/saved_image.dart';

abstract class Message {}

class LoadImages extends Message {}

class ImagesLoaded extends Message {
  final List<SavedImage> images;

  ImagesLoaded(this.images);
}

class ImagesLoadError extends Message {
  final String message;

  ImagesLoadError(this.message);
}

class ToggleSearch extends Message {
  final bool isSearching;

  ToggleSearch(this.isSearching);
}

class SearchQueryChanged extends Message {
  final String query;

  SearchQueryChanged(this.query);
}

class AddImage extends Message {
  final SavedImage image;

  AddImage(this.image);
}

class NavigateToAddImage extends Message {}
