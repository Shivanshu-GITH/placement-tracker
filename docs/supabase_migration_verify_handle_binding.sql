-- PrepPilot — migration: bind verified stats to the handle that proved ownership.
-- Run AFTER docs/supabase_migration_ratings_country.sql. Idempotent — safe to
-- re-run. Paste into Supabase → SQL Editor → Run.
--
-- Why: verify-platform took `handle` from the request body but only skipped the
-- ownership-token check based on platform_stats.verified. So once a user had
-- verified ANY handle for a platform, they could re-sync with somebody else's
-- handle and have that person's numbers written into their own row, still
-- flagged verified. That defeats the anti-cheat guarantee of the leaderboard.
--
-- Fix: remember which handle was actually token-verified. The Edge Function now
-- only skips the token when the requested handle matches this column, and
-- rejects any handle that isn't the one linked in platform_links.
--
-- Deploy the function alongside this migration:
--   supabase functions deploy verify-platform

alter table public.platform_stats add column if not exists handle text;

-- Backfill so already-verified users are not forced to re-verify: their current
-- linked handle is the one they proved ownership of.
update public.platform_stats s
   set handle = l.handle
  from public.platform_links l
 where l.user_id = s.user_id
   and l.platform = s.platform
   and s.handle is null;

comment on column public.platform_stats.handle is
  'The handle whose ownership was token-verified. verify-platform only skips the token check when the requested handle matches this value.';
