import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spruuk/providers/project_provider.dart';

class MyAreaRange extends ConsumerStatefulWidget {
  MyAreaRange({Key? key, this.projectMinArea, this.projectMaxArea})
      : super(key: key);
  int? projectMinArea;
  int? projectMaxArea;

  @override
  ConsumerState<MyAreaRange> createState() => _MyAreaRange();
}

class _MyAreaRange extends ConsumerState<MyAreaRange> {
  // Set up variable for cost range, taken from https://api.flutter.dev/flutter/material/RangeSlider-class.html
  RangeValues? _currentRangeValues = RangeValues(10, 500);
  RangeValues? _initialRangeValues;
  bool newAreaToggle = false;

  @override
  Widget build(BuildContext context) {
    if (widget.projectMinArea != null &&
        widget.projectMaxArea != null &&
        newAreaToggle == false) {
      _initialRangeValues = RangeValues(
          widget.projectMinArea!.toDouble(), widget.projectMaxArea!.toDouble());
      _currentRangeValues = RangeValues(
          widget.projectMinArea!.toDouble(), widget.projectMaxArea!.toDouble());
    } else {
      _initialRangeValues = null;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          height: 20,
          width: 70,
          margin: const EdgeInsets.only(left: 0, right: 0, top: 6, bottom: 6),
          padding: const EdgeInsets.only(left: 0, right: 0, top: 4, bottom: 4),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(25)),
          child: const Text(
            "<10 m.sq",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12.0,
            ),
          ),
        ),
        SliderTheme(
            data: SliderThemeData(
              // taken from https://medium.com/flutter-community/flutter-sliders-demystified-4b3ea65879c
              activeTrackColor: Colors.red[700],
              inactiveTrackColor: Colors.red[100],
              trackShape: const RoundedRectSliderTrackShape(),
              trackHeight: 4.0,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12.0),
              thumbColor: Colors.redAccent,
              overlayColor: Colors.red.withAlpha(32),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 28.0),
              tickMarkShape: const RoundSliderTickMarkShape(),
              activeTickMarkColor: Colors.red[700],
              inactiveTickMarkColor: Colors.red[100],
              valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
              valueIndicatorColor: Colors.redAccent,
              valueIndicatorTextStyle: const TextStyle(
                color: Colors.white,
              ),
            ),
            child: RangeSlider(
              values: _initialRangeValues == null
                  ? _currentRangeValues!
                  : _initialRangeValues!,
              min: 10,
              max: 500,
              divisions: 49,
              labels: RangeLabels(
                "${_currentRangeValues!.start.round().toString()}m.sq",
                "${_currentRangeValues!.end.round().toString()}m.sq",
              ),
              onChanged: (RangeValues values) {
                setState(() {
                  newAreaToggle =
                      true; // used to shift date if new cost selected.
                  _currentRangeValues = values;
                  ref.read(projectAreaRangeProvider.notifier).state =
                      _currentRangeValues;
                });
              },
            )),
        Container(
          height: 20,
          width: 70,
          margin: const EdgeInsets.only(left: 0, right: 0, top: 6, bottom: 6),
          padding: const EdgeInsets.only(left: 0, right: 0, top: 4, bottom: 4),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(25)),
          child: const Text(
            ">500 m.sq",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12.0,
            ),
          ),
        ),
      ],
    );
  }
}
