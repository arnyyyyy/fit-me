import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/common/base_runtime.dart';
import '../../../core/repositories/hive_repository.dart';
import '../../collages/model/saved_collage.dart';
import '../../collages/view/main_collages_screen.dart';
import '../../collages/view/view_collage_screen.dart';
import '../model/model.dart';
import '../message/message.dart';
import '../update/update.dart';

final calendarModelProvider = StateProvider<CalendarModel>(
  (ref) => CalendarModel(),
);

const String calendarEventsBoxName = 'calendarEventsBox';

class CalendarRuntime extends BaseRuntime<CalendarMessage> {
  final WidgetRef ref;
  final BuildContext context;
  late final HiveRepository _repository;

  CalendarRuntime(this.context, this.ref) {
    _repository = HiveRepository();
  }

  @override
  void dispatch(CalendarMessage message) {
    final currentModel = ref.read(calendarModelProvider);
    final result = update(currentModel, message);

    if (result.model != currentModel) {
      ref.read(calendarModelProvider.notifier).state = result.model;
    }

    if (result.effects != null) {
      for (final effect in result.effects!) {
        _handleEffect(effect);
      }
    }
  }

  void _handleEffect(CalendarEffect effect) {
    if (effect is SnackBarEffect) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(effect.message)),
      );
    } else if (effect is LocalizableSnackBarEffect) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(effect.getLocalizedMessage(context))),
      );
    }
  }

  Future<void> loadCalendarEvents() async {
    try {
      dispatch(LoadCalendarEvents());

      final events = await _loadEventsFromStorage();
      dispatch(CalendarEventsLoaded(events));

      await loadAvailableCollages();
    } catch (e) {
      dispatch(CalendarEventsLoadError(e.toString()));
    }
  }

  Future<List<CalendarEventDay>> _loadEventsFromStorage() async {
    try {
      return await _repository.getAllCalendarEvents();
    } catch (e) {
      throw Exception('Ошибка загрузки событий: $e');
    }
  }

  Future<void> saveCalendarEvents(List<CalendarEventDay> events) async {
    try {
      await _saveEventsToStorage(events);
    } catch (e) {
      dispatch(CalendarEventsLoadError('Ошибка сохранения событий: $e'));
    }
  }

  Future<void> _saveEventsToStorage(List<CalendarEventDay> events) async {
    try {
      await _repository.updateCalendarEvents(events);
    } catch (e) {
      throw Exception('Ошибка сохранения событий: $e');
    }
  }

  Future<void> toggleEvent(DateTime date) async {
    final model = ref.read(calendarModelProvider);
    final normalizedDate = DateTime(date.year, date.month, date.day);

    final hasEvent = model.hasEventOnDate(normalizedDate);

    if (hasEvent) {
      dispatch(RemoveCalendarEvent(normalizedDate));
      await saveCalendarEvents(ref.read(calendarModelProvider).events);
    } else {
      dispatch(SelectCalendarDate(normalizedDate));
      await openCollageSelectionScreen();
    }
  }

  Future<void> loadAvailableCollages() async {
    try {
      final collages = await _repository.getAllCollages();
      dispatch(AvailableCollagesLoaded(collages));
    } catch (e) {
      dispatch(CalendarEventsLoadError('Ошибка загрузки коллажей: $e'));
    }
  }

  Future<void> addCollageToDate(DateTime date, SavedCollage collage) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);

    dispatch(AddCollageToDate(normalizedDate, collage));

    await saveCalendarEvents(ref.read(calendarModelProvider).events);

    dispatch(SelectCalendarDate(normalizedDate));
  }

  Future<void> openCollageSelectionScreen() async {
    final result = await Navigator.push<SavedCollage>(
      context,
      MaterialPageRoute(
        builder: (context) => const CollagesScreen(
          selectionMode: true,
          customTitle: 'Выберите коллаж',
        ),
      ),
    );

    if (result != null) {
      final model = ref.read(calendarModelProvider);
      await addCollageToDate(model.selectedDate, result);
    }
    dispatch(ToggleCollageSelection(false));
  }

  Future<void> removeCollageFromDate(DateTime date, int collageIndex) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);

    dispatch(RemoveCollageFromDate(normalizedDate, collageIndex));
    await saveCalendarEvents(ref.read(calendarModelProvider).events);
  }

  Future<void> openCollage(SavedCollage collage) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewCollageScreen(collage: collage),
      ),
    );
  }
}
