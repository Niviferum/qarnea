import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/colors.dart';
import 'onboarding_screen.dart';
import '../theme/transitions.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          fadeRoute(const OnboardingScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QarneaColors.vertSapin,
      body: Center(
        child: SvgPicture.asset(
          'assets/images/logo_splash.svg',
          width: MediaQuery.of(context).size.width * 0.6,
        ),
      ),
    );
  }
}
