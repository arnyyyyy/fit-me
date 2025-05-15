import 'package:flutter/material.dart';

class CalendarEventDay {
  final DateTime date;
  final bool hasEvent;

  const CalendarEventDay({
    required this.date,
    this.hasEvent = false,
  });

  CalendarEventDay copyWith({
    DateTime? date,
    bool? hasEvent,
  }) {
    return CalendarEventDay(
      date: date ?? this.date,
      hasEvent: hasEvent ?? this.hasEvent,
    );
  }
}

class CalendarModel {
  final DateTime selectedDate;
  final DateTime displayedMonth;
  final List<CalendarEventDay> events;
  final bool isLoading;
  final String? errorMessage;

  CalendarModel({
    DateTime? selectedDate,
    DateTime? displayedMonth,
    this.events = const [],
    this.isLoading = false,
    this.errorMessage,
  }) : 
    selectedDate = selectedDate ?? DateTime.now(),
    displayedMonth = displayedMonth ?? DateTime.now();

  CalendarModel copyWith({
    DateTime? selectedDate,
    DateTime? displayedMonth,
    List<CalendarEventDay>? events,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CalendarModel(
      selectedDate: selectedDate ?? this.selectedDate,
      displayedMonth: displayedMonth ?? this.displayedMonth,
      events: events ?? this.events,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool hasEventOnDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return events.any((event) => 
      event.date.year == normalizedDate.year && 
      event.date.month == normalizedDate.month && 
      event.date.day == normalizedDate.day && 
      event.hasEvent);
  }
}
