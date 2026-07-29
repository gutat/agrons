export default defineNuxtConfig({
  ssr: false,
  compatibilityDate: "2025-07-15",
  devtools: { enabled: true },

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
});
