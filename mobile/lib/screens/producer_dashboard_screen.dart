import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/colors.dart';
import '../services/auth_service.dart';
import '../services/producteur_service.dart';
import 'login_screen.dart';
import '../theme/transitions.dart';

class ProducerDashboardScreen extends StatefulWidget {
  const ProducerDashboardScreen({super.key});

  @override
  State<ProducerDashboardScreen> createState() =>
      _ProducerDashboardScreenState();
}

class _ProducerDashboardScreenState extends State<ProducerDashboardScreen> {
  int _selectedNavIndex = 0;
  Map<String, dynamic>? _profil;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfil();
  }

  Future<void> _loadProfil() async {
    try {
      final profil = await ProducteurService().getMonProfil();
      if (mounted) setState(() { _profil = profil; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    await AuthService().logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        fadeRoute(const LoginScreen()),
        (_) => false,
      );
    }
  }

  static const _navIconPaths = [
    'assets/icons/nav_v_home.svg',
    'assets/icons/nav_v_products.svg',
    'assets/icons/nav_v_orders.svg',
    'assets/icons/nav_v_stats.svg',
    'assets/icons/nav_v_profile.svg',
  ];

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final bottomPadding = mq.padding.bottom;

    return Scaffold(
      backgroundColor: QarneaColors.blancCasse,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: QarneaColors.vertSapin),
                    )
                  : IndexedStack(
                      index: _selectedNavIndex,
                      children: [
                        _buildBody(),
                        _buildPlaceholder(Icons.inventory_2_outlined, 'Produits'),
                        _buildPlaceholder(Icons.receipt_long_outlined, 'Commandes'),
                        _buildPlaceholder(Icons.bar_chart_outlined, 'Statistiques'),
                        _buildPlaceholder(Icons.person_outline, 'Profil'),
                      ],
                    ),
            ),
            _buildNavBar(bottomPadding),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final nom = _profil?['nom_exploitation'] as String? ?? 'Ma boutique';
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bonjour !',
                  style: const TextStyle(
                    fontFamily: 'HostGrotesk',
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    color: QarneaColors.textLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  nom,
                  style: const TextStyle(
                    fontFamily: 'OpenSauceTwo',
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: QarneaColors.vertSapin,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined, size: 22),
            color: QarneaColors.vertSapin,
            onPressed: _logout,
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 28),
          _buildStatsRow(),
          const SizedBox(height: 28),
          _buildSectionTitle('Commandes récentes'),
          const SizedBox(height: 12),
          _buildEmptyState(
            icon: Icons.receipt_long_outlined,
            label: 'Aucune commande pour l\'instant',
          ),
          const SizedBox(height: 28),
          _buildSectionTitle('Mes produits'),
          const SizedBox(height: 12),
          _buildAddProductButton(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('0', 'Commandes', Icons.receipt_long_outlined)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('0', 'Produits', Icons.inventory_2_outlined)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('0 €', 'Revenus', Icons.euro_outlined)),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: QarneaColors.blanc,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: QarneaColors.accentBlanc),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: QarneaColors.vertSapin),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'OpenSauceTwo',
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: QarneaColors.vertSapin,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'HostGrotesk',
              fontSize: 11,
              fontWeight: FontWeight.w300,
              color: QarneaColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'OpenSauceTwo',
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: QarneaColors.vertSapin,
      ),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String label}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: QarneaColors.blanc,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: QarneaColors.accentBlanc),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: QarneaColors.textLight),
          const SizedBox(height: 8),
          Text(
            label,
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

  Widget _buildAddProductButton() {
    return GestureDetector(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ajout de produit — bientôt disponible')),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: QarneaColors.blanc,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: QarneaColors.vertCitron,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.add, color: QarneaColors.vertSapin, size: 20),
            SizedBox(width: 8),
            Text(
              'Ajouter un produit',
              style: TextStyle(
                fontFamily: 'HostGrotesk',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: QarneaColors.vertSapin,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(IconData icon, String label) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: QarneaColors.textLight),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'OpenSauceTwo',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: QarneaColors.vertSapin,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Bientôt disponible',
            style: TextStyle(
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

  Widget _buildNavBar(double bottomPadding) {
    const pillSize = 56.0;
    const navH = 70.0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      decoration: const BoxDecoration(
        color: QarneaColors.vertSapin,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: LayoutBuilder(
        builder: (_, constraints) {
          final itemW = constraints.maxWidth / _navIconPaths.length;
          final pillLeft = _selectedNavIndex * itemW + (itemW - pillSize) / 2;

          return SizedBox(
            height: navH + bottomPadding,
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 700),
                  curve: const Cubic(0.34, 1.3, 0.64, 1.0),
                  left: pillLeft,
                  top: (navH - pillSize) / 2,
                  width: pillSize,
                  height: pillSize,
                  child: Container(
                    decoration: BoxDecoration(
                      color: QarneaColors.vertCitron,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: navH,
                  child: Row(
                    children: List.generate(_navIconPaths.length, (i) => Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedNavIndex = i),
                        behavior: HitTestBehavior.opaque,
                        child: Center(
                          child: SvgPicture.asset(
                            _navIconPaths[i],
                            width: 34,
                            height: 34,
                            colorFilter: ColorFilter.mode(
                              i == _selectedNavIndex
                                  ? QarneaColors.vertSapin
                                  : QarneaColors.vertCitron,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    )),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
