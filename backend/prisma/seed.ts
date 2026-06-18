import 'dotenv/config';
import { PrismaClient, Role, StatutCompte, StatutVerification, SourceScan } from '../src/generated/prisma';
import { PrismaPg } from '@prisma/adapter-pg';
import pg from 'pg';

const connectionString = (process.env.DATABASE_URL ?? '').replace(/sslmode=\w+/g, 'sslmode=disable');
const pool = new pg.Pool({ connectionString });
const adapter = new PrismaPg(pool);
const prisma = new PrismaClient({ adapter } as any);

const PASSWORD_HASH = '$2b$10$moM.qUXsam1TvEkanq1YN.wVnNkGhR3NQ2vqVqhj8tyYJU8dVj9xm'; // Test@1234

// ── IDs fixes pour pouvoir relier les entités ────────────────────────────────

const IDS = {
  // Utilisateurs
  admin:            'seed-0001-0000-0000-000000000001',
  conso1:           'seed-0002-0000-0000-000000000001',
  conso2:           'seed-0003-0000-0000-000000000001',
  prodBeausoleil:   'seed-0004-0000-0000-000000000001',
  prodBreizh:       'seed-0005-0000-0000-000000000001',
  prodCharcuterie:  'seed-0006-0000-0000-000000000001',
  prodCombrailles:  'seed-0007-0000-0000-000000000001',

  // Producteurs
  beausoleil:       'seed-0010-0000-0000-000000000001',
  breizh:           'seed-0011-0000-0000-000000000001',
  charcuterie:      'seed-0012-0000-0000-000000000001',
  combrailles:      'seed-0013-0000-0000-000000000001',

  // Types de production
  typeLegumes:      'seed-0020-0000-0000-000000000001',
  typeFruits:       'seed-0021-0000-0000-000000000001',
  typeLait:         'seed-0022-0000-0000-000000000001',
  typeViande:       'seed-0023-0000-0000-000000000001',
  typeMiel:         'seed-0024-0000-0000-000000000001',
  typeEaux:         'seed-0025-0000-0000-000000000001',

  // Labels
  labelBio:         'seed-0030-0000-0000-000000000001',
  labelHVE:         'seed-0031-0000-0000-000000000001',
  labelRouge:       'seed-0032-0000-0000-000000000001',

  // Scans
  scanNutella:      'seed-0040-0000-0000-000000000001',
  scanLactel:       'seed-0041-0000-0000-000000000001',
  scanDanette:      'seed-0042-0000-0000-000000000001',
  scanJambon:       'seed-0043-0000-0000-000000000001',
  scanVolvic:       'seed-0044-0000-0000-000000000001',
};

