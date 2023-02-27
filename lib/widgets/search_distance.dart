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

class MySearchDistance extends ConsumerStatefulWidget {
  MySearchDistance({Key? key, this.searchDistanceFrom}) : super(key: key);
  int? searchDistanceFrom;

  @override
  ConsumerState<MySearchDistance> createState() => _MySearchDistance();
}

class _MySearchDistance extends ConsumerState<MySearchDistance> {
  // Set up variable for cost range, taken from https://api.flutter.dev/flutter/material/RangeSlider-class.html
  double _currentSearchDistanceValue = 1;
  int? _initialSearchDistanceValue;
  bool newSearchDistanceToggle = false;

  @override
  Widget build(BuildContext context) {
    if(widget.searchDistanceFrom !=null && newSearchDistanceToggle == false) {
      _initialSearchDistanceValue = widget.searchDistanceFrom;
      _currentSearchDistanceValue = widget.searchDistanceFrom!.toDouble();
    } else {
      _initialSearchDistanceValue = null;
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
            "<1km",
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
              value: _initialSearchDistanceValue == null ? _currentSearchDistanceValue : _initialSearchDistanceValue!.toDouble(),
              min: 1,
              max: 200,
              divisions: 50,
              label: "${_currentSearchDistanceValue.round().toString()} km",
              onChanged: (value) {
                setState(() {
                  newSearchDistanceToggle = true;
                  _currentSearchDistanceValue = value;
                  ref.read(projectDistanceFromProvider.notifier).state =
                      _currentSearchDistanceValue;
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
            ">200km",
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
