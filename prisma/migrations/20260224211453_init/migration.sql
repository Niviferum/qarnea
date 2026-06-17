-- CreateEnum
CREATE TYPE "Role" AS ENUM ('user', 'supporter', 'producteur', 'admin');

-- CreateEnum
CREATE TYPE "StatutCompte" AS ENUM ('actif', 'restricted', 'deleted');

-- CreateEnum
CREATE TYPE "TypeAbonnement" AS ENUM ('mensuel', 'annuel');

-- CreateEnum
CREATE TYPE "StatutAbonnement" AS ENUM ('actif', 'annule', 'expire', 'en_attente');

-- CreateEnum
CREATE TYPE "StatutVerification" AS ENUM ('verified', 'pending', 'rejected', 'not_submitted');

-- CreateEnum
CREATE TYPE "RayonFloutage" AS ENUM ('km_5', 'km_10', 'km_25');

-- CreateTable
CREATE TABLE "utilisateur" (
    "id_utilisateur" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "password_hash" TEXT NOT NULL,
    "nom" TEXT NOT NULL,
    "prenom" TEXT NOT NULL,
    "telephone" TEXT,
    "date_naissance" DATE,
    "date_inscription" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "date_derniere_connexion" TIMESTAMP(3),
    "role" "Role" NOT NULL DEFAULT 'user',
    "statut_compte" "StatutCompte" NOT NULL DEFAULT 'actif',
    "localisation_autorisee" BOOLEAN NOT NULL DEFAULT true,
    "localisation_lat" DOUBLE PRECISION,
    "localisation_lng" DOUBLE PRECISION,
    "ville_preferee" TEXT,
    "rayon_recherche_defaut" INTEGER NOT NULL DEFAULT 20,
    "langue" VARCHAR(5) NOT NULL DEFAULT 'fr',
    "accepte_notifications" BOOLEAN NOT NULL DEFAULT true,
    "avatar_url" TEXT,
    "stripe_customer_id" TEXT,
    "fcm_token" TEXT,

    CONSTRAINT "utilisateur_pkey" PRIMARY KEY ("id_utilisateur")
);

-- CreateTable
CREATE TABLE "abonnement" (
    "id_abonnement" TEXT NOT NULL,
    "id_utilisateur" TEXT NOT NULL,
    "stripe_subscription_id" TEXT,
    "type_abonnement" "TypeAbonnement" NOT NULL,
    "statut" "StatutAbonnement" NOT NULL,
    "montant" DECIMAL(10,2) NOT NULL,
    "devise" VARCHAR(3) NOT NULL,
    "date_debut" TIMESTAMP(3) NOT NULL,
    "date_fin" TIMESTAMP(3),
    "date_prochain_paiement" TIMESTAMP(3),
    "date_annulation" TIMESTAMP(3),
    "renouvellement_automatique" BOOLEAN NOT NULL DEFAULT true,
    "raison_annulation" TEXT,

    CONSTRAINT "abonnement_pkey" PRIMARY KEY ("id_abonnement")
);

