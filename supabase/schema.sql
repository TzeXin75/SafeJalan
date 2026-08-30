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

-- Public profile mirror for the classroom prototype.
-- Password hashes and per-device login settings are intentionally excluded.
create table if not exists public.user_profiles (
  email text primary key,
  full_name text not null,
  is_admin boolean not null default false,
  avatar_url text,
  updated_at timestamptz not null default now()
);

create index if not exists user_profiles_role_idx
  on public.user_profiles (is_admin);

alter table public.user_profiles enable row level security;

drop policy if exists "prototype_read_profiles" on public.user_profiles;
create policy "prototype_read_profiles"
  on public.user_profiles for select
  to anon, authenticated
  using (true);

drop policy if exists "prototype_insert_profiles" on public.user_profiles;
create policy "prototype_insert_profiles"
  on public.user_profiles for insert
  to anon, authenticated
  with check (true);

drop policy if exists "prototype_update_profiles" on public.user_profiles;
create policy "prototype_update_profiles"
  on public.user_profiles for update
  to anon, authenticated
  using (true)
  with check (true);

drop policy if exists "prototype_delete_profiles" on public.user_profiles;
create policy "prototype_delete_profiles"
  on public.user_profiles for delete
  to anon, authenticated
  using (true);

grant select, insert, update, delete on public.user_profiles
  to anon, authenticated;

-- One verification per report and user. The composite primary key prevents
-- the same user from adding a second verification for the same report.
create table if not exists public.report_verifications (
  report_id uuid not null references public.road_reports(id) on delete cascade,
  user_email text not null,
  created_at timestamptz not null default now(),
  primary key (report_id, user_email)
);

create index if not exists report_verifications_user_email_idx
  on public.report_verifications (user_email);

alter table public.report_verifications enable row level security;

drop policy if exists "prototype_read_verifications"
  on public.report_verifications;
create policy "prototype_read_verifications"
  on public.report_verifications for select
  to anon, authenticated
  using (true);

drop policy if exists "prototype_insert_verifications"
  on public.report_verifications;
create policy "prototype_insert_verifications"
  on public.report_verifications for insert
  to anon, authenticated
  with check (true);

drop policy if exists "prototype_update_verifications"
  on public.report_verifications;
create policy "prototype_update_verifications"
  on public.report_verifications for update
  to anon, authenticated
  using (true)
  with check (true);

drop policy if exists "prototype_delete_verifications"
  on public.report_verifications;
create policy "prototype_delete_verifications"
  on public.report_verifications for delete
  to anon, authenticated
  using (true);

grant select, insert, update, delete on public.report_verifications
  to anon, authenticated;

-- Connectivity reports submitted by users and managed by administrators.
create table if not exists public.connectivity_reports (
  id uuid primary key default gen_random_uuid(),
  issue_type text not null,
  carrier text not null,
  notes text not null default '',
  area text not null,
  reporter_email text not null default '',
  status text not null default 'Pending',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists connectivity_reports_created_at_idx
  on public.connectivity_reports (created_at desc);

alter table public.connectivity_reports enable row level security;

drop policy if exists "prototype_read_connectivity"
  on public.connectivity_reports;
create policy "prototype_read_connectivity"
  on public.connectivity_reports for select
  to anon, authenticated using (true);

drop policy if exists "prototype_insert_connectivity"
  on public.connectivity_reports;
create policy "prototype_insert_connectivity"
  on public.connectivity_reports for insert
  to anon, authenticated with check (true);

drop policy if exists "prototype_update_connectivity"
  on public.connectivity_reports;
create policy "prototype_update_connectivity"
  on public.connectivity_reports for update
  to anon, authenticated using (true) with check (true);

drop policy if exists "prototype_delete_connectivity"
  on public.connectivity_reports;
create policy "prototype_delete_connectivity"
  on public.connectivity_reports for delete
  to anon, authenticated using (true);

grant select, insert, update, delete on public.connectivity_reports
  to anon, authenticated;

-- Safety notices: administrators perform CRUD; users read active rows in-app.
create table if not exists public.safety_announcements (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  message text not null,
  priority text not null default 'Normal',
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists safety_announcements_created_at_idx
  on public.safety_announcements (created_at desc);

alter table public.safety_announcements enable row level security;

drop policy if exists "prototype_read_announcements"
  on public.safety_announcements;
create policy "prototype_read_announcements"
  on public.safety_announcements for select
  to anon, authenticated using (true);

drop policy if exists "prototype_insert_announcements"
  on public.safety_announcements;
create policy "prototype_insert_announcements"
  on public.safety_announcements for insert
  to anon, authenticated with check (true);

drop policy if exists "prototype_update_announcements"
  on public.safety_announcements;
create policy "prototype_update_announcements"
  on public.safety_announcements for update
  to anon, authenticated using (true) with check (true);

drop policy if exists "prototype_delete_announcements"
  on public.safety_announcements;
create policy "prototype_delete_announcements"
  on public.safety_announcements for delete
  to anon, authenticated using (true);

grant select, insert, update, delete on public.safety_announcements
  to anon, authenticated;
