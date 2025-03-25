import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:fitness_dashboard_ui/UI/model/air_quality_model.dart';
import 'package:fitness_dashboard_ui/UI/services/air_quality_service.dart';

class LocationService extends ChangeNotifier {
  // _instance is a private static variable that stores the single instance.
  static final LocationService _instance = LocationService._internal();

  // Factory constructor that returns the single instance.
  factory LocationService() {
    return _instance;
  }
  
  // Private constructor to prevent instantiation from outside.
  LocationService._internal();
  
  // Private variables for location data
  double? _latitude;
  double? _longitude;
  String? _locationName;
  
  // Air quality data
  // ? indicates that the variable can be null
  AirQualityData? _airQualityData;
  
  // Stream controller for location updates
  // A StreamController allows other parts of the app to listen for location changes in real-time.
  // .broadcast() means multiple widgets can listen to updates.
  final _locationController = StreamController<LocationData>.broadcast();
  
  // Getters
  double? get latitude => _latitude;
  double? get longitude => _longitude;
  String? get locationName => _locationName;
  Stream<LocationData> get locationStream => _locationController.stream;
  AirQualityData? get airQualityData => _airQualityData;
  
  // Update location and fetch air quality data
  Future<void> updateLocation(double lat, double lng, String name) async {
    print('location_service :: updateLocation start');
    _latitude = lat;
    _longitude = lng;
    _locationName = name;
    
    // Notify location update (widgets, other services)
    _locationController.add(LocationData(
      latitude: lat,
      longitude: lng,
      locationName: name,
    ));
    
    // Fetch air quality data (updates air quality data)
    try {
      final newAirQualityData = await AirQualityService.getAirQuality(lat, lng);
      _airQualityData = newAirQualityData;
      notifyListeners();
    } catch (e) {
      print('Error fetching air quality data: $e');
    } finally {
      print('location_service :: updateLocation end');
    }
  }

  // Update location and fetch air quality data
  Future<void> refreshBtnClicked() async {
    print('location_service :: refreshBtnClicked start');
    // Notify location update (widgets, other services)
    _locationController.add(LocationData(
      latitude: _latitude!,
      longitude: _longitude!,
      locationName: _locationName!,
    ));
    
    // Fetch air quality data (updates air quality data)
    try {
      final newAirQualityData = await AirQualityService.getAirQuality(_latitude!, _longitude!);
      _airQualityData = newAirQualityData;
      notifyListeners();
    } catch (e) {
      print('Error fetching air quality data: $e');
    } finally {
      print('location_service :: refreshBtnClicked end');
    }
  }
  
  // Cleanup - When LocationService is no longer needed, this closes the stream to prevent memory leaks.
  @override
  void dispose() {
    _locationController.close();
    super.dispose();
  }
}

// LocationData class - Holds location information
class LocationData {
  final double latitude;
  final double longitude;
  final String locationName;
  
  LocationData({
    required this.latitude,
    required this.longitude,
    required this.locationName,
  });
}