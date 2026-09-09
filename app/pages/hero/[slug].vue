<script setup lang="ts">
import type { HeroSummary } from '~/types/domain'

const route = useRoute()
const supabase = useSupabaseClient()
const user = useSupabaseUser()

const slug = computed(() => String(route.params.slug))

const { data: hero } = await useAsyncData(
  () => `hero:${slug.value}`,
  async () => {
    const { data, error } = await supabase
      .from('hero_summary')
      .select('*')
      .eq('slug', slug.value)
      .maybeSingle()
    if (error) throw error
    return (data ?? null) as unknown as HeroSummary | null
  },
  { watch: [slug] },
)

if (!hero.value) {
  throw createError({ statusCode: 404, statusMessage: 'No hero by that name.', fatal: true })
}

useHead({ title: () => `${hero.value?.name ?? 'Hero'} · Embercrown` })

const { data: abilities } = useHeroAbilities(() => hero.value?.id)
const { data: deeds } = useChronicle({ heroId: () => hero.value?.id, limit: 25 })

const { data: streak } = await useAsyncData(
  () => `streak:${hero.value?.id ?? 'none'}`,
  async () => {
    if (!hero.value) return 0
    const { data, error } = await supabase.rpc('hero_streak', { p_hero: hero.value.id })
    if (error) throw error
    return Number(data ?? 0)
  },
)

const isMe = computed(() => !!user.value && user.value.id === hero.value?.id)

/**
 * Boons — small titles for the milestones that are worth noticing. Derived, not
 * stored; there is nothing here the chronicle doesn't already know.
 */
const boons = computed(() => {
  const h = hero.value
  if (!h) return []
  const list: { name: string; note: string; icon: string; earned: boolean }[] = [
    {
      name: 'Emberlit',
      note: 'Set down a first deed',
      icon: 'game-icons:flame',
      earned: h.deed_count > 0,
    },
    {
      name: 'Sixfold',
      note: 'Fed all six abilities',
      icon: 'game-icons:star-formation',
      earned: (abilities.value ?? []).every(a => Number(a.points) > 0),
    },
    {
      name: 'Unbroken',
      note: 'Seven days without a gap',
      icon: 'game-icons:chain',
      earned: (streak.value ?? 0) >= 7,
    },
    {
      name: 'Ten-Deed',
      note: 'Ten deeds in the chronicle',
      icon: 'game-icons:scroll-quill',
      earned: h.deed_count >= 10,
    },
  ]
  return list
})
</script>

<template>
  <div v-if="hero" class="space-y-5">
    <section class="panel p-5">
      <div class="flex items-start gap-4">
        <HeroPortrait :class-id="hero.class_id" :seed="hero.portrait_seed" size="lg" />
        <div class="min-w-0 flex-1">
          <h1 class="truncate text-2xl">{{ hero.name }}</h1>
          <p class="mt-0.5 text-sm text-parchment-400">
            Level {{ hero.level }} {{ hero.ancestry }} {{ hero.class_name }}
          </p>
          <div class="mt-3 flex flex-wrap gap-x-5 gap-y-1 text-xs text-parchment-500">
            <span>{{ Math.round(Number(hero.total_points)).toLocaleString() }} points</span>
            <span>{{ hero.deed_count }} deeds</span>
            <span v-if="streak">{{ streak }}-day streak</span>
            <span v-if="hero.last_deed_on">last seen {{ formatDate(hero.last_deed_on) }}</span>
          </div>
        </div>
      </div>
    </section>

    <UiPanel title="Ability scores">
      <div class="space-y-4">
        <HeroAbilityBar
          v-for="a in abilities"
          :key="a.ability_code"
          :code="a.ability_code"
          :points="Number(a.points)"
          :score="a.score"
          :favoured="hero.primary_ability === a.ability_code"
        />
      </div>
    </UiPanel>

    <UiPanel title="Boons">
      <ul class="grid grid-cols-2 gap-2">
        <li
          v-for="boon in boons"
          :key="boon.name"
          class="flex items-center gap-2.5 rounded border p-2.5"
          :class="boon.earned ? 'border-gold-500/40' : 'border-ash-800 opacity-45'"
        >
          <Icon
            :name="boon.icon"
            class="shrink-0 text-lg"
            :class="boon.earned ? 'text-gold-400' : 'text-parchment-500'"
          />
          <span class="min-w-0">
            <span class="block truncate font-display text-sm text-parchment-100">
              {{ boon.name }}
            </span>
            <span class="block truncate text-[0.6875rem] text-parchment-500">
              {{ boon.note }}
            </span>
          </span>
        </li>
      </ul>
    </UiPanel>

    <UiPanel :title="isMe ? 'Your deeds' : `Deeds of ${hero.name}`">
      <ul v-if="deeds?.length">
        <DeedFeedItem v-for="deed in deeds" :key="deed.id" :deed="deed" />
      </ul>
      <p v-else class="font-chronicle text-sm italic text-parchment-500">
        Nothing written here yet.
      </p>
    </UiPanel>
  </div>
</template>
