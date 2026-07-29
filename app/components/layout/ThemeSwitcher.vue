<script setup lang="ts">
interface Props {
  showLabel?: boolean
}
withDefaults(defineProps<Props>(), {
  showLabel: false,
})

const colorMode = useColorMode({ storageKey: 'agrons-theme' })
const isDark = computed(() => colorMode.value === 'dark' || (colorMode.value === 'auto' && usePreferredDark().value))

function toggle() {
  colorMode.value = isDark.value ? 'light' : 'dark'
}
</script>

<template>
  <button
    class="inline-flex items-center gap-2 p-2 rounded-lg text-[var(--color-on-surface-variant)] hover:bg-[var(--color-surface-container)] dark:hover:bg-[var(--color-dark-surface-container)] transition-colors"
    :aria-label="isDark ? 'Switch to light mode' : 'Switch to dark mode'"
    @click="toggle"
  >
    <svg v-if="isDark" xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
      <path stroke-linecap="round" stroke-linejoin="round" d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707" />
      <circle cx="12" cy="12" r="5" />
    </svg>
    <svg v-else xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
      <path stroke-linecap="round" stroke-linejoin="round" d="M21.752 15.002A9.718 9.718 0 0118 15.75c-5.385 0-9.75-4.365-9.75-9.75 0-1.33.266-2.597.748-3.752A9.753 9.753 0 003 11.25C3 16.635 7.365 21 12.75 21a9.753 9.753 0 009.002-5.998z" />
    </svg>
    <span v-if="showLabel" class="text-sm">{{ isDark ? 'Light Mode' : 'Dark Mode' }}</span>
  </button>
</template>
