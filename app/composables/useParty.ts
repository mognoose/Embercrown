import type { AbilityCode, HeroSummary } from '~/types/domain'
import { ABILITY_CODES } from '~/types/domain'

export interface PartyAbility {
  ability_code: AbilityCode
  points: number
  contributing_heroes: number
}

/** The whole company, and what it has built between them. */
export function useParty() {
  const supabase = useSupabaseClient()

  const { data, pending, refresh } = useAsyncData('party', async () => {
    const [heroResult, abilityResult] = await Promise.all([
      supabase.from('hero_summary').select('*').order('total_points', { ascending: false }),
      supabase.from('party_abilities').select('*'),
    ])
    if (heroResult.error) throw heroResult.error
    if (abilityResult.error) throw abilityResult.error

    const rows = (abilityResult.data ?? []) as unknown as PartyAbility[]
    return {
      heroes: (heroResult.data ?? []) as unknown as HeroSummary[],
      abilities: ABILITY_CODES.map(
        code =>
          rows.find(r => r.ability_code === code)
          ?? { ability_code: code, points: 0, contributing_heroes: 0 },
      ),
    }
  })

  const heroes = computed(() => data.value?.heroes ?? [])
  const abilities = computed(() => data.value?.abilities ?? [])
  const totalPoints = computed(() =>
    abilities.value.reduce((sum, a) => sum + Number(a.points), 0),
  )

  /** The ability the company has neglected most — the dragon will find it. */
  const weakest = computed(() => {
    if (!abilities.value.length) return null
    return [...abilities.value].sort((a, b) => Number(a.points) - Number(b.points))[0]!
  })

  return { heroes, abilities, totalPoints, weakest, pending, refresh }
}
