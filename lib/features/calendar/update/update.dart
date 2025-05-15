import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../model/model.dart';
import '../message/message.dart';

abstract class CalendarEffect {}

class SnackBarEffect extends CalendarEffect {
  final String message;

  SnackBarEffect(this.message);
}

class LocalizableSnackBarEffect extends CalendarEffect {
  final String messageKey;
  final Map<String, String>? args;

  LocalizableSnackBarEffect(this.messageKey, [this.args]);

  String getLocalizedMessage(BuildContext context) {
    final loc = AppLocalizations.of(context);

    switch (messageKey) {
      case 'eventsLoadError':
        return loc.error(args?['message'] ?? '');
      case 'eventAdded':
        return loc.eventAdded;
      case 'eventRemoved':
        return loc.eventRemoved;
      default:
        return messageKey;
    }
  }
}

class UpdateResult {
  final CalendarModel model;
  final Set<CalendarEffect>? effects;

  UpdateResult(this.model, [this.effects]);
}

UpdateResult update(CalendarModel model, CalendarMessage message) {
  switch (message) {
    case InitCalendar():
      return UpdateResult(model.copyWith(isLoading: true));

    case LoadCalendarEvents():
      return UpdateResult(model.copyWith(isLoading: true));

    case CalendarEventsLoaded(:final events):
      return UpdateResult(model.copyWith(
        isLoading: false,
        events: events,
      ));

    case CalendarEventsLoadError(:final message):
      return UpdateResult(
        model.copyWith(
          isLoading: false,
          errorMessage: message,
        ),
        {
          LocalizableSnackBarEffect('eventsLoadError', {'message': message})
        },
      );

    case SelectCalendarDate(:final date):
      return UpdateResult(model.copyWith(selectedDate: date));

    case ChangeCalendarMonth(:final month):
      return UpdateResult(model.copyWith(displayedMonth: month));

    case ToggleCalendarEvent(:final date):
      final normalizedDate = DateTime(date.year, date.month, date.day);
      final hasEvent = model.hasEventOnDate(normalizedDate);

      if (hasEvent) {
        return _removeEvent(model, normalizedDate);
      } else {
        return _addEvent(model, normalizedDate);
      }

    case AddCalendarEvent(:final date):
      return _addEvent(model, date);

    case RemoveCalendarEvent(:final date):
      return _removeEvent(model, date);
  }

  return UpdateResult(model);
}

UpdateResult _addEvent(CalendarModel model, DateTime date) {
  final normalizedDate = DateTime(date.year, date.month, date.day);
  final index = model.events.indexWhere((e) =>
      e.date.year == normalizedDate.year &&
      e.date.month == normalizedDate.month &&
      e.date.day == normalizedDate.day);

  List<CalendarEventDay> updatedEvents;

  if (index >= 0) {
    updatedEvents = List<CalendarEventDay>.from(model.events);
    updatedEvents[index] = model.events[index].copyWith(hasEvent: true);
  } else {
    updatedEvents = List<CalendarEventDay>.from(model.events)
      ..add(CalendarEventDay(date: normalizedDate, hasEvent: true));
  }

  return UpdateResult(
    model.copyWith(events: updatedEvents),
    {LocalizableSnackBarEffect('eventAdded')},
  );
}

UpdateResult _removeEvent(CalendarModel model, DateTime date) {
  final normalizedDate = DateTime(date.year, date.month, date.day);
  final index = model.events.indexWhere((e) =>
      e.date.year == normalizedDate.year &&
      e.date.month == normalizedDate.month &&
      e.date.day == normalizedDate.day);

  if (index < 0) {
    return UpdateResult(model);
  }

  List<CalendarEventDay> updatedEvents =
      List<CalendarEventDay>.from(model.events);
  updatedEvents[index] = model.events[index].copyWith(hasEvent: false);

  return UpdateResult(
    model.copyWith(events: updatedEvents),
    {LocalizableSnackBarEffect('eventRemoved')},
  );
}
