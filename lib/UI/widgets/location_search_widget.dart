import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import '../const/constant.dart';
import 'dart:developer' as developer;
import '../services/air_quality_service.dart';

class LocationSearchWidget extends StatefulWidget {
  final Function(double lat, double lng, String locationName) onLocationSelected;

  const LocationSearchWidget({
    super.key,
    required this.onLocationSelected,
  });

  @override
  State<LocationSearchWidget> createState() => _LocationSearchWidgetState();
}

class _LocationSearchWidgetState extends State<LocationSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _predictions = [];
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    developer.log('LocationSearchWidget initialized', name: 'location.widget');
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showPopup(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hey there!"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> _getPlacePredictions(String input) async {
    if (input.isEmpty) {
      setState(() => _predictions = []);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    // Log the search query
    print('🔍 SEARCH QUERY: "$input"');
    developer.log('Searching for: $input', name: 'location.search');
    
    try {
      final url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json'
          '?input=$input'
          '&key=${ApiConfig.apiKey}'
          '&types=(cities)';
          
      // Log the API request URL
      print('🌐 API REQUEST: $url');
      developer.log('API request URL: $url', name: 'location.search');
      
      final response = await http.get(Uri.parse(url));

      // Log the API response status
      print('📊 API RESPONSE STATUS: ${response.statusCode}');
      developer.log('API response status: ${response.statusCode}', name: 'location.search');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Log the full API response
        print('📋 API RESPONSE: ${response.body}');
        developer.log('API response: ${response.body}', name: 'location.search');
        
        if (data['status'] == 'OK') {
          setState(() {
            _predictions = data['predictions'] ?? [];
            _isLoading = false;
          });
          
          // Log the predictions found
          print('✅ FOUND ${_predictions.length} PREDICTIONS:');
          for (var prediction in _predictions) {
            print('  - ${prediction['description']} (${prediction['place_id']})');
          }
          developer.log('Found ${_predictions.length} predictions', name: 'location.search');
        } else {
          setState(() {
            _predictions = [];
            _isLoading = false;
            _errorMessage = 'Error: ${data['status']} - ${data['error_message'] ?? 'Unknown error'}';
          });
          _showPopup('We are facing an issue while fetching location predictions. Please try again.');
          
          // Log the API error
          print('❌ API ERROR: ${data['status']} - ${data['error_message'] ?? 'Unknown error'}');
          developer.log('API error: ${data['status']} - ${data['error_message'] ?? 'Unknown error'}', 
              name: 'location.search.error');
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Network error: ${response.statusCode}';
        });
        _showPopup('We are facing an issue while fetching location predictions. Please try again.');
        
        // Log the network error
        print('❌ NETWORK ERROR: ${response.statusCode}');
        developer.log('Network error: ${response.statusCode}', name: 'location.search.error');
      }
    } catch (e, stackTrace) {
      // Log any exceptions
      print('❌ EXCEPTION: $e');
      print('STACK TRACE: $stackTrace');
      _showPopup('We are facing an issue while fetching location predictions. Please try again.');
      developer.log('Error getting place predictions',
          name: 'location.search.error',
          error: e,
          stackTrace: stackTrace);
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: $e';
      });
    }
  }

  Future<void> _getPlaceDetails(String placeId) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    // Log the place ID
    print('🔍 GETTING DETAILS FOR PLACE ID: "$placeId"');
    developer.log('Getting details for place ID: $placeId', name: 'location.details');
    
    try {
      final url = 'https://maps.googleapis.com/maps/api/place/details/json'
          '?place_id=$placeId'
          '&key=${ApiConfig.apiKey}'
          '&fields=geometry,formatted_address';
          
      // Log the API request URL
      print('🌐 API REQUEST: $url');
      developer.log('API request URL: $url', name: 'location.details');
      
      final response = await http.get(Uri.parse(url));

      // Log the API response status
      print('📊 API RESPONSE STATUS: ${response.statusCode}');
      developer.log('API response status: ${response.statusCode}', name: 'location.details');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Log the full API response
        print('📋 API RESPONSE: ${response.body}');
        developer.log('API response: ${response.body}', name: 'location.details');
        
        if (data['status'] == 'OK' && data['result'] != null) {
          final location = data['result']['geometry']['location'];
          final lat = location['lat'] as double;
          final lng = location['lng'] as double;
          final address = data['result']['formatted_address'] as String;
          
          // Log the selected location
          print('✅ SELECTED LOCATION: $address ($lat, $lng)');
          developer.log('Selected location: $address ($lat, $lng)', name: 'location.details');
          
          // First call the location selected callback
          widget.onLocationSelected(lat, lng, address);
          
          // Then get air quality data for the selected location
          try {
            print('Calling AirQualityService.getAirQuality(lat, lng) : $lat, $lng, $mounted');
            if (!mounted) return;
            final airQualityData = await AirQualityService.getAirQuality(lat, lng);
            print('Returned from getAirQuality service');
            print('🌍 Air Quality Data for $address:');
            print('📊 Local AQI: ${airQualityData.localAqi}');
            print('📊 Universal AQI: ${airQualityData.universalAqi}');
            print('🏷️ Category: ${airQualityData.category}');
            print('⚠️ Dominant Pollutant: ${airQualityData.dominantPollutant}');
            print('📈 Pollutants: ${airQualityData.pollutants.keys.join(", ")}');
            developer.log('🌍 Air Quality Data for $address:', name: 'air.quality');
            developer.log('📊 Local AQI: ${airQualityData.localAqi}', name: 'air.quality');
            developer.log('📊 Universal AQI: ${airQualityData.universalAqi}', name: 'air.quality');
            developer.log('🏷️ Category: ${airQualityData.category}', name: 'air.quality');
            developer.log('⚠️ Dominant Pollutant: ${airQualityData.dominantPollutant}', name: 'air.quality');
            developer.log('📈 Pollutants: ${airQualityData.pollutants.keys.join(", ")}', name: 'air.quality');
          } catch (e, stackTrace) {
            developer.log('Error getting air quality data',
                name: 'air.quality.error',
                error: e,
                stackTrace: stackTrace);
            _showPopup('We are facing an issue while fetching air quality data. Please try again.');
          }
          
          if (!mounted) return;
          setState(() => _isLoading = false);
        } else {
          if (!mounted) return;
          setState(() {
            _isLoading = false;
            _errorMessage = 'Error: ${data['status']} - ${data['error_message'] ?? 'Unknown error'}';
          });
          _showPopup('We are facing an issue while fetching air quality data. Please try again.');
          
          // Log the API error
          print('❌ API ERROR: ${data['status']} - ${data['error_message'] ?? 'Unknown error'}');
          developer.log('API error: ${data['status']} - ${data['error_message'] ?? 'Unknown error'}', 
              name: 'location.details.error');
        }
      } else {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _errorMessage = 'Network error: ${response.statusCode}';
        });
        _showPopup('We are facing an issue while fetching air quality data. Please try again.');
        
        // Log the network error
        print('❌ NETWORK ERROR: ${response.statusCode}');
        developer.log('Network error: ${response.statusCode}', name: 'location.details.error');
      }
    } catch (e, stackTrace) {
      // Log any exceptions
      print('❌ EXCEPTION: $e');
      print('STACK TRACE: $stackTrace');
      _showPopup('We are facing an issue while fetching air quality data. Please try again.');
      developer.log('Error getting place details',
          name: 'location.details.error',
          error: e,
          stackTrace: stackTrace);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: $e';
      });
    }
  }

    Future<void> _getAQIDetails(String placeId) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    // Log the place ID
    print('🔍 GETTING DETAILS FOR PLACE ID: "$placeId"');
    developer.log('Getting details for place ID: $placeId', name: 'location.details');
    
    try {
      final url = 'https://airquality.googleapis.com/v1/currentConditions:lookup'
          '?key=YOUR_API_KEY=${ApiConfig.apiKey}';
          
      // Log the API request URL
      print('🌐 API REQUEST: $url');
      developer.log('API request URL: $url', name: 'location.details');
      
      final response = await http.get(Uri.parse(url));

      // Log the API response status
      print('📊 API RESPONSE STATUS: ${response.statusCode}');
      developer.log('API response status: ${response.statusCode}', name: 'location.details');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Log the full API response
        print('📋 API RESPONSE: ${response.body}');
        developer.log('API response: ${response.body}', name: 'location.details');
        
        if (data['status'] == 'OK' && data['result'] != null) {
          final location = data['result']['geometry']['location'];
          final lat = location['lat'] as double;
          final lng = location['lng'] as double;
          final address = data['result']['formatted_address'] as String;
          
          // Log the selected location
          print('✅ SELECTED LOCATION: $address ($lat, $lng)');
          developer.log('Selected location: $address ($lat, $lng)', name: 'location.details');
          
          widget.onLocationSelected(lat, lng, address);
          setState(() => _isLoading = false);
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Error: ${data['status']} - ${data['error_message'] ?? 'Unknown error'}';
          });
          
          // Log the API error
          print('❌ API ERROR: ${data['status']} - ${data['error_message'] ?? 'Unknown error'}');
          developer.log('API error: ${data['status']} - ${data['error_message'] ?? 'Unknown error'}', 
              name: 'location.details.error');
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Network error: ${response.statusCode}';
        });
        _showPopup('We are facing an issue while fetching air quality data. Please try again.');
        
        // Log the network error
        print('❌ NETWORK ERROR: ${response.statusCode}');
        developer.log('Network error: ${response.statusCode}', name: 'location.details.error');
      }
    } catch (e, stackTrace) {
      // Log any exceptions
      print('❌ EXCEPTION: $e');
      print('STACK TRACE: $stackTrace');
      _showPopup('We are facing an issue while fetching air quality data. Please try again.');
      developer.log('Error getting place details',
          name: 'location.details.error',
          error: e,
          stackTrace: stackTrace);
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: cardBackgroundColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.search,
                color: Colors.grey[400],
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search location...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  onChanged: (value) {
                    print('📝 TEXT CHANGED: "$value"');
                    _getPlacePredictions(value);
                  },
                ),
              ),
              if (_isLoading)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  ),
                ),
              if (!_isLoading && _searchController.text.isNotEmpty)
                IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Colors.grey[400],
                    size: 20,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _predictions = [];
                      _errorMessage = '';
                    });
                    print('🧹 SEARCH CLEARED');
                  },
                ),
            ],
          ),
        ),
        if (_errorMessage.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: Colors.red.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        if (_predictions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: cardBackgroundColor,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: Colors.grey.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _predictions.length,
              itemBuilder: (context, index) {
                final prediction = _predictions[index];
                return ListTile(
                  title: Text(
                    prediction['description'],
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    _searchController.text = prediction['description'];
                    print('🔍 SELECTED PREDICTION: ${prediction['description']} (${prediction['place_id']})');
                    setState(() => _predictions = []);
                    _getPlaceDetails(prediction['place_id']);
                  },
                );
              },
            ),
          ),
      ],
    );
  }
} 