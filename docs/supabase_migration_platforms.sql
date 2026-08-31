-- PrepPilot — migration: verified coding-platform stats + PrepPilot Score.
-- Run AFTER the base schema (docs/supabase_schema.sql). Idempotent — safe to
-- re-run. Paste into Supabase → SQL Editor → Run.
--
-- Anti-cheat model:
--   • platform_links  → the USER writes their handle + a verification token.
--   • platform_stats  → ONLY the Edge Function (service role) writes the fetched
--     numbers. Users have NO write policy here, so verified counts can't be faked.

-- ------------------------------------------------------- platform_links
-- User-managed: which handle they claim + the token they'll place in their
-- platform profile to prove ownership.
alter table public.platform_links add column if not exists verify_token text;
alter table public.platform_links add column if not exists created_at timestamptz not null default now();

-- --------------------------------------------------- platform_stats (locked)
-- Written ONLY by the verify-platform Edge Function (service role bypasses RLS).
create table if not exists public.platform_stats (
  user_id   uuid references public.profiles(id) on delete cascade,
  platform  text not null,               -- leetcode | codeforces
  verified  boolean not null default false,
  solved    int not null default 0,
  rating    int,
  streak    int not null default 0,
  synced_at timestamptz not null default now(),
  primary key (user_id, platform)
);

alter table public.platform_stats enable row level security;
-- Everyone can READ verified stats; NO insert/update/delete policy exists, so
-- authenticated users cannot write here — only the service-role Edge Function can.
drop policy if exists "pstats read" on public.platform_stats;
create policy "pstats read" on public.platform_stats for select using (true);
-- Users may DELETE their own row (to unlink) but still cannot INSERT/UPDATE it,
-- so verified numbers can never be faked — only the Edge Function writes them.
drop policy if exists "pstats delete own" on public.platform_stats;
create policy "pstats delete own" on public.platform_stats for delete using (auth.uid() = user_id);

-- --------------------------------------------------------- leaderboard view
-- Aggregates verified external stats + in-app stats and computes the PrepPilot
-- Score (50% verified external work + 50% in-app consistency, each normalized
-- 0..100 against a "maxed-out" reference so the score is a stable 0..100).
-- Dropped first because the column set changes (CREATE OR REPLACE can't rename
-- existing view columns like total_solved → verified_solved).
drop view if exists public.leaderboard;
create view public.leaderboard
with (security_invoker = true) as
with ext as (
  select user_id,
         coalesce(sum(solved), 0)                    as verified_solved,
         coalesce(max(rating), 0)                    as rating,
         coalesce(max(streak), 0)                    as ext_streak,
         count(*) filter (where verified)            as verified_platforms
  from public.platform_stats
  group by user_id
)
select
  p.id, p.name, p.handle, p.avatar_url, p.college,
  coalesce(e.verified_solved, 0)     as verified_solved,
  coalesce(e.rating, 0)              as rating,
  coalesce(e.ext_streak, 0)         as ext_streak,
  coalesce(e.verified_platforms, 0) as verified_platforms,
  coalesce(s.total_solved, 0)       as app_solved,
  coalesce(s.current_streak, 0)     as current_streak,
  coalesce(s.longest_streak, 0)     as longest_streak,
  coalesce(s.xp, 0)                 as xp,
  coalesce(s.weekly_solved, 0)      as weekly_solved,
  coalesce(s.week_key, 0)           as week_key,
  round(
    0.5 * (
      -- external half: solved (cap 1000) + rating (cap 3000), averaged → 0..100
      ( least(coalesce(e.verified_solved,0) / 1000.0, 1)
        + least(coalesce(e.rating,0) / 3000.0, 1) ) / 2.0 * 100
    )
    + 0.5 * (
      -- in-app half: xp (cap 5000) + longest streak (cap 100), averaged → 0..100
      ( least(coalesce(s.xp,0) / 5000.0, 1)
        + least(coalesce(s.longest_streak,0) / 100.0, 1) ) / 2.0 * 100
    )
  )::int as prep_score
from public.profiles p
left join public.stats s          on s.user_id = p.id
left join ext e                   on e.user_id = p.id;

-- Query examples:
--   Overall (PrepPilot Score): select * from leaderboard order by prep_score desc limit 100;
--   Verified solved:           select * from leaderboard order by verified_solved desc limit 100;
--   Rating:                    select * from leaderboard where rating > 0 order by rating desc limit 100;
