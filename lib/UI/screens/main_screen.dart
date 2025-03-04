import 'package:fitness_dashboard_ui/UI/util/responsive.dart';
import 'package:fitness_dashboard_ui/UI/widgets/dashboard_widget.dart';
import 'package:fitness_dashboard_ui/UI/widgets/side_menu_widget.dart';
import 'package:fitness_dashboard_ui/UI/widgets/summary_widget.dart';
import 'package:fitness_dashboard_ui/UI/widgets/bottom_navigation_widget.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      bottomNavigationBar: !isDesktop 
        ? BottomNavigationWidget(onItemSelected: _onItemSelected) 
        : null,
      endDrawer: Responsive.isMobile(context)
          ? SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: const SummaryWidget(),
            )
          : null,
      body: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: 7,
              child: DashboardWidget(),
            ),
            if (isDesktop)
              Expanded(
                flex: 3,
                child: SummaryWidget(),
              ),
          ],
        ),
      ),
    );
  }
}