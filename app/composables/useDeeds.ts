import type { ActivityType, DeedPoint, Intensity } from '~/types/domain'

export interface DeedDraft {
  activity_type_id: string
  performed_on: string
  duration_minutes: number
  intensity: Intensity
  note?: string
}

/** The activity catalogue, grouped the way the log form shows it. */
export function useActivityTypes() {
  const supabase = useSupabaseClient()

  const { data, pending } = useAsyncData('activity-types', async () => {
    const { data, error } = await supabase
      .from('activity_types')
      .select('*')
      .order('ability_code')
      .order('sort_order')
    if (error) throw error
    return (data ?? []) as unknown as ActivityType[]
  })

  const all = computed(() => data.value ?? [])

  const byAbility = computed(() =>
    ABILITY_LIST.map(ability => ({
      ability,
      types: all.value.filter(t => t.ability_code === ability.code),
    })),
  )

  return { all, byAbility, pending }
}

/**
 * The shared chronicle: every deed the party has logged, newest first.
 * `limit` keeps the Hearth feed short; the character sheet asks for one hero.
 */
export function useChronicle(options: {
  heroId?: MaybeRefOrGetter<string | null | undefined>
  limit?: number
} = {}) {
  const supabase = useSupabaseClient()
  const heroId = computed(() => toValue(options.heroId) ?? null)
  const limit = options.limit ?? 30

  return useAsyncData(
    () => `chronicle:${heroId.value ?? 'party'}:${limit}`,
    async () => {
      let query = supabase
        .from('deed_points')
        .select('*')
        .order('performed_on', { ascending: false })
        .order('created_at', { ascending: false })
        .limit(limit)
      if (heroId.value) query = query.eq('hero_id', heroId.value)

      const { data, error } = await query
      if (error) throw error
      return (data ?? []) as unknown as DeedPoint[]
    },
    { watch: [heroId] },
  )
}

/**
 * Writing deeds. The database enforces the rules — window, daily cap,
 * duplicates — so this mostly exists to turn a Postgres error into a sentence
 * a person can act on.
 */
export function useDeedLog() {
  const supabase = useSupabaseClient()
  const user = useSupabaseUser()

  async function log(draft: DeedDraft) {
    if (!user.value) throw new Error('You must be signed in to log a deed.')
    const { error } = await supabase.from('deeds').insert({
      hero_id: user.value.id,
      activity_type_id: draft.activity_type_id,
      performed_on: draft.performed_on,
      duration_minutes: draft.duration_minutes,
      intensity: draft.intensity,
      note: draft.note?.trim() || null,
    })
    if (error) throw new Error(readableError(error.message))
  }

  async function retract(deedId: string) {
    const { error } = await supabase.from('deeds').delete().eq('id', deedId)
    if (error) throw new Error(readableError(error.message))
  }

  return { log, retract }
}

function readableError(message: string): string {
  if (message.includes('duplicate key') || message.includes('deeds_hero_id_activity')) {
    return 'That exact deed is already in the chronicle.'
  }
  if (message.includes('duration_minutes')) {
    return 'A single deed must be between 1 and 300 minutes.'
  }
  if (message.includes('row-level security')) {
    return 'You can only write your own deeds.'
  }
  // The triggers already raise sentences; pass those through untouched.
  return message
}
