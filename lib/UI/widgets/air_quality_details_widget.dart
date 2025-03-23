import 'package:flutter/material.dart';
import 'package:fitness_dashboard_ui/UI/widgets/custom_card_widget.dart';
import 'package:fitness_dashboard_ui/UI/const/constant.dart';
import 'package:fitness_dashboard_ui/UI/model/air_quality_model.dart';
import 'package:fitness_dashboard_ui/UI/services/air_quality_service.dart';
import 'package:fitness_dashboard_ui/UI/services/location_service.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:developer' as developer;

class AirQualityDetailsWidget extends StatefulWidget {
  final LocationService locationService;
  
  const AirQualityDetailsWidget({
    super.key,
    required this.locationService,
  });

  @override
  State<AirQualityDetailsWidget> createState() => _AirQualityDetailsWidgetState();
}

class _AirQualityDetailsWidgetState extends State<AirQualityDetailsWidget> {
  bool _isLoading = true;
  AirQualityData? _airQualityData;
  String _errorMessage = '';
  StreamSubscription? _locationSubscription;

  @override
  void initState() {
    super.initState();
    developer.log('AirQualityDetailsWidget initialized', name: 'air.quality.details');
    _fetchAirQualityData();
    
    // Listen for location changes
    _locationSubscription = widget.locationService.locationStream.listen((locationData) {
      developer.log('Location updated in AirQualityDetailsWidget: ${locationData.locationName}', 
          name: 'air.quality.details');
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
      final position = await AirQualityService.getCurrentLocation();
      
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
          name: 'air.quality.details.error',
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
          name: 'air.quality.details');
      final airQualityData = await AirQualityService.getAirQuality(lat, lng);
      
      setState(() {
        _airQualityData = airQualityData;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      developer.log('Error fetching air quality for location',
          name: 'air.quality.details.error',
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
                    Icons.science,
                    color: primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Pollutants Detail',
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
          else if (_airQualityData != null && _airQualityData!.pollutants.isNotEmpty)
            _buildPollutantsData(_airQualityData!)
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
            'Loading pollutants data...',
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
            'No Pollutants Data Available',
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

  Widget _buildPollutantsData(AirQualityData? data) {
    if (data == null) {
      return const Center(
        child: Text('No pollutants data available'),
      );
    }
    final pollutants = data.pollutants;
    final formattedTime = DateFormat('MMM d, h:mm a').format(data.timestamp);
    
    return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Location and time - make this row wrap properly
      Wrap(
        alignment: WrapAlignment.spaceBetween,
        spacing: 8,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_on,
                color: primaryColor,
                size: 16,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  data.locationName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Text(
            'Updated: $formattedTime',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
      
      const SizedBox(height: 16),
      
      // Make GridView responsive based on screen width
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width < 400 ? 1 : 2,
          childAspectRatio: MediaQuery.of(context).size.width < 400 ? 2.5 : 1.5,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: pollutants.length,
        itemBuilder: (context, index) {
          final pollutantKey = pollutants.keys.elementAt(index);
          final pollutant = pollutants[pollutantKey]!;
          
          return _buildPollutantCard(pollutant, pollutantKey == data.dominantPollutant);
        },
      ),
        
        const SizedBox(height: 16),
        
        // Pollutants explanation
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: backgroundColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: primaryColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'About Pollutants',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'PM2.5: Fine particulate matter that can penetrate deep into the lungs.\n'
                'PM10: Coarse particulate matter from dust, pollen, and mold.\n'
                'O3: Ozone, a reactive gas that can irritate airways.\n'
                'NO2: Nitrogen dioxide from vehicle emissions and power plants.\n'
                'SO2: Sulfur dioxide from burning fossil fuels.\n'
                'CO: Carbon monoxide, a colorless, odorless gas from combustion.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildPollutantCard(PollutantData pollutant, bool isDominant) {
    Color cardColor;
    
    // Simplified color assignment based on pollutant type
    if (pollutant.displayName.contains('PM')) {
      cardColor = dangerColor;
    } else if (pollutant.displayName.contains('O3')) {
      cardColor = accentColor;
    } else if (pollutant.displayName.contains('NO2')) {
      cardColor = Colors.deepOrange;
    } else if (pollutant.displayName.contains('SO2')) {
      cardColor = Colors.purple;
    } else if (pollutant.displayName.contains('CO')) {
      cardColor = Colors.brown;
    } else {
      cardColor = primaryColor;
    }
    
    return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: cardColor.withOpacity(0.1),
      borderRadius: BorderRadius.circular(borderRadius),
      border: isDominant 
          ? Border.all(color: cardColor, width: 2)
          : null,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                pollutant.displayName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: cardColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isDominant) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.warning_amber,
                color: cardColor,
                size: 16,
              ),
            ],
          ],
        ),
          const SizedBox(height: 4),
          Text(
            '${pollutant.concentration.toStringAsFixed(1)} ${pollutant.units}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            pollutant.fullName,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[400],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
} 