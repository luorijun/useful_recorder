import 'package:flutter/material.dart';

class Style {
  Style({
    required this.text,
    required this.color,
  });

  final StyleText text;
  final StyleColor color;
}

class StyleText {
  StyleText({
    required this.title,
    required this.normal,
  });

  final TextStyle title;
  final TextStyle normal;
}

class StyleColor {
  StyleColor({
    required this.surfaceBackgroundText,
    required this.surfaceBackgroundTextWeak,
    required this.primaryBackgroundText,
    required this.primaryBackgroundTextWeak,
    required this.secondaryBackgroundText,
    required this.secondaryBackgroundTextWeak,
  });

  final Color surfaceBackgroundText;
  final Color surfaceBackgroundTextWeak;

  final Color primaryBackgroundText;
  final Color primaryBackgroundTextWeak;

  final Color secondaryBackgroundText;
  final Color secondaryBackgroundTextWeak;
}

// ==============================
// 样式实现
// ==============================

final styles = Style(
  text: StyleText(
    title: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    normal: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
    ),
  ),
  color: StyleColor(
    surfaceBackgroundText: Color(0xff333333),
    surfaceBackgroundTextWeak: Color(0xff999999),
    primaryBackgroundText: Color(0xff333333),
    primaryBackgroundTextWeak: Color(0xff999999),
    secondaryBackgroundText: Color(0xff333333),
    secondaryBackgroundTextWeak: Color(0xff999999),
  ),
);
