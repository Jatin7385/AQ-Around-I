import 'package:flutter/material.dart';
import 'package:fitness_dashboard_ui/UI/data/pollutant_data.dart';
import 'package:fitness_dashboard_ui/UI/widgets/custom_card_widget.dart';
import 'package:fitness_dashboard_ui/UI/const/constant.dart';

class PollutantDetailsPopup extends StatelessWidget {
  final PollutantData pollutantData = PollutantData();

  PollutantDetailsPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Pollutant Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1,
                ),
                itemCount: pollutantData.pollutants.length,
                itemBuilder: (context, index) {
                  final pollutant = pollutantData.pollutants[index];
                  return CustomCard(
                    color: pollutant.color.withOpacity(0.2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          pollutant.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: pollutant.color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${pollutant.value}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          pollutant.unit,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}