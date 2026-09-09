/**
 * A signed-in account with no hero row is a half-finished summons. Send it to
 * character creation and keep it there until a hero exists.
 */
const ALLOWED_WITHOUT_HERO = new Set(['/create', '/enter', '/tale'])

export default defineNuxtRouteMiddleware(async (to) => {
  const user = useSupabaseUser()
  if (!user.value) return
  if (ALLOWED_WITHOUT_HERO.has(to.path)) return

  const supabase = useSupabaseClient()
  const { data } = await useAsyncData(`has-hero:${user.value.id}`, async () => {
    const { count } = await supabase
      .from('heroes')
      .select('id', { count: 'exact', head: true })
      .eq('id', user.value!.id)
    return (count ?? 0) > 0
  })

  if (data.value === false) return navigateTo('/create')
})
