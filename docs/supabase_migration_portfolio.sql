-- PrepPilot — migration: full Codolio-style portfolio.
-- Run AFTER docs/supabase_migration_github.sql. Idempotent — safe to re-run.
-- Paste into Supabase → SQL Editor → Run.

-- ---------------------------------------------------- platform_stats (extend)
-- Richer development + activity stats (written only by the Edge Function).
alter table public.platform_stats add column if not exists commits int;
alter table public.platform_stats add column if not exists prs int;
alter table public.platform_stats add column if not exists issues int;
alter table public.platform_stats add column if not exists active_days int;
-- Per-day submission counts {"YYYY-MM-DD": n} for the aggregated heatmap.
alter table public.platform_stats add column if not exists daily jsonb;
-- Max (longest-ever) streak per platform, alongside the existing current streak.
alter table public.platform_stats add column if not exists max_streak int;
-- GitHub language distribution {"Dart": 12, "Python": 5} for the languages chart.
alter table public.platform_stats add column if not exists languages jsonb;

-- ------------------------------------------------------- contest_history
-- One row per contest a user has attended (service-role writes; public read).
create table if not exists public.contest_history (
  user_id  uuid references public.profiles(id) on delete cascade,
  platform text not null,
  contest  text not null,
  rank     int,
  rating   int,          -- rating AFTER the contest
  held_at  timestamptz,
  primary key (user_id, platform, contest)
);
alter table public.contest_history enable row level security;
drop policy if exists "contest read"       on public.contest_history;
drop policy if exists "contest delete own" on public.contest_history;
create policy "contest read"       on public.contest_history for select using (true);
create policy "contest delete own" on public.contest_history for delete using (auth.uid() = user_id);

-- ------------------------------------------------------- social_links
-- User-managed profile links (github/linkedin/x/website/email).
create table if not exists public.social_links (
  user_id uuid references public.profiles(id) on delete cascade,
  kind    text not null,     -- github | linkedin | x | website | email
  url     text not null,
  primary key (user_id, kind)
);
alter table public.social_links enable row level security;
drop policy if exists "links2 read"       on public.social_links;
drop policy if exists "links2 write own"  on public.social_links;
drop policy if exists "links2 update own" on public.social_links;
drop policy if exists "links2 delete own" on public.social_links;
create policy "links2 read"       on public.social_links for select using (true);
create policy "links2 write own"  on public.social_links for insert with check (auth.uid() = user_id);
create policy "links2 update own" on public.social_links for update using (auth.uid() = user_id);
create policy "links2 delete own" on public.social_links for delete using (auth.uid() = user_id);

-- ------------------------------------------------------- projects
create table if not exists public.projects (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid references public.profiles(id) on delete cascade,
  title       text not null,
  description text,
  repo_url    text,
  demo_url    text,
  image_url   text,
  tech        text,          -- comma-separated tech/tags
  order_index int not null default 0,
  created_at  timestamptz not null default now()
);
alter table public.projects enable row level security;
drop policy if exists "proj read"       on public.projects;
drop policy if exists "proj write own"  on public.projects;
drop policy if exists "proj update own" on public.projects;
drop policy if exists "proj delete own" on public.projects;
create policy "proj read"       on public.projects for select using (true);
create policy "proj write own"  on public.projects for insert with check (auth.uid() = user_id);
create policy "proj update own" on public.projects for update using (auth.uid() = user_id);
create policy "proj delete own" on public.projects for delete using (auth.uid() = user_id);

-- ------------------------------------------------------- profile views
alter table public.profiles add column if not exists profile_views int not null default 0;

-- Increment another user's profile view count (any signed-in user, not yourself).
create or replace function public.increment_profile_views(target uuid)
returns void language plpgsql security definer set search_path = public as $$
begin
  if target is null or target = auth.uid() then return; end if;
  update public.profiles set profile_views = profile_views + 1 where id = target;
end;
$$;
grant execute on function public.increment_profile_views(uuid) to authenticated;

-- ------------------------------------------------------- leaderboard view (extend)
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
  coalesce(p.profile_views, 0)        as profile_views,
  coalesce(e.verified_solved, 0)      as verified_solved,
  coalesce(e.rating, 0)               as rating,
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
