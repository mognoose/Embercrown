-- Close the default PUBLIC execute grant on the two functions that should be
-- members-only.
--
-- Two defaults held the door open, and the `grant ... to authenticated` lines
-- at the end of 0001 were additive rather than restrictive, so anon could still
-- call them. Live verification caught it:
--   * Postgres grants EXECUTE on every new function to PUBLIC, and
--   * Supabase's default privileges on the public schema grant it to `anon`
--     explicitly on top of that, so revoking from PUBLIC alone is not enough.
--
-- Nothing was exposed by it — resolve_encounter validates its argument, only
-- acts on an encounter whose date has already passed, and computes entirely
-- from real data; hero_streak is SECURITY INVOKER, so RLS already returned 0 to
-- anonymous callers. But resolve_encounter is SECURITY DEFINER and what it
-- writes is permanent, so it should not be reachable from the public API.
--
-- 0001 has been corrected too. Running this against a database built from the
-- corrected 0001 is harmless — revoke and grant are both idempotent.

revoke execute on function resolve_encounter(text) from public, anon;
revoke execute on function hero_streak(uuid)       from public, anon;

grant execute on function resolve_encounter(text) to authenticated;
grant execute on function hero_streak(uuid)       to authenticated;
