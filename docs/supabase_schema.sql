-- PrepPilot — Supabase schema for social leaderboards.
-- Paste this whole file into Supabase → SQL Editor → Run (once).
-- Security model: everyone can READ leaderboard data; each user can only WRITE
-- their own rows (enforced by Row-Level Security + auth.uid()).

-- ------------------------------------------------------------------ tables
create table if not exists public.profiles (
  id         uuid primary key references auth.users(id) on delete cascade,
  handle     text unique,
  name       text not null default 'Aspirant',
  avatar_url text,
  college    text,
  created_at timestamptz not null default now()
);

create table if not exists public.stats (
  user_id        uuid primary key references public.profiles(id) on delete cascade,
  total_solved   int not null default 0,
  current_streak int not null default 0,
  longest_streak int not null default 0,
  xp             int not null default 0,
  weekly_solved  int not null default 0,
  weekly_minutes int not null default 0,
  week_key       int not null default 0,   -- yyyyww, for weekly-board scoping
  updated_at     timestamptz not null default now()
);

create table if not exists public.follows (
  follower_id  uuid references public.profiles(id) on delete cascade,
  following_id uuid references public.profiles(id) on delete cascade,
  created_at   timestamptz not null default now(),
  primary key (follower_id, following_id)
);

create table if not exists public.platform_links (
  user_id        uuid references public.profiles(id) on delete cascade,
  platform       text not null,            -- leetcode | codeforces | gfg | codechef
  handle         text not null,
  verified_solved int,
  rating          int,
  last_synced     timestamptz,
  primary key (user_id, platform)
);

-- --------------------------------------------------------------------- RLS
alter table public.profiles       enable row level security;
alter table public.stats          enable row level security;
alter table public.follows        enable row level security;
alter table public.platform_links enable row level security;

drop policy if exists "profiles read"       on public.profiles;
drop policy if exists "profiles insert own"  on public.profiles;
drop policy if exists "profiles update own"  on public.profiles;
create policy "profiles read"      on public.profiles for select using (true);
create policy "profiles insert own" on public.profiles for insert with check (auth.uid() = id);
create policy "profiles update own" on public.profiles for update using (auth.uid() = id);

drop policy if exists "stats read"       on public.stats;
drop policy if exists "stats insert own" on public.stats;
drop policy if exists "stats update own" on public.stats;
create policy "stats read"       on public.stats for select using (true);
create policy "stats insert own" on public.stats for insert with check (auth.uid() = user_id);
create policy "stats update own" on public.stats for update using (auth.uid() = user_id);

drop policy if exists "follows read own"   on public.follows;
drop policy if exists "follows insert own" on public.follows;
drop policy if exists "follows delete own" on public.follows;
create policy "follows read own"   on public.follows for select using (auth.uid() = follower_id);
create policy "follows insert own" on public.follows for insert with check (auth.uid() = follower_id);
create policy "follows delete own" on public.follows for delete using (auth.uid() = follower_id);

drop policy if exists "links read"       on public.platform_links;
drop policy if exists "links insert own" on public.platform_links;
drop policy if exists "links update own" on public.platform_links;
drop policy if exists "links delete own" on public.platform_links;
create policy "links read"       on public.platform_links for select using (true);
create policy "links insert own" on public.platform_links for insert with check (auth.uid() = user_id);
create policy "links update own" on public.platform_links for update using (auth.uid() = user_id);
create policy "links delete own" on public.platform_links for delete using (auth.uid() = user_id);

-- ------------------------------------------------------ convenience view
-- Joins profile + stats so the app can query one place for the leaderboard.
create or replace view public.leaderboard
with (security_invoker = true) as
select p.id, p.name, p.handle, p.avatar_url, p.college,
       coalesce(s.total_solved, 0)   as total_solved,
       coalesce(s.current_streak, 0) as current_streak,
       coalesce(s.longest_streak, 0) as longest_streak,
       coalesce(s.xp, 0)             as xp,
       coalesce(s.weekly_solved, 0)  as weekly_solved,
       coalesce(s.week_key, 0)       as week_key
from public.profiles p
left join public.stats s on s.user_id = p.id;

-- Query examples the app will use:
--   Global (by solved):  select * from leaderboard order by total_solved desc limit 100;
--   Weekly:              select * from leaderboard where week_key = :thisWeek order by weekly_solved desc limit 100;
--   College:             select * from leaderboard where college = :college order by total_solved desc limit 100;
--   Friends:             select * from leaderboard where id in (select following_id from follows where follower_id = auth.uid());
