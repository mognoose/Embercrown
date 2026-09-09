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
        {
          name: 'description',
          content: 'The Waking of the Ashen Wyrm — a HiQ campaign, 14 September to 15 December.',
        },
        { name: 'theme-color', content: '#0d0b0a' },
      ],
      link: [
        // SVG first for anything modern; the .ico is the fallback older
        // browsers ask for at the root anyway.
        { rel: 'icon', type: 'image/svg+xml', href: '/favicon.svg' },
        { rel: 'icon', type: 'image/x-icon', href: '/favicon.ico', sizes: '48x48' },
        { rel: 'apple-touch-icon', href: '/apple-touch-icon.png', sizes: '180x180' },
      ],
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
