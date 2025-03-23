import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fitness_dashboard_ui/UI/const/constant.dart';
import 'package:fitness_dashboard_ui/UI/model/air_quality_model.dart';
import 'package:fitness_dashboard_ui/UI/widgets/health_recommendations_widget.dart';
import 'package:fitness_dashboard_ui/UI/services/location_service.dart';
import 'dart:developer' as developer;

class AQISummaryWidget extends StatefulWidget {
  final LocationService locationService;

  const AQISummaryWidget({
    Key? key,
    required this.locationService,
  }) : super(key: key);

  @override
  State<AQISummaryWidget> createState() => _AQISummaryWidgetState();
}

class _AQISummaryWidgetState extends State<AQISummaryWidget> {
  late AirQualityData? _data;
  String _totalCigarettes = '0.0';

  @override
  void initState() {
    super.initState();
    developer.log('Initializing AQISummaryWidget', name: 'widget.aqi');
    print('aqi_summary_widget :: initState start');
    _data = widget.locationService.airQualityData;
    _updateData();
    widget.locationService.addListener(_updateData);
    print('aqi_summary_widget :: initState end');
  }

  @override
  void dispose() {
    print('aqi_summary_widget :: dispose start');
    widget.locationService.removeListener(_updateData);
    super.dispose();
    print('aqi_summary_widget :: dispose end');
  }

  Future<void> checkLocationAndFetch() async {
    bool serviceEnabled;
    LocationPermission permission;

    // ✅ Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("❌ Location services are disabled.");
      return;
    }

    // ✅ Check & Request Permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("❌ Location permission denied.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print("❌ Location permission permanently denied. Please enable it in settings.");
      openAppSettings(); // Opens app settings for user to enable manually
      return;
    }

    // ✅ Get Current Location
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print("📍 Location: ${position.latitude}, ${position.longitude}");
}

  void _updateData() {
    print('aqi_summary_widget :: _updateData start');
    developer.log('Updating AQI data', name: 'widget.aqi');
    setState(() {
      _data = widget.locationService.airQualityData;
      _totalCigarettes = _calculateCigarettes(_data?.localAqi ?? -1); //  Let's for now consider, that if the value is null, we'll pick it up as a -1.
    });
    print('aqi_summary_widget :: _data : ${_data} :: _totalCigarettes : ${_totalCigarettes}');
    print('aqi_summary_widget :: _updateData end');
  }

  static String _calculateCigarettes(double aqi) {
    print('aqi_summary_widget :: _calculateCigarettes called');
    return (aqi != -1) ? (aqi / 22).toStringAsFixed(1) : 'Data not available';
  }

  @override
  Widget build(BuildContext context) {
    developer.log('Building AQISummaryWidget', name: 'widget.aqi');
    print('aqi_summary_widget :: build start');
    return Container(
      color: Color(0xFF1A1C1E),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[850]?.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.air, color: Colors.blue[200], size: 24),
                              const SizedBox(width: 8),
                              const Text(
                                'Air Quality Summary',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis, // Prevents overflow
                                maxLines: 1, // Ensures text doesn't wrap
                              ),
                            ],
                          ),
                          // Container(
                          //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          //   decoration: BoxDecoration(
                          //     color: _getAQIColor(_data.localAqi).withOpacity(0.2),
                          //     borderRadius: BorderRadius.circular(12),
                          //   ),
                          //   child: Text(
                          //     _getAQICategory(_data.localAqi),
                          //     style: TextStyle(
                          //       color: _getAQIColor(_data.localAqi),
                          //       fontSize: 14,
                          //       fontWeight: FontWeight.w500,
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity, // Ensures it doesn't try to overflow
                        // AQI Values
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildAQICard(
                                'Local',
                                _data?.localAqi.toStringAsFixed(0) ?? 'Data not available',
                                Icons.location_on,
                                Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildAQICard(
                                'Universal',
                                _data?.universalAqi.toStringAsFixed(0) ?? 'Data not available',
                                Icons.public,
                                Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Health Recommendations
                      HealthRecommendationsWidget(
                        recommendations: _data?.healthRecommendations,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAQICard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icon(icon, color: color, size: 10),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis, // Prevents overflow
                maxLines: 1, // Ensures text doesn't wrap
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis, // Prevents overflow
            maxLines: 1, // Ensures text doesn't wrap
          ),
        ],
      ),
    );
  }

  Color _getAQIColor(double aqi) {
    if (aqi <= 50) return Colors.green;
    if (aqi <= 100) return Colors.yellow;
    if (aqi <= 150) return Colors.orange;
    if (aqi <= 200) return Colors.red;
    if (aqi <= 300) return Colors.purple;
    return Colors.brown;
  }

  String _getAQICategory(double aqi) {
    if (aqi <= 50) return 'Good';
    if (aqi <= 100) return 'Moderate';
    if (aqi <= 150) return 'Unhealthy for Sensitive Groups';
    if (aqi <= 200) return 'Unhealthy';
    if (aqi <= 300) return 'Very Unhealthy';
    return 'Hazardous';
  }
}