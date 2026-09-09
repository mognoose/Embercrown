<script setup lang="ts">
/**
 * Where @nuxtjs/supabase lands after it has finished setting up a session.
 * Name-and-sigil sign-in never comes through here, but the module requires a
 * callback route and renders it client-side only — so it gets its own path
 * rather than costing the Hearth its server render.
 */
definePageMeta({ layout: 'scroll' })

const user = useSupabaseUser()

watchEffect(() => {
  if (user.value) navigateTo('/')
})
</script>

<template>
  <div class="py-16 text-center">
    <Icon name="game-icons:flame" class="text-4xl text-ember-400" />
    <p class="rune mt-3">Lighting your ember…</p>
  </div>
</template>