-- CreateTable
CREATE TABLE "producteur" (
    "id_producteur" TEXT NOT NULL,
    "id_utilisateur" TEXT NOT NULL,
    "nom_exploitation" VARCHAR(100) NOT NULL,
    "raison_sociale" VARCHAR(100) NOT NULL,
    "siret" VARCHAR(14) NOT NULL,
    "description" VARCHAR(300) NOT NULL,
    "description_pratiques" VARCHAR(300),
    "adresse_ligne1" VARCHAR(50) NOT NULL,
    "adresse_ligne2" VARCHAR(50),
    "ville" VARCHAR(50) NOT NULL,
    "region" VARCHAR(50) NOT NULL,
    "departement" VARCHAR(50) NOT NULL,
    "coordonnees_lat" DOUBLE PRECISION NOT NULL,
    "coordonnees_lng" DOUBLE PRECISION NOT NULL,
    "afficher_adresse_exacte" BOOLEAN NOT NULL DEFAULT true,
    "rayon_floutage_km" "RayonFloutage",
    "telephone" VARCHAR(20) NOT NULL,
    "email_contact" VARCHAR(50) NOT NULL,
    "site_web" VARCHAR(50),
    "facebook_url" VARCHAR(50),
    "instagram_url" VARCHAR(50),
    "horaires_ouverture" JSONB NOT NULL,
    "jours_marches" VARCHAR(300),
    "vente_directe" BOOLEAN NOT NULL,
    "vente_paniers" BOOLEAN NOT NULL,
    "livraison_possible" BOOLEAN NOT NULL,
    "rayon_livraison_km" INTEGER,
    "click_and_collect" BOOLEAN NOT NULL DEFAULT false,
    "commande_en_ligne" BOOLEAN DEFAULT false,
    "photo_profil_url" TEXT,
    "photos_exploitation" TEXT[],
    "statut_verification" "StatutVerification" NOT NULL,
    "date_verification" TIMESTAMP(3),
    "id_admin_verificateur" TEXT,
    "note_admin" VARCHAR(300),
    "id_utilisateur_proposeur" TEXT,
    "date_creation" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "date_modification" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "visible_publiquement" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "producteur_pkey" PRIMARY KEY ("id_producteur")
);

-- CreateTable
CREATE TABLE "type_production" (
    "id_type_production" TEXT NOT NULL,
    "nom" VARCHAR(50) NOT NULL,
    "slug" VARCHAR(300) NOT NULL,
    "description" VARCHAR(300) NOT NULL,
    "id_categorie_parent" TEXT,

    CONSTRAINT "type_production_pkey" PRIMARY KEY ("id_type_production")
);

-- CreateTable
CREATE TABLE "producteur_type_production" (
    "id_producteur" TEXT NOT NULL,
    "id_type_production" TEXT NOT NULL,
    "production_principale" BOOLEAN NOT NULL,
    "volume_annuel" INTEGER,
    "disponibilite_saisonniere" JSONB,

    CONSTRAINT "producteur_type_production_pkey" PRIMARY KEY ("id_producteur","id_type_production")
);

-- CreateTable
CREATE TABLE "label" (
    "id_label" TEXT NOT NULL,
    "nom" VARCHAR(100) NOT NULL,
    "code" VARCHAR(20) NOT NULL,
    "description" TEXT,
    "organisme_certificateur" VARCHAR(150),
    "logo_url" TEXT,
    "site_web" TEXT,
    "niveau_exigence" VARCHAR(20),
    "type_label" VARCHAR(50),
    "actif" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "label_pkey" PRIMARY KEY ("id_label")
);

-- CreateTable
CREATE TABLE "producteur_label" (
    "id_producteur_label" TEXT NOT NULL,
    "id_producteur" TEXT NOT NULL,
    "id_label" TEXT NOT NULL,
    "numero_certification" TEXT,
    "date_obtention" TIMESTAMP(3),
    "date_expiration" TIMESTAMP(3),
    "document_preuve_url" TEXT,
    "verifie" BOOLEAN NOT NULL DEFAULT false,
    "date_verification" TIMESTAMP(3),

    CONSTRAINT "producteur_label_pkey" PRIMARY KEY ("id_producteur_label")
);

-- CreateTable
CREATE TABLE "produit_scanne" (
    "id_produit_scanne" TEXT NOT NULL,
    "id_utilisateur" TEXT NOT NULL,
    "code_barre" VARCHAR(20) NOT NULL,
    "nom_produit" VARCHAR(255),
    "marque" VARCHAR(255),
    "categorie" VARCHAR(255) NOT NULL,
    "date_scan" TIMESTAMP(3) NOT NULL,
    "donnees_off" JSONB,
    "nutriscore" CHAR(1),
    "score_nova" INTEGER,
    "ecoscore" CHAR(1),
    "nombre_additifs" INTEGER,
    "additifs_controverses" JSONB,
    "allergenes" JSONB,
    "origines_ingredients" JSONB,
    "label_bio" BOOLEAN NOT NULL,
    "localisation_scan_lat" DOUBLE PRECISION NOT NULL,
    "localisation_scan_lng" DOUBLE PRECISION NOT NULL,
    "source_donnees" VARCHAR(255) NOT NULL,

    CONSTRAINT "produit_scanne_pkey" PRIMARY KEY ("id_produit_scanne")
);

