-- AlterTable
ALTER TABLE "type_production" ADD COLUMN     "off_categories_tags" TEXT[] DEFAULT ARRAY[]::TEXT[];
