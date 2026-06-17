import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/colors.dart';
import 'role_selection_screen.dart';
import '../theme/transitions.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardingPage(
      backgroundImage: 'assets/images/onboarding_bg1.jpg',
      decoImage: 'assets/images/deco_leaf1.svg',
      title: 'Redécouvrez la qualité',
      description: 'Parce que votre santé commence par ce que vous mangez, nous décryptons pour vous l\'impact réel de vos produits.',
      showDots: true,
      dotsTotal: 3,
      dotIndex: 0,
      cardTopRatio: 0.661,
      decoWidthRatio: 0.295,
      decoRightRatio: 0.079,
    ),
    _OnboardingPage(
      backgroundImage: 'assets/images/onboarding_bg2.jpg',
      decoImage: 'assets/images/deco_leaf2.svg',
      title: 'Respectez le vivant',
      description: 'Soutenez des modes d\'élevage dignes. Nous valorisons les agriculteurs qui placent le bien-être animal au cœur de leur métier.',
      showDots: true,
      dotsTotal: 3,
      dotIndex: 1,
      cardTopRatio: 0.661,
      decoWidthRatio: 0.244,
      decoRightRatio: 0.151,
    ),
    _OnboardingPage(
      backgroundImage: 'assets/images/onboarding_bg3.jpg',
      decoImage: 'assets/images/deco_leaf3.svg',
      title: 'Agissez localement',
      description: 'Supprimez les intermédiaires pour recréer un lien direct et solidaire avec les producteurs passionnés de votre région.',
      showDots: true,
      dotsTotal: 3,
      dotIndex: 2,
      cardTopRatio: 0.661,
      decoWidthRatio: 0.437,
      decoRightRatio: 0.135,
    ),
  ];

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pushReplacement(
        fadeRoute(const RoleSelectionScreen()),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _pages.length,
        onPageChanged: (i) => setState(() => _currentPage = i),
        itemBuilder: (_, i) => _OnboardingPageView(
          page: _pages[i],
          pageIndex: i,
          currentPage: _currentPage,
          totalPages: _pages.length,
          onContinue: _next,
        ),
      ),
    );
  }
}

class _OnboardingPage {
  final String backgroundImage;
  final String? decoImage;
  final String title;
  final String description;
  final bool showDots;
  final int dotsTotal;
  final int dotIndex;
  final double cardTopRatio;
  // Deco leaf proportional dimensions (fraction of screen width)
  final double decoWidthRatio;
  final double decoRightRatio;
  const _OnboardingPage({
    required this.backgroundImage,
    this.decoImage,
    required this.title,
    required this.description,
    this.showDots = false,
    this.dotsTotal = 3,
    this.dotIndex = 0,
    this.cardTopRatio = 0.661,
    this.decoWidthRatio = 0.295,
    this.decoRightRatio = 0.079,
  });
}

class _OnboardingPageView extends StatelessWidget {
  final _OnboardingPage page;
  final int pageIndex;
  final int currentPage;
  final int totalPages;
  final VoidCallback onContinue;

