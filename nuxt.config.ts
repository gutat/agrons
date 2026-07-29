import tailwindcss from "@tailwindcss/vite";

export default defineNuxtConfig({
  ssr: false,
  compatibilityDate: "2025-07-15",
  devtools: { enabled: true },

  modules: [
    "@pinia/nuxt",
    "@vueuse/nuxt",
  ],

  css: ["~/assets/css/main.css"],

  vite: {
    plugins: [tailwindcss()],
  },

  app: {
    head: {
      link: [
        { rel: "preconnect", href: "https://fonts.googleapis.com" },
        { rel: "preconnect", href: "https://fonts.gstatic.com", crossorigin: "" },
        { rel: "stylesheet", href: "https://fonts.googleapis.com/css2?family=Source+Serif+4:wght@600;700&family=Hanken+Grotesk:wght@400;700&display=swap" },
      ],
    },
  },

  runtimeConfig: {
    public: {
      supabaseUrl: process.env.SUPABASE_URL,
      supabaseKey: process.env.SUPABASE_KEY,
      appUrl: "",
      whatsappNumber: "",
      whatsappMessage: "",
      mapEmbedUrl: "",
      adminPath: "admin",
      defaultTheme: "system",
    },
  },

  nitro: {
    preset: "static",
    prerender: {
      routes: ["/"],
    },
  },
});
