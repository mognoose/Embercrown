<script setup lang="ts">
import type { Boss } from '~/types/domain'

const props = defineProps<{ boss: Boss }>()

const today = useToday()
const { overall, resolved, outcome, shortfall, pending } = useEncounter(() => props.boss.id)

const state = computed<'won' | 'lost' | 'current' | 'ahead'>(() => {
  if (resolved.value) return outcome.value === 'victory' ? 'won' : 'lost'
  if (today.value >= props.boss.window_starts_on) return 'current'
  return 'ahead'
})

const daysAway = computed(() => daysBetween(today.value, props.boss.encounter_on))

const RING = {
  won: 'var(--color-gold-400)',
  lost: 'var(--color-blood-500)',
  current: 'var(--color-ember-400)',
  ahead: 'var(--color-ash-600)',
} as const
</script>

<template>
  <NuxtLink
    :to="`/encounter/${boss.id}`"
    class="panel flex items-start gap-4 p-4 transition hover:border-ash-600"
    :class="{
      'border-gold-500/45': state === 'won',
      'border-blood-600/55': state === 'lost',
      'border-ember-600/50': state === 'current',
      'opacity-70': state === 'ahead',
    }"
  >
    <!-- Progress ring around the boss glyph. -->
    <div class="relative shrink-0">
      <svg viewBox="0 0 44 44" class="h-14 w-14 -rotate-90">
        <circle cx="22" cy="22" r="19" fill="none" stroke="var(--color-ash-800)" stroke-width="3" />
        <circle
          cx="22" cy="22" r="19" fill="none"
          :stroke="RING[state]"
          stroke-width="3"
          stroke-linecap="round"
          :stroke-dasharray="`${(state === 'won' ? 1 : overall) * 119.4} 119.4`"
          class="transition-[stroke-dasharray] duration-700"
        />
      </svg>
      <Icon
        :name="boss.icon"
        class="absolute inset-0 m-auto text-2xl"
        :style="{ color: RING[state] }"
      />
    </div>

    <div class="min-w-0 flex-1">
      <div class="flex items-baseline gap-2">
        <span class="rune">Act {{ boss.act }}</span>
        <span
          v-if="state === 'won'"
          class="rune text-gold-400"
        >Won</span>
        <span
          v-else-if="state === 'lost'"
          class="rune text-blood-400"
        >Escaped</span>
        <span
          v-else-if="state === 'current'"
          class="rune text-ember-300"
        >Underway</span>
      </div>

      <h3 class="mt-0.5 truncate text-base">
        {{ boss.name }}<span class="text-parchment-400">, {{ boss.title }}</span>
      </h3>
      <p class="truncate text-xs text-parchment-500">{{ boss.place }}</p>

      <div class="mt-2 flex flex-wrap items-center gap-x-3 gap-y-1 text-[0.6875rem]">
        <span class="text-parchment-500">
          {{ formatDate(boss.encounter_on) }}
          <template v-if="!resolved"> · {{ describeGap(daysAway) }}</template>
        </span>

        <span
          v-for="code in boss.tested_abilities"
          :key="code"
          class="inline-flex items-center gap-1 text-parchment-400"
        >
          <Icon
            :name="ABILITIES[code].icon"
            :style="{ color: `var(${ABILITIES[code].colorVar})` }"
          />
          {{ ABILITIES[code].short }}
        </span>
      </div>

      <p
        v-if="!pending && !resolved && state === 'current' && shortfall"
        class="mt-2 text-[0.6875rem] text-ember-300"
      >
        Weakest front: {{ ABILITIES[shortfall.code].name }}.
      </p>
    </div>
  </NuxtLink>
</template>
