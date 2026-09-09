<script setup lang="ts">
const { hero } = useHero()
const user = useSupabaseUser()

const tabs = computed(() => [
  { to: '/', label: 'Hearth', icon: 'game-icons:campfire' },
  { to: '/map', label: 'Road', icon: 'game-icons:path-distance' },
  { to: '/log', label: 'Log', icon: 'game-icons:quill-ink', primary: true },
  { to: '/party', label: 'Company', icon: 'game-icons:three-friends' },
  {
    to: hero.value ? `/hero/${hero.value.slug}` : '/enter',
    label: 'Hero',
    icon: 'game-icons:visored-helm',
  },
])
</script>

<template>
  <div class="flex min-h-dvh flex-col">
    <header class="border-b border-ash-800/80 backdrop-blur-sm">
      <div class="mx-auto flex w-full max-w-3xl items-center gap-3 px-4 py-3">
        <NuxtLink to="/" class="flex items-center gap-2.5">
          <Icon name="game-icons:flame" class="text-2xl text-ember-400" />
          <span class="font-display text-lg tracking-wide text-parchment-100">
            Embercrown
          </span>
        </NuxtLink>

        <nav class="ml-auto hidden items-center gap-1 md:flex">
          <NuxtLink
            v-for="tab in tabs"
            :key="tab.to"
            :to="tab.to"
            class="rounded px-3 py-1.5 text-sm text-parchment-400 transition hover:bg-ash-800 hover:text-parchment-100"
            active-class="text-ember-300"
          >
            {{ tab.label }}
          </NuxtLink>
        </nav>

        <NuxtLink
          v-if="!user"
          to="/enter"
          class="ml-auto rounded border border-ember-600/60 px-3 py-1.5 text-sm text-ember-300 md:ml-0"
        >
          Answer the summons
        </NuxtLink>
      </div>
    </header>

    <main class="mx-auto w-full max-w-3xl flex-1 px-4 pb-28 pt-5 md:pb-10">
      <slot />
    </main>

    <!-- Mobile: the five places you actually go, thumb-height. -->
    <nav
      class="fixed inset-x-0 bottom-0 z-20 border-t border-ash-800 bg-ash-950/95 backdrop-blur md:hidden"
      style="padding-bottom: env(safe-area-inset-bottom)"
    >
      <ul class="mx-auto flex max-w-3xl">
        <li v-for="tab in tabs" :key="tab.to" class="flex-1">
          <NuxtLink
            :to="tab.to"
            class="flex flex-col items-center gap-0.5 py-2.5 text-parchment-500 transition"
            active-class="text-ember-300"
          >
            <Icon
              :name="tab.icon"
              class="text-xl"
              :class="tab.primary ? 'text-ember-400' : ''"
            />
            <span class="text-[0.625rem] tracking-wide">{{ tab.label }}</span>
          </NuxtLink>
        </li>
      </ul>
    </nav>
  </div>
</template>
