import 'package:flutter/material.dart';
import 'package:fitness_dashboard_ui/UI/widgets/custom_card_widget.dart';
import 'package:fitness_dashboard_ui/UI/const/constant.dart';
import 'package:fitness_dashboard_ui/UI/services/location_service.dart';
import 'package:fitness_dashboard_ui/UI/widgets/pollutant_details_popup.dart';

class CigaretteSummaryWidget extends StatelessWidget {
  final LocationService locationService;
  final String localAqi = 'Unable to retrieve data.';
  final String universalAqi = 'Unable to retrieve data.';
  final String totalCigarettes = 'Unable to retrieve data.';
  final String healthRisk = 'Unable to retrieve data.';
  
  const CigaretteSummaryWidget({
    super.key,
    required this.locationService,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return PollutantDetailsPopup(
              pollutants: {},  // Since this widget doesn't have access to pollutants, pass empty map
            );
          },
        );
      },
      child: CustomCard(
        useGradient: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title with icon
            Row(
              children: [
                Icon(
                  Icons.smoke_free,
                  color: primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Cigarette Summary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: dangerColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: dangerColor,
                        size: 14,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'High Risk',
                        style: TextStyle(
                          color: dangerColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // GIF and Content
            Row(
              children: [
                // Left side - GIF
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(borderRadius),
                      image: DecorationImage(
                        image: AssetImage('assets/images/cigs_1.gif'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Right side - Stats
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cigarettes per Month
                      _buildStatItem(
                        icon: Icons.smoking_rooms,
                        title: 'Cigarettes',
                        value: '$totalCigarettes',
                        valueColor: primaryColor,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Health Risk
                      _buildStatItem(
                        icon: Icons.health_and_safety,
                        title: 'Local AQI',
                        value: '$localAqi',
                        valueColor: dangerColor,
                      ),

                      const SizedBox(height: 16),

                      _buildStatItem(
                        icon: Icons.health_and_safety,
                        title: 'Universal AQI',
                        value: '$universalAqi',
                        valueColor: dangerColor,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Progress indicator
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Reduction Goal',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '25%',
                                style: TextStyle(
                                  color: successColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: 0.25,
                              backgroundColor: Colors.grey.withOpacity(0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(successColor),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String value,
    required Color valueColor,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: valueColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: valueColor,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}