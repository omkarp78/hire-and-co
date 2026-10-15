# Hire & Co. Storefront

A lightweight storefront for Hire & Co. with product categories, product details, Marathi and Hindi translations, reviews, a cart, WhatsApp checkout, and an admin dashboard.

## Run locally

Serve the `dist/` directory with any static web server. The hosted site output directory is `dist`.

## Supabase setup

The SQL migration in [`supabase/migrations/`](supabase/migrations/) sets up the product catalog, coupons, home page rails, reviews, private order details, order tracking, storage, and row-level security. See [`supabase/README.md`](supabase/README.md) for setup and admin account instructions.

The browser app uses only the Supabase publishable key. Never put a service-role key or admin password in the repository.

## Customer orders

Checkout opens WhatsApp with the cart and customer details filled into a message. Admins can manage products, coupons, featured home page rails, and order status after signing in.
