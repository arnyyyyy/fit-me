import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../core/common/base_runtime.dart';
import '../model/model.dart';
import '../message/message.dart';
import '../update/update.dart';
import '../model/saved_image.dart';

final modelProvider =
    StateProvider<ClothesModel>((ref) => const ClothesModel());

typedef EffectHandler = void Function(Effect effect);

class Runtime extends BaseRuntime<Message> {
  final WidgetRef ref;
  final BuildContext context;

  Runtime(this.context, this.ref);

  void dispatch(Message message) {
    final currentModel = ref.read(modelProvider);
    final result = update(currentModel, message);

    if (message is RemoveImage) {
      _handlePhysicalDelete(message.image).then((_) {
        loadImages();
      });
    }

    if (result.model != currentModel) {
      ref.read(modelProvider.notifier).state = result.model;
    }

    if (result.effects != null) {
      for (final effect in result.effects!) {
        _handleEffect(effect);
      }
    }
  }

  // TODO: decompose
  void _handleEffect(Effect effect) {
    final runtime = Runtime(context, ref);

    if (effect is ConfirmDeleteEffect) {
      final localizations = AppLocalizations.of(context);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(localizations.deleteItem),
          content: Text(localizations.deleteItemConfirmation),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(localizations.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                runtime.dispatch(RemoveImage(effect.item));
              },
              child: Text(localizations.delete),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
          ],
        ),
      );
    } else if (effect is NavigationEffect) {
      final destination = effect.destination;

      final typeName = destination.runtimeType.toString();
      if (typeName == 'EditClothesScreen') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => destination),
        ).then((result) {
          if (result == true) {
            runtime.loadImages();
          }
        });
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => destination),
        );
      }
    }
  }

  Future<void> _handlePhysicalDelete(SavedImage image) async {
    await image.delete();
  }

  Future<void> loadImages() async {
    dispatch(LoadImages());
    try {
      final box = await Hive.openBox<SavedImage>('imagesBox');
      final images = box.values.toList();
      dispatch(ImagesLoaded(images));
    } catch (e) {
      dispatch(ImagesLoadError(e.toString()));
    }
  }

  Future<void> loadTags() async {
    dispatch(LoadAvailableTags());
  }
}
