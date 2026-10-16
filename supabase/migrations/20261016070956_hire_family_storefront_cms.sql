alter table public.home_settings
  add column if not exists cms_config jsonb not null default '{}'::jsonb
  check (jsonb_typeof(cms_config) = 'object');
