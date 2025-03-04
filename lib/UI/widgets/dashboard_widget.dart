import 'package:flutter/material.dart';
import 'package:fitness_dashboard_ui/UI/util/responsive.dart';
import 'package:fitness_dashboard_ui/UI/widgets/header_widget.dart';
import 'package:fitness_dashboard_ui/UI/widgets/cigarette_summary_widget.dart';
import 'package:fitness_dashboard_ui/UI/widgets/aqi_summary_widget.dart';
import 'package:fitness_dashboard_ui/UI/widgets/line_chart_card.dart';
import 'package:fitness_dashboard_ui/UI/widgets/bar_graph_widget.dart';

class DashboardWidget extends StatelessWidget {
  const DashboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          children: [
            const SizedBox(height: 18),
            const HeaderWidget(),
            const SizedBox(height: 18),
            const CigaretteSummaryWidget(
              totalCigarettes: 120,
              healthRisk: 45.5,
            ),
            // const SizedBox(height: 18),
            // const AQISummaryWidget(
            //   aqi: 85.6,
            //   location: 'New York City',
            // ),
            const SizedBox(height: 18),
            const LineChartCard(),
            // const SizedBox(height: 18),
            // const BarGraphCard(),
            // const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}