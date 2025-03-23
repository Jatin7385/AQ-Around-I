import 'package:flutter/material.dart';
import 'package:fitness_dashboard_ui/UI/util/responsive.dart';
import 'package:fitness_dashboard_ui/UI/widgets/header_widget.dart';
import 'package:fitness_dashboard_ui/UI/widgets/cigarette_summary_widget.dart';
import 'package:fitness_dashboard_ui/UI/widgets/aqi_summary_widget.dart';
import 'package:fitness_dashboard_ui/UI/widgets/air_quality_details_widget.dart';
import 'package:fitness_dashboard_ui/UI/widgets/line_chart_card.dart';
import 'package:fitness_dashboard_ui/UI/widgets/bar_graph_widget.dart';
import 'package:fitness_dashboard_ui/UI/widgets/location_search_widget.dart';
import 'package:fitness_dashboard_ui/UI/services/location_service.dart';
import 'dart:developer' as developer;

class DashboardWidget extends StatefulWidget {
  const DashboardWidget({super.key});

  @override
  State<DashboardWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  final LocationService _locationService = LocationService();
  bool _showLocationSearch = false;

  @override
  void initState() {
    print('dashboard_widget :: initState start');
    super.initState();
    print('dashboard_widget :: initState end');
    developer.log('DashboardWidget initialized', name: 'dashboard.widget');
  }

  void _onLocationSelected(double lat, double lng, String locationName) {
    print('dashboard_widget :: _onLocationSelected start');
    developer.log('Location selected: $locationName ($lat, $lng)', name: 'dashboard.location');
    _locationService.updateLocation(lat, lng, locationName);
    setState(() {
      _showLocationSearch = false;
    });
    print('dashboard_widget :: _onLocationSelected end');
  }

  @override
  Widget build(BuildContext context) {
    print('dashboard_widget :: build start');
    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 18),
            const HeaderWidget(),
            const SizedBox(height: 18),
            
            // Location Search
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Location',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    icon: Icon(
                      _showLocationSearch ? Icons.close : Icons.search,
                      color: Colors.white,
                      size: 20,
                    ),
                    label: Text(
                      _showLocationSearch ? 'Cancel' : 'Search Location',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      setState(() {
                        _showLocationSearch = !_showLocationSearch;
                      });
                    },
                  ),
                ],
              ),
            ),
            
            if (_showLocationSearch)
              Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: LocationSearchWidget(
                  onLocationSelected: _onLocationSelected,
                ),
              ),
            
            // Air Quality Section Title
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.air_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Air Quality & Health',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            
            // Air Quality Widgets
            AQISummaryWidget(locationService: _locationService),
            
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}