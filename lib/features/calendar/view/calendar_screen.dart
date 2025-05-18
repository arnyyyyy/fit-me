import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../effect/runtime.dart';
import '../message/message.dart';
import '../model/model.dart';
import 'calendar_widget.dart';
import 'event_collages_view.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  @override
  void initState() {
    super.initState();
    final runtime = CalendarRuntime(context, ref);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      runtime.dispatch(InitCalendar());
      runtime.loadCalendarEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final model = ref.watch(calendarModelProvider);
    final runtime = CalendarRuntime(context, ref);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(AppLocalizations.of(context).calendar,
            style: AppTextStyles.appBarTitle),
      ),
      body: _buildBody(model, runtime),
    );
  }

  Widget _buildBody(CalendarModel model, CalendarRuntime runtime) {
    if (model.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (model.errorMessage != null) {
      return Center(
        child: Text(
          AppLocalizations.of(context).error(model.errorMessage!),
          style: AppTextStyles.emptyText,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          CalendarWidget(
            model: model,
            onDaySelected: (date) {
              runtime.dispatch(SelectCalendarDate(date));
            },
            onPageChanged: (date) {
              runtime.dispatch(ChangeCalendarMonth(date));
            },
            onDayTapped: (date) {
              runtime.toggleEvent(date);
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _buildSelectedDateInfo(model),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDateInfo(CalendarModel model) {
    final hasEvent = model.hasEventOnDate(model.selectedDate);
    final event = model.getEventByDate(model.selectedDate);
    final runtime = CalendarRuntime(context, ref);

    return Card(
      elevation: 4,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: AppColors.cardBackground,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatDate(model.selectedDate),
                    style: AppTextStyles.title,
                  ),
                  const SizedBox(height: 0),
                  !hasEvent
                      ? Row(
                          children: [
                            const Icon(
                              Icons.event_available,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                AppLocalizations.of(context).noEvent,
                                style: AppTextStyles.body.copyWith(
                                  color: Colors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        )
                      : const SizedBox(height: 0),
                ],
              ),
              Expanded(
                child: hasEvent && event != null
                    ? EventCollagesView(
                        event: event,
                        onRemoveCollage: (index) {
                          runtime.removeCollageFromDate(
                              model.selectedDate, index);
                        },
                        onAddCollage: () {
                          runtime.openCollageSelectionScreen();
                        },
                        onOpenCollage: (collage) {
                          runtime.openCollage(collage);
                        },
                      )
                    : Center(
                        child: ElevatedButton.icon(
                          onPressed: () => runtime.openCollageSelectionScreen(),
                          icon: const Icon(Icons.add_photo_alternate),
                          label: Text(AppLocalizations.of(context).addEvent),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          );
        }),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonthName(date.month, context)} ${date.year}';
  }

  String _getMonthName(int month, BuildContext context) {
    final locale = AppLocalizations.of(context);

    switch (month) {
      case 1:
        return locale.january;
      case 2:
        return locale.february;
      case 3:
        return locale.march;
      case 4:
        return locale.april;
      case 5:
        return locale.may;
      case 6:
        return locale.june;
      case 7:
        return locale.july;
      case 8:
        return locale.august;
      case 9:
        return locale.september;
      case 10:
        return locale.october;
      case 11:
        return locale.november;
      case 12:
        return locale.december;
      default:
        return '';
    }
  }
}
