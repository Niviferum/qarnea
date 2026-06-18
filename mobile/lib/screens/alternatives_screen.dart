import 'package:flutter/material.dart';
import '../models/alternative_locale.dart';
import '../services/scan_service.dart';
import '../theme/colors.dart';

class AlternativesScreen extends StatefulWidget {
  final String idScan;
  final String nomProduitScanne;
  final double? userLat;
  final double? userLng;

  const AlternativesScreen({
    super.key,
    required this.idScan,
    required this.nomProduitScanne,
    this.userLat,
    this.userLng,
  });

  @override
  State<AlternativesScreen> createState() => _AlternativesScreenState();
}

class _AlternativesScreenState extends State<AlternativesScreen> {
  final _scanService = ScanService();
  late Future<List<AlternativeLocale>> _future;

  @override
  void initState() {
    super.initState();
    _future = _scanService.getAlternatives(widget.idScan);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QarneaColors.blancCasse,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(nomProduit: widget.nomProduitScanne),
            Expanded(
              child: FutureBuilder<List<AlternativeLocale>>(
                future: _future,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: QarneaColors.vertSapin,
                        strokeWidth: 2,
                      ),
                    );
                  }
                  if (snap.hasError) {
                    return _ErrorView(message: snap.error.toString());
                  }
                  final alternatives = snap.data!;
                  if (alternatives.isEmpty) {
                    return const _EmptyView();
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                    itemCount: alternatives.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _AlternativeCard(
                      alternative: alternatives[i],
                      userLat: widget.userLat,
                      userLng: widget.userLng,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final String nomProduit;

  const _Header({required this.nomProduit});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: QarneaColors.blanc,
      padding: const EdgeInsets.fromLTRB(16, 12, 20, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            color: QarneaColors.vertSapin,
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                const Text(
                  'Alternatives locales',
                  style: TextStyle(
                    fontFamily: 'OpenSauceTwo',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: QarneaColors.vertSapin,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Pour remplacer $nomProduit',
                  style: const TextStyle(
                    fontFamily: 'HostGrotesk',
                    fontSize: 13,
                    fontWeight: FontWeight.w300,
                    color: QarneaColors.textLight,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Alternative card ──────────────────────────────────────────────────────────

class _AlternativeCard extends StatelessWidget {
  final AlternativeLocale alternative;
  final double? userLat;
  final double? userLng;

  const _AlternativeCard({
    required this.alternative,
    this.userLat,
    this.userLng,
  });

  @override
  Widget build(BuildContext context) {
    final p = alternative.producteur;
    final distKm = alternative.distanceKm(userLat, userLng);

    return Container(
      decoration: BoxDecoration(
        color: QarneaColors.blanc,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: QarneaColors.accentBlanc),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nom + distance
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  p.nomExploitation,
                  style: const TextStyle(
                    fontFamily: 'OpenSauceTwo',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: QarneaColors.vertSapin,
                  ),
                ),
              ),
              if (distKm != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: QarneaColors.vertCitron,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${distKm.toStringAsFixed(1)} km',
                    style: const TextStyle(
                      fontFamily: 'HostGrotesk',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: QarneaColors.vertSapin,
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 4),
          Text(
            p.ville,
            style: const TextStyle(
              fontFamily: 'HostGrotesk',
              fontSize: 13,
              fontWeight: FontWeight.w300,
              color: QarneaColors.textLight,
            ),
          ),

          // Type de produit équivalent
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFDCEFD6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              alternative.typeProduitEquivalent,
              style: const TextStyle(
                fontFamily: 'HostGrotesk',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2D6A2D),
              ),
            ),
          ),

          const SizedBox(height: 12),
          Text(
            p.description,
            style: const TextStyle(
              fontFamily: 'HostGrotesk',
              fontSize: 13,
              fontWeight: FontWeight.w300,
              color: QarneaColors.vertSapin,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 12),
          _ModesVente(producteur: p),

          const SizedBox(height: 12),
          _ContactRow(producteur: p),
        ],
      ),
    );
  }
}

// ── Modes de vente ────────────────────────────────────────────────────────────

class _ModesVente extends StatelessWidget {
  final AlternativeProducteur producteur;

  const _ModesVente({required this.producteur});

  @override
  Widget build(BuildContext context) {
    final modes = <String>[
      if (producteur.venteDirecte) 'Vente directe',
      if (producteur.ventePaniers) 'Paniers',
      if (producteur.livraisonPossible)
        'Livraison${producteur.rayonLivraisonKm != null ? ' (${producteur.rayonLivraisonKm} km)' : ''}',
    ];

    if (modes.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: modes
          .map(
            (m) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: QarneaColors.blancCasse,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: QarneaColors.accentBlanc),
              ),
              child: Text(
                m,
                style: const TextStyle(
                  fontFamily: 'HostGrotesk',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: QarneaColors.vertSapin,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

// ── Contact ───────────────────────────────────────────────────────────────────

class _ContactRow extends StatelessWidget {
  final AlternativeProducteur producteur;

  const _ContactRow({required this.producteur});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.phone_outlined,
            size: 15, color: QarneaColors.textLight),
        const SizedBox(width: 6),
        Text(
          producteur.telephone,
          style: const TextStyle(
            fontFamily: 'HostGrotesk',
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: QarneaColors.vertSapin,
          ),
        ),
      ],
    );
  }
}

// ── États vides / erreur ──────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.eco_outlined, size: 48, color: QarneaColors.textLight),
            SizedBox(height: 16),
            Text(
              'Aucune alternative locale\ntrouvée pour l\'instant',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'HostGrotesk',
                fontSize: 15,
                fontWeight: FontWeight.w300,
                color: QarneaColors.textLight,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'HostGrotesk',
            fontSize: 14,
            color: QarneaColors.textLight,
          ),
        ),
      ),
    );
  }
}
