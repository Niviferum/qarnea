import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/colors.dart';
import '../services/auth_service.dart';
import '../services/utilisateur_service.dart';
import 'login_screen.dart';
import '../theme/transitions.dart';

class ConsumerProfileScreen extends StatefulWidget {
  const ConsumerProfileScreen({super.key});

  @override
  State<ConsumerProfileScreen> createState() => _ConsumerProfileScreenState();
}

class _ConsumerProfileScreenState extends State<ConsumerProfileScreen> {
  Map<String, dynamic>? _profil;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfil();
  }

  Future<void> _loadProfil() async {
    try {
      final profil = await UtilisateurService().getMonProfil();
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

  String get _fullName {
    final prenom = _profil?['prenom'] as String? ?? '';
    final nom = _profil?['nom'] as String? ?? '';
    final full = '$prenom $nom'.trim();
    return full.isEmpty ? '—' : full;
  }

  String get _ville {
    return _profil?['ville_preferee'] as String? ?? '';
  }

  String get _rayonLabel {
    final rayon = _profil?['rayon_recherche_defaut'];
    if (rayon == null) return '5 km (défaut)';
    return '$rayon km';
  }

  String get _initiales {
    final prenom = (_profil?['prenom'] as String? ?? '').trim();
    final nom = (_profil?['nom'] as String? ?? '').trim();
    final p = prenom.isNotEmpty ? prenom[0].toUpperCase() : '';
    final n = nom.isNotEmpty ? nom[0].toUpperCase() : '';
    return '$p$n'.isNotEmpty ? '$p$n' : '?';
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: QarneaColors.blancCasse,
      body: Column(
        children: [
          _buildHeader(mq.padding.top),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: QarneaColors.vertSapin),
                  )
                : SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                        20, 20, 20, mq.padding.bottom + 24),
                    child: Column(
                      children: [
                        _buildProfileCard(),
                        const SizedBox(height: 14),
                        _buildSection([
                          _SettingsRow(
                            label: 'Préférence de kilomètre',
                            value: _rayonLabel,
                            premium: true,
                            onTap: () {},
                          ),
                          _SettingsRow(
                            label: "Gestion de l'abonnement",
                            value: 'Freemium',
                            onTap: () {},
                          ),
                          _SettingsRow(
                            label: 'Préférence de paiement',
                            value: 'À définir',
                            onTap: () {},
                          ),
                          _SettingsRow(
                            label: 'Autorisations',
                            onTap: () {},
                          ),
                          _SettingsRow(
                            label: 'Double authentification',
                            value: 'Désactivé',
                            onTap: () {},
                            isLast: true,
                          ),
                        ]),
                        const SizedBox(height: 14),
                        _buildSection([
                          _SettingsRow(
                            label: 'CGV / CGU',
                            onTap: () {},
                          ),
                          _SettingsRow(
                            label: 'Mise à jour',
                            onTap: () {},
                            isLast: true,
                          ),
                        ]),
                        const SizedBox(height: 14),
                        _buildSection([
                          _SettingsRow(
                            label: 'Désactiver le profil',
                            onTap: () {},
                            danger: true,
                          ),
                          _SettingsRow(
                            label: 'Supprimer le compte',
                            onTap: () => _confirmDeleteAccount(),
                            danger: true,
                            isLast: true,
                          ),
                        ]),
                        const SizedBox(height: 14),
                        _buildLogoutButton(),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(double topPadding) {
    return Container(
      color: QarneaColors.blancCasse,
      padding: EdgeInsets.fromLTRB(4, topPadding + 8, 24, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 18),
            color: QarneaColors.vertSapin,
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Expanded(
            child: Text(
              'Paramètres',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'HostGrotesk',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF041615),
                letterSpacing: -0.32,
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return _CardContainer(
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(30),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: QarneaColors.vertSapin,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  _isLoading ? '' : _initiales,
                  style: const TextStyle(
                    fontFamily: 'OpenSauceTwo',
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: QarneaColors.vertCitron,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _fullName,
                      style: const TextStyle(
                        fontFamily: 'OpenSauceTwo',
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF06261E),
                      ),
                    ),
                    if (_ville.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/icon_filter.svg',
                            width: 12,
                            height: 14,
                            colorFilter: const ColorFilter.mode(
                              Color(0xFF06261E),
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _ville,
                            style: const TextStyle(
                              fontFamily: 'HostGrotesk',
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                              color: Color(0xFF06261E),
                              letterSpacing: -0.28,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: QarneaColors.cardBorder,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(List<Widget> rows) {
    return _CardContainer(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      child: Column(
        children: rows,
      ),
    );
  }

  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: _logout,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: QarneaColors.blanc,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: QarneaColors.cardBorder),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_outlined, color: QarneaColors.saumon, size: 20),
            SizedBox(width: 10),
            Text(
              'Se déconnecter',
              style: TextStyle(
                fontFamily: 'HostGrotesk',
                fontSize: 16,
                fontWeight: FontWeight.w300,
                color: QarneaColors.saumon,
                letterSpacing: -0.32,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer le compte'),
        content: const Text(
            'Cette action est irréversible. Confirmer la suppression ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer',
                style: TextStyle(color: QarneaColors.saumon)),
          ),
        ],
      ),
    );
    if (confirmed == true) _logout();
  }
}

class _CardContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const _CardContainer({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: QarneaColors.blanc,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: QarneaColors.cardBorder),
      ),
      child: child,
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final String label;
  final String? value;
  final bool premium;
  final bool danger;
  final bool isLast;
  final VoidCallback onTap;

  const _SettingsRow({
    required this.label,
    required this.onTap,
    this.value,
    this.premium = false,
    this.danger = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final labelColor =
        danger ? QarneaColors.saumon : const Color(0xFF06261E);

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'HostGrotesk',
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  color: labelColor,
                  letterSpacing: -0.32,
                ),
              ),
              if (premium) ...[
                const SizedBox(width: 6),
                _PremiumBadge(),
              ],
              const Spacer(),
              if (value != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    value!,
                    style: const TextStyle(
                      fontFamily: 'HostGrotesk',
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                      color: QarneaColors.cardBorder,
                      letterSpacing: -0.32,
                    ),
                  ),
                ),
              const Icon(
                Icons.chevron_right,
                size: 18,
                color: QarneaColors.cardBorder,
              ),
            ],
          ),
        ),
        if (!isLast) ...[
          const SizedBox(height: 10),
          const Divider(
              height: 1, thickness: 1, color: QarneaColors.accentBlanc),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _PremiumBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: QarneaColors.vertCitron,
        borderRadius: BorderRadius.circular(15),
      ),
      child: SvgPicture.asset(
        'assets/icons/icon_crown.svg',
        width: 11,
        height: 10,
      ),
    );
  }
}
