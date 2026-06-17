import 'package:flutter/material.dart';
import 'theme/colors.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const QarneaApp());
}

class QarneaApp extends StatelessWidget {
  const QarneaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Qarnea',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: QarneaColors.vertSapin,
          primary: QarneaColors.vertSapin,
          surface: QarneaColors.blancCasse,
        ),
        scaffoldBackgroundColor: QarneaColors.blancCasse,
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
