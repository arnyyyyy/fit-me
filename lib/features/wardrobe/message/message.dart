import 'package:fit_me/core/common/base_message.dart';

import '../model/saved_image.dart';

abstract class Message extends BaseMessage{}

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

class RemoveImage extends Message {
  final SavedImage image;

  RemoveImage(this.image);
}

class NavigateToAddImage extends Message {}

class ToggleTagFilter extends Message {
  final bool isVisible;

  ToggleTagFilter(this.isVisible);
}

class LoadAvailableTags extends Message {}

class TagsLoaded extends Message {
  final List<String> tags;

  TagsLoaded(this.tags);
}

class TagSelected extends Message {
  final String tag;
  final bool isSelected;

  TagSelected(this.tag, this.isSelected);
}

class ClearTagFilters extends Message {}

class EditImage extends Message {
  final SavedImage image;

  EditImage(this.image);
}

class ShowDeleteConfirmation extends Message {
  final SavedImage image;

  ShowDeleteConfirmation(this.image);
}
