import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import '../model/air_quality_model.dart';
import '../config/api_config.dart';
import 'dart:developer' as developer;

class AirQualityService {
  // Get API key from config
  static final String apiKey = ApiConfig.apiKey;
  static const String baseUrl = 'https://airquality.googleapis.com/v1/currentConditions:lookup';

  // Check if location services are available for the current platform
  static Future<bool> isLocationAvailable() async {
    try {
      developer.log('Checking location availability', name: 'location.service');
      
      if (kIsWeb) {
        developer.log('Running on web platform', name: 'location.service');
        return true;
      }

      if (Platform.isLinux || Platform.isWindows) {
        developer.log('Running on desktop platform, location services not supported', 
            name: 'location.service');
        return false;
      }

      final bool isEnabled = await Geolocator.isLocationServiceEnabled();
      developer.log('Location services enabled: $isEnabled', name: 'location.service');
      return isEnabled;
    } catch (e, stackTrace) {
      developer.log('Error checking location service',
          name: 'location.error',
          error: e,
          stackTrace: stackTrace);
      return false;
    }
  }

  // Get current location with error handling
  static Future<Position?> getCurrentLocation() async {
    try {
      developer.log('Getting current location', name: 'location.service');
      
      if (!await isLocationAvailable()) {
        developer.log('Location services not available', name: 'location.service');
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      developer.log('Current location permission status: $permission', 
          name: 'location.service');
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        developer.log('Requested location permission, new status: $permission', 
            name: 'location.service');
        if (permission == LocationPermission.denied) {
          return null;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition();
      developer.log('Retrieved current location: ${position.latitude}, ${position.longitude}', 
          name: 'location.service');
      return position;
    } catch (e, stackTrace) {
      developer.log('Error getting current location',
          name: 'location.error',
          error: e,
          stackTrace: stackTrace);
      return null;
    }
  }

  // Get location name from coordinates using reverse geocoding
  static Future<String> getLocationName(double latitude, double longitude) async {
    try {
      print('Getting location name for coordinates: $latitude, $longitude');
      
      final response = await http.get(
        Uri.parse('https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey')
      );
      
      print('Geocoding API response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          for (var component in data['results']) {
            List<dynamic> addressComponents = component['address_components'] ?? [];
            for (var address in addressComponents) {
              List<dynamic> types = address['types'] ?? [];
              if (types.contains('locality') || types.contains('administrative_area_level_1')) {
                final locationName = address['long_name'];
                print('Found location name: $locationName');
                return locationName;
              }
            }
          }
          
          if (data['results'][0]['formatted_address'] != null) {
            String formattedAddress = data['results'][0]['formatted_address'];
            List<String> addressParts = formattedAddress.split(',');
            if (addressParts.length > 1) {
              final locationName = addressParts[1].trim();
              print('Using formatted address part as location name: $locationName');
              return locationName;
            }
            print('Using full formatted address as location name: $formattedAddress');
            return formattedAddress;
          }
        }
      }
      print('Could not determine location');
      return 'Unknown Location';
    } catch (e, stackTrace) {
      // developer.log('Error getting location name',
      //     name: 'location.error',
      //     error: e,
      //     stackTrace: stackTrace);
      print('Error getting location name $e');
      return 'Unknown Location';
    }
  }

