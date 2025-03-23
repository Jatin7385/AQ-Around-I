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

  // Get appropriate color based on category
  Color _getCategoryColor(int index) {
    switch (index) {
      case 0: return Colors.blue;
      case 1: return Colors.purple;
      case 2: return Colors.lightBlue;
      case 3: return Colors.red;
      case 4: return Colors.green;
      case 5: return Colors.pink;
      case 6: return Colors.amber;
      default: return Colors.blue;
    }
  }

  @override
Widget build(BuildContext context) {
  final isSmallScreen = MediaQuery.of(context).size.width < 400;
  
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: Color(0xFF1E2428),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.black12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            children: [
              Icon(
                Icons.health_and_safety, 
                color: Colors.blue[300],
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Health Recommendations',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),

        // Tab Bar with scrollable tabs
        Container(
          height: 40,
          margin: const EdgeInsets.symmetric(horizontal: 12),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.blue,
            ),
            dividerColor: Colors.transparent,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey[400],
            labelStyle: TextStyle(
              fontSize: isSmallScreen ? 13 : 15,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: isSmallScreen ? 13 : 15,
              fontWeight: FontWeight.w400,
            ),
            padding: EdgeInsets.zero,
            tabs: List.generate(7, (index) {
              return _buildColorCodedTab(index);
            }),
          ),
        ),

        // Tab Content - adjusted height
        Container(
          margin: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFF1A1F24),
            borderRadius: BorderRadius.circular(16),
          ),
          constraints: BoxConstraints(
            minHeight: 120,
            maxHeight: isSmallScreen ? 180 : 220,
          ),
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildRecommendationContent(widget.recommendations?.generalPopulation, 'General Population', Icons.people, 0),
              _buildRecommendationContent(widget.recommendations?.elderly, 'Elderly', Icons.elderly, 1),
              _buildRecommendationContent(widget.recommendations?.lungDiseasePopulation, 'People with Lung Disease', Icons.air, 2),
              _buildRecommendationContent(widget.recommendations?.heartDiseasePopulation, 'People with Heart Disease', Icons.favorite, 3),
              _buildRecommendationContent(widget.recommendations?.athletes, 'Athletes & Active Individuals', Icons.fitness_center, 4),
              _buildRecommendationContent(widget.recommendations?.pregnantWomen, 'Pregnant Women', Icons.pregnant_woman, 5),
              _buildRecommendationContent(widget.recommendations?.children, 'Children', Icons.child_care, 6),
            ],
          ),
        ),
      ],
    ),
  );
}
  // Custom color-coded tab
  Widget _buildColorCodedTab(int index) {
    Color tabColor = _getCategoryColor(index);
    String tabText;
    IconData tabIcon;
    
    switch (index) {
      case 0:
        tabText = 'General';
        tabIcon = Icons.people;
        break;
      case 1:
        tabText = 'Elderly';
        tabIcon = Icons.elderly;
        break;
      case 2:
        tabText = 'Lung Disease';
        tabIcon = Icons.air;
        break;
      case 3:
        tabText = 'Heart Disease';
        tabIcon = Icons.favorite;
        break;
      case 4:
        tabText = 'Athletes';
        tabIcon = Icons.fitness_center;
        break;
      case 5:
        tabText = 'Pregnant';
        tabIcon = Icons.pregnant_woman;
        break;
      case 6:
        tabText = 'Children';
        tabIcon = Icons.child_care;
        break;
      default:
        tabText = 'General';
        tabIcon = Icons.people;
    }
    
    return Container(
    margin: EdgeInsets.symmetric(horizontal: 2),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
    ),
    child: Tab(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: _tabController.index == index ? tabColor : Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(tabIcon, size: 14),
            SizedBox(width: 4),
            Text(tabText),
          ],
        ),
      ),
    ),
  );
}

  // Enhanced recommendation content with color coding
  Widget _buildRecommendationContent(String? content, String title, IconData icon, int index) {
    final text = content ?? 'Data not available';
    final Color categoryColor = _getCategoryColor(index);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: categoryColor, size: 18),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: categoryColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Divider(color: categoryColor.withOpacity(0.3), height: 24),
        Expanded(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 15,
                height: 1.6,
              ),
            ),
          ),
        ),
      ],
    );
  }
}