  const _OnboardingPageView({
    required this.page,
    required this.pageIndex,
    required this.currentPage,
    required this.totalPages,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenH = mq.size.height;
    final screenW = mq.size.width;
    final topPadding = mq.padding.top;
    final bottomPadding = mq.padding.bottom;

    // Figma: card top at 66.1% of 932px screen, 10px margin everywhere
    // Card height = screen - cardTop - 10px bottom margin
    final cardTopRatio = 0.661;
    final cardMargin = screenW * 0.023; // ~10px on 430px screen
    final cardTop = screenH * cardTopRatio;
    final cardHeight = screenH - cardTop - cardMargin - bottomPadding;

    // Deco oval: right offset and width come from Figma inset values per slide.
    final decoRight = screenW * page.decoRightRatio;
    final decoWidth = screenW * page.decoWidthRatio;

    // Measure the title text so the oval centers on its last line regardless
    // of screen size or wrapping behaviour.
    final titleFontSize = (screenH * 0.032).clamp(22.0, 30.0);
    final cardInnerWidth = screenW - 2 * cardMargin - 48.0; // 24 px padding each side
    final tp = TextPainter(
      text: TextSpan(
        text: page.title,
        style: TextStyle(
          fontFamily: 'OpenSauceTwo',
          fontSize: titleFontSize,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: cardInnerWidth);

    // Title starts at: card top + top padding (20) + dots bar (5) + dots spacing
    final titleTopAbs = cardTop + 20.0 + 5.0 + screenH * 0.022;

    // SVG viewBox height/width ratios for each deco asset
    final decoAspect = page.decoImage == 'assets/images/deco_leaf2.svg'
        ? 51.0 / 105.0
        : page.decoImage == 'assets/images/deco_leaf3.svg'
            ? 52.0 / 188.0
            : 56.0001 / 127.269; // deco_leaf1
    final decoHeight = decoWidth * decoAspect;

    // Center the oval on the vertical midpoint of the last text line
    final decoTop = titleTopAbs + tp.height - tp.preferredLineHeight / 2 - decoHeight / 2;

    // Logo header: "Bienvenue sur" at ~9.9% from top, logo just below
    final headerTop = topPadding + screenH * 0.055;

    return Stack(
      children: [
        // ── Background image ────────────────────────────────────────────
        Positioned.fill(
          child: Image.asset(page.backgroundImage, fit: BoxFit.cover),
        ),
        // Blur uniquement sur le quart supérieur
        Positioned.fill(
          child: ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 0.17, 0.27],
              colors: [Colors.white, Colors.white, Colors.transparent],
            ).createShader(bounds),
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Image.asset(page.backgroundImage, fit: BoxFit.cover),
            ),
          ),
        ),
        Positioned.fill(
          child: Container(color: Colors.black.withAlpha(51)),
        ),

        // ── "Bienvenue sur" + logo ──────────────────────────────────────
        Positioned(
          top: headerTop,
          left: 0,
          right: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Bienvenue sur',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'OpenSauceTwo',
                  fontSize: (screenH * 0.026).clamp(18.0, 26.0),
                  fontWeight: FontWeight.w400,
                  color: QarneaColors.blancCasse,
                ),
              ),
              SizedBox(height: screenH * 0.008),
              SvgPicture.asset(
                'assets/images/logo_white.svg',
                height: (screenH * 0.055).clamp(36.0, 52.0),
              ),
            ],
          ),
        ),

        // ── White card (fully rounded, 10px margins all sides) ──────────
        Positioned(
          left: cardMargin,
          right: cardMargin,
          bottom: cardMargin + bottomPadding,
          height: cardHeight,
          child: Container(
            decoration: BoxDecoration(
              color: QarneaColors.blanc,
              borderRadius: BorderRadius.circular(40),
            ),
            padding: EdgeInsets.fromLTRB(24, 20, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Progress dots (optionnel selon la page)
                if (page.showDots) ...[
                  Row(
                    children: List.generate(
                      page.dotsTotal,
                      (i) => Expanded(
                        child: Container(
                          margin: EdgeInsets.only(right: i < page.dotsTotal - 1 ? 5 : 0),
                          height: 5,
                          decoration: BoxDecoration(
                            color: i <= page.dotIndex
                                ? QarneaColors.vertCitron
                                : QarneaColors.accentBlanc,
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenH * 0.022),
                ],

                // Title
                Text(
                  page.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'OpenSauceTwo',
                    fontSize: (screenH * 0.032).clamp(22.0, 30.0),
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),

                SizedBox(height: screenH * 0.012),

                // Description
                Text(
                  page.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'HostGrotesk',
                    fontSize: (screenH * 0.018).clamp(13.0, 17.0),
                    fontWeight: FontWeight.w300,
                    color: Colors.black,
                    letterSpacing: -0.32,
                  ),
                ),

                const Spacer(),

                // Continuer button
                SizedBox(
                  width: screenW * 0.814, // ~350px on 430px
                  height: (screenH * 0.056).clamp(40.0, 52.0),
                  child: ElevatedButton(
                    onPressed: onContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: QarneaColors.vertCitron,
                      foregroundColor: QarneaColors.vertSapin,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      pageIndex < totalPages - 1 ? 'Continuer' : 'Commencer',
                      style: const TextStyle(
                        fontFamily: 'HostGrotesk',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.32,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Deco leaf — overlaps the card top-right, rotated 180° ───────
        if (page.decoImage != null)
          Positioned(
            top: decoTop,
            right: decoRight,
            width: decoWidth,
            child: Transform.rotate(
              angle: 3.14159,
              child: SvgPicture.asset(
                page.decoImage!,
                width: decoWidth,
                fit: BoxFit.contain,
              ),
            ),
          ),
      ],
    );
  }
}
