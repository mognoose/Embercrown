<script setup lang="ts">
import type { Boss } from '~/types/domain'

const props = defineProps<{ boss: Boss }>()

const today = useToday()
const days = computed(() => daysBetween(today.value, props.boss.encounter_on))
</script>

<template>
  <div class="flex items-center gap-4">
    <div class="text-center">
      <div class="font-display text-4xl leading-none tabular-nums text-ember-300">
        {{ Math.max(days, 0) }}
      </div>
      <div class="rune mt-1">{{ days === 1 ? 'day' : 'days' }}</div>
    </div>

    <div class="min-w-0">
      <p class="rune">
        {{ boss.is_final ? 'Until the Ember Throne' : `Until Act ${boss.act}` }}
      </p>
      <h3 class="mt-0.5 truncate text-base">
        {{ boss.name }}<span class="text-parchment-400">, {{ boss.title }}</span>
      </h3>
      <p class="mt-0.5 text-xs text-parchment-500">
        {{ formatDate(boss.encounter_on) }} · {{ boss.place }}
      </p>
    </div>
  </div>
</template>
