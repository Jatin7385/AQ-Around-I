import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

class TestApiWidget extends StatefulWidget {
  const TestApiWidget({super.key});

  @override
  State<TestApiWidget> createState() => _TestApiWidgetState();
}

class _TestApiWidgetState extends State<TestApiWidget> {
  String _apiResponse = 'No response yet';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'API Test Widget',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isLoading ? null : _testPlacesApi,
            child: Text(_isLoading ? 'Loading...' : 'Test Places API'),
          ),
          SizedBox(height: 16),
          Text(
            'API Response:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: Text(
                  _apiResponse,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _testPlacesApi() async {
    setState(() {
      _isLoading = true;
      _apiResponse = 'Loading...';
    });

    try {
      print('🔑 TESTING API KEY: ${ApiConfig.apiKey}');
      
      final url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json'
          '?input=New York'
          '&key=${ApiConfig.apiKey}'
          '&types=(cities)';
          
      print('🌐 TEST API REQUEST: $url');
      
      final response = await http.get(Uri.parse(url));
      
      print('📊 TEST API RESPONSE STATUS: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final prettyJson = const JsonEncoder.withIndent('  ').convert(data);
        
        print('📋 TEST API RESPONSE: $prettyJson');
        
        setState(() {
          _apiResponse = prettyJson;
          _isLoading = false;
        });
      } else {
        print('❌ API TEST FAILED: Network error ${response.statusCode}');
        setState(() {
          _apiResponse = 'Network error: ${response.statusCode}\n${response.body}';
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('❌ API TEST EXCEPTION: $e');
      print('STACK TRACE: $stackTrace');
      setState(() {
        _apiResponse = 'Error: $e\n$stackTrace';
        _isLoading = false;
      });
    }
  }
} 