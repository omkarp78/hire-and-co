# Supabase setup

This storefront is connected to Supabase project `esdtpdbljyorqvoaleev`.

## Database

The migration in `migrations/` creates the product catalog, coupons, homepage rails, customer reviews, private admin orders, public order-status lookup, and the `product-images` Storage bucket. Row-level security is enabled on every application table. The database was initialized with the current sample catalog and `GLOW10` coupon.

To recreate the schema in a fresh project, apply the SQL migration from the Supabase SQL editor or with the Supabase CLI.

## Admin sign-in

The admin page accepts the ID `hire123` and sends the entered password to Supabase Auth for the account `omkarpatil0806@gmail.com`. The password is never included in this repository. Create or reset that email account in Supabase **Authentication → Users** before using the admin page. Use a fresh password; do not reuse a password shared in chat.

Database write policies authorize only a signed-in session whose verified JWT email matches the configured admin email. Do not replace the publishable key in `dist/app.js` with a secret or service-role key.

## Security model

- The browser uses Supabase's publishable key; table access is constrained by grants and RLS.
- Public visitors can read active products, active coupons, homepage settings, published reviews, and status-only order-tracking rows.
- Customer names, phone numbers, order contents, and totals are stored in `orders`, which has admin-only RLS access.
- Public visitors can submit bounded reviews but cannot edit or delete them.
- Product images are public to view; uploads and deletes require the admin session.
