import type { Boss, Campaign } from '~/types/domain'

/**
 * The campaign and its six encounters. Cached under one key so every page that
 * asks gets the same fetch.
 */
export function useCampaign() {
  const supabase = useSupabaseClient()
  const today = useToday()

  const { data, pending, refresh } = useAsyncData('campaign', async () => {
    const [campaignResult, bossResult] = await Promise.all([
      supabase.from('campaign').select('*').single(),
      supabase.from('bosses').select('*').order('act'),
    ])
    if (campaignResult.error) throw campaignResult.error
    if (bossResult.error) throw bossResult.error
    return {
      campaign: campaignResult.data as unknown as Campaign,
      bosses: (bossResult.data ?? []) as unknown as Boss[],
    }
  })

  const campaign = computed(() => data.value?.campaign ?? null)
  const bosses = computed(() => data.value?.bosses ?? [])
  const acts = computed(() => bosses.value.filter(b => !b.is_final))
  const dragon = computed(() => bosses.value.find(b => b.is_final) ?? null)

  /** The act currently being fought, or null before the start / after the end. */
  const currentAct = computed(() =>
    acts.value.find(
      b => today.value >= b.window_starts_on && today.value <= b.encounter_on,
    ) ?? null,
  )

  /** The next encounter still ahead of us, dragon included. */
  const nextEncounter = computed(() =>
    bosses.value
      .filter(b => b.encounter_on >= today.value)
      .sort((a, b) => a.encounter_on.localeCompare(b.encounter_on))[0] ?? null,
  )

  const hasStarted = computed(
    () => !!campaign.value && today.value >= campaign.value.starts_on,
  )
  const hasEnded = computed(
    () => !!campaign.value && today.value > campaign.value.ends_on,
  )

  const daysRemaining = computed(() =>
    campaign.value ? Math.max(daysBetween(today.value, campaign.value.ends_on), 0) : 0,
  )

  const progress = computed(() => {
    if (!campaign.value) return 0
    const total = daysBetween(campaign.value.starts_on, campaign.value.ends_on)
    const done = daysBetween(campaign.value.starts_on, today.value)
    return total <= 0 ? 0 : Math.min(Math.max(done / total, 0), 1)
  })

  return {
    campaign,
    bosses,
    acts,
    dragon,
    currentAct,
    nextEncounter,
    hasStarted,
    hasEnded,
    daysRemaining,
    progress,
    pending,
    refresh,
  }
}
