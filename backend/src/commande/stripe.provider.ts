import Stripe from 'stripe';

export const STRIPE_CLIENT = 'STRIPE_CLIENT';

export const stripeProvider = {
  provide: STRIPE_CLIENT,
  useFactory: (): InstanceType<typeof Stripe> => {
    const apiVersion = process.env.STRIPE_API_VERSION ?? '2026-05-27.dahlia';
    return new Stripe(process.env.STRIPE_SECRET_KEY ?? '', {
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      apiVersion: apiVersion as any,
    });
  },
};
