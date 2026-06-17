class ScanResult {
  final String idProduitScanne;
  final String codeBarre;
  final String? nomProduit;
  final String? marque;
  final String? categorie;
  final String? nutriscore;
  final int? scoreNova;
  final String? ecoscore;
  final int nombreAdditifs;
  final List<String> allergenes;
  final List<String> originesIngredients;
  final bool labelBio;
  final bool origineAnimale;

  const ScanResult({
    required this.idProduitScanne,
    required this.codeBarre,
    this.nomProduit,
    this.marque,
    this.categorie,
    this.nutriscore,
    this.scoreNova,
    this.ecoscore,
    required this.nombreAdditifs,
    required this.allergenes,
    required this.originesIngredients,
    required this.labelBio,
    required this.origineAnimale,
  });

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    return ScanResult(
      idProduitScanne: json['id_produit_scanne'] as String,
      codeBarre: json['code_barre'] as String,
      nomProduit: json['nom_produit'] as String?,
      marque: json['marque'] as String?,
      categorie: json['categorie'] as String?,
      nutriscore: json['nutriscore'] as String?,
      scoreNova: json['score_nova'] as int?,
      ecoscore: json['ecoscore'] as String?,
      nombreAdditifs: json['nombre_additifs'] as int? ?? 0,
      allergenes: (json['allergenes'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      originesIngredients:
          (json['origines_ingredients'] as List<dynamic>? ?? [])
              .map((e) => e as String)
              .toList(),
      labelBio: json['label_bio'] as bool? ?? false,
      origineAnimale: json['origine_animale'] as bool? ?? false,
    );
  }
}
