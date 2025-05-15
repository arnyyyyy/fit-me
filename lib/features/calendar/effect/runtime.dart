import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../core/common/base_runtime.dart';
import '../model/model.dart';
import '../message/message.dart';
import '../update/update.dart';

final calendarModelProvider = StateProvider<CalendarModel>(
  (ref) => CalendarModel(),
);

class CalendarRuntime extends BaseRuntime<CalendarMessage> {
  final WidgetRef ref;
  final BuildContext context;

  CalendarRuntime(this.context, this.ref);

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
    } catch (e) {
      dispatch(CalendarEventsLoadError(e.toString()));
    }
  }

  Future<List<CalendarEventDay>> _loadEventsFromStorage() async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final now = DateTime.now();
      final currentMonth = DateTime(now.year, now.month, 1);

      return [
        CalendarEventDay(date: now, hasEvent: true),
        CalendarEventDay(
            date: now.add(const Duration(days: 3)), hasEvent: true),
        CalendarEventDay(
            date: now.add(const Duration(days: 7)), hasEvent: true),
      ];
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
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> toggleEvent(DateTime date) async {
    final model = ref.read(calendarModelProvider);
    final normalizedDate = DateTime(date.year, date.month, date.day);

    dispatch(ToggleCalendarEvent(normalizedDate));

    await saveCalendarEvents(ref.read(calendarModelProvider).events);
  }
}
