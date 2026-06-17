-- CreateEnum
CREATE TYPE "StatutCommande" AS ENUM ('en_attente', 'payee', 'echouee', 'remboursee');

-- CreateTable
CREATE TABLE "commande" (
    "id_commande" TEXT NOT NULL,
    "stripe_payment_intent_id" TEXT NOT NULL,
    "id_utilisateur" TEXT NOT NULL,
    "id_producteur" TEXT NOT NULL,
    "description" VARCHAR(200) NOT NULL,
    "prix_producteur" DECIMAL(10,2) NOT NULL,
    "commission_qarnea" DECIMAL(10,2) NOT NULL,
    "frais_stripe" DECIMAL(10,2) NOT NULL,
    "total" DECIMAL(10,2) NOT NULL,
    "statut" "StatutCommande" NOT NULL DEFAULT 'en_attente',
    "date_creation" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "date_paiement" TIMESTAMP(3),

    CONSTRAINT "commande_pkey" PRIMARY KEY ("id_commande")
);

-- CreateIndex
CREATE UNIQUE INDEX "commande_stripe_payment_intent_id_key" ON "commande"("stripe_payment_intent_id");

-- AddForeignKey
ALTER TABLE "commande" ADD CONSTRAINT "commande_id_utilisateur_fkey" FOREIGN KEY ("id_utilisateur") REFERENCES "utilisateur"("id_utilisateur") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "commande" ADD CONSTRAINT "commande_id_producteur_fkey" FOREIGN KEY ("id_producteur") REFERENCES "producteur"("id_producteur") ON DELETE RESTRICT ON UPDATE CASCADE;
