<script setup lang="ts">
import { useLocale } from '~/composables/useLocale'

const { locale, setLocale } = useLocale()
</script>

<template>
  <div
    role="group"
    :aria-label="$t('locale.switchTo')"
    class="flex items-center gap-1 p-1 rounded-full border border-[var(--color-ink)]/10 bg-[var(--color-parchment-raised)]/60 backdrop-blur-sm"
  >
    <button
      v-for="l in ['en', 'id']"
      :key="l"
      type="button"
      :aria-pressed="locale === l"
      :class="[
        'px-2.5 py-1 rounded-full text-xs font-bold uppercase tracking-wide transition-all cursor-pointer',
        locale === l
          ? 'bg-[var(--color-forest)] text-white shadow-sm'
          : 'text-[var(--color-ink-muted)] hover:text-[var(--color-forest)]',
      ]"
      @click="setLocale(l as 'en' | 'id')"
    >
      {{ l }}
    </button>
  </div>
</template>
