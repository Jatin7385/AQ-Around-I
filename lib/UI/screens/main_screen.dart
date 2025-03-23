import 'package:fitness_dashboard_ui/UI/util/responsive.dart';
import 'package:fitness_dashboard_ui/UI/widgets/dashboard_widget.dart';
import 'package:fitness_dashboard_ui/UI/const/constant.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _selectedIndex = 0;

  // List of screens to navigate between
  final List<Widget> _screens = [
    const DashboardWidget(),
    // Add other screens as needed
  ];

  @override
  void initState() {
    print('main_screen :: initState start');
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    developer.log('MainScreen initialized', name: 'screen.lifecycle');
    _initializeScreen();
    print('main_screen :: initState end');
  }

  Future<void> _initializeScreen() async {
    try {
      developer.log('Initializing MainScreen', name: 'screen.lifecycle');
      // Add any async initialization here
    } catch (e, stackTrace) {
      developer.log('Error initializing MainScreen',
          name: 'screen.error',
          error: e,
          stackTrace: stackTrace);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    developer.log('MainScreen disposed', name: 'screen.lifecycle');
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    developer.log('App lifecycle state changed to: $state', name: 'screen.lifecycle');
  }

  void _onItemSelected(int index) {
    developer.log('Navigation item selected: $index', name: 'screen.navigation');
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    try {
      developer.log('Building MainScreen', name: 'screen.lifecycle');
      print('main_screen :: build start');
      final isDesktop = Responsive.isDesktop(context);
      final isMobile = Responsive.isMobile(context);
      developer.log('Device type: ${isDesktop ? "Desktop" : isMobile ? "Mobile" : "Tablet"}', 
          name: 'screen.layout');

      return Scaffold(
        backgroundColor: backgroundColor,
        // Add a modern app bar for mobile
        appBar: isMobile 
          ? AppBar(
              backgroundColor: backgroundColor,
              elevation: 0,
              title: Row(
                children: [
                  const Text(
                    'AQ Around I',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          : null,
        
        // Main body
        body: SafeArea(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main content
              Expanded(
                flex: 7,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: isDesktop ? 30 : 16,
                    horizontal: isDesktop ? 30 : 5,
                  ),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                  ),
                  child: _screens[_selectedIndex],
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e, stackTrace) {
      developer.log('Error building MainScreen',
          name: 'screen.error',
          error: e,
          stackTrace: stackTrace);
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Error loading dashboard',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  setState(() {});
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
  }
}