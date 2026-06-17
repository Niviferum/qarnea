import 'package:flutter/material.dart';
import '../models/scan_result.dart';
import '../theme/colors.dart';
import '../theme/transitions.dart';
import 'alternatives_screen.dart';

class ScanResultScreen extends StatelessWidget {
  final ScanResult result;

  const ScanResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QarneaColors.blancCasse,
      body: SafeArea(
        child: Column(
          children: [
            _Header(result: result),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ScoresRow(result: result),
                    if (result.origineAnimale || result.labelBio) ...[
                      const SizedBox(height: 12),
                      _BadgesRow(result: result),
                    ],
                    if (result.nombreAdditifs > 0) ...[
                      const SizedBox(height: 12),
                      _InfoCard(
                        label: 'Additifs',
                        value: '${result.nombreAdditifs}',
                        valueColor: result.nombreAdditifs > 5
                            ? const Color(0xFFE63312)
                            : result.nombreAdditifs > 2
                                ? const Color(0xFFEE8100)
                                : QarneaColors.vertSapin,
                      ),
                    ],
                    if (result.allergenes.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _TagsSection(
                        title: 'Allergènes',
                        tags: result.allergenes,
                        tagLabel: _allergenLabel,
                        tagColor: QarneaColors.saumon,
                      ),
                    ],
                    if (result.originesIngredients.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _TagsSection(
                        title: 'Origines',
                        tags: result.originesIngredients,
                        tagLabel: _cleanTag,
                        tagColor: const Color(0xFFDCEFD6),
                      ),
                    ],
                    const SizedBox(height: 24),
                    _CtaButton(
                      onTap: () => Navigator.of(context).push(
                        fadeRoute(AlternativesScreen(
                          idScan: result.idProduitScanne,
                          nomProduitScanne: result.nomProduit ?? result.codeBarre,
                        )),
                      ),
                    ),
                  ],
                ),
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
  final ScanResult result;

  const _Header({required this.result});

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
                Text(
                  result.nomProduit ?? 'Produit sans nom',
                  style: const TextStyle(
                    fontFamily: 'OpenSauceTwo',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: QarneaColors.vertSapin,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (result.marque != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    result.marque!,
                    style: const TextStyle(
                      fontFamily: 'HostGrotesk',
                      fontSize: 13,
                      fontWeight: FontWeight.w300,
                      color: QarneaColors.textLight,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Scores row ─────────────────────────────────────────────────────────────────

class _ScoresRow extends StatelessWidget {
  final ScanResult result;

  const _ScoresRow({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: QarneaColors.blanc,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: QarneaColors.accentBlanc),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          _ScoreBadge(
            label: 'Nutriscore',
            value: result.nutriscore?.toUpperCase() ?? '—',
            color: _nutriscoreColor(result.nutriscore),
          ),
          _Divider(),
          _ScoreBadge(
            label: 'NOVA',
            value: result.scoreNova?.toString() ?? '—',
            color: _novaColor(result.scoreNova),
          ),
          _Divider(),
          _ScoreBadge(
            label: 'Ecoscore',
            value: result.ecoscore?.toUpperCase() ?? '—',
            color: _nutriscoreColor(result.ecoscore),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 48,
      color: QarneaColors.accentBlanc,
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ScoreBadge({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = color != QarneaColors.textLight;
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isDark ? color : QarneaColors.accentBlanc,
              shape: BoxShape.circle,
            ),
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'OpenSauceTwo',
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : QarneaColors.textLight,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'HostGrotesk',
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: QarneaColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Badges ────────────────────────────────────────────────────────────────────

class _BadgesRow extends StatelessWidget {
  final ScanResult result;

  const _BadgesRow({required this.result});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (result.labelBio)
          _Badge(
            label: '🌿 Bio certifié',
            color: const Color(0xFFDCEFD6),
            textColor: const Color(0xFF2D6A2D),
          ),
        if (result.origineAnimale)
          _Badge(
            label: '🐄 Origine animale',
            color: const Color(0xFFFFF3CD),
            textColor: const Color(0xFF7A5800),
          ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;

  const _Badge({
    required this.label,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'HostGrotesk',
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }
}

// ── Info card ─────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _InfoCard({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: QarneaColors.blanc,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: QarneaColors.accentBlanc),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'HostGrotesk',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: QarneaColors.vertSapin,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'OpenSauceTwo',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tags section ──────────────────────────────────────────────────────────────

class _TagsSection extends StatelessWidget {
  final String title;
  final List<String> tags;
  final String Function(String) tagLabel;
  final Color tagColor;

  const _TagsSection({
    required this.title,
    required this.tags,
    required this.tagLabel,
    required this.tagColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: QarneaColors.blanc,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: QarneaColors.accentBlanc),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'OpenSauceTwo',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: QarneaColors.textLight,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: tagColor.withAlpha(180),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tagLabel(tag),
                  style: const TextStyle(
                    fontFamily: 'HostGrotesk',
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: QarneaColors.vertSapin,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ── CTA button ────────────────────────────────────────────────────────────────

class _CtaButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CtaButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: QarneaColors.vertSapin,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: const Text(
          'Trouver une alternative locale',
          style: TextStyle(
            fontFamily: 'OpenSauceTwo',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

const _allergenLabels = {
  'en:gluten': 'Gluten',
  'en:milk': 'Lait',
  'en:eggs': 'Œufs',
  'en:nuts': 'Fruits à coque',
  'en:peanuts': 'Arachides',
  'en:soybeans': 'Soja',
  'en:fish': 'Poisson',
  'en:shellfish': 'Crustacés',
  'en:sesame-seeds': 'Sésame',
  'en:mustard': 'Moutarde',
  'en:celery': 'Céleri',
  'en:lupin': 'Lupin',
  'en:molluscs': 'Mollusques',
  'en:sulphur-dioxide-and-sulphites': 'Sulfites',
};

String _allergenLabel(String tag) => _allergenLabels[tag] ?? _cleanTag(tag);

String _cleanTag(String tag) {
  final value = tag.contains(':') ? tag.split(':').last : tag;
  return value
      .replaceAll('-', ' ')
      .split(' ')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}

Color _nutriscoreColor(String? score) {
  switch (score?.toUpperCase()) {
    case 'A':
      return const Color(0xFF038141);
    case 'B':
      return const Color(0xFF85BB2F);
    case 'C':
      return const Color(0xFFFECB02);
    case 'D':
      return const Color(0xFFEE8100);
    case 'E':
      return const Color(0xFFE63312);
    default:
      return QarneaColors.textLight;
  }
}

Color _novaColor(int? nova) {
  switch (nova) {
    case 1:
      return const Color(0xFF038141);
    case 2:
      return const Color(0xFF85BB2F);
    case 3:
      return const Color(0xFFEE8100);
    case 4:
      return const Color(0xFFE63312);
    default:
      return QarneaColors.textLight;
  }
}
