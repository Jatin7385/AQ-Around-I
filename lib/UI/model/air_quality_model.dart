import 'package:flutter/material.dart';

class AirQualityData {
  final double aqi;
  final String category;
  final String dominantPollutant;
  final Map<String, PollutantData> pollutants;
  final DateTime timestamp;
  final String locationName;

  AirQualityData({
    required this.aqi,
    required this.category,
    required this.dominantPollutant,
    required this.pollutants,
    required this.timestamp,
    required this.locationName,
  });

  factory AirQualityData.fromJson(Map<String, dynamic> json, String locationName) {
    final airQualityData = json['airQualityData'] ?? {};
    final indexes = airQualityData['indexes'] ?? [];
    final pollutants = airQualityData['pollutants'] ?? {};
    
    // Get the AQI from the first index (usually the main AQI)
    double aqi = 0;
    String category = 'Unknown';
    String dominantPollutant = 'Unknown';
    
    if (indexes.isNotEmpty) {
      final mainIndex = indexes[0];
      aqi = mainIndex['aqi']?.toDouble() ?? 0;
      category = mainIndex['category'] ?? 'Unknown';
      dominantPollutant = mainIndex['dominantPollutant'] ?? 'Unknown';
    }
    
    // Parse pollutants
    Map<String, PollutantData> pollutantsMap = {};
    pollutants.forEach((key, value) {
      pollutantsMap[key] = PollutantData.fromJson(value);
    });
    
    return AirQualityData(
      aqi: aqi,
      category: category,
      dominantPollutant: dominantPollutant,
      pollutants: pollutantsMap,
      timestamp: DateTime.now(),
      locationName: locationName,
    );
  }
  
  // Helper method to get color based on AQI
  Color getAqiColor() {
    if (aqi <= 50) return Colors.green;
    if (aqi <= 100) return Colors.yellow;
    if (aqi <= 150) return const Color(0xFFFFA500); // Orange
    if (aqi <= 200) return Colors.red;
    if (aqi <= 300) return const Color(0xFF800080); // Purple
    return const Color(0xFF8B0000); // Dark Red
  }
  
  // Helper method to get health recommendation based on AQI
  String getHealthRecommendation() {
    if (aqi <= 50) {
      return 'Air quality is good. Perfect for outdoor activities!';
    } else if (aqi <= 100) {
      return 'Air quality is moderate. Unusually sensitive people should consider reducing prolonged outdoor exertion.';
    } else if (aqi <= 150) {
      return 'Air quality is unhealthy for sensitive groups. Reduce prolonged or heavy outdoor exertion.';
    } else if (aqi <= 200) {
      return 'Air quality is unhealthy. Everyone may begin to experience health effects. Avoid prolonged outdoor exertion.';
    } else if (aqi <= 300) {
      return 'Air quality is very unhealthy. Avoid all outdoor activities. Consider wearing a mask outdoors.';
    } else {
      return 'Air quality is hazardous. Avoid all outdoor activities. Stay indoors with air purifiers if possible.';
    }
  }
}

class PollutantData {
  final String displayName;
  final String fullName;
  final double concentration;
  final String units;

  PollutantData({
    required this.displayName,
    required this.fullName,
    required this.concentration,
    required this.units,
  });

  factory PollutantData.fromJson(Map<String, dynamic> json) {
    return PollutantData(
      displayName: json['displayName'] ?? '',
      fullName: json['fullName'] ?? '',
      concentration: json['concentration']?.toDouble() ?? 0.0,
      units: json['units'] ?? '',
    );
  }
} 