import type { HeroAbility, HeroSummary } from '~/types/domain'
import { ABILITY_CODES } from '~/types/domain'

/**
 * The signed-in player's own hero. Null while signed out, and null in the gap
 * between signing up and finishing character creation — which is exactly what
 * the hero.global middleware watches for.
 */
export function useHero() {
  const supabase = useSupabaseClient()
  const user = useSupabaseUser()

  const { data, pending, refresh } = useAsyncData(
    'my-hero',
    async () => {
      if (!user.value) return null
      const { data, error } = await supabase
        .from('hero_summary')
        .select('*')
        .eq('id', user.value.id)
        .maybeSingle()
      if (error) throw error
      return (data ?? null) as unknown as HeroSummary | null
    },
    { watch: [user] },
  )

  return { hero: data, pending, refresh }
}

/** The six ability rows for one hero — always six, zeros included. */
export function useHeroAbilities(heroId: MaybeRefOrGetter<string | null | undefined>) {
  const supabase = useSupabaseClient()
  const id = computed(() => toValue(heroId) ?? null)

  return useAsyncData(
    () => `hero-abilities:${id.value ?? 'none'}`,
    async () => {
      if (!id.value) return [] as HeroAbility[]
      const { data, error } = await supabase
        .from('hero_abilities')
        .select('*')
        .eq('hero_id', id.value)
      if (error) throw error
      const rows = (data ?? []) as unknown as HeroAbility[]
      // Return them in canonical STR..CHA order rather than whatever the
      // planner felt like.
      return ABILITY_CODES.map(
        code =>
          rows.find(r => r.ability_code === code)
          ?? { hero_id: id.value!, ability_code: code, points: 0, score: 8 },
      )
    },
    { watch: [id] },
  )
}
