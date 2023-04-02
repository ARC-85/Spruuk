import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spruuk/providers/project_provider.dart';

class MyCheckBoxListTileStyles extends ConsumerStatefulWidget {
  MyCheckBoxListTileStyles({Key? key, required this.listText, this.textStyle})
      : super(key: key);
  String? listText;
  TextStyle? textStyle;

  @override
  ConsumerState<MyCheckBoxListTileStyles> createState() =>
      _MyCheckBoxListTileStyles();
}

class _MyCheckBoxListTileStyles
    extends ConsumerState<MyCheckBoxListTileStyles> {
  bool isBoxChecked = true;
  List<String?>? stylesList = [
    "Traditional",
    "Contemporary",
    "Retro",
    "Modern",
    "Minimalist",
    "None"
  ];

  @override
  void didChangeDependencies() {
    stylesList = ref.watch(projectStylesProvider);
    super.didChangeDependencies();
  }

  Future<void> getStylesList() async {
    stylesList = ref.watch(projectStylesProvider);
  }

  Future<void> addStyleToStyles(String style) async {
    bool? alreadyStyle = stylesList?.any((_style) => _style == widget.listText);

    if (alreadyStyle != null && !alreadyStyle) {
      stylesList?.add(widget.listText);
      ref.read(projectStylesProvider.notifier).state = stylesList;
    }
  }

  Future<void> removeStyleToStyles(String style) async {
    bool? alreadyStyle = stylesList?.any((_style) => _style == widget.listText);

    if (alreadyStyle != null && alreadyStyle) {
      stylesList?.remove(widget.listText);
      ref.read(projectStylesProvider.notifier).state = stylesList;
    }
  }

  void updateStylesList(String style, bool change) async {
    if (change) {
      await addStyleToStyles(style);
      print("this is add stylesList $stylesList");
    } else {
      await removeStyleToStyles(style);
      print("this is remove stylesList $stylesList");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 30,
        alignment: Alignment.centerLeft,
        child: CheckboxListTile(
          title: Text(
            widget.listText!,
            textAlign: TextAlign.center,
            style: widget.textStyle,
          ),
          value: isBoxChecked,
          onChanged: (bool? value) {
            updateStylesList(widget.listText!, value!);

            setState(() {
              isBoxChecked = value;
            });
          },
        ));
  }
}
