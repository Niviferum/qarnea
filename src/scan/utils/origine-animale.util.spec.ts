import { estOrigineAnimale } from './origine-animale.util';

describe('estOrigineAnimale', () => {
  it('retourne true pour une viande (en:meats)', () => {
    expect(estOrigineAnimale(['en:meats', 'en:cooked-hams', 'en:charcuterie'])).toBe(true);
  });

  it('retourne true pour un produit laitier (en:dairy-products)', () => {
    expect(estOrigineAnimale(['en:dairy-products', 'en:cheeses', 'en:soft-cheeses'])).toBe(true);
  });

  it('retourne true pour du poisson (en:fish)', () => {
    expect(estOrigineAnimale(['en:fish', 'en:seafood', 'en:canned-fish'])).toBe(true);
  });

  it('retourne true pour des oeufs (en:eggs)', () => {
    expect(estOrigineAnimale(['en:eggs', 'en:hen-eggs'])).toBe(true);
  });

  it('retourne true pour de la volaille (en:poultry)', () => {
    expect(estOrigineAnimale(['en:meats', 'en:poultry', 'en:chicken-breasts'])).toBe(true);
  });

  it('retourne true pour des crustaces (en:crustaceans)', () => {
    expect(estOrigineAnimale(['en:seafood', 'en:crustaceans', 'en:shrimps'])).toBe(true);
  });

  it('retourne true pour du beurre (en:butter)', () => {
    expect(estOrigineAnimale(['en:dairy-products', 'en:butter'])).toBe(true);
  });

  it('retourne false pour un fruit (en:fruits)', () => {
    expect(estOrigineAnimale(['en:fruits', 'en:fruit-compotes', 'en:plant-based-foods'])).toBe(false);
  });

  it('retourne false pour une boisson vegetale', () => {
    expect(estOrigineAnimale(['en:beverages', 'en:plant-based-beverages', 'en:fruit-juices'])).toBe(false);
  });

  it('retourne false pour des cereales (en:cereals)', () => {
    expect(estOrigineAnimale(['en:cereals-and-their-products', 'en:breads', 'en:whole-wheat-breads'])).toBe(false);
  });

  it('retourne false pour une liste vide', () => {
    expect(estOrigineAnimale([])).toBe(false);
  });

  it('retourne false pour des categories inconnues', () => {
    expect(estOrigineAnimale(['fr:inconnu', 'en:snacks'])).toBe(false);
  });
});
