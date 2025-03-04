import 'package:flutter/material.dart';

class PollutantModel {
  final String name;
  final double value;
  final String unit;
  final Color color;

  const PollutantModel({
    required this.name, 
    required this.value, 
    required this.unit,
    required this.color,
  });
}