-- CreateTable
CREATE TABLE "alternative_locale" (
    "id_alternative" TEXT NOT NULL,
    "id_produit_scanne" TEXT NOT NULL,
    "id_producteur" TEXT NOT NULL,
    "type_produit_equivalent" VARCHAR(255),
    "distance_km" DECIMAL(6,2),
    "score_pertinence" INTEGER,
    "date_suggestion" TIMESTAMP(3) NOT NULL,
    "alternative_cliquee" BOOLEAN NOT NULL DEFAULT false,
    "date_clic" TIMESTAMP(3),

    CONSTRAINT "alternative_locale_pkey" PRIMARY KEY ("id_alternative")
);

-- CreateTable
CREATE TABLE "recherche_utilisateur" (
    "id_recherche" TEXT NOT NULL,
    "id_utilisateur" TEXT,
    "date_recherche" TIMESTAMP(3) NOT NULL,
    "localisation_lat" DOUBLE PRECISION,
    "localisation_lng" DOUBLE PRECISION,
    "rayon_km" INTEGER,
    "type_production_filtres" JSONB,
    "livraison_possible" BOOLEAN NOT NULL DEFAULT false,
    "nombre_resultats" INTEGER,
    "session_id" VARCHAR(100),

    CONSTRAINT "recherche_utilisateur_pkey" PRIMARY KEY ("id_recherche")
);

-- CreateTable
CREATE TABLE "notification" (
    "id_notification" TEXT NOT NULL,
    "id_utilisateur" TEXT NOT NULL,
    "type" VARCHAR(100) NOT NULL,
    "titre" VARCHAR(100) NOT NULL,
    "message" VARCHAR(255) NOT NULL,
    "url" VARCHAR(500),
    "lue" BOOLEAN NOT NULL DEFAULT false,
    "date_envoi" TIMESTAMP(3) NOT NULL,
    "date_lecture" TIMESTAMP(3),

    CONSTRAINT "notification_pkey" PRIMARY KEY ("id_notification")
);

-- CreateTable
CREATE TABLE "log" (
    "id_log" TEXT NOT NULL,
    "date" TIMESTAMP(3) NOT NULL,
    "id_utilisateur" TEXT,
    "action" VARCHAR(30) NOT NULL,
    "ressource_type" VARCHAR(100),
    "id_ressource" TEXT,
    "ip_address" VARCHAR(45),
    "client_version" VARCHAR(100) NOT NULL,
    "details" JSONB,

    CONSTRAINT "log_pkey" PRIMARY KEY ("id_log")
);

-- CreateTable
CREATE TABLE "action_admin" (
    "id_admin_action" TEXT NOT NULL,
    "id_admin" TEXT NOT NULL,
    "date" TIMESTAMP(3) NOT NULL,
    "type_action" VARCHAR(100) NOT NULL,
    "type_ressource" VARCHAR(100) NOT NULL,
    "ressource_id" TEXT NOT NULL,
    "old_value" JSONB,
    "new_value" JSONB,
    "motif" TEXT,

    CONSTRAINT "action_admin_pkey" PRIMARY KEY ("id_admin_action")
);

-- CreateIndex
CREATE UNIQUE INDEX "utilisateur_email_key" ON "utilisateur"("email");

-- CreateIndex
CREATE UNIQUE INDEX "utilisateur_stripe_customer_id_key" ON "utilisateur"("stripe_customer_id");

-- CreateIndex
CREATE UNIQUE INDEX "utilisateur_fcm_token_key" ON "utilisateur"("fcm_token");

