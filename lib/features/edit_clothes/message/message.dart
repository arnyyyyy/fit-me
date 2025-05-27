sealed class EditClothesMessage {}

class EditClothesInit extends EditClothesMessage {}

class EditClothesUpdateName extends EditClothesMessage {
  final String name;

  EditClothesUpdateName(this.name);
}

class EditClothesUpdateDescription extends EditClothesMessage {
  final String description;

  EditClothesUpdateDescription(this.description);
}

class EditClothesAddTag extends EditClothesMessage {
  final String tag;

  EditClothesAddTag(this.tag);
}

class EditClothesRemoveTag extends EditClothesMessage {
  final String tag;

  EditClothesRemoveTag(this.tag);
}

class EditClothesSave extends EditClothesMessage {}

class EditClothesCancel extends EditClothesMessage {}

class EditClothesCompleted extends EditClothesMessage {
  final bool success;

  EditClothesCompleted({required this.success});
}
