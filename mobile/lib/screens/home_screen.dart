import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/producteur_service.dart';
import '../theme/colors.dart';
import 'marketplace_screen.dart';
import 'producer_dashboard_screen.dart';
import 'login_screen.dart';
import '../theme/transitions.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _route();
  }

  Future<void> _route() async {
    try {
      final profil = await ProducteurService().getMonProfil();
      if (!mounted) return;
      if (profil != null) {
        Navigator.of(context).pushReplacement(
          fadeRoute(const ProducerDashboardScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          fadeRoute(const MarketplaceScreen()),
        );
      }
    } catch (_) {
      if (mounted) {
        final nav = Navigator.of(context);
        await AuthService().logout();
        nav.pushAndRemoveUntil(
          fadeRoute(const LoginScreen()),
          (_) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: QarneaColors.blancCasse,
      body: Center(
        child: CircularProgressIndicator(color: QarneaColors.vertSapin),
      ),
    );
  }
}
