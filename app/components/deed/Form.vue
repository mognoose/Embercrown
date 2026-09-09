<script setup lang="ts">
import type { AbilityCode, Intensity } from '~/types/domain'
import { INTENSITY_MULTIPLIER } from '~/types/domain'

/**
 * The screen that has to be effortless, because it is the one people use four
 * times a week: pick an ability, pick what you did, nudge the minutes, done.
 */
const emit = defineEmits<{ logged: [] }>()

const { hero } = useHero()
const { byAbility, all } = useActivityTypes()
const { log } = useDeedLog()
const { campaign } = useCampaign()
const today = useToday()

const ability = ref<AbilityCode>('con')
const activityId = ref<string | null>(null)
const minutes = ref(30)
const intensity = ref<Intensity>('moderate')
const performedOn = ref(today.value)
const note = ref('')

const saving = ref(false)
const error = ref<string | null>(null)
const justLogged = ref<string | null>(null)

const choices = computed(() => all.value.filter(t => t.ability_code === ability.value))

// Picking a new ability clears a now-irrelevant activity choice.
watch(ability, () => {
  if (!choices.value.some(c => c.id === activityId.value)) {
    activityId.value = choices.value[0]?.id ?? null
  }
})
watch(choices, list => {
  if (!activityId.value && list.length) activityId.value = list[0]!.id
}, { immediate: true })

const activity = computed(() => all.value.find(t => t.id === activityId.value) ?? null)

const overCap = computed(
  () => !!activity.value && minutes.value > activity.value.daily_minute_cap,
)

/**
 * Shown live so the trade-offs are visible while choosing, not after
 * submitting. Mirrors the deed_points view — see app/utils/score.ts.
 */
const projectedPoints = computed(() => {
  if (!activity.value || !hero.value) return 0
  const favoured = hero.value.primary_ability === activity.value.ability_code
  return Math.round(
    minutes.value
    * activity.value.points_per_minute
    * INTENSITY_MULTIPLIER[intensity.value]
    * (favoured ? 1.25 : 1),
  )
})

const minDate = computed(() => campaign.value?.starts_on ?? today.value)

const MINUTE_STEPS = [15, 30, 45, 60, 90]

async function submit() {
  if (!activity.value) return
  saving.value = true
  error.value = null
  justLogged.value = null
  try {
    await log({
      activity_type_id: activity.value.id,
      performed_on: performedOn.value,
      duration_minutes: minutes.value,
      intensity: intensity.value,
      note: note.value,
    })
    justLogged.value = `${ABILITIES[ability.value].name} +${projectedPoints.value}. The ember takes.`
    note.value = ''
    emit('logged')
  }
  catch (e) {
    error.value = e instanceof Error ? e.message : String(e)
  }
  finally {
    saving.value = false
  }
}
</script>

