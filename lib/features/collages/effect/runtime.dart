import 'package:fit_me/core/common/base_runtime.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../model/model.dart';
import '../message/message.dart';
import '../update/update.dart';
import '../model/saved_collage.dart';

final collagesModelProvider =
    StateProvider<CollagesModel>((ref) => const CollagesModel());

typedef EffectHandler = void Function(Effect effect);

class Runtime extends BaseRuntime<Message> {
  final WidgetRef ref;
  final BuildContext context;

  Runtime(this.context, this.ref);

  @override
  void dispatch(Message message) {
    final currentModel = ref.read(collagesModelProvider);
    final result = update(currentModel, message);

    if (message is RemoveCollage) {
      _handlePhysicalDelete(message.collage).then((_) {
        loadCollages();
      });
    }

    if (result.model != currentModel) {
      ref.read(collagesModelProvider.notifier).state = result.model;
    }

    if (result.effects != null) {
      for (final effect in result.effects!) {
        _handleEffect(effect);
      }
    }
  }

  // TODO: decompose
  void _handleEffect(Effect effect) {
    if (effect is NavigationEffect) {
      final destination = effect.destination;
      if (destination.runtimeType.toString() == 'EditCollageScreen') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => destination),
        ).then((result) {
          if (result == true) {
            loadCollages();
          }
        });
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => destination),
        );
      }
    } else if (effect is ReloadDataEffect) {
      loadCollages();
    } else if (effect is ConfirmDeleteEffect) {
      final localizations = AppLocalizations.of(context);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(localizations.deleteCollage),
          content: Text(localizations.deleteCollageConfirmation),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(localizations.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                dispatch(RemoveCollage(effect.item));
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(localizations.delete),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _handlePhysicalDelete(SavedCollage collage) async {
    await collage.delete();
  }

  Future<void> loadCollages() async {
    try {
      dispatch(LoadCollages());

      final box = await Hive.openBox<SavedCollage>('collagesBox');

      final collages = box.values.toList();
      dispatch(CollagesLoaded(collages));
    } catch (e) {
      dispatch(CollagesLoadError(e.toString()));
    }
  }

  Future<void> loadTags() async {
    dispatch(LoadAvailableTags());
  }
}
