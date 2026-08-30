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

-- Remove the previous Supabase Auth profile link, if that version of the
-- classroom project was installed. Existing profile rows are kept.
drop trigger if exists on_auth_user_created on auth.users;
drop function if exists public.handle_new_user();

do $$
begin
  if exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'user_profiles'
      and column_name = 'id'
  ) then
    alter table public.user_profiles drop column id cascade;
  end if;
end
$$;

-- Classroom offline-first account mirror. Passwords are stored only as
-- SHA-256 hashes so the same account can be checked online and offline.
create table if not exists public.user_profiles (
  email text primary key,
  full_name text not null,
  password_hash text not null default '',
  is_admin boolean not null default false,
  is_active boolean not null default true,
  avatar_url text,
  updated_at timestamptz not null default now()
);

alter table public.user_profiles
  add column if not exists password_hash text not null default '';
alter table public.user_profiles
  add column if not exists is_active boolean not null default true;

alter table public.user_profiles alter column email set not null;

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conrelid = 'public.user_profiles'::regclass
      and contype = 'p'
  ) then
    alter table public.user_profiles add primary key (email);
  end if;
end
$$;

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

-- Replace the original demo administrator with the project team accounts.
delete from public.user_profiles
where lower(email) = 'admin@safejalan.my';

insert into public.user_profiles
  (email, full_name, password_hash, is_admin, is_active, updated_at)
values
  ('rouyu@safejalan.com', 'Rouyu',
   'dfdb0bb0f0df5a02e37e4d44f8641c6979d16015ecbde05dafdb48837a9bb8e6',
   true, true, now()),
  ('xintong@safejalan.com', 'Xintong',
   '90c929a76949ba3fb1c30b76d3fba1b08dca4547bf64ff1218dd13b267aa7375',
   true, true, now()),
  ('yueshan@safejalan.com', 'Yueshan',
   'e88e96f222a162487a916b85eb439308c44d8155355d07507a74903824778d72',
   true, true, now()),
  ('tzexin@safejalan.com', 'TzeXin',
   '47429213bac3e0238cb5bb5b569bd8d669cf8d27175565b045583d6e614ac77c',
   true, true, now())
on conflict (email) do update set
  full_name = excluded.full_name,
  password_hash = excluded.password_hash,
  is_admin = true,
  is_active = true,
  updated_at = excluded.updated_at;

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

-- Classroom prototype access. The lecture uses an sb_secret_ key, which is
-- evaluated as service_role. PostgreSQL privileges are still required even
-- though service_role bypasses RLS.
grant usage on schema public to service_role;
grant select, insert, update, delete on public.user_profiles
  to service_role;
grant select, insert, update, delete on public.road_reports
  to service_role;
grant select, insert, update, delete on public.report_verifications
  to service_role;
grant select, insert, update, delete on public.connectivity_reports
  to service_role;
grant select, insert, update, delete on public.safety_announcements
  to service_role;
