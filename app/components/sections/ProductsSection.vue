<script setup lang="ts">
import { useSupabase } from '~/utils/supabase'
import type { Product } from '~/types'
import Section from '~/components/common/Section.vue'
import Button from '~/components/common/Button.vue'
import Aurora from '~/components/bits/Aurora.vue'
import CircularGallery from '~/components/bits/CircularGallery.vue'
import BlurText from '~/components/bits/BlurText.vue'

const supabase = useSupabase()

const products = ref<Product[]>([])
const activeCategory = ref<'cocopeat' | 'cocofiber'>('cocopeat')
const loading = ref(true)
const productDetailOpen = ref(false)
const selectedProduct = ref<Product | null>(null)
const swiperRef = ref<any>(null)

const { width: windowWidth } = useWindowSize()
const auroraAmplitude = computed(() => windowWidth.value < 768 ? 0.4 : 1.0)

const filteredProducts = computed(() =>
  products.value.filter(p => p.category === activeCategory.value)
)

function openProduct(product: Product) {
  selectedProduct.value = product
  productDetailOpen.value = true
  document.body.style.overflow = 'hidden'
}
function closeProduct() {
  productDetailOpen.value = false
  document.body.style.overflow = ''
  selectedProduct.value = null
}

onMounted(async () => {
  const { data } = await supabase
    .from('products')
    .select('*')
    .eq('published', true)
    .order('sort_order')
  if (data) products.value = data
  loading.value = false
})
</script>

