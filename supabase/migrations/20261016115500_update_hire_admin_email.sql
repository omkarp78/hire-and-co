create or replace function private.is_hire_admin()
returns boolean
language sql
stable
security invoker
set search_path = ''
as $$
  select lower(coalesce((select auth.jwt()->>'email'), '')) = 'hire@g.com'
$$;
