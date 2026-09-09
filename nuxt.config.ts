import tailwindcss from '@tailwindcss/vite'

// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  modules: ['@nuxtjs/supabase', '@nuxt/fonts', '@nuxt/icon'],
  css: ['~/assets/css/main.css'],
  vite: {
    plugins: [tailwindcss()],
  },
  app: {
    head: {
      htmlAttrs: { lang: 'en' },
      title: 'Embercrown',
      meta: [
        { name: 'description', content: 'The Waking of the Ashen Wyrm — a twelve-week campaign.' },
        { name: 'theme-color', content: '#0d0b0a' },
      ],
      link: [{ rel: 'icon', href: '/favicon.ico' }],
    },
  },
  supabase: {
    // Auth is a hero name + six-digit sigil, shimmed onto Supabase Auth email/password.
    redirect: true,
    redirectOptions: {
      login: '/enter',
      // The module forces its callback route to render client-side only, so it
      // gets a page of its own — pointing it at '/' would cost the Hearth its
      // server render.
      callback: '/confirm',
      // The Hearth and the lore both read fine signed out — they are the pitch.
      exclude: ['/', '/tale'],
    },
  },
  compatibilityDate: '2025-07-15',
  devtools: { enabled: true },
})
