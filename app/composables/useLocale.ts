import { useI18n } from 'vue-i18n'

/**
 * Access and change the site locale (en | id).
 * Persisted in localStorage + cookie so the choice survives reloads.
 */
export function useLocale() {
  const { locale } = useI18n({ useScope: 'global' })
  const localeCookie = useCookie('agrons-locale', {
    maxAge: 60 * 60 * 24 * 365,
  })

  const current = computed(() => (locale.value === 'id' ? 'id' : 'en'))

  function setLocale(l: 'en' | 'id') {
    locale.value = l
    localeCookie.value = l
    if (process.client) {
      localStorage.setItem('agrons-locale', l)
      document.documentElement.lang = l
    }
  }

  return { locale: current, setLocale }
}
