<script setup lang="ts">
useHead({ title: 'Embercrown' })

const user = useSupabaseUser()
const { hero } = useHero()
const { campaign, nextEncounter, currentAct, hasStarted, hasEnded, daysRemaining, progress }
  = useCampaign()
const { heroes, weakest, totalPoints } = useParty()
const { data: feed } = useChronicle({ limit: 12 })
const { data: myAbilities } = useHeroAbilities(() => hero.value?.id)

const heroWeakest = computed(() => {
  if (!myAbilities.value?.length) return null
  return [...myAbilities.value].sort((a, b) => Number(a.points) - Number(b.points))[0]!
})
</script>

<template>
  <div class="space-y-6">
    <!-- Signed out: the summons. -->
    <section v-if="!user" class="panel border-ember-600/40 p-6">
      <p class="rune">A second summons</p>
      <h1 class="mt-1.5 text-3xl">{{ campaign?.title ?? 'Embercrown' }}</h1>
      <p class="mt-1 font-display text-parchment-400">{{ campaign?.subtitle }}</p>
      <p class="mt-4 font-chronicle leading-relaxed text-parchment-300">
        A year ago the Fellowship of HiQ carried thirty million steps to the
        cliffs of Highcrown and rekindled the Eternal Flame. The realm rejoiced.
        It should not have.
      </p>
      <div class="mt-5 flex flex-wrap gap-2">
        <NuxtLink
          to="/enter"
          class="rounded bg-ember-600 px-5 py-3 font-display tracking-wide text-parchment-100 transition hover:bg-ember-500"
        >
          Answer the summons
        </NuxtLink>
        <NuxtLink
          to="/tale"
          class="rounded border border-ash-700 px-5 py-3 font-display tracking-wide text-parchment-300 transition hover:border-ash-600"
        >
          Read the tale
        </NuxtLink>
      </div>
    </section>

    <!-- Signed in: where the company stands. -->
    <template v-else>
      <section class="panel border-ember-600/40 p-5">
        <div v-if="!hasStarted" class="text-center">
          <p class="rune">The road is not yet open</p>
          <p class="mt-2 font-chronicle text-parchment-300">
            The company gathers. Embercrown begins on
            {{ campaign ? formatDate(campaign.starts_on) : '—' }}.
          </p>
        </div>

        <CampaignCountdown v-else-if="nextEncounter" :boss="nextEncounter" />

        <div v-else class="text-center">
          <p class="rune">The campaign is over</p>
          <NuxtLink to="/encounter/vharaxis" class="mt-2 inline-block text-ember-300">
            See how it ended →
          </NuxtLink>
        </div>

        <div v-if="hasStarted && !hasEnded" class="mt-4">
          <div class="h-1 overflow-hidden rounded-full bg-ash-800">
            <div
              class="h-full rounded-full bg-ember-500 transition-[width] duration-700"
              :style="{ width: `${progress * 100}%` }"
            />
          </div>
          <p class="mt-1.5 text-[0.6875rem] text-parchment-500">
            {{ daysRemaining }} days until the Ember Throne.
          </p>
        </div>
      </section>

      <!-- A single, unmissable call to the thing we want people to do. -->
      <NuxtLink
        to="/log"
        class="flex items-center gap-3 rounded bg-ember-600 px-5 py-4 transition hover:bg-ember-500"
      >
        <Icon name="game-icons:quill-ink" class="text-2xl text-parchment-100" />
        <span class="font-display tracking-wide text-parchment-100">Log a deed</span>
        <Icon name="lucide:chevron-right" class="ml-auto text-parchment-200" />
      </NuxtLink>

      <div class="grid gap-4 sm:grid-cols-2">
        <UiPanel title="Your hero">
          <div v-if="hero" class="flex items-center gap-3">
            <HeroPortrait :class-id="hero.class_id" :seed="hero.portrait_seed" />
            <div class="min-w-0">
              <NuxtLink
                :to="`/hero/${hero.slug}`"
                class="block truncate font-display text-parchment-100"
              >
                {{ hero.name }}
              </NuxtLink>
              <p class="text-xs text-parchment-500">
                Level {{ hero.level }} {{ hero.ancestry }} {{ hero.class_name }}
              </p>
              <p class="mt-0.5 text-xs text-parchment-500">
                {{ hero.deed_count }} deeds · {{ Math.round(Number(hero.total_points)) }} points
              </p>
            </div>
          </div>
          <p
            v-if="heroWeakest"
            class="mt-3 border-t border-ash-800 pt-3 text-xs text-parchment-400"
          >
            Your thinnest thread is
            <span :style="{ color: `var(${ABILITIES[heroWeakest.ability_code].colorVar})` }">
              {{ ABILITIES[heroWeakest.ability_code].name }}</span>.
          </p>
        </UiPanel>

        <UiPanel title="The company">
          <p class="font-display text-2xl text-parchment-100">
            {{ heroes.length }}
            <span class="text-sm text-parchment-500">
              {{ heroes.length === 1 ? 'hero' : 'heroes' }}
            </span>
          </p>
          <p class="mt-1 text-xs text-parchment-500">
            {{ Math.round(totalPoints).toLocaleString() }} points between them.
          </p>
          <p
            v-if="weakest"
            class="mt-3 border-t border-ash-800 pt-3 text-xs text-parchment-400"
          >
            The company is thinnest on
            <span :style="{ color: `var(${ABILITIES[weakest.ability_code].colorVar})` }">
              {{ ABILITIES[weakest.ability_code].name }}</span>. She will find it.
          </p>
        </UiPanel>
      </div>

      <UiPanel v-if="currentAct" title="The Council's dispatch" tone="ember">
        <div class="space-y-3 font-chronicle leading-relaxed text-parchment-300">
          <p v-for="(para, i) in paragraphs(currentAct.approach_text)" :key="i">{{ para }}</p>
        </div>
        <NuxtLink
          :to="`/encounter/${currentAct.id}`"
          class="mt-3 inline-block text-sm text-ember-300"
        >
          {{ currentAct.name }}, {{ currentAct.title }} →
        </NuxtLink>
      </UiPanel>

      <UiPanel title="The chronicle" aside="everything the company has done">
        <ul v-if="feed?.length">
          <DeedFeedItem v-for="deed in feed" :key="deed.id" :deed="deed" />
        </ul>
        <p v-else class="font-chronicle text-sm italic text-parchment-500">
          Nothing written yet. Somebody has to go first.
        </p>
      </UiPanel>
    </template>
  </div>
</template>
