-- PrepPilot — migration: per-platform ratings + country leaderboard.
-- Run AFTER docs/supabase_migration_portfolio.sql. Idempotent — safe to re-run.
-- Paste into Supabase → SQL Editor → Run.

-- Country for the Country leaderboard (India-first; expandable later).
alter table public.profiles add column if not exists country text default 'India';
update public.profiles set country = 'India' where country is null;

-- Rebuild the leaderboard view: expose country + each contest platform's rating.
drop view if exists public.leaderboard;
create view public.leaderboard
with (security_invoker = true) as
with ext as (
  select user_id,
         coalesce(sum(solved), 0)         as verified_solved,
         coalesce(max(rating), 0)         as rating,
         coalesce(max(streak), 0)         as ext_streak,
         coalesce(max(max_streak), 0)     as ext_max_streak,
         coalesce(max(active_days), 0)    as ext_active_days,
         count(*) filter (where verified) as verified_platforms,
         coalesce(max(rating) filter (where platform = 'leetcode'), 0)   as leetcode_rating,
         coalesce(max(rating) filter (where platform = 'codeforces'), 0) as codeforces_rating,
         coalesce(max(rating) filter (where platform = 'codechef'), 0)   as codechef_rating,
         coalesce(max(rating) filter (where platform = 'atcoder'), 0)    as atcoder_rating
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
         coalesce(commits, 0)          as github_commits,
         coalesce(prs, 0)              as github_prs,
         coalesce(issues, 0)           as github_issues,
         coalesce(active_days, 0)      as github_active_days,
         coalesce(streak, 0)           as github_streak
  from public.platform_stats
  where platform = 'github'
)
select
  p.id, p.name, p.handle, p.avatar_url, p.college,
  coalesce(p.country, 'India')        as country,
  coalesce(p.profile_views, 0)        as profile_views,
  coalesce(e.verified_solved, 0)      as verified_solved,
  coalesce(e.rating, 0)               as rating,
  coalesce(e.leetcode_rating, 0)      as leetcode_rating,
  coalesce(e.codeforces_rating, 0)    as codeforces_rating,
  coalesce(e.codechef_rating, 0)      as codechef_rating,
  coalesce(e.atcoder_rating, 0)       as atcoder_rating,
  coalesce(e.ext_streak, 0)           as ext_streak,
  coalesce(e.ext_max_streak, 0)       as ext_max_streak,
  coalesce(e.ext_active_days, 0)      as ext_active_days,
  coalesce(e.verified_platforms, 0)   as verified_platforms,
  coalesce(d.github_repos, 0)         as github_repos,
  coalesce(d.github_stars, 0)         as github_stars,
  coalesce(d.github_contributions, 0) as github_contributions,
  coalesce(d.github_commits, 0)       as github_commits,
  coalesce(d.github_prs, 0)           as github_prs,
  coalesce(d.github_issues, 0)        as github_issues,
  coalesce(d.github_active_days, 0)   as github_active_days,
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
        ( ( least(coalesce(e.verified_solved,0) / 1000.0, 1)
            + least(coalesce(e.rating,0) / 3000.0, 1) ) / 2.0 * 100
          + ( least(coalesce(d.github_contributions,0) / 2000.0, 1)
            + least(coalesce(d.github_stars,0) / 500.0, 1)
            + least(coalesce(d.github_repos,0) / 50.0, 1) ) / 3.0 * 100
        ) / 2.0
      else
        ( least(coalesce(e.verified_solved,0) / 1000.0, 1)
          + least(coalesce(e.rating,0) / 3000.0, 1) ) / 2.0 * 100
      end
    )
    + 0.5 * (
      ( least(coalesce(s.xp,0) / 5000.0, 1)
        + least(coalesce(s.longest_streak,0) / 100.0, 1) ) / 2.0 * 100
    )
  )::int as prep_score
from public.profiles p
left join public.stats s on s.user_id = p.id
left join ext e          on e.user_id = p.id
left join dev d          on d.user_id = p.id;
