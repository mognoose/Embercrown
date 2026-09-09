<script setup lang="ts">
definePageMeta({ layout: 'scroll' })
useHead({ title: 'The tale · Embercrown' })

const { campaign, acts, dragon } = useCampaign()
</script>

<template>
  <article class="space-y-6">
    <header>
      <p class="rune">A HiQ campaign</p>
      <h1 class="mt-1 text-4xl">{{ campaign?.title ?? 'Embercrown' }}</h1>
      <p class="mt-1 font-display text-lg text-parchment-400">
        {{ campaign?.subtitle ?? 'The Waking of the Ashen Wyrm' }}
      </p>
    </header>

    <section class="space-y-4 font-chronicle text-[1.0625rem] leading-relaxed text-parchment-300">
      <p>
        One year ago the Fellowship of HiQ carried thirty million steps to the
        cliffs of Highcrown and rekindled the Eternal Flame. The realm rejoiced.
        It should not have.
      </p>
      <p>
        The Flame burns on the strength of people moving together — and it
        burned so brightly that its light went down through the roots of the
        mountain, into a dark that had held still for an age. There it touched a
        sleeping eye.
      </p>
      <p>
        <strong class="font-normal text-parchment-100">Vharaxis the Ashen</strong>
        was old when the Flame was young. The founders of Highcrown did not
        forge that fire; they <em>took</em> it, one ember, from a hoard beneath
        the world, and they never told the story that way. The wyrm has been
        dreaming of it ever since. Now she is awake, she has taken the sky above
        Highcrown, and she has set her lieutenants on every road the fellowship
        once walked.
      </p>
      <p>
        The Council of HiQ has sent out a second summons — and this one is not
        for marchers. Ash chokes the long roads; there is no walking to
        Highcrown now. What the realm needs is a company: a handful of heroes
        who will spend twelve weeks making themselves strong enough to climb the
        mountain and stand on the Ember Throne.
      </p>
      <p class="text-parchment-200">
        You cannot out-fly a dragon. You cannot out-burn one. You can only
        arrive at the summit having become something she did not expect.
      </p>
    </section>

    <hr class="border-ash-800">

    <section>
      <h2 class="text-xl">How a hero grows</h2>
      <p class="mt-2 font-chronicle leading-relaxed text-parchment-300">
        Every deed you log feeds one of the six ability scores. What you train
        is what grows — and the wyrm is beaten only by a company that is
        complete, because an ember of the Flame lives in each of the six, and a
        fire fed from one side burns hot and thin.
      </p>
      <dl class="mt-4 space-y-2.5">
        <div v-for="a in ABILITY_LIST" :key="a.code" class="flex gap-3">
          <Icon
            :name="a.icon"
            class="mt-0.5 shrink-0 text-lg"
            :style="{ color: `var(${a.colorVar})` }"
          />
          <div>
            <dt class="font-display text-sm text-parchment-100">{{ a.name }}</dt>
            <dd class="font-chronicle text-sm italic text-parchment-400">
              {{ a.flavour }}
            </dd>
          </div>
        </div>
      </dl>
    </section>

    <hr class="border-ash-800">

    <section>
      <h2 class="text-xl">Who stands in the way</h2>
      <ol class="mt-3 space-y-4">
        <li v-for="boss in acts" :key="boss.id">
          <p class="rune">Act {{ boss.act }} · {{ formatDate(boss.encounter_on) }}</p>
          <h3 class="mt-0.5 text-base">
            {{ boss.name }}<span class="text-parchment-400">, {{ boss.title }}</span>
          </h3>
          <p class="text-xs text-parchment-500">{{ boss.place }}</p>
          <p class="mt-1.5 font-chronicle text-sm leading-relaxed text-parchment-400">
            {{ boss.intro }}
          </p>
        </li>
      </ol>

      <div v-if="dragon" class="mt-6 border-l-2 border-blood-600 pl-4">
        <p class="rune text-blood-400">
          The finale · {{ formatDate(dragon.encounter_on) }}
        </p>
        <h3 class="mt-0.5 text-lg">
          {{ dragon.name }}<span class="text-parchment-400">, {{ dragon.title }}</span>
        </h3>
        <p class="text-xs text-parchment-500">{{ dragon.place }}</p>
        <p class="mt-1.5 font-chronicle text-sm leading-relaxed text-parchment-400">
          {{ dragon.intro }}
        </p>
      </div>
    </section>

    <hr class="border-ash-800">

    <p>
      <NuxtLink
        to="/enter"
        class="inline-block rounded bg-ember-600 px-5 py-3 font-display tracking-wide text-parchment-100 transition hover:bg-ember-500"
      >
        Answer the summons
      </NuxtLink>
    </p>
  </article>
</template>
