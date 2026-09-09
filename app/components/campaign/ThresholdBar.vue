<script setup lang="ts">
import type { AbilityStanding } from '~/types/domain'

/**
 * One tested ability against a boss: how much the party has, how much it needs,
 * and whether that front is holding.
 */
const props = defineProps<{ standing: AbilityStanding }>()

const ability = computed(() => ABILITIES[props.standing.code])
const ratio = computed(() => Math.min(Number(props.standing.ratio), 1))
const points = computed(() => Math.round(Number(props.standing.points)))
const required = computed(() => Math.round(Number(props.standing.required)))
const shortBy = computed(() => Math.max(required.value - points.value, 0))
</script>

<template>
  <div>
    <div class="flex items-baseline gap-2">
      <Icon
        :name="ability.icon"
        class="text-base"
        :style="{ color: `var(${ability.colorVar})` }"
      />
      <span class="rune text-parchment-300">{{ ability.short }}</span>
      <span
        class="ml-auto tabular-nums text-xs"
        :class="standing.met ? 'text-gold-400' : 'text-parchment-400'"
      >
        {{ points.toLocaleString() }} / {{ required.toLocaleString() }}
      </span>
    </div>

    <div class="mt-1.5 h-2 overflow-hidden rounded-full bg-ash-800">
      <div
        class="h-full rounded-full transition-[width] duration-700"
        :style="{
          width: `${ratio * 100}%`,
          backgroundColor: standing.met ? 'var(--color-gold-400)' : `var(${ability.colorVar})`,
        }"
      />
    </div>

    <p class="mt-1 text-[0.6875rem]" :class="standing.met ? 'text-gold-400' : 'text-parchment-500'">
      <template v-if="standing.met">This front holds.</template>
      <template v-else>{{ shortBy.toLocaleString() }} short.</template>
    </p>
  </div>
</template>
