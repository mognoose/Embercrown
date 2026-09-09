<script setup lang="ts">
/**
 * A portrait without an illustrator: the class glyph on a ring whose hue comes
 * from the hero's seed, so every hero looks like themselves and nobody had to
 * draw thirty pictures.
 */
const props = withDefaults(
  defineProps<{
    classId: string
    seed: number
    size?: 'sm' | 'md' | 'lg'
    /** Ring colour override — used to mark victory or the fallen. */
    ring?: string
  }>(),
  { size: 'md' },
)

const SIZES = {
  sm: 'h-9 w-9 text-lg',
  md: 'h-14 w-14 text-2xl',
  lg: 'h-24 w-24 text-5xl',
} as const

const hue = computed(() => props.seed % 360)
const icon = computed(() => CLASS_ICONS[props.classId] ?? 'game-icons:visored-helm')

const style = computed(() => ({
  background: `radial-gradient(circle at 32% 26%,
    hsl(${hue.value} 38% 22%),
    hsl(${(hue.value + 40) % 360} 30% 11%) 70%)`,
  borderColor: props.ring ?? `hsl(${hue.value} 45% 42%)`,
  color: `hsl(${hue.value} 55% 76%)`,
}))
</script>

<template>
  <span
    class="inline-flex shrink-0 items-center justify-center rounded-full border-2 shadow-inner"
    :class="SIZES[size]"
    :style="style"
  >
    <Icon :name="icon" />
  </span>
</template>
