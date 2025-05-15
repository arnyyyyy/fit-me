import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../model/model.dart';

class CalendarWidget extends StatelessWidget {
  final CalendarModel model;
  final Function(DateTime) onDaySelected;
  final Function(DateTime) onPageChanged;
  final Function(DateTime) onDayTapped;

  const CalendarWidget({
    super.key,
    required this.model,
    required this.onDaySelected,
    required this.onPageChanged,
    required this.onDayTapped,
  });

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context).localeName;

    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: model.displayedMonth,
      selectedDayPredicate: (day) {
        return isSameDay(model.selectedDate, day);
      },
      calendarFormat: CalendarFormat.month,
      availableCalendarFormats: const {
        CalendarFormat.month: 'Месяц',
      },
      onDaySelected: (selectedDay, focusedDay) {
        onDaySelected(selectedDay);
      },
      onPageChanged: (focusedDay) {
        onPageChanged(focusedDay);
      },
      onDayLongPressed: (selectedDay, focusedDay) {
        onDayTapped(selectedDay);
      },
      locale: locale,
      headerStyle: HeaderStyle(
        titleCentered: true,
        formatButtonVisible: false,
        titleTextStyle: AppTextStyles.appBarTitle.copyWith(
          fontSize: 18,
        ),
        leftChevronIcon: const Icon(
          Icons.chevron_left,
          color: AppColors.primary,
        ),
        rightChevronIcon: const Icon(
          Icons.chevron_right,
          color: AppColors.primary,
        ),
      ),
      calendarStyle: CalendarStyle(
        outsideDaysVisible: true,
        weekendTextStyle: const TextStyle(color: Colors.red),
        holidayTextStyle: const TextStyle(color: Colors.red),
        todayDecoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        selectedDecoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        markerDecoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        markersMaxCount: 1,
        cellMargin: const EdgeInsets.all(4),
      ),
      eventLoader: (day) {
        return model.hasEventOnDate(day) ? [day] : [];
      },
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, date, events) {
          if (events.isEmpty) return null;
          
          return Positioned(
            bottom: 1,
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
              ),
            ),
          );
        },
      ),
    );
  }
}
