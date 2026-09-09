<script setup lang="ts">
definePageMeta({ layout: 'scroll' })
useHead({ title: 'Answer the summons · Embercrown' })

const { enter, summon } = useSigil()
const user = useSupabaseUser()

const mode = ref<'enter' | 'summon'>('enter')
const name = ref('')
const sigil = ref('')
const busy = ref(false)
const error = ref<string | null>(null)

// Cheap defence in depth on a six-digit secret: after five misses this hero
// stops guessing for half a minute. Supabase rate-limits per IP as well.
const misses = ref(0)
const lockedUntil = ref(0)
const now = ref(Date.now())
let ticker: ReturnType<typeof setInterval> | undefined

onMounted(() => {
  ticker = setInterval(() => (now.value = Date.now()), 500)
})
onUnmounted(() => clearInterval(ticker))

const lockSeconds = computed(() =>
  Math.max(Math.ceil((lockedUntil.value - now.value) / 1000), 0),
)

const valid = computed(
  () => slugify(name.value).length >= 2 && /^\d{6}$/.test(sigil.value),
)

// Somebody who is already signed in has no business here. This deliberately
// runs once on mount rather than watching `user`: signing in and signing up
// both set that ref, and a watcher would race the explicit navigation those
// two do — sending a brand-new hero to the Hearth instead of to the oath.
onMounted(() => {
  if (user.value) navigateTo('/')
})

async function submit() {
  if (!valid.value || lockSeconds.value > 0) return
  busy.value = true
  error.value = null
  try {
    if (mode.value === 'summon') {
      await summon(name.value, sigil.value)
      await navigateTo('/create')
    }
    else {
      await enter(name.value, sigil.value)
      misses.value = 0
      await navigateTo('/')
    }
  }
  catch (e) {
    error.value = e instanceof Error ? e.message : String(e)
    if (mode.value === 'enter') {
      misses.value += 1
      if (misses.value >= 5) {
        lockedUntil.value = Date.now() + 30_000
        misses.value = 0
      }
    }
  }
  finally {
    busy.value = false
  }
}
</script>

<template>
  <div>
    <p class="rune">The Council of HiQ</p>
    <h1 class="mt-1 text-3xl">
      {{ mode === 'summon' ? 'Answer the summons' : 'Return to the road' }}
    </h1>
    <p class="mt-3 font-chronicle text-parchment-400">
      <template v-if="mode === 'summon'">
        Give the name you will be known by, and choose a sigil of six digits.
        There is no email here and no password to forget — only a name and six
        marks, which is how it was always done.
      </template>
      <template v-else>
        Your name and your six marks.
      </template>
    </p>

    <form class="mt-7 space-y-4" @submit.prevent="submit">
      <label class="block">
        <span class="rune">Hero name</span>
        <input
          v-model="name"
          type="text"
          autocomplete="username"
          maxlength="30"
          placeholder="Torvin Ashfoot"
          class="mt-1.5 w-full rounded border border-ash-700 bg-ash-900 px-3 py-3 text-parchment-100 placeholder:text-parchment-500"
        >
      </label>

      <label class="block">
        <span class="rune">Sigil — six digits</span>
        <input
          v-model="sigil"
          type="password"
          inputmode="numeric"
          autocomplete="one-time-code"
          :maxlength="SIGIL_LENGTH"
          placeholder="······"
          class="mt-1.5 w-full rounded border border-ash-700 bg-ash-900 px-3 py-3 text-center font-display text-2xl tracking-[0.5em] text-parchment-100 placeholder:tracking-[0.3em] placeholder:text-parchment-500"
          @input="sigil = sigil.replace(/\D/g, '')"
        >
      </label>

      <button
        type="submit"
        class="w-full rounded bg-ember-600 py-3.5 font-display tracking-wide text-parchment-100 transition hover:bg-ember-500 disabled:opacity-50"
        :disabled="!valid || busy || lockSeconds > 0"
      >
        <template v-if="lockSeconds > 0">Wait {{ lockSeconds }}s</template>
        <template v-else-if="busy">…</template>
        <template v-else-if="mode === 'summon'">Step forward</template>
        <template v-else>Enter</template>
      </button>

      <p v-if="error" class="text-sm text-blood-400">{{ error }}</p>
    </form>

    <p class="mt-6 text-sm text-parchment-500">
      <template v-if="mode === 'summon'">
        Already sworn in?
        <button class="text-ember-300 underline-offset-2 hover:underline" @click="mode = 'enter'">
          Enter with your sigil
        </button>
      </template>
      <template v-else>
        Not yet in the company?
        <button class="text-ember-300 underline-offset-2 hover:underline" @click="mode = 'summon'">
          Answer the summons
        </button>
      </template>
    </p>

    <p class="mt-8 text-xs text-parchment-500">
      Your sigil is the only thing standing between someone else and your
      chronicle. Six digits is enough for a company that trusts each other; it
      is not a bank vault. Don't reuse a PIN you care about.
    </p>

    <p class="mt-4">
      <NuxtLink to="/tale" class="rune transition hover:text-parchment-200">
        Read the tale first →
      </NuxtLink>
    </p>
  </div>
</template>