<template>
  <form class="space-y-5" @submit.prevent="submit">
    <!-- Which ability this feeds. -->
    <fieldset>
      <legend class="rune mb-2">What did you train?</legend>
      <div class="grid grid-cols-6 gap-1.5">
        <button
          v-for="a in ABILITY_LIST"
          :key="a.code"
          type="button"
          class="flex flex-col items-center gap-1 rounded border py-2 transition"
          :class="ability === a.code
            ? 'border-current bg-ash-800'
            : 'border-ash-700 text-parchment-500 hover:border-ash-600'"
          :style="ability === a.code ? { color: `var(${a.colorVar})` } : undefined"
          :aria-pressed="ability === a.code"
          @click="ability = a.code"
        >
          <Icon :name="a.icon" class="text-xl" />
          <span class="text-[0.625rem] tracking-wide">{{ a.short }}</span>
        </button>
      </div>
      <p class="mt-1.5 text-[0.6875rem] italic text-parchment-500">
        {{ ABILITIES[ability].flavour }}
      </p>
    </fieldset>

    <!-- Which activity. -->
    <fieldset>
      <legend class="rune mb-2">The deed</legend>
      <div class="flex flex-wrap gap-1.5">
        <button
          v-for="t in choices"
          :key="t.id"
          type="button"
          class="rounded-full border px-3 py-1.5 text-xs transition"
          :class="activityId === t.id
            ? 'border-ember-500 bg-ember-600/15 text-parchment-100'
            : 'border-ash-700 text-parchment-400 hover:border-ash-600'"
          :aria-pressed="activityId === t.id"
          @click="activityId = t.id"
        >
          {{ t.name }}
        </button>
      </div>
    </fieldset>

    <!-- How long. -->
    <fieldset>
      <legend class="rune mb-2">For how long</legend>
      <div class="flex items-center gap-2">
        <button
          type="button"
          class="h-11 w-11 rounded border border-ash-700 text-lg text-parchment-300 disabled:opacity-40"
          :disabled="minutes <= 5"
          aria-label="Five minutes less"
          @click="minutes = Math.max(minutes - 5, 5)"
        >
          −
        </button>
        <div class="flex-1 text-center">
          <span class="font-display text-3xl tabular-nums text-parchment-100">{{ minutes }}</span>
          <span class="ml-1 text-sm text-parchment-500">min</span>
        </div>
        <button
          type="button"
          class="h-11 w-11 rounded border border-ash-700 text-lg text-parchment-300 disabled:opacity-40"
          :disabled="minutes >= 300"
          aria-label="Five minutes more"
          @click="minutes = Math.min(minutes + 5, 300)"
        >
          +
        </button>
      </div>
      <div class="mt-2 flex gap-1.5">
        <button
          v-for="step in MINUTE_STEPS"
          :key="step"
          type="button"
          class="flex-1 rounded border border-ash-700 py-1.5 text-xs text-parchment-400 transition hover:border-ash-600"
          :class="minutes === step ? 'border-ash-500 text-parchment-100' : ''"
          @click="minutes = step"
        >
          {{ step }}
        </button>
      </div>
      <p v-if="overCap" class="mt-1.5 text-[0.6875rem] text-blood-400">
        {{ activity?.name }} counts for at most
        {{ activity?.daily_minute_cap }} minutes a day.
      </p>
    </fieldset>

    <!-- How hard. -->
    <fieldset>
      <legend class="rune mb-2">How hard</legend>
      <div class="grid grid-cols-3 gap-1.5">
        <button
          v-for="level in (['light', 'moderate', 'hard'] as Intensity[])"
          :key="level"
          type="button"
          class="rounded border py-2 text-xs capitalize transition"
          :class="intensity === level
            ? 'border-ember-500 bg-ember-600/15 text-parchment-100'
            : 'border-ash-700 text-parchment-400 hover:border-ash-600'"
          :aria-pressed="intensity === level"
          @click="intensity = level"
        >
          {{ level }}
        </button>
      </div>
    </fieldset>

    <!-- When, and anything worth remembering. -->
    <div class="grid gap-3 sm:grid-cols-2">
      <label class="block">
        <span class="rune">When</span>
        <input
          v-model="performedOn"
          type="date"
          :min="minDate"
          :max="today"
          class="mt-1.5 w-full rounded border border-ash-700 bg-ash-900 px-3 py-2.5 text-sm text-parchment-200"
        >
      </label>
      <label class="block">
        <span class="rune">A line for the chronicle</span>
        <input
          v-model="note"
          type="text"
          maxlength="200"
          placeholder="optional"
          class="mt-1.5 w-full rounded border border-ash-700 bg-ash-900 px-3 py-2.5 text-sm text-parchment-200 placeholder:text-parchment-500"
        >
      </label>
    </div>

    <div class="panel flex items-center gap-3 border-ember-600/40 p-3">
      <Icon name="game-icons:flame" class="text-xl text-ember-400" />
      <p class="text-sm text-parchment-300">
        This deed is worth
        <strong class="text-ember-300">{{ projectedPoints }}</strong>
        {{ ABILITIES[ability].name }}<template
          v-if="hero && hero.primary_ability === ability"
        >, favoured by your class</template>.
      </p>
    </div>

    <button
      type="submit"
      class="w-full rounded bg-ember-600 py-3.5 font-display tracking-wide text-parchment-100 transition hover:bg-ember-500 disabled:opacity-50"
      :disabled="saving || !activity || overCap"
    >
      {{ saving ? 'Setting it down…' : 'Enter it in the chronicle' }}
    </button>

    <p v-if="error" class="text-sm text-blood-400">{{ error }}</p>
    <p v-else-if="justLogged" class="text-sm text-gold-400">{{ justLogged }}</p>
  </form>
</template>
