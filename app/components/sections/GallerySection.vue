<script setup lang="ts">
import { useSupabase } from '~/utils/supabase'
import type { GalleryItem } from '~/types'
import Section from '~/components/common/Section.vue'
import Masonry from '~/components/bits/Masonry.vue'
import BlurText from '~/components/bits/BlurText.vue'
import SplitText from '~/components/bits/SplitText.vue'

const supabase = useSupabase()

const items = ref<GalleryItem[]>([])
const loading = ref(true)

const masonryItems = computed(() =>
  items.value.slice(0, 8).map((item, i) => ({
    id: item.id,
    img: item.image,
    url: '',
    height: [350, 250, 400, 280, 320][i % 5],
  }))
)

// Gallery overlay
const galleryOpen = ref(false)
const galleryIndex = ref(0)

function open(index: number) {
  galleryIndex.value = index
  galleryOpen.value = true
  document.body.style.overflow = 'hidden'
}
function closeGallery() {
  galleryOpen.value = false
  document.body.style.overflow = ''
}

function prevImage() {
  galleryIndex.value = (galleryIndex.value - 1 + masonryItems.value.length) % masonryItems.value.length
}
function nextImage() {
  galleryIndex.value = (galleryIndex.value + 1) % masonryItems.value.length
}

onMounted(async () => {
  const { data } = await supabase.from('gallery_items').select('*').eq('published', true).order('sort_order')
  if (data) items.value = data
  loading.value = false
})
</script>

<template>
  <Section id="gallery" class="section-fixed">
    <div class="max-w-(--spacing-container) mx-auto px-(--spacing-gutter) w-full section-content h-full flex flex-col">
      <!-- Numbered Header -->
      <div class="mb-3 flex-shrink-0">
        <SplitText
          text="04 &mdash; Gallery"
          className="section-number block"
          :delay="80"
          :duration="0.5"
          ease="power3.out"
          split-type="chars"
          :from="{ opacity: 0, y: 30 }"
          :to="{ opacity: 1, y: 0 }"
          :threshold="0.1"
          root-margin="-100px"
          text-align="left"
        />
        <span class="section-divider mt-2 block" />
      </div>

      <!-- Section Title -->
      <div class="animate-entry delay-1 flex-shrink-0">
        <BlurText
          text="Our Facilities"
          className="headline-md mb-3"
          :delay="60"
          :step-duration="0.3"
          animate-by="words"
          direction="bottom"
        />
        <BlurText
          text="A look inside our production, quality control, and team."
          className="body-md max-w-lg leading-relaxed"
          :delay="80"
          :step-duration="0.25"
          animate-by="words"
          direction="bottom"
        />
      </div>

      <!-- Loading -->
      <div v-if="loading" class="flex justify-center py-6 md:py-10 animate-entry delay-3">
        <div class="w-6 md:w-7 h-6 md:h-7 border-2 border-[var(--color-forest)] dark:border-[var(--color-forest-light)] border-t-transparent rounded-full animate-spin" />
      </div>

      <!-- Masonry Gallery -->
      <div v-else-if="masonryItems.length > 0" class="animate-entry delay-3 flex-1 min-h-0 w-full mt-4 overflow-y-auto">
        <Masonry
          :items="masonryItems"
          ease="power3.out"
          :duration="0.6"
          :stagger="0.05"
          animate-from="bottom"
          :scale-on-hover="true"
          :hover-scale="0.95"
          :blur-to-focus="true"
          :color-shift-on-hover="false"
          class="w-full h-full"
        />
      </div>

      <!-- Empty -->
      <div v-else class="flex-1 flex items-center justify-center text-[var(--color-ink-muted)] dark:text-[var(--color-charcoal-ink-muted)] animate-entry delay-3">
        <div class="text-center">
          <svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" fill="none" viewBox="0 0 24 24" stroke-width="1" class="mx-auto mb-3 opacity-30 stroke-current"><rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/><path d="M21 15l-5-5L5 21"/></svg>
          <p>No images in this category yet.</p>
        </div>
      </div>
    </div>

    <!-- Gallery Fullscreen Overlay -->
    <Teleport to="body">
      <Transition name="overlay">
        <div v-if="galleryOpen && masonryItems.length" class="fixed inset-0 z-50 flex items-center justify-center bg-black/95">
          <button class="absolute top-5 right-5 z-10 w-11 h-11 rounded-full bg-white/10 flex items-center justify-center text-white hover:bg-white/20 transition-all hover:scale-105" @click="closeGallery" aria-label="Close">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2"><path stroke-linecap="round" d="M6 6l12 12M18 6l-12 12"/></svg>
          </button>
          <button class="absolute left-4 md:left-8 top-1/2 -translate-y-1/2 z-10 w-12 h-12 rounded-full bg-white/10 flex items-center justify-center text-white hover:bg-white/20 transition-all hover:scale-105" @click="prevImage" aria-label="Previous">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M15 19l-7-7 7-7"/></svg>
          </button>
          <button class="absolute right-4 md:right-8 top-1/2 -translate-y-1/2 z-10 w-12 h-12 rounded-full bg-white/10 flex items-center justify-center text-white hover:bg-white/20 transition-all hover:scale-105" @click="nextImage" aria-label="Next">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M9 5l7 7-7 7"/></svg>
          </button>

          <div class="max-w-5xl w-full mx-6 text-center">
            <img :key="galleryIndex" :src="masonryItems[galleryIndex].img" :alt="masonryItems[galleryIndex].text" class="w-full max-h-[70vh] object-contain rounded-xl" />
            <div class="mt-5">
              <p class="text-white text-lg font-semibold">{{ masonryItems[galleryIndex].text }}</p>
              <p v-if="masonryItems[galleryIndex].description" class="text-white/70 text-sm mt-1.5">{{ masonryItems[galleryIndex].description }}</p>
              <div class="flex items-center justify-center gap-2 mt-5">
                <span v-for="(_, idx) in masonryItems" :key="idx" :class="['h-1.5 rounded-full transition-all duration-500', idx === galleryIndex ? 'w-8 bg-white' : 'w-1.5 bg-white/30']" />
              </div>
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
