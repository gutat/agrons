export default defineNuxtConfig({
  ssr: false,
  compatibilityDate: "2025-07-15",
  devtools: { enabled: true },

  runtimeConfig: {
    public: {
      supabaseUrl: process.env.SUPABASE_URL || "https://kulobdwegcyjtoeancet.supabase.co",
      supabaseKey: process.env.SUPABASE_KEY || "sb_publishable__KJNmpoQK7dmhVxZqqTsgA_X1EJ_aji",
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
