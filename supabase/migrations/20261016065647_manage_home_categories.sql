alter table public.home_settings
  add column if not exists categories_enabled boolean not null default true,
  add column if not exists category_order text[] not null default array['Earrings','Mangalsutra','Jewellery Sets']::text[],
  add column if not exists hidden_categories text[] not null default '{}'::text[];
