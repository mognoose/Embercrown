<script setup lang="ts">
import type { DeedPoint } from '~/types/domain'

const props = defineProps<{
  deed: DeedPoint
  /** Show a retract button when this is the viewer's own recent deed. */
  retractable?: boolean
}>()

const emit = defineEmits<{ retract: [id: string] }>()

const ability = computed(() => ABILITIES[props.deed.ability_code])
</script>

<template>
  <li class="flex items-start gap-3 border-b border-ash-800/70 py-3 last:border-0">
    <Icon
      :name="ability.icon"
      class="mt-0.5 shrink-0 text-lg"
      :style="{ color: `var(${ability.colorVar})` }"
    />

    <div class="min-w-0 flex-1">
      <p class="font-chronicle text-sm leading-snug text-parchment-200">
        {{ chronicleLine(deed) }}
      </p>
      <p v-if="deed.note" class="mt-0.5 font-chronicle text-xs italic text-parchment-500">
        “{{ deed.note }}”
      </p>
      <p class="mt-1 text-[0.6875rem] text-parchment-500">
        {{ formatDate(deed.performed_on) }}
        <button
          v-if="retractable"
          type="button"
          class="ml-2 text-blood-400 underline-offset-2 hover:underline"
          @click="emit('retract', deed.id)"
        >
          retract
        </button>
      </p>
    </div>

    <span
      class="shrink-0 whitespace-nowrap text-xs tabular-nums"
      :style="{ color: `var(${ability.colorVar})` }"
    >
      {{ chronicleGain(deed) }}
    </span>
  </li>
</template>
