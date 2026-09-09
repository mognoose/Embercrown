<script setup lang="ts">
import type { AbilityCode } from '~/types/domain'

useHead({ title: 'The company · Embercrown' })

const supabase = useSupabaseClient()
const { heroes, abilities, totalPoints } = useParty()

/** Per-hero, per-ability points, so the roster can show who carries what. */
const { data: contributions } = await useAsyncData('contributions', async () => {
  const { data, error } = await supabase.from('hero_abilities').select('*')
  if (error) throw error
  return (data ?? []) as unknown as {
    hero_id: string
    ability_code: AbilityCode
    points: number
  }[]
})

const sortBy = ref<'total' | AbilityCode>('total')

const ranked = computed(() => {
  if (sortBy.value === 'total') return heroes.value
  const code = sortBy.value
  const pointsFor = (heroId: string) =>
    Number(
      contributions.value?.find(c => c.hero_id === heroId && c.ability_code === code)?.points ?? 0,
    )
  return [...heroes.value].sort((a, b) => pointsFor(b.id) - pointsFor(a.id))
})

function pointsFor(heroId: string, code: AbilityCode) {
  return Math.round(
    Number(
      contributions.value?.find(c => c.hero_id === heroId && c.ability_code === code)?.points ?? 0,
    ),
  )
}
</script>

<template>
  <div class="space-y-5">
    <div>
      <p class="rune">Sworn to the road</p>
      <h1 class="mt-1 text-2xl">The company</h1>
    </div>

    <UiPanel title="What the company has built" :aside="`${Math.round(totalPoints).toLocaleString()} points`">
      <div class="space-y-3">
        <HeroAbilityBar
          v-for="a in abilities"
          :key="a.ability_code"
          :code="a.ability_code"
          :points="Number(a.points)"
          compact
        />
      </div>
    </UiPanel>

    <UiPanel title="The roster">
      <template #aside>
        <label class="flex items-center gap-1.5">
          <span class="sr-only">Rank by</span>
          <select
            v-model="sortBy"
            class="rounded border border-ash-700 bg-ash-900 px-2 py-1 text-xs text-parchment-300"
          >
            <option value="total">Overall</option>
            <option v-for="a in ABILITY_LIST" :key="a.code" :value="a.code">
              {{ a.name }}
            </option>
          </select>
        </label>
      </template>

      <ol v-if="ranked.length" class="divide-y divide-ash-800/70">
        <li v-for="(h, i) in ranked" :key="h.id" class="flex items-center gap-3 py-3">
          <span class="w-5 shrink-0 text-center font-display text-sm text-parchment-500">
            {{ i + 1 }}
          </span>
          <HeroPortrait :class-id="h.class_id" :seed="h.portrait_seed" size="sm" />
          <div class="min-w-0 flex-1">
            <NuxtLink
              :to="`/hero/${h.slug}`"
              class="block truncate text-sm text-parchment-100"
            >
              {{ h.name }}
            </NuxtLink>
            <p class="truncate text-[0.6875rem] text-parchment-500">
              Level {{ h.level }} {{ h.class_name }} · {{ h.deed_count }} deeds
            </p>
          </div>
          <span class="shrink-0 text-right text-sm tabular-nums">
            <template v-if="sortBy === 'total'">
              <span class="text-parchment-200">
                {{ Math.round(Number(h.total_points)).toLocaleString() }}
              </span>
            </template>
            <template v-else>
              <span :style="{ color: `var(${ABILITIES[sortBy].colorVar})` }">
                {{ pointsFor(h.id, sortBy).toLocaleString() }}
              </span>
            </template>
          </span>
        </li>
      </ol>

      <p v-else class="font-chronicle text-sm italic text-parchment-500">
        Nobody has sworn in yet.
      </p>
    </UiPanel>
  </div>
</template>
