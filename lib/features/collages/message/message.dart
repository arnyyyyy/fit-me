import 'package:fit_me/core/common/base_message.dart';

import '../model/saved_collage.dart';

abstract class Message extends BaseMessage {}

class LoadCollages extends Message {}

class CollagesLoaded extends Message {
  final List<SavedCollage> collages;

  CollagesLoaded(this.collages);
}

class CollagesLoadError extends Message {
  final String message;

  CollagesLoadError(this.message);
}

class ToggleSearch extends Message {
  final bool isSearching;

  ToggleSearch(this.isSearching);
}

class SearchQueryChanged extends Message {
  final String query;

  SearchQueryChanged(this.query);
}

class AddCollage extends Message {
  final SavedCollage collage;

  AddCollage(this.collage);
}

class RemoveCollage extends Message {
  final SavedCollage collage;

  RemoveCollage(this.collage);
}

class NavigateToCreateCollage extends Message {}

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

class EditCollage extends Message {
  final SavedCollage collage;

  EditCollage(this.collage);
}

class ShowDeleteConfirmation extends Message {
  final SavedCollage collage;

  ShowDeleteConfirmation(this.collage);
}