<template>
  <Section id="products" class="relative overflow-hidden">
    <!-- LightRays Background -->
    <div class="absolute inset-0 z-0">
    </div>
    <div class="relative z-10 max-w-(--spacing-container) mx-auto px-(--spacing-gutter) w-full section-content h-full">
      <!-- Header area (non-growing) -->
      <div class="pt-2 md:pt-4">
        <!-- Numbered Header -->
        <div class="section-header animate-entry">
          <span class="section-number">02 &mdash; Products</span>
          <span class="section-divider" />
        </div>

        <!-- Section Title -->
        <div class="animate-entry delay-1">
          <BlurText
            text="Premium Coconut Products"
            className="headline-md mb-3"
            :delay="60"
            :step-duration="0.3"
            animate-by="words"
            direction="bottom"
          />
          <BlurText
            text="High-quality cocopeat and cocofiber for greenhouses, horticulture, and industrial applications."
            className="body-md max-w-lg leading-relaxed"
            :delay="80"
            :step-duration="0.25"
            animate-by="words"
            direction="bottom"
          />
        </div>

        <!-- Category Tabs -->
        <div class="flex items-center gap-2 mt-3 md:mt-4 mb-2 md:mb-3 animate-entry delay-2">
          <button
            v-for="cat in ['cocopeat', 'cocofiber']"
            :key="cat"
            :class="[
              'relative px-5 py-2 rounded-xl text-sm font-medium transition-all capitalize',
              activeCategory === cat
                ? 'text-white shadow-lg'
                : 'text-[var(--color-ink-muted)] dark:text-[var(--color-charcoal-ink-muted)] hover:text-[var(--color-forest)] dark:hover:text-[var(--color-forest-light)] bg-transparent border border-[var(--color-ink)]/10 dark:border-white/10 hover:border-[var(--color-forest)]/30 dark:hover:border-[var(--color-forest-light)]/30'
            ]"
            @click="activeCategory = cat as 'cocopeat' | 'cocofiber'"
          >
            <span v-if="activeCategory === cat" class="absolute inset-0 rounded-xl bg-[var(--color-forest)]" />
            <span class="relative z-[1]">{{ cat }}</span>
          </button>
        </div>
      </div>

      <!-- Loading -->
      <div v-if="loading" class="flex justify-center py-6 md:py-10 animate-entry delay-3">
        <div class="w-6 md:w-7 h-6 md:h-7 border-2 border-[var(--color-forest)] dark:border-[var(--color-forest-light)] border-t-transparent rounded-full animate-spin" />
      </div>

      <!-- Gallery (grows to fill remaining space) -->
      <div v-else class="animate-entry delay-3 flex-1 min-h-0 w-full">
        <CircularGallery
          v-if="filteredProducts.length > 0"
          :items="filteredProducts.map(p => ({ image: p.thumbnail || '', text: p.name }))"
          :bend="0"
          text-color="#ffffff"
          :border-radius="0.05"
          :scroll-ease="0.02"
          font="bold 24px 'Hanken Grotesk', sans-serif"
          :scrollSpeed=1
          font-url="https://fonts.googleapis.com/css2?family=Hanken+Grotesk:wght@700&display=swap"
          class="w-full h-full"
        />
        <div v-else class="text-center py-10 text-[var(--color-ink-muted)] dark:text-[var(--color-charcoal-ink-muted)]">
          <p>No products in this category yet.</p>
        </div>
      </div>
    </div>

    <!-- Product Detail Overlay -->
    <Teleport to="body">
      <Transition name="overlay">
        <div v-if="productDetailOpen && selectedProduct" class="fixed inset-0 z-50 flex items-center justify-center p-4">
          <div class="absolute inset-0 bg-black/50 backdrop-blur-sm" @click="closeProduct" />
          <div class="relative bg-[var(--color-parchment)] dark:bg-[var(--color-charcoal)] rounded-2xl max-w-lg w-full shadow-2xl border border-[var(--color-ink)]/10 dark:border-white/10 max-h-[85vh] overflow-y-auto">
            <!-- Image header -->
            <div v-if="selectedProduct.thumbnail" class="h-44 overflow-hidden rounded-t-2xl">
              <img :src="selectedProduct.thumbnail" :alt="selectedProduct.name" class="w-full h-full object-cover" />
            </div>
            <div class="p-7">
              <button class="absolute top-4 right-4 w-9 h-9 rounded-full bg-[var(--color-parchment)] dark:bg-[var(--color-charcoal-raised)] flex items-center justify-center shadow-md hover:shadow-lg transition-shadow" @click="closeProduct" aria-label="Close">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                  <path stroke-linecap="round" d="M6 6l12 12M18 6l-12 12" />
                </svg>
              </button>

              <h2 class="headline-md mb-1">{{ selectedProduct.name }}</h2>
              <span class="label-caps">{{ selectedProduct.category }}</span>
              <p class="body-md mt-3">{{ selectedProduct.short_description }}</p>
              <p v-if="selectedProduct.description" class="body-md mt-2">{{ selectedProduct.description }}</p>

              <!-- Specifications -->
              <div v-if="selectedProduct.specifications?.length" class="mt-5">
                <h3 class="text-xs font-bold uppercase tracking-widest text-[var(--color-husk)] dark:text-[var(--color-husk-light)] mb-3">Specifications</h3>
                <div class="grid grid-cols-2 gap-x-4 gap-y-1">
                  <div v-for="spec in selectedProduct.specifications" :key="spec.name" class="flex justify-between py-1.5 border-b border-[var(--color-ink)]/8 dark:border-white/8 text-sm">
                    <span class="text-[var(--color-ink-muted)] dark:text-[var(--color-charcoal-ink-muted)]">{{ spec.name }}</span>
                    <span class="font-medium text-[var(--color-ink)] dark:text-[var(--color-charcoal-ink)]">{{ spec.value }}{{ spec.unit ? ' ' + spec.unit : '' }}</span>
                  </div>
                </div>
              </div>

              <!-- Applications -->
              <div v-if="selectedProduct.applications?.length" class="mt-4">
                <h3 class="text-xs font-bold uppercase tracking-widest text-[var(--color-husk)] dark:text-[var(--color-husk-light)] mb-2">Applications</h3>
                <div class="flex flex-wrap gap-2">
                  <span v-for="app in selectedProduct.applications" :key="app" class="px-3 py-1.5 bg-[var(--color-forest-muted)] dark:bg-white/10 rounded-lg text-xs font-medium text-[var(--color-forest)] dark:text-[var(--color-forest-light)]">{{ app }}</span>
                </div>
              </div>

              <Button variant="whatsapp" size="md" class="mt-6 w-full justify-center" :href="`https://wa.me/6281234567890?text=I'm interested in ${selectedProduct.name}`">
                Inquire via WhatsApp
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M13.5 4.5L21 12m0 0l-7.5 7.5M21 12H3" />
                </svg>
              </Button>
            </div>
          </div>
        </div>
      </Transition>
    </Teleport>
  </Section>
</template>

<style scoped>
.overlay-enter-active, .overlay-leave-active { transition: opacity 0.2s ease; }
.overlay-enter-active > div:last-child, .overlay-leave-active > div:last-child { transition: transform 0.25s cubic-bezier(0.16, 1, 0.3, 1), opacity 0.25s ease; }
.overlay-enter, .overlay-leave-to { opacity: 0; }
.overlay-enter > div:last-child, .overlay-leave-to > div:last-child { transform: scale(0.95); opacity: 0; }
</style>
