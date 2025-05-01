import '../model/saved_collage.dart';

abstract class Message {}

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

class NavigateToCreateCollage extends Message {}
