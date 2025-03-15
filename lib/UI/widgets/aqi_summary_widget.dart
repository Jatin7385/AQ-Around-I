import 'package:flutter/material.dart';
import 'package:fitness_dashboard_ui/UI/widgets/custom_card_widget.dart';
import 'package:fitness_dashboard_ui/UI/const/constant.dart';
import 'package:fitness_dashboard_ui/UI/model/air_quality_model.dart';
import 'package:fitness_dashboard_ui/UI/services/air_quality_service.dart';
import 'package:fitness_dashboard_ui/UI/services/location_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:developer' as developer;

class AQISummaryWidget extends StatefulWidget {
  final LocationService locationService;
  
  const AQISummaryWidget({
    super.key,
    required this.locationService,
  });

  @override
  State<AQISummaryWidget> createState() => _AQISummaryWidgetState();
}

class _AQISummaryWidgetState extends State<AQISummaryWidget> {
  bool _isLoading = true;
  AirQualityData? _airQualityData;
  String _errorMessage = '';
  StreamSubscription? _locationSubscription;

  @override
  void initState() {
    super.initState();
    developer.log('AQISummaryWidget initialized', name: 'aqi.widget');
    _fetchAirQualityData();
    
    // Listen for location changes
    _locationSubscription = widget.locationService.locationStream.listen((locationData) {
      developer.log('Location updated in AQISummaryWidget: ${locationData.locationName}', 
          name: 'aqi.widget');
      _fetchAirQualityForLocation(
        locationData.latitude, 
        locationData.longitude,
        locationData.locationName
      );
    });
  }
  
  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _fetchAirQualityData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Check if we already have a location from the service
      if (widget.locationService.latitude != null && 
          widget.locationService.longitude != null &&
          widget.locationService.locationName != null) {
        
        await _fetchAirQualityForLocation(
          widget.locationService.latitude!,
          widget.locationService.longitude!,
          widget.locationService.locationName!
        );
        return;
      }
      
      // Otherwise try to get current location
      final Position? position = await AirQualityService.getCurrentLocation();
      
      if (position == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Unable to get current location. Please search for a location.';
        });
        return;
      }
      
      // Get air quality data for the current location
      final airQualityData = await AirQualityService.getAirQuality(
        position.latitude,
        position.longitude,
      );
      
      // Update the location service
      widget.locationService.updateLocation(
        position.latitude,
        position.longitude,
        airQualityData.locationName
      );
      
      setState(() {
        _airQualityData = airQualityData;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      developer.log('Error fetching air quality data',
          name: 'aqi.widget.error',
          error: e,
          stackTrace: stackTrace);
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load air quality data: $e';
      });
    }
  }

  Future<void> _fetchAirQualityForLocation(double lat, double lng, String locationName) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      developer.log('Fetching air quality for location: $locationName ($lat, $lng)', 
          name: 'aqi.widget');
      final airQualityData = await AirQualityService.getAirQuality(lat, lng);
      
      setState(() {
        _airQualityData = airQualityData;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      developer.log('Error fetching air quality for location',
          name: 'aqi.widget.error',
          error: e,
          stackTrace: stackTrace);
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load air quality data: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      useGradient: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and refresh button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.air,
                    color: primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Air Quality Index',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                  Icons.refresh,
                  color: Colors.grey[400],
                  size: 20,
                ),
                onPressed: _fetchAirQualityData,
              ),
            ],
          ),

          const SizedBox(height: 16),
          
          // Content
          if (_isLoading)
            _buildLoadingState()
          else if (_errorMessage.isNotEmpty)
            _buildErrorState()
          else if (_airQualityData != null)
            _buildAirQualityData(_airQualityData!)
          else
            _buildNoDataState(),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: primaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading air quality data...',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: dangerColor,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: TextStyle(
              color: dangerColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchAirQualityData,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off,
            color: Colors.grey[400],
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'No Data Available',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAirQualityData(AirQualityData data) {
    final color = data.getAqiColor();
    final recommendation = data.getHealthRecommendation();
    final formattedTime = DateFormat('MMM d, h:mm a').format(data.timestamp);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // AQI value and location
        Row(
          children: [
            // AQI value with circular indicator
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.1),
                border: Border.all(
                  color: color,
                  width: 2,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      data.aqi.toStringAsFixed(0),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      'AQI',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Location and category
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.locationName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      data.category,
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Updated: $formattedTime',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Divider
        Divider(
          color: Colors.grey.withOpacity(0.2),
          thickness: 1,
        ),
        
        const SizedBox(height: 16),
        
        // Health recommendation
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.health_and_safety,
              color: primaryColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Health Recommendation',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    recommendation,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Dominant pollutant
        if (data.dominantPollutant != 'Unknown' && data.dominantPollutant != 'N/A')
          Row(
            children: [
              Icon(
                Icons.warning_amber,
                color: accentColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Dominant Pollutant: ',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[400],
                ),
              ),
              Text(
                data.dominantPollutant,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
      ],
    );
  }
}