async function main() {
  console.log('🌱 Démarrage du seed...');

  // ── Utilisateurs ────────────────────────────────────────────────────────────

  await prisma.utilisateur.upsert({
    where: { email: 'admin@qarnea.fr' },
    update: {},
    create: {
      id_utilisateur: IDS.admin,
      email: 'admin@qarnea.fr',
      password_hash: PASSWORD_HASH,
      nom: 'Admin',
      prenom: 'Qarnea',
      role: Role.admin,
      statut_compte: StatutCompte.actif,
    },
  });

  await prisma.utilisateur.upsert({
    where: { email: 'jean.consumer@test.fr' },
    update: {},
    create: {
      id_utilisateur: IDS.conso1,
      email: 'jean.consumer@test.fr',
      password_hash: PASSWORD_HASH,
      nom: 'Dupont',
      prenom: 'Jean',
      role: Role.user,
      statut_compte: StatutCompte.actif,
      ville_preferee: 'Rennes',
      localisation_lat: 48.1173,
      localisation_lng: -1.6778,
    },
  });

  await prisma.utilisateur.upsert({
    where: { email: 'marie.consumer@test.fr' },
    update: {},
    create: {
      id_utilisateur: IDS.conso2,
      email: 'marie.consumer@test.fr',
      password_hash: PASSWORD_HASH,
      nom: 'Lefebvre',
      prenom: 'Marie',
      role: Role.user,
      statut_compte: StatutCompte.actif,
      ville_preferee: 'Rennes',
    },
  });

  await prisma.utilisateur.upsert({
    where: { email: 'contact@ferme-beausoleil.fr' },
    update: {},
    create: {
      id_utilisateur: IDS.prodBeausoleil,
      email: 'contact@ferme-beausoleil.fr',
      password_hash: PASSWORD_HASH,
      nom: 'Beausoleil',
      prenom: 'Sophie',
      role: Role.producteur,
      statut_compte: StatutCompte.actif,
    },
  });

  await prisma.utilisateur.upsert({
    where: { email: 'contact@charcuterie-bretonne.fr' },
    update: {},
    create: {
      id_utilisateur: IDS.prodCharcuterie,
      email: 'contact@charcuterie-bretonne.fr',
      password_hash: PASSWORD_HASH,
      nom: 'Guillou',
      prenom: 'Marc',
      role: Role.producteur,
      statut_compte: StatutCompte.actif,
    },
  });

  await prisma.utilisateur.upsert({
    where: { email: 'contact@source-combrailles.fr' },
    update: {},
    create: {
      id_utilisateur: IDS.prodCombrailles,
      email: 'contact@source-combrailles.fr',
      password_hash: PASSWORD_HASH,
      nom: 'Aubert',
      prenom: 'Céline',
      role: Role.producteur,
      statut_compte: StatutCompte.actif,
    },
  });

  await prisma.utilisateur.upsert({
    where: { email: 'contact@breizh-elevage.fr' },
    update: {},
    create: {
      id_utilisateur: IDS.prodBreizh,
      email: 'contact@breizh-elevage.fr',
      password_hash: PASSWORD_HASH,
      nom: 'Perron',
      prenom: 'Luc',
      role: Role.producteur,
      statut_compte: StatutCompte.actif,
    },
  });

  console.log('✓ Utilisateurs');

  // ── Types de production ──────────────────────────────────────────────────────

  const types = [
    {
      id_type_production: IDS.typeLegumes,
      nom: 'Fruits et légumes',
      slug: 'fruits-et-legumes',
      description: 'Maraîchage, arboriculture et petits fruits',
      off_categories_tags: [
        'en:vegetables', 'en:fruits', 'en:fresh-vegetables', 'en:fresh-fruits',
        'en:plant-based-foods', 'en:fruits-and-vegetables-based-foods',
      ],
    },
    {
      id_type_production: IDS.typeFruits,
      nom: 'Jus de fruits artisanaux',
      slug: 'jus-de-fruits-artisanaux',
      description: 'Jus pressés à froid, sans conservateurs ni sucres ajoutés',
      off_categories_tags: [
        'en:fruit-juices', 'en:juices-and-nectars', 'en:fruit-based-beverages',
      ],
    },
    {
      id_type_production: IDS.typeLait,
      nom: 'Produits laitiers et fromages',
      slug: 'produits-laitiers-fromages',
      description: 'Lait cru, fromages fermiers, beurre et crème',
      off_categories_tags: [
        'en:dairy-products', 'en:milks', 'en:cheeses', 'en:fermented-milk-products',
        'en:yogurts', 'en:dairies',
      ],
    },
    {
      id_type_production: IDS.typeViande,
      nom: 'Viande et volaille',
      slug: 'viande-volaille',
      description: 'Élevage bovin, porcin, ovin et volaille',
      off_categories_tags: [
        'en:meats', 'en:meats-and-their-products', 'en:pork', 'en:hams',
        'en:charcuterie', 'en:cooked-charcuterie-products', 'en:cooked-meats',
        'en:poultries', 'en:beef', 'en:deli-meat',
      ],
    },
    {
      id_type_production: IDS.typeMiel,
      nom: 'Miel et apiculture',
      slug: 'miel-apiculture',
      description: 'Miels mono-floraux et produits de la ruche',
      off_categories_tags: ['en:honeys', 'en:honey', 'en:sweeteners'],
    },
    {
      id_type_production: IDS.typeEaux,
      nom: 'Eaux de source et boissons',
      slug: 'eaux-de-source-boissons',
      description: 'Eaux de source, eaux de captage artisanal et boissons non alcoolisées',
      off_categories_tags: [
        'en:beverages', 'en:waters', 'en:spring-waters', 'en:mineral-waters',
        'en:natural-mineral-waters', 'en:beverages-and-beverages-preparations',
      ],
    },
  ];

  for (const t of types) {
    await prisma.typeProduction.upsert({
      where: { slug: t.slug },
      update: { off_categories_tags: t.off_categories_tags },
      create: t,
    });
  }

  console.log('✓ Types de production');

  // ── Labels ───────────────────────────────────────────────────────────────────

  await prisma.label.upsert({
    where: { code: 'AB' },
    update: {},
    create: {
      id_label: IDS.labelBio,
      nom: 'Agriculture Biologique',
      code: 'AB',
      description: 'Certification officielle européenne pour les produits biologiques',
      organisme_certificateur: 'Agence Bio',
      niveau_exigence: 'eleve',
      type_label: 'environnemental',
    },
  });

  await prisma.label.upsert({
    where: { code: 'HVE' },
    update: {},
    create: {
      id_label: IDS.labelHVE,
      nom: 'Haute Valeur Environnementale',
      code: 'HVE',
      description: 'Certification française récompensant les pratiques agricoles respectueuses',
      organisme_certificateur: 'Ministère de l\'Agriculture',
      niveau_exigence: 'moyen',
      type_label: 'environnemental',
    },
  });

  await prisma.label.upsert({
    where: { code: 'LR' },
    update: {},
    create: {
      id_label: IDS.labelRouge,
      nom: 'Label Rouge',
      code: 'LR',
      description: 'Label national attestant d\'une qualité supérieure au niveau standard',
      organisme_certificateur: 'INAO',
      niveau_exigence: 'eleve',
      type_label: 'qualite',
    },
  });

  console.log('✓ Labels');

  // ── Producteurs ───────────────────────────────────────────────────────────────

  const horairesStandard = {
    lundi: '9h-12h30 / 14h-19h',
    mardi: '9h-12h30 / 14h-19h',
    mercredi: '9h-12h30 / 14h-19h',
    jeudi: '9h-12h30 / 14h-19h',
    vendredi: '9h-12h30 / 14h-19h',
    samedi: '9h-13h',
    dimanche: 'fermé',
  };

  await prisma.producteur.upsert({
    where: { raison_sociale: 'GAEC Ferme Beausoleil' },
    update: {},
    create: {
      id_producteur: IDS.beausoleil,
      id_utilisateur: IDS.prodBeausoleil,
      nom_exploitation: 'Ferme Beausoleil',
      raison_sociale: 'GAEC Ferme Beausoleil',
      siret: '98765432100012',
      description: 'Maraîchers bio depuis 2010. Légumes de saison cultivés sans pesticides sur 8 hectares à Cesson-Sévigné.',
      description_pratiques: 'Rotation des cultures, compost maison, irrigation au goutte-à-goutte. Certifiés AB depuis 2012.',
      adresse_ligne1: '4 rue des Jardins',
      ville: 'Cesson-Sévigné',
      region: 'Bretagne',
      departement: 'Ille-et-Vilaine',
      coordonnees_lat: 48.1205,
      coordonnees_lng: -1.6063,
      telephone: '06 23 45 67 89',
      email_contact: 'contact@ferme-beausoleil.fr',
      horaires_ouverture: horairesStandard,
      jours_marches: 'Marché de Cesson-Sévigné (mercredi matin), Marché de Rennes (samedi)',
      vente_directe: true,
      vente_paniers: true,
      livraison_possible: true,
      rayon_livraison_km: 25,
      click_and_collect: true,
      commande_en_ligne: true,
      statut_verification: StatutVerification.verified,
      date_verification: new Date('2025-03-15'),
      visible_publiquement: true,
    },
  });

  await prisma.producteurTypeProduction.upsert({
    where: { id_producteur_id_type_production: { id_producteur: IDS.beausoleil, id_type_production: IDS.typeLegumes } },
    update: {},
    create: { id_producteur: IDS.beausoleil, id_type_production: IDS.typeLegumes, production_principale: true },
  });

  await prisma.producteur.upsert({
    where: { raison_sociale: 'EARL Breizh Élevage' },
    update: {},
    create: {
      id_producteur: IDS.breizh,
      id_utilisateur: IDS.prodBreizh,
      nom_exploitation: 'Breizh Élevage',
      raison_sociale: 'EARL Breizh Élevage',
      siret: '11223344500099',
      description: 'Élevage laitier de 45 vaches Prim\'Holstein en plein air. Fromages fermiers et lait cru produits à Pacé.',
      description_pratiques: 'Pâturage libre 8 mois par an, alimentation sans OGM, transformation à la ferme.',
      adresse_ligne1: '18 chemin de la Lande',
      ville: 'Pacé',
      region: 'Bretagne',
      departement: 'Ille-et-Vilaine',
      coordonnees_lat: 48.1492,
      coordonnees_lng: -1.7609,
      telephone: '06 34 56 78 90',
      email_contact: 'contact@breizh-elevage.fr',
      horaires_ouverture: { ...horairesStandard, dimanche: '10h-12h' },
      vente_directe: true,
      vente_paniers: false,
      livraison_possible: true,
      rayon_livraison_km: 20,
      click_and_collect: false,
      commande_en_ligne: false,
      statut_verification: StatutVerification.verified,
      date_verification: new Date('2025-04-10'),
      visible_publiquement: true,
    },
  });

  await prisma.producteurTypeProduction.upsert({
    where: { id_producteur_id_type_production: { id_producteur: IDS.breizh, id_type_production: IDS.typeLait } },
    update: {},
    create: { id_producteur: IDS.breizh, id_type_production: IDS.typeLait, production_principale: true },
  });

  await prisma.producteur.upsert({
    where: { raison_sociale: 'SASU Charcuterie Bretonne Guillou' },
    update: {},
    create: {
      id_producteur: IDS.charcuterie,
      id_utilisateur: IDS.prodCharcuterie,
      nom_exploitation: 'Charcuterie Bretonne Guillou',
      raison_sociale: 'SASU Charcuterie Bretonne Guillou',
      siret: '55544433300077',
      description: 'Charcuterie artisanale depuis 1987. Jambons cuits et crus, saucissons et pâtés élaborés à partir de porcs élevés en plein air à Saint-Gilles.',
      description_pratiques: 'Porcs Label Rouge, alimentation sans antibiotiques, fumaison au bois de hêtre. Zéro nitrite ajouté sur nos jambons cuits.',
      adresse_ligne1: '3 rue de la Salaison',
      ville: 'Saint-Gilles',
      region: 'Bretagne',
      departement: 'Ille-et-Vilaine',
      coordonnees_lat: 48.1389,
      coordonnees_lng: -1.8201,
      telephone: '06 45 67 89 01',
      email_contact: 'contact@charcuterie-bretonne.fr',
      horaires_ouverture: {
        lundi: 'fermé',
        mardi: '9h-12h30 / 14h-18h',
        mercredi: '9h-12h30 / 14h-18h',
        jeudi: '9h-12h30 / 14h-18h',
        vendredi: '9h-12h30 / 14h-19h',
        samedi: '8h-13h',
        dimanche: 'fermé',
      },
      jours_marches: 'Marché de Rennes (samedi), Marché de Saint-Gilles (vendredi matin)',
      vente_directe: true,
      vente_paniers: false,
      livraison_possible: true,
      rayon_livraison_km: 35,
      click_and_collect: true,
      commande_en_ligne: false,
      statut_verification: StatutVerification.verified,
      date_verification: new Date('2025-05-20'),
      visible_publiquement: true,
    },
  });

  await prisma.producteurTypeProduction.upsert({
    where: { id_producteur_id_type_production: { id_producteur: IDS.charcuterie, id_type_production: IDS.typeViande } },
    update: {},
    create: { id_producteur: IDS.charcuterie, id_type_production: IDS.typeViande, production_principale: true },
  });

  await prisma.producteur.upsert({
    where: { raison_sociale: 'SARL Source des Combrailles' },
    update: {},
    create: {
      id_producteur: IDS.combrailles,
      id_utilisateur: IDS.prodCombrailles,
      nom_exploitation: 'Source des Combrailles',
      raison_sociale: 'SARL Source des Combrailles',
      siret: '77788899900011',
      description: 'Captage artisanal d\'eau de source sur le massif des Combrailles. Conditionnée en bouteilles consignées en verre depuis 1994.',
      description_pratiques: 'Source protégée en zone Natura 2000, zéro traitement chimique, conditionnement local en verre consigné.',
      adresse_ligne1: '12 chemin de la Source',
      ville: 'Saint-Gervais-d\'Auvergne',
      region: 'Auvergne-Rhône-Alpes',
      departement: 'Puy-de-Dôme',
      coordonnees_lat: 46.0247,
      coordonnees_lng: 2.8219,
      telephone: '06 78 90 12 34',
      email_contact: 'contact@source-combrailles.fr',
      horaires_ouverture: {
        lundi: 'fermé',
        mardi: '9h-12h',
        mercredi: '9h-12h',
        jeudi: '9h-12h',
        vendredi: '9h-12h',
        samedi: '9h-12h',
        dimanche: 'fermé',
      },
      jours_marches: 'Marché de Riom (vendredi), Marché de Vichy (samedi)',
      vente_directe: true,
      vente_paniers: false,
      livraison_possible: true,
      rayon_livraison_km: 50,
      click_and_collect: false,
      commande_en_ligne: false,
      statut_verification: StatutVerification.verified,
      date_verification: new Date('2025-06-01'),
      visible_publiquement: true,
    },
  });

  await prisma.producteurTypeProduction.upsert({
    where: { id_producteur_id_type_production: { id_producteur: IDS.combrailles, id_type_production: IDS.typeEaux } },
    update: {},
    create: { id_producteur: IDS.combrailles, id_type_production: IDS.typeEaux, production_principale: true },
  });

  console.log('✓ Producteurs');

  // ── Labels producteurs ───────────────────────────────────────────────────────

  const existingBeausoleilLabel = await prisma.producteurLabel.findFirst({
    where: { id_producteur: IDS.beausoleil, id_label: IDS.labelBio },
  });
  if (!existingBeausoleilLabel) {
    await prisma.producteurLabel.create({
      data: {
        id_producteur: IDS.beausoleil,
        id_label: IDS.labelBio,
        numero_certification: 'FR-BIO-01-2025-BEAUSOLEIL',
        date_obtention: new Date('2012-06-01'),
        verifie: true,
        date_verification: new Date('2025-03-15'),
      },
    });
  }

  const existingBreizhLabel = await prisma.producteurLabel.findFirst({
    where: { id_producteur: IDS.breizh, id_label: IDS.labelHVE },
  });
  if (!existingBreizhLabel) {
    await prisma.producteurLabel.create({
      data: {
        id_producteur: IDS.breizh,
        id_label: IDS.labelHVE,
        numero_certification: 'HVE-35-2024-BREIZH',
        date_obtention: new Date('2024-01-15'),
        verifie: true,
        date_verification: new Date('2025-04-10'),
      },
    });
  }

  console.log('✓ Labels producteurs');

  // ── Scans de Jean (conso1) ────────────────────────────────────────────────────

  await prisma.produitScanne.upsert({
    where: { id_produit_scanne: IDS.scanNutella },
    update: {},
    create: {
      id_produit_scanne: IDS.scanNutella,
      id_utilisateur: IDS.conso1,
      code_barre: '3017620422003',
      nom_produit: 'Nutella',
      marque: 'Ferrero',
      categorie: 'Pâtes à tartiner',
      date_scan: new Date('2026-06-15T10:30:00'),
      nutriscore: 'E',
      score_nova: 4,
      ecoscore: 'D',
      nombre_additifs: 1,
      allergenes: ['en:nuts', 'en:milk', 'en:soybeans'],
      origines_ingredients: ['en:italy', 'en:france'],
      label_bio: false,
      source_donnees: SourceScan.open_food_facts,
      donnees_off: {},
    },
  });

  await prisma.produitScanne.upsert({
    where: { id_produit_scanne: IDS.scanLactel },
    update: {},
    create: {
      id_produit_scanne: IDS.scanLactel,
      id_utilisateur: IDS.conso1,
      code_barre: '3564700110016',
      nom_produit: 'Lait demi-écrémé UHT',
      marque: 'Lactel',
      categorie: 'Laits',
      date_scan: new Date('2026-06-16T09:00:00'),
      nutriscore: 'B',
      score_nova: 1,
      ecoscore: 'C',
      nombre_additifs: 0,
      allergenes: ['en:milk'],
      origines_ingredients: ['en:france'],
      label_bio: false,
      source_donnees: SourceScan.open_food_facts,
      donnees_off: {},
    },
  });

  await prisma.produitScanne.upsert({
    where: { id_produit_scanne: IDS.scanJambon },
    update: {},
    create: {
      id_produit_scanne: IDS.scanJambon,
      id_utilisateur: IDS.conso1,
      code_barre: '3154230007097',
      nom_produit: 'Le Bon Paris — Jambon cuit supérieur',
      marque: 'Herta',
      categorie: 'Jambons cuits',
      date_scan: new Date('2026-06-17T11:00:00'),
      nutriscore: 'B',
      score_nova: 3,
      ecoscore: 'C',
      nombre_additifs: 3,
      allergenes: [],
      origines_ingredients: ['en:france', 'en:europe'],
      label_bio: false,
      source_donnees: SourceScan.open_food_facts,
      donnees_off: {},
    },
  });

  await prisma.produitScanne.upsert({
    where: { id_produit_scanne: IDS.scanVolvic },
    update: {},
    create: {
      id_produit_scanne: IDS.scanVolvic,
      id_utilisateur: IDS.conso1,
      code_barre: '3057640265358',
      nom_produit: 'Eau minérale naturelle',
      marque: 'Volvic',
      categorie: 'Eaux minérales naturelles',
      date_scan: new Date('2026-06-18T08:00:00'),
      nutriscore: 'A',
      score_nova: 1,
      ecoscore: null,
      nombre_additifs: 0,
      allergenes: [],
      origines_ingredients: ['en:france'],
      label_bio: false,
      source_donnees: SourceScan.open_food_facts,
      donnees_off: {
        categories_tags: [
          'en:beverages-and-beverages-preparations',
          'en:beverages',
          'en:waters',
          'en:spring-waters',
          'en:mineral-waters',
          'en:natural-mineral-waters',
        ],
        labels_tags: ['en:carbon-trust', 'en:certified-b-corporation', 'fr:triman'],
      },
    },
  });

  await prisma.produitScanne.upsert({
    where: { id_produit_scanne: IDS.scanDanette },
    update: {},
    create: {
      id_produit_scanne: IDS.scanDanette,
      id_utilisateur: IDS.conso1,
      code_barre: '3023290007145',
      nom_produit: 'Danette Chocolat',
      marque: 'Danone',
      categorie: 'Desserts lactés',
      date_scan: new Date('2026-06-16T14:00:00'),
      nutriscore: 'D',
      score_nova: 4,
      ecoscore: 'D',
      nombre_additifs: 4,
      allergenes: ['en:milk', 'en:soybeans'],
      origines_ingredients: ['en:france'],
      label_bio: false,
      source_donnees: SourceScan.open_food_facts,
      donnees_off: {},
    },
  });

  console.log('✓ Scans');

  // ── Alternatives locales ──────────────────────────────────────────────────────

  const alts = [
    {
      id_produit_scanne: IDS.scanVolvic,
      id_producteur: IDS.combrailles,
      type_produit_equivalent: 'Eau de source artisanale en verre consigné',
      prix_unitaire: 0.80,
      score_pertinence: 85,
    },
    {
      id_produit_scanne: IDS.scanJambon,
      id_producteur: IDS.charcuterie,
      type_produit_equivalent: 'Jambon cuit artisanal sans nitrite',
      prix_unitaire: 5.90,
      score_pertinence: 88,
    },
    {
      id_produit_scanne: IDS.scanLactel,
      id_producteur: IDS.breizh,
      type_produit_equivalent: 'Lait cru frais de vache',
      prix_unitaire: 1.20,
      score_pertinence: 92,
    },
    {
      id_produit_scanne: IDS.scanDanette,
      id_producteur: IDS.breizh,
      type_produit_equivalent: 'Fromage blanc fermier nature',
      prix_unitaire: 2.80,
      score_pertinence: 70,
    },
  ];

  for (const alt of alts) {
    const existing = await prisma.alternativeLocale.findFirst({
      where: { id_produit_scanne: alt.id_produit_scanne, id_producteur: alt.id_producteur },
    });
    if (!existing) {
      await prisma.alternativeLocale.create({
        data: { ...alt, date_suggestion: new Date(), alternative_cliquee: false },
      });
    }
  }

  console.log('✓ Alternatives locales');
  console.log('\n✅ Seed terminé !');
  console.log('\nComptes de test (mot de passe : Test@1234)');
  console.log('  admin@qarnea.fr           → Admin');
  console.log('  jean.consumer@test.fr     → Consommateur');
  console.log('  marie.consumer@test.fr    → Consommateur');
  console.log('  contact@ferme-beausoleil.fr     → Producteur (légumes bio)');
  console.log('  contact@breizh-elevage.fr       → Producteur (lait/fromages)');
  console.log('  contact@charcuterie-bretonne.fr → Producteur (jambon/charcuterie)');
  console.log('  contact@source-combrailles.fr   → Producteur (eaux de source)');
}

main()
  .catch((e) => { console.error(e); process.exit(1); })
  .finally(() => prisma.$disconnect());
