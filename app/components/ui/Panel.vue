<script setup lang="ts">
withDefaults(
  defineProps<{
    /** Small-caps heading above the panel body. */
    title?: string
    /** Right-aligned note beside the title. */
    aside?: string
    tone?: 'default' | 'ember' | 'gold' | 'blood'
  }>(),
  { tone: 'default' },
)

const TONE_BORDER = {
  default: 'border-ash-700',
  ember: 'border-ember-600/50',
  gold: 'border-gold-500/45',
  blood: 'border-blood-600/55',
} as const
</script>

<template>
  <section
    class="panel p-4"
    :class="TONE_BORDER[tone]"
  >
    <header v-if="title || aside || $slots.aside" class="mb-3 flex items-baseline gap-3">
      <h2 v-if="title" class="rune">{{ title }}</h2>
      <div class="ml-auto text-xs text-parchment-500">
        <slot name="aside">{{ aside }}</slot>
      </div>
    </header>
    <slot />
  </section>
</template>
