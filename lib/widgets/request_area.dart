import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';

import 'package:spruuk/providers/request_provider.dart';
import 'package:spruuk/widgets/text_label.dart';

class MyRequestArea extends ConsumerStatefulWidget {
  MyRequestArea({Key? key, this.requestArea}) : super(key: key);
  int? requestArea;

  @override
  ConsumerState<MyRequestArea> createState() => _MyRequestArea();
}

class _MyRequestArea extends ConsumerState<MyRequestArea> {
  // Set up variable for cost range, taken from https://api.flutter.dev/flutter/material/RangeSlider-class.html
  double _currentAreaValue = 0;
  int? _initialAreaValue;
  bool newAreaToggle = false;

  @override
  Widget build(BuildContext context) {
    if(widget.requestArea !=null && newAreaToggle == false) {
      _initialAreaValue = widget.requestArea;
      _currentAreaValue = widget.requestArea!.toDouble();
    } else {
      _initialAreaValue = null;
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
            "Min (<10)",
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
            child: Slider(
              value: _initialAreaValue == null ? _currentAreaValue : _initialAreaValue!.toDouble(),
              max: 500,
              divisions: 10,
              label: "${_currentAreaValue.round().toString()} m.sq",
              onChanged: (value) {
                setState(() {
                  newAreaToggle = true;
                  _currentAreaValue = value;
                  ref.read(requestAreaProvider.notifier).state =
                      _currentAreaValue;
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
            "Max (>500)",
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
