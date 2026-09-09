import type { AbilityCode, Boss, EncounterProjection } from '~/types/domain'

/**
 * How the party stands against one boss.
 *
 * Before the encounter date this is a live projection that moves as people log.
 * On or after the date the first page load calls `resolve_encounter`, which
 * freezes the outcome into the `encounters` table — from then on everyone reads
 * the same recorded result, whatever anybody logs afterwards.
 */
export function useEncounter(bossId: MaybeRefOrGetter<string | null | undefined>) {
  const supabase = useSupabaseClient()
  const user = useSupabaseUser()
  const today = useToday()
  const { bosses } = useCampaign()

  const id = computed(() => toValue(bossId) ?? null)
  const boss = computed<Boss | null>(
    () => bosses.value.find(b => b.id === id.value) ?? null,
  )

  const { data, pending, refresh } = useAsyncData(
    () => `encounter:${id.value ?? 'none'}`,
    async () => {
      if (!id.value) return null
      // Past its date and we're signed in? Try to close the books. The RPC is
      // idempotent and returns the frozen record either way.
      const past = boss.value ? boss.value.encounter_on < today.value : false
      const fn = past && user.value ? 'resolve_encounter' : 'project_encounter'
      const { data, error } = await supabase.rpc(fn, { p_boss_id: id.value })
      if (error) throw error
      return data as unknown as EncounterProjection
    },
    { watch: [id] },
  )

  const standing = computed(() => data.value?.abilities ?? [])
  const resolved = computed(() => data.value?.resolved ?? false)
  const outcome = computed(() => data.value?.outcome ?? null)

  /** 0..1 across every tested ability — the boss's overall progress ring. */
  const overall = computed(() => {
    if (!standing.value.length) return 0
    const sum = standing.value.reduce((acc, a) => acc + Number(a.ratio), 0)
    return sum / standing.value.length
  })

  /** The tested ability furthest from its threshold — what to train next. */
  const shortfall = computed(() => {
    const unmet = standing.value.filter(a => !a.met)
    if (!unmet.length) return null
    return [...unmet].sort((a, b) => Number(a.ratio) - Number(b.ratio))[0]!
  })

  const escapedBurden = computed(
    () => (data.value?.escaped_burden ?? {}) as Partial<Record<AbilityCode, number>>,
  )

  return {
    boss,
    projection: data,
    standing,
    resolved,
    outcome,
    overall,
    shortfall,
    escapedBurden,
    pending,
    refresh,
  }
}
