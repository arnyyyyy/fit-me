import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../model/model.dart';
import '../message/message.dart';
import '../../collages/model/saved_collage.dart';

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
      case 'collageAdded':
        return loc.collageAddedToEvent;
      case 'collageRemoved':
        return loc.collageRemovedFromEvent;
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
        return _removeAllCollagesFromEvent(model, normalizedDate);
      } else {
        return _toggleCollageSelection(model, true);
      }

    case AddCalendarEvent(:final date):
      return _toggleCollageSelection(model, true);

    case RemoveCalendarEvent(:final date):
      return _removeAllCollagesFromEvent(model, date);
      
    case LoadAvailableCollages():
      return UpdateResult(model.copyWith(isLoading: true));
      
    case AvailableCollagesLoaded(:final collages):
      return UpdateResult(model.copyWith(
        isLoading: false,
        availableCollages: collages,
      ));
      
    case ToggleCollageSelection(:final isSelecting):
      return _toggleCollageSelection(model, isSelecting);
      
    case AddCollageToDate(:final date, :final collage):
      return _addCollageToEvent(model, date, collage);
      
    case RemoveCollageFromDate(:final date, :final collageIndex):
      return _removeCollageFromEvent(model, date, collageIndex);
  }

  return UpdateResult(model);
}

UpdateResult _toggleCollageSelection(CalendarModel model, bool isSelecting) {
  return UpdateResult(model.copyWith(isSelectingCollage: isSelecting));
}

UpdateResult _addCollageToEvent(CalendarModel model, DateTime date, SavedCollage collage) {
  final normalizedDate = DateTime(date.year, date.month, date.day);
  
  final List<CalendarEventDay> updatedEvents = List.from(model.events);
  
  final existingIndex = updatedEvents.indexWhere((e) =>
    e.date.year == normalizedDate.year && 
    e.date.month == normalizedDate.month && 
    e.date.day == normalizedDate.day);
  
  if (existingIndex >= 0) {
    final existingEvent = updatedEvents[existingIndex];
    final updatedEvent = existingEvent.addCollage(collage);
    updatedEvents[existingIndex] = updatedEvent;
  } else {
    final newCollages = List<SavedCollage?>.filled(CalendarEventDay.maxCollages, null);
    newCollages[0] = collage;
    
    final newEvent = CalendarEventDay(
      date: normalizedDate,
      collages: newCollages,
    );
    
    updatedEvents.add(newEvent);
  }
  
  return UpdateResult(
    model.copyWith(
      events: updatedEvents,
      isSelectingCollage: false,
    ),
    {LocalizableSnackBarEffect('collageAdded')},
  );
}

UpdateResult _removeCollageFromEvent(CalendarModel model, DateTime date, int collageIndex) {
  final normalizedDate = DateTime(date.year, date.month, date.day);
  
  final existingIndex = model.events.indexWhere((e) =>
    e.date.year == normalizedDate.year && 
    e.date.month == normalizedDate.month && 
    e.date.day == normalizedDate.day);
  
  if (existingIndex < 0) {
    return UpdateResult(model);
  }
  
  final existingEvent = model.events[existingIndex];
  final updatedEvent = existingEvent.removeCollage(collageIndex);
  
  final List<CalendarEventDay> updatedEvents = List.from(model.events);
  updatedEvents[existingIndex] = updatedEvent;
  
  return UpdateResult(
    model.copyWith(events: updatedEvents),
    {LocalizableSnackBarEffect('collageRemoved')},
  );
}

UpdateResult _removeAllCollagesFromEvent(CalendarModel model, DateTime date) {
  final normalizedDate = DateTime(date.year, date.month, date.day);
  
  final existingIndex = model.events.indexWhere((e) =>
    e.date.year == normalizedDate.year && 
    e.date.month == normalizedDate.month && 
    e.date.day == normalizedDate.day);
  
  if (existingIndex < 0) {
    return UpdateResult(model);
  }
  
  final List<CalendarEventDay> updatedEvents = List.from(model.events);
  
  updatedEvents[existingIndex] = CalendarEventDay(
    date: normalizedDate,
    collages: List.generate(CalendarEventDay.maxCollages, (_) => null),
  );
  
  return UpdateResult(
    model.copyWith(events: updatedEvents),
    {LocalizableSnackBarEffect('eventRemoved')},
  );
}
