import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/colors.dart';
import 'home_screen.dart';
import '../theme/transitions.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        fadeRoute(const HomeScreen()),
        (_) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: QarneaColors.vertSapin,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Bienvenue sur',
                style: TextStyle(
                  fontFamily: 'OpenSauceTwo',
                  fontSize: (screenH * 0.026).clamp(18.0, 26.0),
                  fontWeight: FontWeight.w400,
                  color: QarneaColors.blancCasse,
                ),
              ),
              SizedBox(height: screenH * 0.012),
              SvgPicture.asset(
                'assets/images/logo_white.svg',
                height: (screenH * 0.06).clamp(40.0, 56.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
