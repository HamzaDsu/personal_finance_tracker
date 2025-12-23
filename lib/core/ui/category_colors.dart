import 'package:flutter/material.dart';

class CategoryColors {
  CategoryColors._();

  static const List<Color> palette = [
    Colors.teal,
    Colors.purple,
    Colors.orange,
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.indigo,
    Colors.pink,
    Colors.amber,
    Colors.cyan,
  ];

  static Color forCategory(String category) {
    final idx = category.hashCode.abs() % palette.length;
    return palette[idx];
  }
}
