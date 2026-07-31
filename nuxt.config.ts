import tailwindcss from "@tailwindcss/vite";
import vue from "@vitejs/plugin-vue";

// Admin mount path — matches runtimeConfig.public.adminPath so prerendered
// admin files land where the deployed app actually serves them.
const adminPath = process.env.NUXT_PUBLIC_ADMIN_PATH || "admin";

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
    vue: {
      template: {
        compilerOptions: {
          isCustomElement: (tag: string) => tag.startsWith("swiper-"),
        },
      },
    },
  },

  app: {
    head: {
      link: [
        { rel: "icon", type: "image/png", href: "/logo.png" },
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
      routes: [
        "/",
        // Admin entry points: generate real files so /<adminPath> works
        // on plain static hosting (no SPA-fallback rewrites needed).
        `/${adminPath}`,
        `/${adminPath}/dashboard`,
        `/${adminPath}/products`,
        `/${adminPath}/gallery`,
        `/${adminPath}/home`,
        `/${adminPath}/about`,
        `/${adminPath}/company`,
        `/${adminPath}/messages`,
      ],
    },
  },
});
