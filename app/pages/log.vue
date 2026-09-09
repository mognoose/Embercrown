<script setup lang="ts">
useHead({ title: 'Log a deed · Embercrown' })

const { hero, refresh: refreshHero } = useHero()
const { refresh: refreshParty } = useParty()
const { data: mine, refresh: refreshMine } = useChronicle({
  heroId: () => hero.value?.id,
  limit: 8,
})
const { retract } = useDeedLog()
const { currentAct } = useCampaign()

async function afterLog() {
  await Promise.all([refreshHero(), refreshMine(), refreshParty()])
}

async function onRetract(id: string) {
  await retract(id)
  await afterLog()
}
</script>

<template>
  <div class="space-y-6">
    <div>
      <p class="rune">The chronicle</p>
      <h1 class="mt-1 text-2xl">Set down a deed</h1>
      <p v-if="currentAct" class="mt-1.5 text-sm text-parchment-500">
        Act {{ currentAct.act }} tests
        <template v-for="(code, i) in currentAct.tested_abilities" :key="code">
          <span :style="{ color: `var(${ABILITIES[code].colorVar})` }">
            {{ ABILITIES[code].name }}</span><template
              v-if="i < currentAct.tested_abilities.length - 1"
            > and </template>
        </template>.
      </p>
    </div>

    <DeedForm @logged="afterLog" />

    <UiPanel v-if="mine?.length" title="Your last deeds">
      <ul>
        <DeedFeedItem
          v-for="deed in mine"
          :key="deed.id"
          :deed="deed"
          retractable
          @retract="onRetract"
        />
      </ul>
      <p class="mt-3 text-[0.6875rem] text-parchment-500">
        A deed can be retracted within a day of writing it. After that the
        record stands.
      </p>
    </UiPanel>
  </div>
</template>
