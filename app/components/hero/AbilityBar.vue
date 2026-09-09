<script setup lang="ts">
import type { AbilityCode } from '~/types/domain'

const props = withDefaults(
  defineProps<{
    code: AbilityCode
    points: number
    /** Omit to derive from points. */
    score?: number
    /** Marks the class's primary ability. */
    favoured?: boolean
    compact?: boolean
  }>(),
  { compact: false, favoured: false },
)

const ability = computed(() => ABILITIES[props.code])
const score = computed(() => props.score ?? abilityScore(props.points))
const modifier = computed(() => abilityModifier(score.value))
const fill = computed(() => scoreProgress(props.points))
const toNext = computed(() => pointsToNextScore(props.points))
</script>

<template>
  <div class="flex items-center gap-3">
    <Icon
      :name="ability.icon"
      class="shrink-0 text-xl"
      :style="{ color: `var(${ability.colorVar})` }"
    />

    <div class="min-w-0 flex-1">
      <div class="flex items-baseline gap-2">
        <span class="rune text-parchment-300">{{ ability.short }}</span>
        <span v-if="!compact" class="truncate text-xs text-parchment-500">
          {{ ability.name }}
        </span>
        <Icon
          v-if="favoured"
          name="game-icons:star-formation"
          class="shrink-0 text-xs text-gold-400"
          :title="`Favoured — this hero's class earns more here`"
        />
        <span class="ml-auto shrink-0 tabular-nums text-parchment-500">
          <span class="text-xs">{{ Math.round(points) }} pts</span>
        </span>
      </div>

      <div class="mt-1 h-1.5 overflow-hidden rounded-full bg-ash-800">
        <div
          class="h-full rounded-full transition-[width] duration-500"
          :style="{
            width: `${Math.max(fill * 100, points > 0 ? 3 : 0)}%`,
            backgroundColor: `var(${ability.colorVar})`,
          }"
        />
      </div>

      <p v-if="!compact" class="mt-1 text-[0.6875rem] text-parchment-500">
        {{ toNext }} more to reach {{ score + 1 }}
      </p>
    </div>

    <div class="shrink-0 text-right">
      <div
        class="font-display text-xl leading-none tabular-nums"
        :style="{ color: `var(${ability.colorVar})` }"
      >
        {{ score }}
      </div>
      <div class="mt-0.5 text-[0.6875rem] tabular-nums text-parchment-500">
        {{ formatModifier(modifier) }}
      </div>
    </div>
  </div>
</template>
