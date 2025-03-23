import 'package:flutter/material.dart';

class AirQualityData {
  final double localAqi;
  final double universalAqi;
  final String category;
  final String dominantPollutant;
  final Map<String, PollutantData> pollutants;
  final HealthRecommendations healthRecommendations;
  final DateTime timestamp;
  final String locationName;

  AirQualityData({
    required this.localAqi,
    required this.universalAqi,
    required this.category,
    required this.dominantPollutant,
    required this.pollutants,
    required this.healthRecommendations,
    required this.timestamp,
    required this.locationName,
  });

  factory AirQualityData.fromJson(Map<String, dynamic> json, String locationName) {
    final airQualityData = json['airQualityData'] ?? {};
    final indexes = airQualityData['indexes'] ?? [];
    final pollutants = airQualityData['pollutants'] ?? {};
    
    // Get the AQI from the first index (usually the main AQI)
    double localAqi = 0;
    double universalAqi = 0;
    String category = 'Unknown';
    String dominantPollutant = 'Unknown';
    
    if (indexes.isNotEmpty) {
      final mainIndex = indexes[0];
      localAqi = mainIndex['aqi']?.toDouble() ?? 0;
      category = mainIndex['category'] ?? 'Unknown';
      dominantPollutant = mainIndex['dominantPollutant'] ?? 'Unknown';
    }
    
    // Parse pollutants
    Map<String, PollutantData> pollutantsMap = {};
    pollutants.forEach((key, value) {
      pollutantsMap[key] = PollutantData.fromJson(value);
    });
    
    // Parse health recommendations
    final healthRecommendationsJson = airQualityData['healthRecommendations'] ?? {};
    HealthRecommendations healthRecommendations = HealthRecommendations(
      generalPopulation: healthRecommendationsJson['generalPopulation'] ?? '',
      elderly: healthRecommendationsJson['elderly'] ?? '',
      lungDiseasePopulation: healthRecommendationsJson['lungDiseasePopulation'] ?? '',
      heartDiseasePopulation: healthRecommendationsJson['heartDiseasePopulation'] ?? '',
      athletes: healthRecommendationsJson['athletes'] ?? '',
      pregnantWomen: healthRecommendationsJson['pregnantWomen'] ?? '',
      children: healthRecommendationsJson['children'] ?? '',
    );
    
    return AirQualityData(
      localAqi: localAqi,
      universalAqi: universalAqi,
      category: category,
      dominantPollutant: dominantPollutant,
      pollutants: pollutantsMap,
      healthRecommendations: healthRecommendations,
      timestamp: DateTime.now(),
      locationName: locationName,
    );
  }
  
  // Helper method to get color based on AQI
  Color getAqiColor() {
    if (localAqi <= 50) return Colors.green;
    if (localAqi <= 100) return Colors.yellow;
    if (localAqi <= 150) return const Color(0xFFFFA500); // Orange
    if (localAqi <= 200) return Colors.red;
    if (localAqi <= 300) return const Color(0xFF800080); // Purple
    return const Color(0xFF8B0000); // Dark Red
  }
  
  // Helper method to get health recommendation based on AQI
  String getHealthRecommendation() {
    if (localAqi <= 50) {
      return 'Air quality is good. Perfect for outdoor activities!';
    } else if (localAqi <= 100) {
      return 'Air quality is moderate. Unusually sensitive people should consider reducing prolonged outdoor exertion.';
    } else if (localAqi <= 150) {
      return 'Air quality is unhealthy for sensitive groups. Reduce prolonged or heavy outdoor exertion.';
    } else if (localAqi <= 200) {
      return 'Air quality is unhealthy. Everyone may begin to experience health effects. Avoid prolonged outdoor exertion.';
    } else if (localAqi <= 300) {
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
  final String sources;
  final String effects;

  PollutantData({
    required this.displayName,
    required this.fullName,
    required this.concentration,
    required this.units,
    this.sources = '',
    this.effects = '',
  });

  factory PollutantData.fromJson(Map<String, dynamic> json) {
    return PollutantData(
      displayName: json['displayName'] ?? '',
      fullName: json['fullName'] ?? '',
      concentration: json['concentration']?.toDouble() ?? 0.0,
      units: json['units'] ?? '',
      sources: json['sources'] ?? '',
      effects: json['effects'] ?? '',
    );
  }
}

class HealthRecommendations {
  final String generalPopulation;
  final String elderly;
  final String lungDiseasePopulation;
  final String heartDiseasePopulation;
  final String athletes;
  final String pregnantWomen;
  final String children;

  HealthRecommendations({
    required this.generalPopulation,
    required this.elderly,
    required this.lungDiseasePopulation,
    required this.heartDiseasePopulation,
    required this.athletes,
    required this.pregnantWomen,
    required this.children,
  });
}