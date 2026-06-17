class AlternativeLocale {
  final String idAlternative;
  final String? typeProduitEquivalent;
  final double? distanceKm;
  final int? scorePertinence;
  final AlternativeProducteur producteur;

  const AlternativeLocale({
    required this.idAlternative,
    this.typeProduitEquivalent,
    this.distanceKm,
    this.scorePertinence,
    required this.producteur,
  });

  factory AlternativeLocale.fromJson(Map<String, dynamic> json) {
    return AlternativeLocale(
      idAlternative: json['id_alternative'] as String,
      typeProduitEquivalent: json['type_produit_equivalent'] as String?,
      distanceKm: json['distance_km'] == null
          ? null
          : double.parse(json['distance_km'].toString()),
      scorePertinence: json['score_pertinence'] as int?,
      producteur: AlternativeProducteur.fromJson(
        json['producteur'] as Map<String, dynamic>,
      ),
    );
  }
}

class AlternativeProducteur {
  final String idProducteur;
  final String nomExploitation;
  final String ville;
  final String description;
  final String telephone;
  final String emailContact;
  final String? siteWeb;
  final bool venteDirecte;
  final bool ventePaniers;
  final bool livraisonPossible;
  final int? rayonLivraisonKm;
  final double coordonneesLat;
  final double coordonneesLng;
  final List<String> typesProduction;

  const AlternativeProducteur({
    required this.idProducteur,
    required this.nomExploitation,
    required this.ville,
    required this.description,
    required this.telephone,
    required this.emailContact,
    this.siteWeb,
    required this.venteDirecte,
    required this.ventePaniers,
    required this.livraisonPossible,
    this.rayonLivraisonKm,
    required this.coordonneesLat,
    required this.coordonneesLng,
    required this.typesProduction,
  });

  factory AlternativeProducteur.fromJson(Map<String, dynamic> json) {
    final types = (json['types_production'] as List<dynamic>? ?? [])
        .map((e) =>
            (e as Map<String, dynamic>)['type_production']['nom'] as String)
        .toList();

    return AlternativeProducteur(
      idProducteur: json['id_producteur'] as String,
      nomExploitation: json['nom_exploitation'] as String,
      ville: json['ville'] as String,
      description: json['description'] as String,
      telephone: json['telephone'] as String,
      emailContact: json['email_contact'] as String,
      siteWeb: json['site_web'] as String?,
      venteDirecte: json['vente_directe'] as bool,
      ventePaniers: json['vente_paniers'] as bool,
      livraisonPossible: json['livraison_possible'] as bool,
      rayonLivraisonKm: json['rayon_livraison_km'] as int?,
      coordonneesLat: (json['coordonnees_lat'] as num).toDouble(),
      coordonneesLng: (json['coordonnees_lng'] as num).toDouble(),
      typesProduction: types,
    );
  }
}
