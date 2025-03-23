import 'package:fitness_dashboard_ui/UI/const/constant.dart';
import 'package:fitness_dashboard_ui/UI/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'dart:async';

void main() {
  try {
    developer.log('Starting application initialization', name: 'app.startup');
    WidgetsFlutterBinding.ensureInitialized();
    
    // Set up global error handling
    FlutterError.onError = (FlutterErrorDetails details) {
      developer.log('Flutter error: ${details.exception}',
          name: 'app.error',
          error: details.exception,
          stackTrace: details.stack);
    };

    // Handle platform errors
    PlatformDispatcher.instance.onError = (error, stack) {
      developer.log('Platform error: $error',
          name: 'app.error',
          error: error,
          stackTrace: stack);
      return true;
    };

    runApp(const MyApp());
    developer.log('Application initialized successfully', name: 'app.startup');
  } catch (e, stackTrace) {
    developer.log('Fatal error during application startup',
        name: 'app.error',
        error: e,
        stackTrace: stackTrace);
    rethrow;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    developer.log('Building MyApp widget', name: 'app.lifecycle');
    return MaterialApp(
      title: 'AQ Around I',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: backgroundColor,
        primaryColor: primaryColor,
        cardColor: cardBackgroundColor,
        colorScheme: ColorScheme.dark(
          primary: primaryColor,
          secondary: secondaryColor,
          surface: cardBackgroundColor,
          background: backgroundColor,
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.grey[300]),
          bodyMedium: TextStyle(color: Colors.grey[400]),
          titleLarge: const TextStyle(color: Colors.white),
          titleMedium: const TextStyle(color: Colors.white),
        ),
      ),
      home: const MainScreen(),
    );
  }
}
