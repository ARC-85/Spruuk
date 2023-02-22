import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:spruuk/providers/project_provider.dart';
import 'package:spruuk/widgets/text_label.dart';

class MyCostRange extends ConsumerStatefulWidget {
  MyCostRange({Key? key, this.projectMinCost, this.projectMaxCost}) : super(key: key);
  int? projectMinCost;
  int? projectMaxCost;

  @override
  ConsumerState<MyCostRange> createState() => _MyCostRange();
}

class _MyCostRange extends ConsumerState<MyCostRange> {
  // Set up variable for cost range, taken from https://api.flutter.dev/flutter/material/RangeSlider-class.html
  RangeValues? _currentRangeValues = RangeValues(0, 1000000);
  RangeValues? _initialRangeValues;
  bool newCostToggle = false;


  @override
  Widget build(BuildContext context) {
    if(widget.projectMinCost !=null && widget.projectMaxCost != null && newCostToggle == false) {
      _initialRangeValues = RangeValues(widget.projectMinCost!.toDouble(), widget.projectMaxCost!.toDouble());
      _currentRangeValues = RangeValues(widget.projectMinCost!.toDouble(), widget.projectMaxCost!.toDouble());
    } else {
      _initialRangeValues = null;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          height: 20,
          width: 70,
          margin: const EdgeInsets.only(left:0,right:0,top:6, bottom:6),
          padding: const EdgeInsets.only(left:0,right:0,top:4, bottom:4),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(25)),
          child: const Text(
            "Min (<€25K)",
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
              values: _initialRangeValues == null ? _currentRangeValues! : _initialRangeValues!,
              max: 1000000,
              divisions: 40,
              labels: RangeLabels(
                "€${_currentRangeValues!.start.round().toString()}",
                "€${_currentRangeValues!.end.round().toString()}",
              ),
              onChanged: (RangeValues values) {
                setState(() {
                  newCostToggle = true; // used to shift date if new cost selected.
                  _currentRangeValues = values;
                  ref.read(projectCostProvider.notifier).state =
                      _currentRangeValues;
                });
              },
            )),
        Container(
          height: 20,
          width: 70,
          margin: const EdgeInsets.only(left:0,right:0,top:6, bottom:6),
          padding: const EdgeInsets.only(left:0,right:0,top:4, bottom:4),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(25)),
          child: const Text(
            "Max (>€1M)",
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
