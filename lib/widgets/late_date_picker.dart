import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spruuk/providers/project_provider.dart';

class MyLateDatePicker extends ConsumerStatefulWidget {
  MyLateDatePicker(
      {Key? key,
      this.completionDay,
      this.completionMonth,
      this.completionYear,
      this.completionDayLate,
      this.completionMonthLate,
      this.completionYearLate})
      : super(key: key);
  int? completionDay;
  int? completionMonth;
  int? completionYear;
  int? completionDayLate;
  int? completionMonthLate;
  int? completionYearLate;

  @override
  ConsumerState<MyLateDatePicker> createState() => _MyLateDatePicker();
}

class _MyLateDatePicker extends ConsumerState<MyLateDatePicker> {
  DateTime? initialDate;
  DateTime? initialDateLate;
  bool newDateToggle = false;

  // Set up variable for completion date, taken from https://github.com/theideasaler/calendar_date_picker2/blob/main/example/lib/main.dart
  List<DateTime?> _rangeDatePickerValueWithDefaultValue = [
    DateTime.now().subtract(const Duration(days: 1)),
    DateTime.now(),
  ];

  // Set up for getting completion date text
  String _getValueText(
    CalendarDatePicker2Type datePickerType,
    List<DateTime?> values,
  ) {
    var valueText = (values.isNotEmpty ? values[0] : null)
        .toString()
        .replaceAll('00:00:00.000', '');

    if (datePickerType == CalendarDatePicker2Type.multi) {
      valueText = values.isNotEmpty
          ? values
              .map((v) => v.toString().replaceAll('00:00:00.000', ''))
              .join(', ')
          : 'null';
    } else if (datePickerType == CalendarDatePicker2Type.range) {
      if (values.isNotEmpty) {
        final startDate = values[0].toString().replaceAll('00:00:00.000', '');
        final endDate = values.length > 1
            ? values[1].toString().replaceAll('00:00:00.000', '')
            : 'null';
        valueText = '$startDate to $endDate';
      } else {
        return 'null';
      }
    }

    return valueText;
  }

  // Date picker widget, taken from https://pub.dev/packages/calendar_date_picker2
  Widget _buildDefaultRangeDatePickerWithValue() {
    if (widget.completionDay != null &&
        widget.completionMonth != null &&
        widget.completionYear != null &&
        newDateToggle == false) {
      initialDate = DateTime(widget.completionYear!, widget.completionMonth!,
          widget.completionDay!);
    } else {
      initialDate = null;
    }
    if (widget.completionDayLate != null &&
        widget.completionMonthLate != null &&
        widget.completionYearLate != null &&
        newDateToggle == false) {
      initialDateLate = DateTime(widget.completionYearLate!,
          widget.completionMonthLate!, widget.completionDayLate!);
    } else {
      initialDateLate = null;
    }
    final config = CalendarDatePicker2Config(
      calendarType: CalendarDatePicker2Type.range,
      selectedDayHighlightColor: Colors.amber[900],
      weekdayLabels: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
      weekdayLabelTextStyle: const TextStyle(
        color: Colors.black87,
        fontWeight: FontWeight.bold,
      ),
      firstDayOfWeek: 1,
      controlsHeight: 50,
      controlsTextStyle: const TextStyle(
        color: Colors.black,
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
      dayTextStyle: const TextStyle(
        color: Colors.amber,
        fontWeight: FontWeight.bold,
      ),
      disabledDayTextStyle: const TextStyle(
        color: Colors.grey,
      ),
      selectableDayPredicate: (day) => day
          .difference(DateTime.now().subtract(const Duration(days: 1)))
          .isNegative,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 5),
        //const Text('Single Date Picker (With default value)'),
        CalendarDatePicker2(
          config: config,
          initialValue: initialDate != null && initialDateLate != null
              ? <DateTime?>[initialDate, initialDateLate]
              : _rangeDatePickerValueWithDefaultValue,
          onValueChanged: (values) => setState(() {
            newDateToggle =
                true; // used to shift date if new date marker selected.
            _rangeDatePickerValueWithDefaultValue = values;
            print(
                "this is rangeDatePickerValueWithDefaultValue $_rangeDatePickerValueWithDefaultValue");
            if (_rangeDatePickerValueWithDefaultValue.length > 1) {
              ref.read(projectLatestDateProvider.notifier).state =
                  _rangeDatePickerValueWithDefaultValue;
            }
          }),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenDimensions = MediaQuery.of(context).size;
    return Center(
      child: SizedBox(
        width: screenDimensions.width,
        child: Container(
            height: 355,
            width: 400,
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(25)),
            child: _buildDefaultRangeDatePickerWithValue()),
      ),
    );
  }
}
