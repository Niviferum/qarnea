class OperateurMap {
  final String? numeroBio;
  final String raisonSociale;
  final String? ville;
  final double lat;
  final double lng;
  final List<String> produitsCertifies;
  final bool inscritQarnea;
  final String? idProducteur;

  const OperateurMap({
    this.numeroBio,
    required this.raisonSociale,
    this.ville,
    required this.lat,
    required this.lng,
    required this.produitsCertifies,
    required this.inscritQarnea,
    this.idProducteur,
  });

  factory OperateurMap.fromJson(Map<String, dynamic> json) {
    final produits = (json['produits_certifies'] as List<dynamic>? ?? [])
        .map((e) => (e as Map<String, dynamic>)['nom'] as String? ?? '')
        .where((n) => n.isNotEmpty)
        .toList();

    return OperateurMap(
      numeroBio: json['numero_bio'] as String?,
      raisonSociale: json['raison_sociale'] as String,
      ville: json['ville'] as String?,
      lat: (json['coordonnees_lat'] as num).toDouble(),
      lng: (json['coordonnees_lng'] as num).toDouble(),
      produitsCertifies: produits,
      inscritQarnea: json['inscrit_qarnea'] as bool,
      idProducteur: json['id_producteur'] as String?,
    );
  }
}
