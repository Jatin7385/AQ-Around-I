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
    return (aqi != -1) ? (aqi / 22).toStringAsFixed(1) : dataNotAvailable;
  }

  @override
Widget build(BuildContext context) {
  developer.log('Building AQISummaryWidget', name: 'widget.aqi');
  print('aqi_summary_widget :: build start');
  return Container(
    color: Color(0xFF1A1C1E),
    child: SingleChildScrollView(
      child: Padding(
        // Reduce side padding to allow more space
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Improved parent container with more breathing room
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF2D3035),
                    Color(0xFF222528),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              // Add more internal padding
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with reduced space
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue[800]?.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.air, color: Colors.blue[200], size: 24),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Air Quality Summary',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Increase spacing between header and card
                    const SizedBox(height: 20),

                    _buildAQICard(
                      'assets/images/cigs_1.gif',
                      _data?.localAqi.toStringAsFixed(0) ?? dataNotAvailable,
                      _data?.universalAqi.toStringAsFixed(0) ?? dataNotAvailable,
                    ),
                    
                    // Increase spacing between AQI card and recommendations
                    const SizedBox(height: 24),

                    HealthRecommendationsWidget(
                      recommendations: _data?.healthRecommendations,
                    ),
                  ],
                ),
              ),
            ),
            // Add bottom spacing
            const SizedBox(height: 16),
          ],
        ),
      ),
    ),
  );
}


Widget _buildAQICard(String gifUrl, String localAqi, String universalAqi) {
  // Convert AQI strings to double safely
  double safeLocalAqi = _parseAQI(localAqi);
  double safeUniversalAqi = _parseAQI(universalAqi);
  
  // Get appropriate emoji based on AQI value
  String emojiForAQI = _getEmojiForAQI(safeLocalAqi);

  return Container(
    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: _getAQIGradient(safeLocalAqi),
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 12,
          offset: Offset(3, 6),
        ),
      ],
    ),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 340;
        
        // Use Column for very small screens, Row for larger screens
        return isSmallScreen 
            ? Column(
                children: [
                  // GIF centered
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        gifUrl,
                        width: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Text info
                  _buildAQITextInfo(localAqi, universalAqi, safeLocalAqi),
                  
                  const SizedBox(height: 12),
                  
                  // Emoji
                  Center(
                    child: Text(
                      emojiForAQI,
                      style: const TextStyle(
                        fontSize: 40,
                      ),
                    ),
                  ),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // GIF on the left
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      gifUrl,
                      width: constraints.maxWidth < 400 ? 60 : 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Text in the middle
                  Expanded(
                    child: _buildAQITextInfo(localAqi, universalAqi, safeLocalAqi),
                  ),
                  
                  // Emoji on the right
                  Text(
                    emojiForAQI,
                    style: const TextStyle(
                      fontSize: 48,
                    ),
                  ),
                ],
              );
      },
    ),
  );
}

Widget _buildAQITextInfo(String localAqi, String universalAqi, double safeLocalAqi) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Local AQI: ${localAqi}',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        'Universal AQI: ${universalAqi}',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 18,
        ),
      ),
      const SizedBox(height: 6),
      RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Cigarettes: ',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: '${_calculateCigarettes(safeLocalAqi)}',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}


// Helper method to get the appropriate emoji based on AQI value
String _getEmojiForAQI(double aqi) {
  if (aqi <= 50) return '😀'; // Good
  if (aqi <= 100) return '🙂'; // Moderate
  if (aqi <= 150) return '😐'; // Unhealthy for sensitive groups
  if (aqi <= 200) return '😷'; // Unhealthy
  if (aqi <= 300) return '🤢'; // Very unhealthy
  if (aqi > 300) return '☠️'; // Hazardous
  return '❓'; // For invalid or unavailable data
}

  double _parseAQI(String aqiString) {
    try {
      return double.parse(aqiString);
    } catch (e) {
      return -1; // Return -1 for invalid AQI values
    }
  }

  List<Color> _getAQIGradient(double aqi) {
  if (aqi <= 50) return [Colors.green.shade700, Colors.green.shade400]; // Good
  if (aqi <= 100) return [Colors.yellow.shade800, Colors.yellow.shade500]; // Moderate
  if (aqi <= 150) return [Colors.orange.shade800, Colors.orange.shade500]; // Unhealthy for sensitive groups
  if (aqi <= 200) return [Colors.red.shade800, Colors.red.shade500]; // Unhealthy
  if (aqi <= 300) return [Colors.purple.shade800, Colors.purple.shade500]; // Very unhealthy
  return [Colors.brown.shade800, Colors.brown.shade500]; // Hazardous
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