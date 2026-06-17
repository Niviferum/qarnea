const CATEGORIES_ANIMALES = [
  'meats',
  'dairy-products',
  'fish',
  'eggs',
  'poultry',
  'crustaceans',
  'butter',
];

export function estOrigineAnimale(categories: string[]): boolean {
  return categories.some((categorie) => {
    const tag = categorie.includes(':') ? categorie.split(':')[1] : categorie;
    return CATEGORIES_ANIMALES.includes(tag);
  });
}
