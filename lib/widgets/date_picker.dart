import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spruuk/providers/project_provider.dart';

class MyDatePicker extends ConsumerStatefulWidget {
  MyDatePicker(
      {Key? key, this.completionDay, this.completionMonth, this.completionYear})
      : super(key: key);
  int? completionDay;
  int? completionMonth;
  int? completionYear;

  @override
  ConsumerState<MyDatePicker> createState() => _MyDatePicker();
}

class _MyDatePicker extends ConsumerState<MyDatePicker> {
  DateTime? initialDate;
  bool newDateToggle = false;

  // Set up variable for completion date, taken from https://github.com/theideasaler/calendar_date_picker2/blob/main/example/lib/main.dart
  List<DateTime?> _singleDatePickerValueWithDefaultValue = [
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
  Widget _buildDefaultSingleDatePickerWithValue() {
    if (widget.completionDay != null &&
        widget.completionMonth != null &&
        widget.completionYear != null &&
        newDateToggle == false) {
      initialDate = DateTime(widget.completionYear!, widget.completionMonth!,
          widget.completionDay!);
    } else {
      initialDate = null;
    }
    final config = CalendarDatePicker2Config(
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
          initialValue: initialDate != null
              ? <DateTime?>[initialDate]
              : _singleDatePickerValueWithDefaultValue,
          onValueChanged: (values) => setState(() {
            newDateToggle =
                true; // used to shift date if new date marker selected.
            _singleDatePickerValueWithDefaultValue = values;
            ref.read(projectDateProvider.notifier).state =
                _singleDatePickerValueWithDefaultValue;
          }),
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Selection:  '),
            const SizedBox(width: 10),
            Text(
              _getValueText(
                config.calendarType,
                _singleDatePickerValueWithDefaultValue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 25),
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
            height: 405,
            width: 400,
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(25)),
            child: _buildDefaultSingleDatePickerWithValue()),
      ),
    );
  }
}
