import 'package:flutter/material.dart';
import '../models/tarification.dart';
import '../services/commande_service.dart';
import '../theme/colors.dart';

class PriceBreakdownButton extends StatelessWidget {
  final double prixProducteur;

  const PriceBreakdownButton({super.key, required this.prixProducteur});

  void _showBreakdown(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: QarneaColors.blancCasse,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _BreakdownSheet(prixProducteur: prixProducteur),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showBreakdown(context),
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: QarneaColors.vertSapin, width: 1.5),
        ),
        child: const Center(
          child: Text(
            '?',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: QarneaColors.vertSapin,
            ),
          ),
        ),
      ),
    );
  }
}

class _BreakdownSheet extends StatefulWidget {
  final double prixProducteur;
  const _BreakdownSheet({required this.prixProducteur});

  @override
  State<_BreakdownSheet> createState() => _BreakdownSheetState();
}

class _BreakdownSheetState extends State<_BreakdownSheet> {
  final _service = CommandeService();
  late final Future<Tarification> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getTarification(widget.prixProducteur);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: FutureBuilder<Tarification>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 120,
              child: Center(
                child: CircularProgressIndicator(color: QarneaColors.vertSapin),
              ),
            );
          }
          if (snap.hasError || !snap.hasData) {
            return const SizedBox(
              height: 80,
              child: Center(child: Text('Impossible de charger la tarification')),
            );
          }

          final t = snap.data!;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Détail du prix',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: QarneaColors.vertSapin,
                ),
              ),
              const SizedBox(height: 20),
              _Line(
                label: 'Prix du producteur',
                sublabel: 'Ce que touche le producteur',
                montant: t.prixProducteur,
                color: QarneaColors.vertSapin,
              ),
              const Divider(height: 24),
              _Line(
                label: 'Commission Qarnea',
                sublabel: '4 % du prix producteur',
                montant: t.commissionQarnea,
              ),
              const SizedBox(height: 12),
              _Line(
                label: 'Frais de paiement',
                sublabel: 'Coût de fonctionnement Stripe',
                montant: t.fraisStripe,
              ),
              const Divider(height: 24),
              _Line(
                label: 'Total',
                montant: t.total,
                color: QarneaColors.vertSapin,
                bold: true,
                fontSize: 17,
              ),
              const SizedBox(height: 16),
              Text(
                '* ${t.noteCarte}',
                style: const TextStyle(fontSize: 11, color: Colors.black54),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Line extends StatelessWidget {
  final String label;
  final String? sublabel;
  final double montant;
  final Color color;
  final bool bold;
  final double fontSize;

  const _Line({
    required this.label,
    this.sublabel,
    required this.montant,
    this.color = Colors.black87,
    this.bold = false,
    this.fontSize = 15,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: bold ? FontWeight.bold : FontWeight.w500,
                  color: color,
                ),
              ),
              if (sublabel != null)
                Text(
                  sublabel!,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
            ],
          ),
        ),
        Text(
          '${montant.toStringAsFixed(2)} €',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
