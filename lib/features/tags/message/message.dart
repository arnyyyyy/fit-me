import 'package:flutter/material.dart';

@immutable
abstract class TagsMessage {}

class LoadTags extends TagsMessage {}

class TagsLoaded extends TagsMessage {
  final List<String> tags;

  TagsLoaded(this.tags);
}

class TagsLoadError extends TagsMessage {
  final String message;

  TagsLoadError(this.message);
}

class AddTag extends TagsMessage {
  final String tag;

  AddTag(this.tag);
}

class RemoveTag extends TagsMessage {
  final String tag;

  RemoveTag(this.tag);
}

class ClearTagInput extends TagsMessage {}

class SetInitialTags extends TagsMessage {
  final List<String> tags;

  SetInitialTags(this.tags);
}

class TagsChanged extends TagsMessage {
  final List<String> tags;

  TagsChanged(this.tags);
}
