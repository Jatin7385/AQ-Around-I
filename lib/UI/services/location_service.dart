import 'dart:async';
import 'package:flutter/foundation.dart';

class LocationService extends ChangeNotifier {
  static final LocationService _instance = LocationService._internal();
  
  factory LocationService() {
    return _instance;
  }
  
  LocationService._internal();
  
  double? _latitude;
  double? _longitude;
  String? _locationName;
  
  // Stream controller for location updates
  final _locationController = StreamController<LocationData>.broadcast();
  
  // Getters
  double? get latitude => _latitude;
  double? get longitude => _longitude;
  String? get locationName => _locationName;
  Stream<LocationData> get locationStream => _locationController.stream;
  
  // Update location
  void updateLocation(double lat, double lng, String name) {
    _latitude = lat;
    _longitude = lng;
    _locationName = name;
    
    // Notify listeners
    _locationController.add(LocationData(
      latitude: lat,
      longitude: lng,
      locationName: name,
    ));
    
    notifyListeners();
  }
  
  @override
  void dispose() {
    _locationController.close();
    super.dispose();
  }
}

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