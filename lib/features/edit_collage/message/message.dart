sealed class EditCollageMessage {}

class EditCollageInit extends EditCollageMessage {}

class EditCollageUpdateName extends EditCollageMessage {
  final String name;

  EditCollageUpdateName(this.name);
}

class EditCollageAddTag extends EditCollageMessage {
  final String tag;

  EditCollageAddTag(this.tag);
}

class EditCollageRemoveTag extends EditCollageMessage {
  final String tag;

  EditCollageRemoveTag(this.tag);
}

class EditCollageSave extends EditCollageMessage {}

class EditCollageCancel extends EditCollageMessage {}

class EditCollageCompleted extends EditCollageMessage {
  final bool success;

  EditCollageCompleted({required this.success});
}
