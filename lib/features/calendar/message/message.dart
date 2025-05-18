import 'package:fit_me/core/common/base_message.dart';
import 'package:fit_me/features/collages/model/saved_collage.dart';

import '../model/model.dart';

abstract class CalendarMessage extends BaseMessage {}

class InitCalendar extends CalendarMessage {}

class LoadCalendarEvents extends CalendarMessage {}

class CalendarEventsLoaded extends CalendarMessage {
  final List<CalendarEventDay> events;

  CalendarEventsLoaded(this.events);
}

class CalendarEventsLoadError extends CalendarMessage {
  final String message;

  CalendarEventsLoadError(this.message);
}

class SelectCalendarDate extends CalendarMessage {
  final DateTime date;

  SelectCalendarDate(this.date);
}

class ChangeCalendarMonth extends CalendarMessage {
  final DateTime month;

  ChangeCalendarMonth(this.month);
}

class ToggleCalendarEvent extends CalendarMessage {
  final DateTime date;

  ToggleCalendarEvent(this.date);
}

class AddCalendarEvent extends CalendarMessage {
  final DateTime date;

  AddCalendarEvent(this.date);
}

class RemoveCalendarEvent extends CalendarMessage {
  final DateTime date;

  RemoveCalendarEvent(this.date);
}

class LoadAvailableCollages extends CalendarMessage {}

class AvailableCollagesLoaded extends CalendarMessage {
  final List<SavedCollage> collages;

  AvailableCollagesLoaded(this.collages);
}

class ToggleCollageSelection extends CalendarMessage {
  final bool isSelecting;

  ToggleCollageSelection(this.isSelecting);
}

class AddCollageToDate extends CalendarMessage {
  final DateTime date;
  final SavedCollage collage;

  AddCollageToDate(this.date, this.collage);
}

class RemoveCollageFromDate extends CalendarMessage {
  final DateTime date;
  final int collageIndex;

  RemoveCollageFromDate(this.date, this.collageIndex);
}
