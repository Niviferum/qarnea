import 'dart:math';

class AlternativeLocale {
  final String typeProduitEquivalent;
  final AlternativeProducteur producteur;

  const AlternativeLocale({
    required this.typeProduitEquivalent,
    required this.producteur,
  });

  factory AlternativeLocale.fromJson(Map<String, dynamic> json) {
    return AlternativeLocale(
      typeProduitEquivalent: json['type_produit_equivalent'] as String,
      producteur: AlternativeProducteur.fromJson(
        json['producteur'] as Map<String, dynamic>,
      ),
    );
  }

  /// Distance en km entre le producteur et une position de référence (Haversine).
  double? distanceKm(double? userLat, double? userLng) {
    if (userLat == null || userLng == null) return null;
    return _haversineKm(
      userLat, userLng,
      producteur.coordonneesLat, producteur.coordonneesLng,
    );
  }

  static double _haversineKm(double lat1, double lng1, double lat2, double lng2) {
    const r = 6371.0;
    final dLat = _rad(lat2 - lat1);
    final dLng = _rad(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_rad(lat1)) * cos(_rad(lat2)) * sin(dLng / 2) * sin(dLng / 2);
    return r * 2 * asin(sqrt(a));
  }

  static double _rad(double deg) => deg * pi / 180;
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
