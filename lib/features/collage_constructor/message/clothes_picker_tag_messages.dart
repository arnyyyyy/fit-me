import 'package:fit_me/core/common/base_message.dart';

abstract class TagMessage extends BaseMessage {}

class TagSelected extends TagMessage {
  final String tag;
  final bool isSelected;

  TagSelected(this.tag, this.isSelected);
}

class ClearTagFilters extends TagMessage {}

class LoadAvailableTags extends TagMessage {}

class SearchQueryChanged extends TagMessage {
  final String query;

  SearchQueryChanged(this.query);
}

class ToggleSearch extends TagMessage {
  final bool isSearching;

  ToggleSearch(this.isSearching);
}

class ToggleTagFilter extends TagMessage {
  final bool isVisible;

  ToggleTagFilter(this.isVisible);
}
