<script setup lang="ts">
// A narrow column for the things that are meant to be read rather than used:
// the lore, and the encounter accounts.
</script>

<template>
  <div class="flex min-h-dvh flex-col">
    <header class="border-b border-ash-800/80">
      <div class="mx-auto flex w-full max-w-2xl items-center gap-2.5 px-4 py-3">
        <NuxtLink to="/" class="flex items-center gap-2.5">
          <Icon name="game-icons:flame" class="text-2xl text-ember-400" />
          <span class="font-display text-lg tracking-wide text-parchment-100">
            Embercrown
          </span>
        </NuxtLink>
        <NuxtLink
          to="/map"
          class="rune ml-auto transition hover:text-parchment-200"
        >
          The road
        </NuxtLink>
      </div>
    </header>

    <main class="mx-auto w-full max-w-2xl flex-1 px-5 py-8">
      <slot />
    </main>

    <footer class="mx-auto w-full max-w-2xl px-5 pb-10 pt-4">
      <p class="rune">Embercrown · a HiQ campaign</p>
    </footer>
  </div>
</template>
