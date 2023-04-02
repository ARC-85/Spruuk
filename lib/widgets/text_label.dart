import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyTextLabel extends ConsumerWidget {
  final double? height;
  final double? width;
  final String? textLabel;
  final Color? color;
  final TextStyle? textStyle;

  const MyTextLabel({
    super.key,
    this.color,
    this.height,
    this.width,
    required this.textLabel,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: height,
      width: width,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(25)),
      child: Text(
        textLabel!,
        textAlign: TextAlign.center,
        style: textStyle,
      ),
    );
  }
}
