<script setup lang="ts">
import { register } from 'swiper/element/bundle'
import { createClient } from '@supabase/supabase-js'
import type { GalleryItem } from '~/types'
register()

const config = useRuntimeConfig()
const supabase = createClient(config.public.supabaseUrl, config.public.supabaseKey)

const items = ref<GalleryItem[]>([])
const activeCat = ref('all')
const loading = ref(true)

const categories = ['all', 'production', 'factory', 'certifications', 'team']

const filtered = computed(() =>
  activeCat.value === 'all' ? items.value : items.value.filter(i => i.category === activeCat.value)
)

// Gallery overlay
const galleryOpen = ref(false)
const galleryIndex = ref(0)

function open(index: number) {
  galleryIndex.value = index
  galleryOpen.value = true
}

onMounted(async () => {
  const { data } = await supabase
    .from('gallery_items')
    .select('*')
    .eq('published', true)
    .order('sort_order')
  if (data) items.value = data
  loading.value = false
})
</script>

<template>
  <Section id="gallery">
    <div class="max-w-(--spacing-container) mx-auto px-(--spacing-gutter) w-full">
      <h2 class="headline-md text-[var(--color-primary)] text-center mb-2">Gallery</h2>
      <p class="body-md text-[var(--color-on-surface-variant)] text-center mb-8">Our facilities and production process</p>

      <!-- Filter -->
      <div class="flex justify-center gap-2 mb-8 flex-wrap">
        <button
          v-for="cat in categories"
          :key="cat"
          :class="[
            'px-4 py-1.5 rounded-lg text-sm font-medium transition-all capitalize',
            activeCat === cat ? 'bg-[var(--color-primary)] text-white' : 'bg-[var(--color-surface-container)] text-[var(--color-on-surface-variant)]'
          ]"
          @click="activeCat = cat"
        >{{ cat }}</button>
      </div>

      <!-- Loading -->
      <div v-if="loading" class="text-center py-8 text-[var(--color-on-surface-variant)]">Loading gallery...</div>

      <!-- Empty state -->
      <div v-else-if="filtered.length === 0" class="text-center py-12 text-[var(--color-on-surface-variant)]">
        <p class="body-md">No images in this category yet.</p>
      </div>

      <!-- Gallery Swiper -->
      <swiper-container v-else slides-per-view="auto" space-between="16" grab-cursor class="pb-4">
        <swiper-slide
          v-for="(item, i) in filtered"
          :key="item.id"
          class="!w-[300px] !h-[350px] cursor-pointer group"
          @click="open(i)"
        >
          <div class="glass rounded-xl overflow-hidden bg-white/50 dark:bg-white/5 h-full">
            <div class="h-48 overflow-hidden">
              <img
                :src="item.image"
                :alt="item.alt || item.title"
                class="w-full h-full object-cover transition-transform duration-300 group-hover:scale-110"
                loading="lazy"
              />
            </div>
            <div class="p-4">
              <p class="text-sm font-medium text-[var(--color-on-surface)]">{{ item.title }}</p>
              <p v-if="item.description" class="text-xs text-[var(--color-on-surface-variant)] mt-1 line-clamp-2">{{ item.description }}</p>
              <span class="label-caps text-[var(--color-secondary)] mt-1 block">{{ item.category }}</span>
            </div>
          </div>
        </swiper-slide>
      </swiper-container>
    </div>

    <!-- Gallery Fullscreen Overlay -->
    <Teleport to="body">
      <Transition name="overlay">
        <div v-if="galleryOpen && filtered.length" class="fixed inset-0 z-50 flex items-center justify-center bg-black/90 backdrop-blur-sm">
          <button class="absolute top-4 right-4 z-10 p-2 bg-white/20 rounded-full text-white hover:bg-white/30 transition-colors" @click="galleryOpen = false" aria-label="Close gallery">
            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
              <path stroke-linecap="round" d="M6 6l12 12M18 6l-12 12" />
            </svg>
          </button>

          <!-- Prev/Next -->
          <button
            class="absolute left-4 top-1/2 -translate-y-1/2 z-10 p-2 bg-white/20 rounded-full text-white hover:bg-white/30"
            @click="galleryIndex = (galleryIndex - 1 + filtered.length) % filtered.length"
            aria-label="Previous"
          >
            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
              <path stroke-linecap="round" stroke-linejoin="round" d="M15 19l-7-7 7-7" />
            </svg>
          </button>
          <button
            class="absolute right-4 top-1/2 -translate-y-1/2 z-10 p-2 bg-white/20 rounded-full text-white hover:bg-white/30"
            @click="galleryIndex = (galleryIndex + 1) % filtered.length"
            aria-label="Next"
          >
            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
              <path stroke-linecap="round" stroke-linejoin="round" d="M9 5l7 7-7 7" />
            </svg>
          </button>

          <!-- Image -->
          <div class="max-w-4xl w-full mx-4">
            <img
              :src="filtered[galleryIndex].image"
              :alt="filtered[galleryIndex].alt || filtered[galleryIndex].title"
              class="w-full max-h-[80vh] object-contain rounded-2xl"
            />
            <div class="text-center mt-4">
              <p class="text-white text-lg font-medium">{{ filtered[galleryIndex].title }}</p>
              <p v-if="filtered[galleryIndex].description" class="text-white/60 text-sm mt-1">{{ filtered[galleryIndex].description }}</p>
              <p class="text-white/40 text-xs mt-2">{{ galleryIndex + 1 }} / {{ filtered.length }}</p>
            </div>
          </div>
        </div>
      </Transition>
    </Teleport>
  </Section>
</template>

<style scoped>
.overlay-enter-active, .overlay-leave-active { transition: opacity 0.2s ease; }
.overlay-enter, .overlay-leave-to { opacity: 0; }
</style>