  // Get air quality data for a specific location
  static Future<AirQualityData> getAirQuality(double latitude, double longitude) async {
    try {
      developer.log('🚀 Starting Air Quality API request for coordinates: $latitude, $longitude', name: 'air.quality.debug');

      final locationName = await getLocationName(latitude, longitude);
      developer.log('📍 Location name retrieved: $locationName', name: 'air.quality.debug');

      final url = Uri.parse('$baseUrl?key=$apiKey');
      final requestBody = {
        'location': {
          'latitude': latitude,
          'longitude': longitude,
        },
        'extraComputations': ['HEALTH_RECOMMENDATIONS',
              'DOMINANT_POLLUTANT_CONCENTRATION',
              'POLLUTANT_CONCENTRATION',
              'LOCAL_AQI',
              'POLLUTANT_ADDITIONAL_INFO'],
      };

      developer.log('📤 Making request to Air Quality API\nURL: $url\nBody: ${json.encode(requestBody)}', name: 'air.quality.debug');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      developer.log('📥 Air Quality API Response Status: ${response.statusCode}', name: 'air.quality.debug');
      developer.log('📄 Air Quality API Response Body: ${response.body}', name: 'air.quality.debug');
      print('Air quality response : ${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        developer.log('✅ Successfully parsed Air Quality API response', name: 'air.quality.debug');

        final indexes = data['indexes'] ?? [];
        if (indexes.isNotEmpty) {
          double? localAqi;
          double? universalAqi;
          String category = 'Unknown';
          String dominantPollutant = 'Unknown';

          // Find Universal AQI
          final universalIndex = indexes.firstWhere(
            (index) => index['code'] == 'uaqi',
            orElse: () => {},
          );
          if (universalIndex.isNotEmpty) {
            universalAqi = double.tryParse(universalIndex['aqiDisplay'] ?? '0');
            category = universalIndex['category'] ?? 'Unknown';
            dominantPollutant = universalIndex['dominantPollutant'] ?? 'Unknown';
          }

          // Find Local AQI (NAQI for India)
          final localIndex = indexes.firstWhere(
            (index) => index['code'] != 'uaqi',
            orElse: () => {},
          );
          if (localIndex.isNotEmpty) {
            localAqi = double.tryParse(localIndex['aqiDisplay'] ?? '0');
          }

          developer.log('📊 Extracted Universal AQI: $universalAqi', name: 'air.quality.debug');
          developer.log('📊 Extracted Local AQI: $localAqi', name: 'air.quality.debug');
          developer.log('🏷️ Category: $category', name: 'air.quality.debug');
          developer.log('⚠️ Dominant Pollutant: $dominantPollutant', name: 'air.quality.debug');

          Map<String, PollutantData> pollutants = {};
          final pollutantsData = data['pollutants'] ?? [];
          for (var pollutant in pollutantsData) {
            final code = pollutant['code'] ?? '';
            final concentration = pollutant['concentration'] ?? {};
            pollutants[code] = PollutantData(
              displayName: pollutant['displayName'] ?? code.toUpperCase(),
              fullName: pollutant['fullName'] ?? _getPollutantFullName(code),
              concentration: concentration['value']?.toDouble() ?? 0.0,
              units: concentration['units'] ?? _getPollutantUnits(code),
              sources: pollutant['additionalInfo']?['sources'] ?? '',
              effects: pollutant['additionalInfo']?['effects'] ?? '',
            );
          }

          // Extract health recommendations
          final healthRecommendations = HealthRecommendations(
            generalPopulation: data['healthRecommendations']?['generalPopulation']?.toString() ?? 'No recommendations available',
            elderly: data['healthRecommendations']?['elderly']?.toString() ?? 'No recommendations available',
            lungDiseasePopulation: data['healthRecommendations']?['lungDiseasePopulation']?.toString() ?? 'No recommendations available',
            heartDiseasePopulation: data['healthRecommendations']?['heartDiseasePopulation']?.toString() ?? 'No recommendations available',
            athletes: data['healthRecommendations']?['athletes']?.toString() ?? 'No recommendations available',
            pregnantWomen: data['healthRecommendations']?['pregnantWomen']?.toString() ?? 'No recommendations available',
            children: data['healthRecommendations']?['children']?.toString() ?? 'No recommendations available',
          );

          developer.log('📈 Extracted pollutants: ${pollutants.keys.join(", ")}', name: 'air.quality.debug');

          return AirQualityData(
            localAqi: localAqi ?? 0,
            universalAqi: universalAqi ?? 0,
            category: category,
            dominantPollutant: dominantPollutant,
            pollutants: pollutants,
            timestamp: DateTime.now(),
            locationName: locationName,
            healthRecommendations: healthRecommendations,
          );
        }
      }

      developer.log('❌ Error: Non-200 response from Air Quality API', name: 'air.quality.error');
      throw Exception('Failed to load air quality data: ${response.statusCode}');
    } catch (e, stackTrace) {
      developer.log('❌ Exception in getAirQuality', name: 'air.quality.error', error: e, stackTrace: stackTrace);
      return AirQualityData(
        localAqi: 0,
        universalAqi: 0,
        category: 'Error',
        dominantPollutant: 'N/A',
        pollutants: {},
        timestamp: DateTime.now(),
        locationName: 'Error loading data',
        healthRecommendations: HealthRecommendations(
          generalPopulation: 'Unable to load recommendations',
          elderly: 'Unable to load recommendations',
          lungDiseasePopulation: 'Unable to load recommendations',
          heartDiseasePopulation: 'Unable to load recommendations',
          athletes: 'Unable to load recommendations',
          pregnantWomen: 'Unable to load recommendations',
          children: 'Unable to load recommendations',
        ),
      );
    }
  }

  static String _getAQICategory(double aqi) {
    if (aqi <= 50) return 'Good';
    if (aqi <= 100) return 'Moderate';
    if (aqi <= 150) return 'Unhealthy for Sensitive Groups';
    if (aqi <= 200) return 'Unhealthy';
    if (aqi <= 300) return 'Very Unhealthy';
    return 'Hazardous';
  }

  static String _getPollutantFullName(String code) {
    switch (code.toLowerCase()) {
      case 'pm25': return 'Fine particulate matter (<2.5μm)';
      case 'pm10': return 'Particulate matter (<10μm)';
      case 'o3': return 'Ozone';
      case 'no2': return 'Nitrogen dioxide';
      case 'so2': return 'Sulfur dioxide';
      case 'co': return 'Carbon monoxide';
      default: return code.toUpperCase();
    }
  }

  static String _getPollutantUnits(String code) {
    switch (code.toLowerCase()) {
      case 'pm25':
      case 'pm10':
        return 'μg/m³';
      case 'o3':
      case 'no2':
      case 'so2':
        return 'ppb';
      case 'co':
        return 'ppm';
      default:
        return 'units';
    }
  }
} 