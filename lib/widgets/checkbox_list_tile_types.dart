import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spruuk/providers/project_provider.dart';

class MyCheckBoxListTileTypes extends ConsumerStatefulWidget {
  MyCheckBoxListTileTypes({Key? key, required this.listText, this.textStyle})
      : super(key: key);
  String? listText;
  TextStyle? textStyle;

  @override
  ConsumerState<MyCheckBoxListTileTypes> createState() =>
      _MyCheckBoxListTileTypes();
}

class _MyCheckBoxListTileTypes extends ConsumerState<MyCheckBoxListTileTypes> {
  bool isBoxChecked = true;
  List<String?>? typesList = [
    "New Build",
    "Renovation",
    "Commercial",
    "Landscaping",
    "Interiors"
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> getTypesList() async {
    typesList = ref.watch(projectTypesProvider);
  }

  Future<void> addTypeToTypes(String type) async {
    bool? alreadyType = typesList?.any((_type) => _type == widget.listText);

    if (alreadyType != null && !alreadyType) {
      await getTypesList();
      typesList?.add(widget.listText);
      ref.read(projectTypesProvider.notifier).state = typesList;
    }
  }

  Future<void> removeTypeToTypes(String type) async {
    bool? alreadyType = typesList?.any((_type) => _type == widget.listText);

    if (alreadyType != null && alreadyType) {
      await getTypesList();
      typesList?.remove(widget.listText);
      ref.read(projectTypesProvider.notifier).state = typesList;
    }
  }

  void updateTypesList(String type, bool change) async {
    //await getTypesList();
    if (change) {
      await addTypeToTypes(type);
      print("this is add typesList $typesList");
    } else {
      await removeTypeToTypes(type);
      print("this is remove typesList $typesList");
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
            updateTypesList(widget.listText!, value!);

            setState(() {
              isBoxChecked = value!;
            });
          },
        ));
  }
}
