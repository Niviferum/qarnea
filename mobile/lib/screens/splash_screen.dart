import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/auth_service.dart';
import '../theme/colors.dart';
import '../theme/transitions.dart';
import 'marketplace_screen.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _authService = AuthService();
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), _navigate);
  }

  Future<void> _navigate({bool forceOnboarding = false}) async {
    if (_navigated || !mounted) return;
    _navigated = true;

    if (forceOnboarding) {
      Navigator.of(context).pushReplacement(fadeRoute(const OnboardingScreen()));
      return;
    }

    final token = await _authService.getAccessToken();
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      token != null
          ? fadeRoute(const MarketplaceScreen())
          : fadeRoute(const OnboardingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QarneaColors.vertSapin,
      body: Center(
        child: GestureDetector(
          onLongPress: () => _navigate(forceOnboarding: true),
          child: SvgPicture.asset(
            'assets/images/logo_splash.svg',
            width: MediaQuery.of(context).size.width * 0.6,
          ),
        ),
      ),
    );
  }
}
