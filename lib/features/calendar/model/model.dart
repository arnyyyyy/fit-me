import 'package:hive/hive.dart';

import '../../collages/model/saved_collage.dart';

part 'model.g.dart';

@HiveType(typeId: 3)
class CalendarEventDay extends HiveObject {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final List<SavedCollage?> collages;

  static const int maxCollages = 3;

  CalendarEventDay({
    required this.date,
    this.collages = const [],
  });

  CalendarEventDay copyWith({
    DateTime? date,
    List<SavedCollage?>? collages,
  }) {
    return CalendarEventDay(
      date: date ?? this.date,
      collages: collages ?? List.from(this.collages),
    );
  }

  CalendarEventDay addCollage(SavedCollage collage) {
    final List<SavedCollage?> updatedCollages;

    if (collages.isEmpty) {
      updatedCollages = List<SavedCollage?>.filled(maxCollages, null);
      updatedCollages[0] = collage; // Добавляем новый коллаж в первую позицию
    } else if (collages.length < maxCollages) {
      updatedCollages = List<SavedCollage?>.filled(maxCollages, null);
      for (int i = 0; i < collages.length; i++) {
        updatedCollages[i] = collages[i];
      }
      int emptyIndex = updatedCollages.indexWhere((c) => c == null);
      if (emptyIndex >= 0) {
        updatedCollages[emptyIndex] = collage;
      } else {
        for (int i = collages.length; i < maxCollages; i++) {
          if (updatedCollages[i] == null) {
            updatedCollages[i] = collage;
            break;
          }
        }
      }
    } else {
      updatedCollages = List<SavedCollage?>.from(collages);
      int emptyIndex = updatedCollages.indexWhere((c) => c == null);
      if (emptyIndex >= 0) {
        updatedCollages[emptyIndex] = collage;
      }
    }

    return copyWith(collages: updatedCollages);
  }

  CalendarEventDay removeCollage(int index) {
    if (index < 0 || index >= collages.length) {
      return this;
    }

    final updatedCollages = List<SavedCollage?>.from(collages);
    updatedCollages[index] = null;

    return copyWith(collages: updatedCollages);
  }

  bool get hasAnyCollage {
    return collages.any((collage) => collage != null);
  }

  int get collageCount {
    return collages.where((collage) => collage != null).length;
  }

  List<String> get collageKeys {
    return collages
        .where((collage) => collage != null)
        .map((collage) => collage!.key.toString())
        .toList();
  }
}

class CalendarModel {
  final DateTime selectedDate;
  final DateTime displayedMonth;
  final List<CalendarEventDay> events;
  final bool isLoading;
  final String? errorMessage;
  final List<SavedCollage>? availableCollages;
  final bool isSelectingCollage;

  CalendarModel({
    DateTime? selectedDate,
    DateTime? displayedMonth,
    this.events = const [],
    this.isLoading = false,
    this.errorMessage,
    this.availableCollages,
    this.isSelectingCollage = false,
  })  : selectedDate = selectedDate ?? DateTime.now(),
        displayedMonth = displayedMonth ?? DateTime.now();

  CalendarModel copyWith({
    DateTime? selectedDate,
    DateTime? displayedMonth,
    List<CalendarEventDay>? events,
    bool? isLoading,
    String? errorMessage,
    List<SavedCollage>? availableCollages,
    bool? isSelectingCollage,
  }) {
    return CalendarModel(
      selectedDate: selectedDate ?? this.selectedDate,
      displayedMonth: displayedMonth ?? this.displayedMonth,
      events: events ?? this.events,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      availableCollages: availableCollages ?? this.availableCollages,
      isSelectingCollage: isSelectingCollage ?? this.isSelectingCollage,
    );
  }

  bool hasEventOnDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);

    final eventIndex = events.indexWhere((event) =>
        event.date.year == normalizedDate.year &&
        event.date.month == normalizedDate.month &&
        event.date.day == normalizedDate.day);

    if (eventIndex >= 0) {
      return events[eventIndex].hasAnyCollage;
    }

    return false;
  }

  CalendarEventDay? getEventByDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    try {
      return events.firstWhere(
        (event) =>
            event.date.year == normalizedDate.year &&
            event.date.month == normalizedDate.month &&
            event.date.day == normalizedDate.day,
      );
    } catch (e) {
      return CalendarEventDay(
        date: normalizedDate,
        collages:
            List<SavedCollage?>.filled(CalendarEventDay.maxCollages, null),
      );
    }
  }
}
