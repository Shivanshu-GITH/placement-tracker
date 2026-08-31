-- PrepPilot — migration: in-app account & data deletion (Google Play requirement).
-- Run AFTER the base schema + earlier migrations. Idempotent — safe to re-run.
-- Paste into Supabase → SQL Editor → Run.
--
-- Why an RPC: RLS lets a user DELETE their own rows in some tables, but the
-- profiles/stats rows have no delete policy on purpose. Deleting the auth.users
-- row instead cascades to EVERYTHING the user owns, because every table below
-- references profiles(id) → auth.users(id) with ON DELETE CASCADE:
--   profiles, stats, follows (both sides), platform_links, platform_stats,
--   contest_history, social_links, projects.
-- So one authoritative delete removes the account and all associated data.
--
-- SECURITY DEFINER runs with the function owner's privileges (postgres, which
-- can touch the auth schema). search_path is pinned to '' and every name is
-- schema-qualified to prevent search-path hijacking.

create or replace function public.delete_account()
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  -- Only ever delete the CALLER's own account.
  if auth.uid() is null then
    raise exception 'Not authenticated';
  end if;
  delete from auth.users where id = auth.uid();
end;
$$;

-- Only signed-in users may call it; never anon/public.
revoke all on function public.delete_account() from public, anon;
grant execute on function public.delete_account() to authenticated;
