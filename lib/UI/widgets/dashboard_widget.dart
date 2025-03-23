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
  bool _showLocationSearch = true;

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
  final isSmallScreen = MediaQuery.of(context).size.width < 400;
  
  return SingleChildScrollView(
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 5),
            
          if (_showLocationSearch)
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: LocationSearchWidget(
                onLocationSelected: _onLocationSelected,
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