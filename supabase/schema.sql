-- SafeJalan remote database (Supabase/PostgreSQL)
-- Run this file once in Supabase Dashboard > SQL Editor.

create extension if not exists pgcrypto;

create table if not exists public.road_reports (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  category text not null,
  severity text not null,
  description text not null,
  location_name text not null,
  latitude double precision not null,
  longitude double precision not null,
  status text not null default 'Pending',
  image_url text,
  votes integer not null default 0 check (votes >= 0),
  reporter_email text not null default '',
  created_on date not null default current_date,
  updated_at timestamptz not null default now()
);

create index if not exists road_reports_created_on_idx
  on public.road_reports (created_on desc);

create index if not exists road_reports_reporter_email_idx
  on public.road_reports (reporter_email);

alter table public.road_reports enable row level security;

-- Prototype policies: the current app uses its own classroom login screen,
-- so the publishable/anon role needs CRUD access. Replace these policies with
-- auth.uid()-based policies when Supabase Auth is added for production.
drop policy if exists "prototype_read_reports" on public.road_reports;
create policy "prototype_read_reports"
  on public.road_reports for select
  to anon, authenticated
  using (true);

drop policy if exists "prototype_insert_reports" on public.road_reports;
create policy "prototype_insert_reports"
  on public.road_reports for insert
  to anon, authenticated
  with check (true);

drop policy if exists "prototype_update_reports" on public.road_reports;
create policy "prototype_update_reports"
  on public.road_reports for update
  to anon, authenticated
  using (true)
  with check (true);

drop policy if exists "prototype_delete_reports" on public.road_reports;
create policy "prototype_delete_reports"
  on public.road_reports for delete
  to anon, authenticated
  using (true);

grant select, insert, update, delete on public.road_reports
  to anon, authenticated;
