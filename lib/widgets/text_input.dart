import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//Adapted from https://stackoverflow.com/questions/67993074/how-to-pass-a-function-as-a-validator-in-a-textformfield
class CustomTextInput extends ConsumerWidget {
  // Declare your custom vars, including your validator function
  final TextEditingController? textEditingController;
  final String? hintText;
  final bool isTextObscured;
  final IconData icon;
  final String? Function(String?)? validator;

  const CustomTextInput({
    Key? key,
    this.textEditingController,
    required this.hintText,
    required this.isTextObscured,
    required this.icon,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextFormField(
      cursorColor: Colors.white,
      obscureText: isTextObscured,
      controller: textEditingController,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.black45),
        helperStyle: const TextStyle(
          color: Colors.black45,
          fontSize: 18.0,
        ),
        prefixIcon: Icon(icon, color: Colors.blue.shade700, size: 24),
        alignLabelWithHint: true,
        border: InputBorder.none,
      ),
      validator: validator,
    );
  }
}
