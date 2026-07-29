<script setup lang="ts">
import { useWindowScroll } from '@vueuse/core'

const { y: scrollY } = useWindowScroll()
const scrolled = computed(() => scrollY.value > 50)
const mobileMenuOpen = ref(false)

function scrollToSection(id: string) {
  mobileMenuOpen.value = false
  const el = document.getElementById(id)
  if (el) el.scrollIntoView({ behavior: 'smooth' })
}
</script>

<template>
  <header
    :class="[
      'fixed top-0 left-0 right-0 z-50 transition-all duration-300',
      scrolled
        ? 'bg-white/90 dark:bg-[var(--color-dark-surface)]/90 backdrop-blur-md shadow-sm'
        : 'bg-transparent'
    ]"
  >
    <div class="max-w-(--spacing-container) mx-auto px-(--spacing-gutter) h-16 flex items-center justify-between">
      <!-- Logo -->
      <a href="#company" class="flex items-center gap-2 no-underline" @click.prevent="scrollToSection('company')">
        <span class="font-display text-lg font-bold text-[var(--color-primary)]">Agro Nusa</span>
      </a>

      <!-- Desktop Nav -->
      <nav class="hidden md:flex items-center gap-6" aria-label="Main navigation">
        <a
          v-for="item in sectionIds"
          :key="item"
          :href="`#${item}`"
          class="text-sm font-medium text-[var(--color-on-surface-variant)] hover:text-[var(--color-primary)] transition-colors no-underline capitalize label-caps"
          @click.prevent="scrollToSection(item)"
        >{{ item === 'company' ? 'About' : item }}</a>
        <ThemeSwitcher />
      </nav>

      <!-- Mobile Menu Button -->
      <button
        class="md:hidden p-2 rounded hover:bg-[var(--color-surface-container)] dark:hover:bg-[var(--color-dark-surface-container)]"
        :aria-label="mobileMenuOpen ? 'Close menu' : 'Open menu'"
        :aria-expanded="mobileMenuOpen"
        @click="mobileMenuOpen = !mobileMenuOpen"
      >
        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path v-if="!mobileMenuOpen" stroke-linecap="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
          <path v-else stroke-linecap="round" stroke-width="2" d="M6 6l12 12M18 6l-12 12" />
        </svg>
      </button>
    </div>

    <!-- Mobile Nav Overlay -->
    <Teleport to="body">
      <Transition name="slide">
        <div v-if="mobileMenuOpen" class="fixed inset-0 z-50 md:hidden">
          <div class="absolute inset-0 bg-black/30" @click="mobileMenuOpen = false" />
          <div class="absolute right-0 top-0 bottom-0 w-72 bg-white dark:bg-[var(--color-dark-surface)] shadow-xl p-6">
            <button class="absolute top-4 right-4 p-2" @click="mobileMenuOpen = false" aria-label="Close menu">
              <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-width="2" d="M6 6l12 12M18 6l-12 12" />
              </svg>
            </button>
            <nav class="mt-12 flex flex-col gap-4" aria-label="Mobile navigation">
              <a
                v-for="item in sectionIds"
                :key="item"
                :href="`#${item}`"
                class="text-lg font-medium text-[var(--color-on-surface)] no-underline hover:text-[var(--color-primary)] transition-colors"
                @click.prevent="scrollToSection(item)"
              >{{ item === 'company' ? 'About' : item }}</a>
              <div class="mt-4">
                <ThemeSwitcher show-label />
              </div>
            </nav>
          </div>
        </div>
      </Transition>
    </Teleport>
  </header>
</template>

<style scoped>
.slide-enter-active, .slide-leave-active {
  transition: opacity 0.2s ease;
}
.slide-enter-active > div:last-child,
.slide-leave-active > div:last-child {
  transition: transform 0.3s ease;
}
.slide-enter > div:last-child,
.slide-leave-to > div:last-child {
  transform: translateX(100%);
}
</style>
