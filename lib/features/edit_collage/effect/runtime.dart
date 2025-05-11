import 'package:fit_me/features/edit_collage/message/message.dart';
import 'package:fit_me/features/edit_collage/update/update.dart';
import 'package:flutter/material.dart';

class EditCollageRuntime {
  final BuildContext context;
  final Function(EditCollageMessage) onMessage;

  EditCollageRuntime({
    required this.context,
    required this.onMessage,
  });

  Future<void> runEffect(Effect effect) async {
    final message = await effect();
    if (message is EditCollageCancel) {
      Navigator.of(context).pop();
      return;
    }

    if (message is EditCollageCompleted && message.success) {
      Navigator.of(context).pop(true);
      return;
    }

    onMessage(message);
  }
}
