/**
 * A signed-in account with no hero row is a half-finished summons. Send it to
 * character creation and keep it there until a hero exists.
 *
 * Two things this has to work around:
 *
 * 1. `useSupabaseUser()` is not populated yet when global route middleware runs
 *    on the server — the module fills it from a plugin that runs after the
 *    router has already resolved the initial route. So the session is read from
 *    the Supabase client here, which parses the request cookie directly.
 * 2. `useAsyncData` inside route middleware does not reliably resolve before the
 *    guard has to decide, so the answer is cached in `useState` instead. That is
 *    filled on the server and carried to the client in the payload, so the whole
 *    check costs one round trip per session rather than one per navigation.
 */
const ALLOWED_WITHOUT_HERO = new Set(['/create', '/enter', '/confirm', '/tale'])

export default defineNuxtRouteMiddleware(async (to) => {
  if (ALLOWED_WITHOUT_HERO.has(to.path)) return

  const hasHero = useHasHero()
  if (hasHero.value !== null) {
    return hasHero.value ? undefined : navigateTo('/create')
  }

  const supabase = useSupabaseClient()
  const { data: { user } } = await supabase.auth.getUser()
  // Signed out — the module's own redirect takes it from here.
  if (!user) return

  const { count, error } = await supabase
    .from('heroes')
    .select('id', { count: 'exact', head: true })
    .eq('id', user.id)
  // On a query failure let the page through, rather than trapping someone in
  // character creation because the database blinked.
  if (error) return

  hasHero.value = (count ?? 0) > 0
  if (!hasHero.value) return navigateTo('/create')
})
