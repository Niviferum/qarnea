import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/colors.dart';
import '../theme/transitions.dart';
import 'consumer_profile_screen.dart';
import 'consumer_scanner_view.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final _searchController = TextEditingController();
  int _selectedNavIndex = 1;
  String? _selectedTag;

  static const _tags = [
    'Volaille 🐓',
    'Lait 🥛',
    'Viande rouge 🥩',
    'Miel 🐝',
    'Agrumes 🍊',
    'Légumes 🥦',
    'Fruits 🍎',
  ];

  // Données mock — à remplacer par l'API /producteurs/nearby
  static const _producers = [
    _ProducerData(name: 'Ferme du petit louboutin', distance: '2 km', isFavorite: true,  image: 'assets/images/producer_card1.jpg'),
    _ProducerData(name: 'La belle étoile',          distance: '2,8 km', isFavorite: false, image: 'assets/images/producer_card2.jpg'),
    _ProducerData(name: 'Jardin des délices',        distance: '3 km', isFavorite: true,  image: 'assets/images/producer_card3.jpg'),
    _ProducerData(name: 'Vignoble des doux rêves',   distance: '3,9 km', isFavorite: false, image: 'assets/images/producer_card4.jpg'),
    _ProducerData(name: 'Verger des souvenirs',       distance: '4,2 km', isFavorite: false, image: 'assets/images/producer_card5.jpg'),
    _ProducerData(name: 'Chalet des nuages',          distance: '5 km', isFavorite: true,  image: 'assets/images/producer_card6.jpg'),
    _ProducerData(name: 'Mont blanc',                 distance: '5 km', isFavorite: true,  image: 'assets/images/producer_card7.jpg'),
    _ProducerData(name: 'Auberge de la Vallée',       distance: '5 km', isFavorite: true,  image: 'assets/images/producer_card8.jpg'),
    _ProducerData(name: 'Antonin en Train',           distance: '5,6 km', isFavorite: true,  image: 'assets/images/producer_card9.jpg'),
    _ProducerData(name: 'Le petit Colin',             distance: '6,2 km', isFavorite: false, image: 'assets/images/producer_card10.jpg'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final p in _producers) {
        precacheImage(ResizeImage(AssetImage(p.image), width: 400), context);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final bottomPadding = mq.padding.bottom;

    return Scaffold(
      backgroundColor: QarneaColors.blancCasse,
      body: SafeArea(
        child: Stack(
          children: [
            IndexedStack(
              index: _selectedNavIndex,
              children: [
                _buildPlaceholder(Icons.location_on_outlined, 'Carte', 'Bientôt disponible'),
                _buildMarketplaceTab(bottomPadding),
                _buildPlaceholder(Icons.home_outlined, 'Accueil', 'Bientôt disponible'),
                ConsumerScannerView(isActive: _selectedNavIndex == 3),
                _buildPlaceholder(Icons.inventory_2_outlined, 'Commandes', 'Bientôt disponible'),
              ],
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20 + bottomPadding,
              child: _NavBar(
                selectedIndex: _selectedNavIndex,
                onTap: (i) => setState(() => _selectedNavIndex = i),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketplaceTab(double bottomPadding) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: _SearchBar(
              controller: _searchController,
              onSettingsTap: () => Navigator.of(context).push(
                fadeRoute(const ConsumerProfileScreen()),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 51,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              itemCount: _tags.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (_, i) => _TagChip(
                label: _tags[i],
                selected: _selectedTag == _tags[i],
                onTap: () => setState(() =>
                    _selectedTag = _selectedTag == _tags[i] ? null : _tags[i]),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + 70 + 20 + bottomPadding),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (_, i) => _ProducerCard(data: _producers[i]),
              childCount: _producers.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 185 / 165,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder(IconData icon, String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: QarneaColors.textLight),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'OpenSauceTwo',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: QarneaColors.vertSapin,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontFamily: 'HostGrotesk',
              fontSize: 13,
              fontWeight: FontWeight.w300,
              color: QarneaColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Search bar ────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSettingsTap;

  const _SearchBar({required this.controller, required this.onSettingsTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _IconButton(
          width: 42,
          height: 39,
          child: SvgPicture.asset('assets/icons/icon_filter.svg',
              width: 22, height: 20,
              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 39,
            decoration: BoxDecoration(
              color: QarneaColors.blanc,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: QarneaColors.accentBlanc),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    style: const TextStyle(
                      fontFamily: 'HostGrotesk',
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      color: QarneaColors.vertSapin,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Rechercher...',
                      hintStyle: TextStyle(
                        fontFamily: 'HostGrotesk',
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        color: QarneaColors.textLight,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                SvgPicture.asset('assets/icons/icon_arrow_search.svg',
                    width: 14, height: 14,
                    colorFilter: const ColorFilter.mode(QarneaColors.textLight, BlendMode.srcIn)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        _IconButton(
          width: 40,
          height: 40,
          onTap: onSettingsTap,
          child: SvgPicture.asset('assets/icons/icon_settings.svg',
              width: 22, height: 22,
              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
        ),
      ],
    );
  }
}

class _IconButton extends StatelessWidget {
  final double width;
  final double height;
  final Widget child;
  final VoidCallback? onTap;

  const _IconButton({
    required this.width,
    required this.height,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: QarneaColors.vertSapin,
          borderRadius: BorderRadius.circular(10),
        ),
        child: child,
      ),
    );
  }
}

// ── Tag chip ──────────────────────────────────────────────────────────────────

class _TagChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TagChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? QarneaColors.vertCitron : const Color(0xFFE6EAE9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'HostGrotesk',
            fontSize: 14,
            fontWeight: FontWeight.w300,
            color: QarneaColors.vertSapin,
            letterSpacing: -0.28,
          ),
        ),
      ),
    );
  }
}

// ── Producer card ─────────────────────────────────────────────────────────────

class _ProducerData {
  final String name;
  final String distance;
  final bool isFavorite;
  final String image;

  const _ProducerData({
    required this.name,
    required this.distance,
    required this.isFavorite,
    required this.image,
  });
}

class _ProducerCard extends StatefulWidget {
  final _ProducerData data;

  const _ProducerCard({required this.data});

  @override
  State<_ProducerCard> createState() => _ProducerCardState();
}

class _ProducerCardState extends State<_ProducerCard> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.data.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Photo de la ferme — precachée + fade-in
            Image(
              image: ResizeImage(AssetImage(widget.data.image), width: 400),
              fit: BoxFit.cover,
              frameBuilder: (_, child, frame, wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded) return child;
                return AnimatedOpacity(
                  opacity: frame == null ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeIn,
                  child: child,
                );
              },
            ),

            // Gradient blur progressif — 3 couches (σ cumulé : 4.5 en bas → 1.5 en haut)
            for (final h in [40.0, 22.0, 8.0])
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: h,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ),

            // Gradient couleur
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

            // Contenu
            Positioned(
              left: 15,
              right: 15,
              top: 10,
              bottom: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.data.name,
                    style: const TextStyle(
                      fontFamily: 'OpenSauceTwo',
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.data.distance,
                            style: const TextStyle(
                              fontFamily: 'HostGrotesk',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.28,
                            ),
                          ),
                          const SizedBox(width: 5),
                          GestureDetector(
                            onTap: () =>
                                setState(() => _isFavorite = !_isFavorite),
                            child: SvgPicture.asset(
                              _isFavorite
                                  ? 'assets/icons/icon_star_filled.svg'
                                  : 'assets/icons/icon_star.svg',
                              width: 17,
                              height: 17,
                              colorFilter: ColorFilter.mode(
                                _isFavorite ? QarneaColors.vertCitron : Colors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 44,
                        height: 33,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: SvgPicture.asset(
                          'assets/icons/icon_arrow_card.svg',
                          width: 18, height: 18,
                          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                        ),
                      ),
                    ],
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

// ── Nav bar ───────────────────────────────────────────────────────────────────

class _NavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _NavBar({required this.selectedIndex, required this.onTap});

  static const _iconPaths = [
    'assets/icons/nav_c_location.svg',
    'assets/icons/nav_c_basket.svg',
    'assets/icons/nav_c_home.svg',
    'assets/icons/nav_c_scanner.svg',
    'assets/icons/nav_c_orders.svg',
  ];

  static const _pillSize = 56.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: QarneaColors.blanc,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: QarneaColors.accentBlanc),
      ),
      child: LayoutBuilder(
        builder: (_, constraints) {
          final itemW = constraints.maxWidth / _iconPaths.length;
          final pillLeft = selectedIndex * itemW + (itemW - _pillSize) / 2;
          final pillTop = (constraints.maxHeight - _pillSize) / 2;

          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 700),
                curve: const Cubic(0.34, 1.3, 0.64, 1.0),
                left: pillLeft,
                top: pillTop,
                width: _pillSize,
                height: _pillSize,
                child: Container(
                  decoration: BoxDecoration(
                    color: QarneaColors.vertCitron,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              Row(
                children: List.generate(
                  _iconPaths.length,
                  (i) => Expanded(
                    child: GestureDetector(
                      onTap: () => onTap(i),
                      behavior: HitTestBehavior.opaque,
                      child: Center(
                        child: SvgPicture.asset(
                          _iconPaths[i],
                          width: 34,
                          height: 34,
                          colorFilter: const ColorFilter.mode(
                            QarneaColors.vertSapin,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
