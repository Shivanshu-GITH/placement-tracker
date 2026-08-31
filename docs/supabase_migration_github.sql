-- PrepPilot — migration: GitHub Development section + dev-aware PrepPilot Score.
-- Run AFTER docs/supabase_migration_platforms.sql. Idempotent — safe to re-run.
-- Paste into Supabase → SQL Editor → Run.

-- Development stats live in the same locked table (written only by the Edge
-- Function). GitHub uses these columns; coding platforms leave them null.
alter table public.platform_stats add column if not exists repos int;
alter table public.platform_stats add column if not exists stars int;
alter table public.platform_stats add column if not exists contributions int;

-- Rebuild the leaderboard view: problem-solving aggregates EXCLUDE github, and a
-- separate GitHub (development) block is exposed. PrepPilot Score becomes
-- 50% external + 50% in-app, where "external" blends problem-solving with
-- development when a GitHub account is linked.
drop view if exists public.leaderboard;
create view public.leaderboard
with (security_invoker = true) as
with ext as (
  select user_id,
         coalesce(sum(solved), 0)         as verified_solved,
         coalesce(max(rating), 0)         as rating,
         coalesce(max(streak), 0)         as ext_streak,
         count(*) filter (where verified) as verified_platforms
  from public.platform_stats
  where platform <> 'github'
  group by user_id
),
dev as (
  select user_id,
         verified                      as github_verified,
         coalesce(repos, 0)            as github_repos,
         coalesce(stars, 0)            as github_stars,
         coalesce(contributions, 0)    as github_contributions,
         coalesce(streak, 0)           as github_streak
  from public.platform_stats
  where platform = 'github'
)
select
  p.id, p.name, p.handle, p.avatar_url, p.college,
  coalesce(e.verified_solved, 0)      as verified_solved,
  coalesce(e.rating, 0)               as rating,
  coalesce(e.ext_streak, 0)           as ext_streak,
  coalesce(e.verified_platforms, 0)   as verified_platforms,
  coalesce(d.github_repos, 0)         as github_repos,
  coalesce(d.github_stars, 0)         as github_stars,
  coalesce(d.github_contributions, 0) as github_contributions,
  coalesce(d.github_streak, 0)        as github_streak,
  coalesce(d.github_verified, false)  as github_verified,
  coalesce(s.total_solved, 0)         as app_solved,
  coalesce(s.current_streak, 0)       as current_streak,
  coalesce(s.longest_streak, 0)       as longest_streak,
  coalesce(s.xp, 0)                   as xp,
  coalesce(s.weekly_solved, 0)        as weekly_solved,
  coalesce(s.week_key, 0)             as week_key,
  round(
    0.5 * (
      case when d.user_id is not null then
        ( -- problem-solving half: solved (cap 1000) + rating (cap 3000)
          ( least(coalesce(e.verified_solved,0) / 1000.0, 1)
            + least(coalesce(e.rating,0) / 3000.0, 1) ) / 2.0 * 100
          + -- development half: contributions (cap 2000) + stars (cap 500) + repos (cap 50)
          ( least(coalesce(d.github_contributions,0) / 2000.0, 1)
            + least(coalesce(d.github_stars,0) / 500.0, 1)
            + least(coalesce(d.github_repos,0) / 50.0, 1) ) / 3.0 * 100
        ) / 2.0
      else
        ( least(coalesce(e.verified_solved,0) / 1000.0, 1)
          + least(coalesce(e.rating,0) / 3000.0, 1) ) / 2.0 * 100
      end
    )
    + 0.5 * (
      -- in-app half: xp (cap 5000) + longest streak (cap 100)
      ( least(coalesce(s.xp,0) / 5000.0, 1)
        + least(coalesce(s.longest_streak,0) / 100.0, 1) ) / 2.0 * 100
    )
  )::int as prep_score
from public.profiles p
left join public.stats s on s.user_id = p.id
left join ext e          on e.user_id = p.id
left join dev d          on d.user_id = p.id;

-- Query examples:
--   Overall (PrepPilot Score): select * from leaderboard order by prep_score desc limit 100;
--   Top developers:            select * from leaderboard where github_verified order by github_contributions desc limit 100;
