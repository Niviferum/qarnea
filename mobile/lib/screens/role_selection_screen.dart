import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'producer_questionnaire_screen.dart';
import 'consumer_auth_screen.dart';
import '../theme/transitions.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenH = mq.size.height;
    final topPadding = mq.padding.top;

    return Scaffold(
      backgroundColor: QarneaColors.blancCasse,
      body: Padding(
        padding: EdgeInsets.fromLTRB(20, topPadding + 16, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: screenH * 0.025),

            Text(
              'Vous êtes plutôt\nla personne qui...',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'OpenSauceTwo',
                fontSize: (screenH * 0.034).clamp(22.0, 32.0),
                fontWeight: FontWeight.w900,
                color: QarneaColors.vertSapin,
                height: 1.2,
              ),
            ),

            SizedBox(height: screenH * 0.025),

            // Card "Mange" (consommateur)
            Expanded(
              child: _RoleCard(
                image: 'assets/images/role_mange.jpg',
                title: 'Mange',
                subtitle: '(Consommateur)',
                onTap: () => Navigator.of(context).push(
                  fadeRoute(const ConsumerAuthScreen()),
                ),
              ),
            ),

            SizedBox(height: screenH * 0.012),

            Text(
              'ou',
              style: TextStyle(
                fontFamily: 'OpenSauceTwo',
                fontSize: (screenH * 0.030).clamp(20.0, 28.0),
                fontWeight: FontWeight.w400,
                color: QarneaColors.vertSapin,
                
              ),
            ),

            SizedBox(height: screenH * 0.012),

            // Card "Partage" (vendeur)
            Expanded(
              child: _RoleCard(
                image: 'assets/images/role_partage.jpg',
                title: 'Partage',
                subtitle: '(Vendeur)',
                onTap: () => Navigator.of(context).push(
                  fadeRoute(const ProducerQuestionnaireScreen()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String image;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _RoleCard({
    required this.image,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(44),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            Image.asset(image, fit: BoxFit.cover),

            // Gradient blur — stacked layers, bottom accumulates more blur
            for (final height in [80.0, 50.0, 30.0, 10.0])
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: height,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ),

            // Gradient overlay — dark at bottom
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  stops: [0.0, 0.45, 1.0],
                  colors: [
                    Color(0xCC000000),
                    Color(0x55000000),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            // Bottom-left: title + subtitle
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'OpenSauceTwo',
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.0,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontFamily: 'HostGrotesk',
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withAlpha(220),
                            letterSpacing: -0.22,
                          ),
                        ),
                    ],
                  ),

                  Container(
                    width: 80,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 1),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(
                      Icons.arrow_right_alt_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
