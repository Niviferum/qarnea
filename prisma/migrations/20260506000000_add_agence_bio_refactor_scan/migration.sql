-- CreateEnum
CREATE TYPE "SourceScan" AS ENUM ('open_food_facts', 'manuel', 'inconnu');

-- CreateTable
CREATE TABLE "agence_bio_operateur" (
    "numero_bio" VARCHAR(20) NOT NULL,
    "raison_sociale" VARCHAR(200) NOT NULL,
    "siret" VARCHAR(14),
    "adresse" VARCHAR(200),
    "code_postal" VARCHAR(5),
    "ville" VARCHAR(100),
    "departement" VARCHAR(100),
    "coordonnees_lat" DOUBLE PRECISION,
    "coordonnees_lng" DOUBLE PRECISION,
    "geocodage_effectue" BOOLEAN NOT NULL DEFAULT false,
    "produits_certifies" JSONB,
    "activites" JSONB,
    "organisme_certificateur" VARCHAR(100),
    "date_mise_a_jour" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "agence_bio_operateur_pkey" PRIMARY KEY ("numero_bio")
);

-- AlterTable producteur : ajout du lien vers l'annuaire Agence Bio
ALTER TABLE "producteur" ADD COLUMN "numero_bio" VARCHAR(20);

-- CreateIndex
CREATE UNIQUE INDEX "producteur_numero_bio_key" ON "producteur"("numero_bio");

-- AddForeignKey
ALTER TABLE "producteur" ADD CONSTRAINT "producteur_numero_bio_fkey"
    FOREIGN KEY ("numero_bio") REFERENCES "agence_bio_operateur"("numero_bio")
    ON DELETE SET NULL ON UPDATE CASCADE;

-- AlterTable produit_scanne : géoloc optionnelle, catégorie nullable, source typée
ALTER TABLE "produit_scanne"
    ALTER COLUMN "categorie" DROP NOT NULL,
    ALTER COLUMN "label_bio" SET DEFAULT false,
    ALTER COLUMN "localisation_scan_lat" DROP NOT NULL,
    ALTER COLUMN "localisation_scan_lng" DROP NOT NULL;

ALTER TABLE "produit_scanne"
    ALTER COLUMN "source_donnees" DROP DEFAULT;

ALTER TABLE "produit_scanne"
    ALTER COLUMN "source_donnees" TYPE "SourceScan"
    USING (
        CASE "source_donnees"
            WHEN 'open_food_facts' THEN 'open_food_facts'::"SourceScan"
            ELSE 'inconnu'::"SourceScan"
        END
    );

ALTER TABLE "produit_scanne"
    ALTER COLUMN "source_donnees" SET DEFAULT 'inconnu'::"SourceScan";
