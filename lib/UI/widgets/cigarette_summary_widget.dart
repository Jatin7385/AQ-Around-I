import 'package:flutter/material.dart';
import 'package:fitness_dashboard_ui/UI/widgets/custom_card_widget.dart';
import 'package:fitness_dashboard_ui/UI/const/constant.dart';
import 'package:fitness_dashboard_ui/UI/widgets/pollutant_details_popup.dart';

class CigaretteSummaryWidget extends StatelessWidget {
  final int totalCigarettes;
  final double healthRisk;

  const CigaretteSummaryWidget({
    super.key,
    required this.totalCigarettes,
    required this.healthRisk,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return PollutantDetailsPopup();
          },
        );
      },
      child: CustomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'Monthly Cigarette Summary',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            
            // GIF and Content
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Center(
                child: Image.asset(
                  'assets/images/cigs_1.gif',
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Statistics Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Cigarettes per Month
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cigs per Month',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '$totalCigarettes',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),

                // Health Risk
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Health Risk',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${healthRisk.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}