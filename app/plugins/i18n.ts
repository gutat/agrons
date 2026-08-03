import { createI18n } from 'vue-i18n'
import en from '~/i18n/en'
import id from '~/i18n/id'

const i18n = createI18n({
  legacy: false,
  locale: 'id',
  fallbackLocale: 'en',
  messages: { en, id },
})

export default defineNuxtPlugin((nuxtApp) => {
  // Restore persisted locale before the app renders (no flash).
  // Default language is Indonesian; English is the fallback for missing keys.
  if (process.client) {
    const saved = localStorage.getItem('agrons-locale') || 'id'
    i18n.global.locale.value = saved === 'en' ? 'en' : 'id'
    document.documentElement.lang = i18n.global.locale.value
  }
  nuxtApp.vueApp.use(i18n)
})
