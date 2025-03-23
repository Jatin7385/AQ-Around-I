import 'package:flutter/material.dart';
import 'package:fitness_dashboard_ui/UI/const/constant.dart';
import 'package:fitness_dashboard_ui/UI/model/air_quality_model.dart';

class HealthRecommendationsWidget extends StatefulWidget {
  final HealthRecommendations? recommendations;

  const HealthRecommendationsWidget({
    super.key,
    required this.recommendations,
  });

  @override
  State<HealthRecommendationsWidget> createState() => _HealthRecommendationsWidgetState();
}

class _HealthRecommendationsWidgetState extends State<HealthRecommendationsWidget> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[850]?.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                Icon(Icons.health_and_safety, 
                  color: Colors.blue[200],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Recommendations',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Tab Bar
          Container(
            height: 40,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicator: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(8),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey[400],
              labelStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(text: 'General'),
                Tab(text: 'Elderly'),
                Tab(text: 'Lung Disease'),
                Tab(text: 'Heart Disease'),
                Tab(text: 'Athletes'),
                Tab(text: 'Pregnant'),
                Tab(text: 'Children'),
              ],
            ),
          ),

          // Tab Content
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
            ),
            constraints: BoxConstraints(
              minHeight: 100,
              maxHeight: 200,
            ),
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRecommendationText(widget.recommendations?.generalPopulation ?? 'Data not available'),
                _buildRecommendationText(widget.recommendations?.elderly ?? 'Data not available'),
                _buildRecommendationText(widget.recommendations?.lungDiseasePopulation ?? 'Data not available'),
                _buildRecommendationText(widget.recommendations?.heartDiseasePopulation ?? 'Data not available'),
                _buildRecommendationText(widget.recommendations?.athletes ?? 'Data not available'),
                _buildRecommendationText(widget.recommendations?.pregnantWomen ?? 'Data not available'),
                _buildRecommendationText(widget.recommendations?.children ?? 'Data not available'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationText(String text) {
    return SingleChildScrollView(
      child: Text(
        text,
        style: TextStyle(
          color: Colors.grey[400],
          fontSize: 14,
          height: 1.5,
        ),
      ),
    );
  }
}
