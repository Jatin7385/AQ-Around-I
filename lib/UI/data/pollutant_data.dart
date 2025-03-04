import 'package:flutter/material.dart';
import 'package:fitness_dashboard_ui/UI/model/pollutant_model.dart';

class PollutantData {
  final List<PollutantModel> pollutants = [
    PollutantModel(
      name: 'PM2.5', 
      value: 35.6, 
      unit: 'µg/m³', 
      color: Colors.red.shade300
    ),
    PollutantModel(
      name: 'PM10', 
      value: 50.2, 
      unit: 'µg/m³', 
      color: Colors.orange.shade300
    ),
    PollutantModel(
      name: 'NO2', 
      value: 25.4, 
      unit: 'ppb', 
      color: Colors.blue.shade300
    ),
    PollutantModel(
      name: 'CO', 
      value: 2.3, 
      unit: 'ppm', 
      color: Colors.green.shade300
    ),
    PollutantModel(
      name: 'SO2', 
      value: 10.1, 
      unit: 'ppb', 
      color: Colors.purple.shade300
    ),
    PollutantModel(
      name: 'O3', 
      value: 45.7, 
      unit: 'ppb', 
      color: Colors.yellow.shade300
    ),
    PollutantModel(
      name: 'Lead', 
      value: 0.15, 
      unit: 'µg/m³', 
      color: Colors.brown.shade300
    ),
    PollutantModel(
      name: 'NH3', 
      value: 20.5, 
      unit: 'ppb', 
      color: Colors.teal.shade300
    ),
    PollutantModel(
      name: 'Benzene', 
      value: 5.2, 
      unit: 'µg/m³', 
      color: Colors.indigo.shade300
    ),
  ];
}