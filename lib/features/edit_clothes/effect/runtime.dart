import 'package:fit_me/features/edit_clothes/message/message.dart';
import 'package:fit_me/features/edit_clothes/update/update.dart';
import 'package:flutter/material.dart';

class EditClothesRuntime {
  final BuildContext context;
  final Function(EditClothesMessage) onMessage;

  EditClothesRuntime({
    required this.context,
    required this.onMessage,
  });

  Future<void> runEffect(Effect effect) async {
    final message = await effect();
    if (message is EditClothesCancel) {
      Navigator.of(context).pop();
      return;
    }
    
    if (message is EditClothesCompleted && message.success) {
      Navigator.of(context).pop(true);
      return;
    }
    
    onMessage(message);
  }
}