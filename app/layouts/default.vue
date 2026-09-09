<script setup lang="ts">
const user = useSupabaseUser()
const route = useRoute()

/**
 * Every destination is a constant. The layout renders before its async data
 * resolves, so a tab built from the current hero would point at its fallback on
 * first paint — /hero forwards to the right sheet instead.
 *
 * `owns` says which paths light a tab up, because vue-router's own matching
 * gets this wrong at both ends: "/" counts as active on every route, and
 * sibling routes like /hero and /hero/[slug] don't count as active on each
 * other. An empty list means the tab lights only on its own exact path.
 */
const tabs = [
  { to: '/', label: 'Hearth', icon: 'game-icons:campfire', owns: [] },
  { to: '/map', label: 'Road', icon: 'game-icons:path-distance', owns: ['/map'] },
  { to: '/log', label: 'Log', icon: 'game-icons:quill-ink', owns: ['/log'], primary: true },
  { to: '/party', label: 'Company', icon: 'game-icons:three-friends', owns: ['/party'] },
  { to: '/hero', label: 'Hero', icon: 'game-icons:visored-helm', owns: ['/hero'] },
]

function isActive(tab: (typeof tabs)[number]) {
  if (!tab.owns.length) return route.path === tab.to
  return tab.owns.some(p => route.path === p || route.path.startsWith(`${p}/`))
}
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
            class="rounded px-3 py-1.5 text-sm transition hover:bg-ash-800 hover:text-parchment-100"
            :class="isActive(tab) ? 'text-ember-300' : 'text-parchment-400'"
            :aria-current="isActive(tab) ? 'page' : undefined"
          >
            {{ tab.label }}
          </NuxtLink>
        </nav>

        <NuxtLink
          v-if="!user"
          to="/enter?summon"
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
            class="flex flex-col items-center gap-0.5 py-2.5 transition"
            :class="isActive(tab) ? 'text-ember-300' : 'text-parchment-500'"
            :aria-current="isActive(tab) ? 'page' : undefined"
          >
            <Icon
              :name="tab.icon"
              class="text-xl"
              :class="tab.primary && !isActive(tab) ? 'text-ember-400' : ''"
            />
            <span class="text-[0.625rem] tracking-wide">{{ tab.label }}</span>
          </NuxtLink>
        </li>
      </ul>
    </nav>
  </div>
</template>
