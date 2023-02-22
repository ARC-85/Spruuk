import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//Adapted from https://stackoverflow.com/questions/67993074/how-to-pass-a-function-as-a-validator-in-a-textformfield
class CustomTextInput extends ConsumerStatefulWidget {

  CustomTextInput({
    Key? key,
    this.textEditingController,
    required this.hintText,
    required this.isTextObscured,
    this.icon,
    this.validator,
    this.initialText,
  }) : super(key: key);


  TextEditingController? textEditingController;
  String? hintText;
  bool isTextObscured;
  IconData? icon;
  String? Function(String?)? validator;
  String? initialText;

  @override
  ConsumerState<CustomTextInput> createState() => _CustomTextInput();
}

class _CustomTextInput extends ConsumerState<CustomTextInput> {

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if(widget.initialText != null) {
      widget.textEditingController?.text = widget.initialText!;
    }

  }

  @override
  Widget build(BuildContext context) {

    return TextFormField(
      cursorColor: Colors.white,
      obscureText: widget.isTextObscured,
      controller: widget.textEditingController,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: const TextStyle(color: Colors.black45),
        helperStyle: const TextStyle(
          color: Colors.black45,
          fontSize: 18.0,
        ),
        prefixIcon: Icon(widget.icon, color: Colors.blue.shade700, size: 24),
        alignLabelWithHint: true,
        border: InputBorder.none,
      ),
      validator: widget.validator,
    );
  }
}
