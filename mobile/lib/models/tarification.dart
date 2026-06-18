class Tarification {
  final double prixProducteur;
  final double commissionQarnea;
  final double fraisStripe;
  final double total;
  final String noteCarte;

  const Tarification({
    required this.prixProducteur,
    required this.commissionQarnea,
    required this.fraisStripe,
    required this.total,
    required this.noteCarte,
  });

  factory Tarification.fromJson(Map<String, dynamic> json) => Tarification(
        prixProducteur: (json['prix_producteur'] as num).toDouble(),
        commissionQarnea: (json['commission_qarnea'] as num).toDouble(),
        fraisStripe: (json['frais_stripe'] as num).toDouble(),
        total: (json['total'] as num).toDouble(),
        noteCarte: json['note_carte_hors_ue'] as String,
      );
}
