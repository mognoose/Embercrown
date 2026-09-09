<script setup lang="ts">
/**
 * "My character sheet", by a route that does not need to know the slug.
 *
 * The navigation cannot build a link out of the current hero: the layout
 * renders before any of its async data resolves, so a link derived from it
 * points wherever the fallback says — which sent a signed-in player to /enter,
 * and from there straight back to the Hearth. The nav links here instead, and
 * this page does the lookup and forwards.
 */
const supabase = useSupabaseClient()

const { data: slug } = await useAsyncData('my-hero-slug', async () => {
  // Ask the client who it is rather than trusting a ref that may have been
  // hydrated from the server while the browser's own session lapsed.
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) return null

  const { data, error } = await supabase
    .from('heroes')
    .select('slug')
    .eq('id', user.id)
    .maybeSingle()
  if (error) throw error
  return data?.slug ?? null
})

await navigateTo(slug.value ? `/hero/${slug.value}` : '/create', { replace: true })
</script>

<template>
  <div class="py-16 text-center">
    <Icon name="game-icons:flame" class="text-3xl text-ember-400" />
    <p class="rune mt-3">Finding your hero…</p>
  </div>
</template>
