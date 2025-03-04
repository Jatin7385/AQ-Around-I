import 'package:flutter/material.dart';
import 'package:fitness_dashboard_ui/UI/widgets/custom_card_widget.dart';

class AQISummaryWidget extends StatelessWidget {
  final double aqi;
  final String location;

  const AQISummaryWidget({
    super.key,
    required this.aqi,
    required this.location,
  });

  Color _getAQIColor(double aqi) {
    if (aqi <= 50) return Colors.green;
    if (aqi <= 100) return Colors.yellow;
    if (aqi <= 150) return Colors.orange;
    if (aqi <= 200) return Colors.red;
    return Colors.purple;
  }

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Air Quality Index',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                Text(
                  aqi.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: _getAQIColor(aqi),
                  ),
                ),
                Text(
                  location,
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}