<script setup lang="ts">
definePageMeta({ layout: 'scroll' })

const route = useRoute()
const today = useToday()
const bossId = computed(() => String(route.params.slug))

const { boss, standing, resolved, outcome, overall, shortfall, projection, escapedBurden, pending }
  = useEncounter(bossId)

useHead({ title: () => (boss.value ? `${boss.value.name} · Embercrown` : 'Encounter') })

const daysAway = computed(() =>
  boss.value ? daysBetween(today.value, boss.value.encounter_on) : 0,
)
const underway = computed(
  () => !!boss.value && today.value >= boss.value.window_starts_on && !resolved.value,
)

const account = computed(() => {
  if (!boss.value || !resolved.value) return []
  return paragraphs(
    outcome.value === 'victory' ? boss.value.victory_text : boss.value.defeat_text,
  )
})

const burdenList = computed(() =>
  Object.entries(escapedBurden.value)
    .filter(([, v]) => Number(v) > 0)
    .map(([code, v]) => ({ code: code as keyof typeof ABILITIES, extra: Math.round(Number(v)) })),
)
</script>

<template>
  <div v-if="boss">
    <NuxtLink to="/map" class="rune transition hover:text-parchment-200">← The road</NuxtLink>

    <header class="mt-4 flex items-start gap-4">
      <Icon
        :name="boss.icon"
        class="shrink-0 text-5xl"
        :class="{
          'text-gold-400': resolved && outcome === 'victory',
          'text-blood-500': resolved && outcome === 'defeat',
          'text-ember-400': !resolved,
        }"
      />
      <div class="min-w-0">
        <p class="rune">
          {{ boss.is_final ? 'The finale' : `Act ${boss.act}` }} ·
          {{ formatDate(boss.encounter_on) }}
        </p>
        <h1 class="mt-1 text-3xl">{{ boss.name }}</h1>
        <p class="font-display text-parchment-400">{{ boss.title }}</p>
        <p class="mt-1 text-sm text-parchment-500">{{ boss.place }}</p>
      </div>
    </header>

    <!-- Status line. -->
    <p
      class="mt-5 border-l-2 pl-4 font-display"
      :class="{
        'border-gold-500 text-gold-400': resolved && outcome === 'victory',
        'border-blood-500 text-blood-400': resolved && outcome === 'defeat',
        'border-ember-500 text-ember-300': !resolved,
      }"
    >
      <template v-if="resolved && outcome === 'victory'">
        The company held. This road is open.
      </template>
      <template v-else-if="resolved">
        The company fell short. It has gone to the mountain.
      </template>
      <template v-else-if="underway">
        Underway — {{ describeGap(daysAway) }}.
      </template>
      <template v-else>
        Ahead — {{ describeGap(daysAway) }}.
      </template>
    </p>

    <section class="mt-6 space-y-4 font-chronicle leading-relaxed text-parchment-300">
      <p v-for="(para, i) in paragraphs(boss.intro)" :key="i">{{ para }}</p>
    </section>

    <!-- How the fight stands. -->
    <section class="panel mt-7 p-5">
      <header class="mb-4 flex items-baseline gap-3">
        <h2 class="rune">{{ resolved ? 'How it stood' : 'How it stands' }}</h2>
        <span class="ml-auto text-xs text-parchment-500">
          {{ projection?.active_heroes ?? 0 }}
          {{ projection?.active_heroes === 1 ? 'hero' : 'heroes' }} in the field
        </span>
      </header>

      <p v-if="pending" class="text-sm text-parchment-500">Counting…</p>

      <div v-else class="space-y-4">
        <CampaignThresholdBar
          v-for="s in standing"
          :key="s.code"
          :standing="s"
        />
      </div>

      <div v-if="!resolved && !pending" class="mt-5 border-t border-ash-800 pt-4">
        <p v-if="!shortfall" class="text-sm text-gold-400">
          Every front holds. If the encounter happened today, the company would
          win.
        </p>
        <p v-else class="text-sm text-parchment-400">
          The company would not win today. The weak front is
          <span :style="{ color: `var(${ABILITIES[shortfall.code].colorVar})` }">
            {{ ABILITIES[shortfall.code].name }}</span> —
          {{ Math.round(Number(shortfall.required) - Number(shortfall.points)).toLocaleString() }}
          points short.
        </p>
        <p class="mt-1.5 text-[0.6875rem] text-parchment-500">
          Overall {{ Math.round(overall * 100) }}%. Thresholds scale with the
          number of heroes who have logged anything in this window, so a hero
          who joins and trains never makes the fight harder for anyone else.
        </p>
      </div>

      <div v-if="burdenList.length" class="mt-5 border-t border-blood-600/40 pt-4">
        <p class="rune text-blood-400">What escaped</p>
        <p class="mt-1.5 text-sm text-parchment-400">
          Lieutenants the company failed to stop have reached the mountain, and
          she is heavier for it:
          <template v-for="(b, i) in burdenList" :key="b.code">
            <span :style="{ color: `var(${ABILITIES[b.code].colorVar})` }">
              +{{ b.extra }} {{ ABILITIES[b.code].short }}</span><template
                v-if="i < burdenList.length - 1"
              >,</template>
          </template>
          per hero.
        </p>
      </div>
    </section>

    <!-- Before: what to train. After: what happened. -->
    <section v-if="!resolved" class="mt-7">
      <h2 class="rune">The Council's dispatch</h2>
      <div class="mt-2 space-y-4 font-chronicle leading-relaxed text-parchment-300">
        <p v-for="(para, i) in paragraphs(boss.approach_text)" :key="i">{{ para }}</p>
      </div>
      <NuxtLink
        to="/log"
        class="mt-5 inline-block rounded bg-ember-600 px-5 py-3 font-display tracking-wide text-parchment-100 transition hover:bg-ember-500"
      >
        Log a deed
      </NuxtLink>
    </section>

    <section v-else class="mt-7">
      <h2 class="rune">{{ outcome === 'victory' ? 'The account' : 'What happened' }}</h2>
      <div class="mt-2 space-y-4 font-chronicle leading-relaxed text-parchment-300">
        <p v-for="(para, i) in account" :key="i">{{ para }}</p>
      </div>
      <p class="mt-4 text-[0.6875rem] text-parchment-500">
        Recorded {{ projection?.resolved_at ? formatDate(projection.resolved_at.slice(0, 10)) : '' }}.
        The result stands whatever anyone logs afterwards.
      </p>
    </section>
  </div>
</template>
