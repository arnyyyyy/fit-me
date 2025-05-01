import 'package:flutter/material.dart';

@immutable
abstract class TagsEffect {}

class TagsUpdatedCallbackEffect extends TagsEffect {
  final List<String> tags;

  TagsUpdatedCallbackEffect(this.tags);
}

class LoadTagsEffect extends TagsEffect {}

class ShowErrorMessageEffect extends TagsEffect {
  final String message;

  ShowErrorMessageEffect(this.message);
}
