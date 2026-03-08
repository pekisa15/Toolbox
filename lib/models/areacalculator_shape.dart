import 'dart:core';

class AreaCalculatorShape {
  final String name;
  final Map<String, String> inputs;
  final Function(dynamic) calculateArea;

  AreaCalculatorShape({required this.name, required this.inputs, required this.calculateArea});
}