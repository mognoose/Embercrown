<script setup lang="ts">
import type { HeroClass } from '~/types/domain'

definePageMeta({ layout: 'scroll' })
useHead({ title: 'Make your hero · Embercrown' })

const supabase = useSupabaseClient()
const user = useSupabaseUser()
const { refresh: refreshHero } = useHero()

const { data: classes } = await useAsyncData('classes', async () => {
  const { data, error } = await supabase.from('classes').select('*').order('sort_order')
  if (error) throw error
  return (data ?? []) as unknown as HeroClass[]
})

// The account was created with a slugified hero name; recover it so the player
// doesn't have to type it twice.
const suggestedName = computed(() => {
  const local = user.value?.email?.split('@')[0] ?? ''
  return local
    .split('-')
    .filter(Boolean)
    .map(part => part[0]!.toUpperCase() + part.slice(1))
    .join(' ')
})

const name = ref('')
const classId = ref('fighter')
const ancestry = ref<string>('Human')
const busy = ref(false)
const error = ref<string | null>(null)

watchEffect(() => {
  if (!name.value && suggestedName.value) name.value = suggestedName.value
})

const chosen = computed(() => classes.value?.find(c => c.id === classId.value) ?? null)
const seed = computed(() => seedFrom(`${name.value}:${ancestry.value}`))
const valid = computed(() => name.value.trim().length >= 2)

async function forge() {
  if (!user.value || !valid.value) return
  busy.value = true
  error.value = null
  try {
    const { error: insertError } = await supabase.from('heroes').insert({
      id: user.value.id,
      name: name.value.trim(),
      slug: slugify(name.value),
      class_id: classId.value,
      ancestry: ancestry.value,
      portrait_seed: seed.value,
    })
    if (insertError) {
      throw new Error(
        insertError.message.includes('duplicate key')
          ? 'That name is already carried by someone in the company.'
          : insertError.message,
      )
    }
    useHasHero().value = true
    await refreshHero()
    await navigateTo('/')
  }
  catch (e) {
    error.value = e instanceof Error ? e.message : String(e)
  }
  finally {
    busy.value = false
  }
}
</script>

<template>
  <div>
    <p class="rune">Before the road</p>
    <h1 class="mt-1 text-3xl">Who is going?</h1>
    <p class="mt-3 font-chronicle text-parchment-400">
      From the first of October to the last night of the year: five lieutenants
      and a wyrm. Your class decides what comes easiest to you — and a company
      of six of the same thing does not get up that mountain.
    </p>

    <form class="mt-7 space-y-6" @submit.prevent="forge">
      <div class="flex items-center gap-4">
        <HeroPortrait :class-id="classId" :seed="seed" size="lg" />
        <div class="min-w-0 flex-1">
          <label class="block">
            <span class="rune">Name</span>
            <input
              v-model="name"
              type="text"
              maxlength="30"
              class="mt-1.5 w-full rounded border border-ash-700 bg-ash-900 px-3 py-2.5 text-parchment-100"
            >
          </label>
        </div>
      </div>

      <fieldset>
        <legend class="rune mb-2">Class</legend>
        <div class="grid gap-2 sm:grid-cols-2">
          <button
            v-for="c in classes"
            :key="c.id"
            type="button"
            class="flex items-start gap-3 rounded border p-3 text-left transition"
            :class="classId === c.id
              ? 'border-ember-500 bg-ember-600/10'
              : 'border-ash-700 hover:border-ash-600'"
            :aria-pressed="classId === c.id"
            @click="classId = c.id"
          >
            <Icon
              :name="CLASS_ICONS[c.id] ?? 'game-icons:visored-helm'"
              class="mt-0.5 shrink-0 text-2xl"
              :style="{ color: `var(${ABILITIES[c.primary_ability].colorVar})` }"
            />
            <span class="min-w-0">
              <span class="block font-display text-parchment-100">{{ c.name }}</span>
              <span class="mt-0.5 block text-xs text-parchment-500">
                Favours {{ ABILITIES[c.primary_ability].name }}
              </span>
              <span class="mt-1 block font-chronicle text-xs italic text-parchment-400">
                {{ c.blurb }}
              </span>
            </span>
          </button>
        </div>
        <p v-if="chosen" class="mt-2 text-xs text-parchment-500">
          Deeds that feed {{ ABILITIES[chosen.primary_ability].name }} earn
          {{ Math.round((Number(chosen.bonus) - 1) * 100) }}% more for you.
        </p>
      </fieldset>

      <fieldset>
        <legend class="rune mb-2">Ancestry <span class="normal-case tracking-normal">— flavour only</span></legend>
        <div class="flex flex-wrap gap-1.5">
          <button
            v-for="a in ANCESTRIES"
            :key="a"
            type="button"
            class="rounded-full border px-3 py-1.5 text-xs transition"
            :class="ancestry === a
              ? 'border-ember-500 bg-ember-600/15 text-parchment-100'
              : 'border-ash-700 text-parchment-400 hover:border-ash-600'"
            :aria-pressed="ancestry === a"
            @click="ancestry = a"
          >
            {{ a }}
          </button>
        </div>
      </fieldset>

      <button
        type="submit"
        class="w-full rounded bg-ember-600 py-3.5 font-display tracking-wide text-parchment-100 transition hover:bg-ember-500 disabled:opacity-50"
        :disabled="!valid || busy"
      >
        {{ busy ? 'Swearing in…' : 'Take the oath' }}
      </button>

      <p v-if="error" class="text-sm text-blood-400">{{ error }}</p>
    </form>
  </div>
</template>