-- CreateIndex
CREATE UNIQUE INDEX "abonnement_stripe_subscription_id_key" ON "abonnement"("stripe_subscription_id");

-- CreateIndex
CREATE UNIQUE INDEX "producteur_id_utilisateur_key" ON "producteur"("id_utilisateur");

-- CreateIndex
CREATE UNIQUE INDEX "producteur_raison_sociale_key" ON "producteur"("raison_sociale");

-- CreateIndex
CREATE UNIQUE INDEX "producteur_email_contact_key" ON "producteur"("email_contact");

-- CreateIndex
CREATE UNIQUE INDEX "type_production_slug_key" ON "type_production"("slug");

-- CreateIndex
CREATE UNIQUE INDEX "label_nom_key" ON "label"("nom");

-- CreateIndex
CREATE UNIQUE INDEX "label_code_key" ON "label"("code");

-- AddForeignKey
ALTER TABLE "abonnement" ADD CONSTRAINT "abonnement_id_utilisateur_fkey" FOREIGN KEY ("id_utilisateur") REFERENCES "utilisateur"("id_utilisateur") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "producteur" ADD CONSTRAINT "producteur_id_utilisateur_fkey" FOREIGN KEY ("id_utilisateur") REFERENCES "utilisateur"("id_utilisateur") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "producteur" ADD CONSTRAINT "producteur_id_admin_verificateur_fkey" FOREIGN KEY ("id_admin_verificateur") REFERENCES "utilisateur"("id_utilisateur") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "producteur" ADD CONSTRAINT "producteur_id_utilisateur_proposeur_fkey" FOREIGN KEY ("id_utilisateur_proposeur") REFERENCES "utilisateur"("id_utilisateur") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "type_production" ADD CONSTRAINT "type_production_id_categorie_parent_fkey" FOREIGN KEY ("id_categorie_parent") REFERENCES "type_production"("id_type_production") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "producteur_type_production" ADD CONSTRAINT "producteur_type_production_id_producteur_fkey" FOREIGN KEY ("id_producteur") REFERENCES "producteur"("id_producteur") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "producteur_type_production" ADD CONSTRAINT "producteur_type_production_id_type_production_fkey" FOREIGN KEY ("id_type_production") REFERENCES "type_production"("id_type_production") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "producteur_label" ADD CONSTRAINT "producteur_label_id_producteur_fkey" FOREIGN KEY ("id_producteur") REFERENCES "producteur"("id_producteur") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "producteur_label" ADD CONSTRAINT "producteur_label_id_label_fkey" FOREIGN KEY ("id_label") REFERENCES "label"("id_label") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "produit_scanne" ADD CONSTRAINT "produit_scanne_id_utilisateur_fkey" FOREIGN KEY ("id_utilisateur") REFERENCES "utilisateur"("id_utilisateur") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "alternative_locale" ADD CONSTRAINT "alternative_locale_id_produit_scanne_fkey" FOREIGN KEY ("id_produit_scanne") REFERENCES "produit_scanne"("id_produit_scanne") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "alternative_locale" ADD CONSTRAINT "alternative_locale_id_producteur_fkey" FOREIGN KEY ("id_producteur") REFERENCES "producteur"("id_producteur") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "recherche_utilisateur" ADD CONSTRAINT "recherche_utilisateur_id_utilisateur_fkey" FOREIGN KEY ("id_utilisateur") REFERENCES "utilisateur"("id_utilisateur") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "notification" ADD CONSTRAINT "notification_id_utilisateur_fkey" FOREIGN KEY ("id_utilisateur") REFERENCES "utilisateur"("id_utilisateur") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "log" ADD CONSTRAINT "log_id_utilisateur_fkey" FOREIGN KEY ("id_utilisateur") REFERENCES "utilisateur"("id_utilisateur") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "action_admin" ADD CONSTRAINT "action_admin_id_admin_fkey" FOREIGN KEY ("id_admin") REFERENCES "utilisateur"("id_utilisateur") ON DELETE RESTRICT ON UPDATE CASCADE;
