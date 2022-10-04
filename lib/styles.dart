import 'package:flutter/material.dart';

class Style {
  Style({required this.text});

  final StyleText text;
}

class StyleText {
  StyleText({required this.title});

  final TextStyle title;
}

final styles = Style(
  text: StyleText(
    title: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
);
