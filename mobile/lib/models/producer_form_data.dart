class ProducerFormData {
  // Depuis ProducerAuthScreen
  String email;
  String telephone;

  // Depuis ProducerShopScreen
  String nomExploitation;
  String raisonSociale;
  String siret;
  String adresseLigne1;

  // Depuis ProducerProfileScreen
  String description;
  String ville;
  String region;
  String departement;

  // Depuis ProducerLogisticsScreen
  bool venteDirecte;
  bool ventePaniers;
  bool livraisonPossible;

  ProducerFormData({
    required this.email,
    required this.telephone,
    this.nomExploitation = '',
    this.raisonSociale = '',
    this.siret = '',
    this.adresseLigne1 = '',
    this.description = '',
    this.ville = '',
    this.region = '',
    this.departement = '',
    this.venteDirecte = true,
    this.ventePaniers = false,
    this.livraisonPossible = false,
  });

  Map<String, dynamic> toJson() => {
        'nom_exploitation': nomExploitation,
        'raison_sociale': raisonSociale,
        'siret': siret,
        'description': description,
        'adresse_ligne1': adresseLigne1,
        'ville': ville,
        'region': region,
        'departement': departement,
        'coordonnees_lat': 48.1173,
        'coordonnees_lng': -1.6778,
        'telephone': telephone,
        'email_contact': email,
        'vente_directe': venteDirecte,
        'vente_paniers': ventePaniers,
        'livraison_possible': livraisonPossible,
        'horaires_ouverture': <String, dynamic>{},
      };
}
