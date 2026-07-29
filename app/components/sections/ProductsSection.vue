<script setup lang="ts">
import { register } from 'swiper/element/bundle'
import { createClient } from '@supabase/supabase-js'
import type { Product } from '~/types'
register()

const config = useRuntimeConfig()
const supabase = createClient(config.public.supabaseUrl, config.public.supabaseKey)

const products = ref<Product[]>([])
const activeCategory = ref<'cocopeat' | 'cocofiber'>('cocopeat')
const loading = ref(true)
const productDetailOpen = ref(false)
const selectedProduct = ref<Product | null>(null)

const filteredProducts = computed(() =>
  products.value.filter(p => p.category === activeCategory.value)
)

function openProduct(product: Product) {
  selectedProduct.value = product
  productDetailOpen.value = true
}
function closeProduct() {
  productDetailOpen.value = false
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
  <Section id="products">
    <div class="max-w-(--spacing-container) mx-auto px-(--spacing-gutter) w-full">
      <h2 class="headline-md text-[var(--color-primary)] text-center mb-2">Our Products</h2>
      <p class="body-md text-[var(--color-on-surface-variant)] text-center mb-8">Premium coconut-based products for global markets</p>

      <!-- Category Tabs -->
      <div class="flex justify-center gap-2 mb-8">
        <button
          v-for="cat in ['cocopeat', 'cocofiber']"
          :key="cat"
          :class="[
            'px-6 py-2 rounded-lg text-sm font-medium transition-all capitalize',
            activeCategory === cat
              ? 'bg-[var(--color-primary)] text-white'
              : 'bg-[var(--color-surface-container)] text-[var(--color-on-surface-variant)] hover:bg-[var(--color-surface-container-high)]'
          ]"
          @click="activeCategory = cat as 'cocopeat' | 'cocofiber'"
        >{{ cat }}</button>
      </div>

      <!-- Loading -->
      <div v-if="loading" class="text-center py-8 text-[var(--color-on-surface-variant)]">Loading products...</div>

      <!-- Product Swiper -->
      <swiper-container v-else slides-per-view="auto" space-between="20" grab-cursor class="pb-4">
        <swiper-slide
          v-for="product in filteredProducts"
          :key="product.id"
          class="!w-[280px]"
        >
          <div
            class="glass rounded-xl p-6 bg-white/50 dark:bg-white/5 cursor-pointer hover:shadow-lg transition-shadow"
            @click="openProduct(product)"
          >
            <div class="w-full h-32 bg-[var(--color-surface-container)] rounded-lg mb-4 flex items-center justify-center overflow-hidden">
              <img v-if="product.thumbnail" :src="product.thumbnail" :alt="product.name" class="w-full h-full object-cover" />
              <svg v-else xmlns="http://www.w3.org/2000/svg" width="40" height="40" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="1" class="text-[var(--color-on-surface-variant)]">
                <rect x="3" y="3" width="18" height="18" rx="2" />
                <circle cx="8.5" cy="8.5" r="1.5" />
                <path d="M21 15l-5-5L5 21" />
              </svg>
            </div>
            <span class="label-caps text-[var(--color-secondary)]">{{ product.category }}</span>
            <h3 class="font-semibold text-[var(--color-on-surface)] mt-1">{{ product.name }}</h3>
            <p class="text-sm text-[var(--color-on-surface-variant)] mt-1 line-clamp-2">{{ product.short_description }}</p>
          </div>
        </swiper-slide>
      </swiper-container>
    </div>

    <!-- Product Detail Overlay -->
    <Teleport to="body">
      <Transition name="overlay">
        <div v-if="productDetailOpen && selectedProduct" class="fixed inset-0 z-50 flex items-center justify-center p-4">
          <div class="absolute inset-0 bg-black/50 backdrop-blur-sm" @click="closeProduct" />
          <div class="relative bg-white dark:bg-[var(--color-dark-surface)] rounded-2xl max-w-lg w-full p-8 shadow-2xl max-h-[90vh] overflow-y-auto">
            <button class="absolute top-4 right-4 p-2 rounded-full hover:bg-[var(--color-surface-container)] dark:hover:bg-[var(--color-dark-surface-container)]" @click="closeProduct" aria-label="Close">
              <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2">
                <path stroke-linecap="round" d="M6 6l12 12M18 6l-12 12" />
              </svg>
            </button>

            <h2 class="headline-md text-[var(--color-primary)] mb-1">{{ selectedProduct.name }}</h2>
            <span class="label-caps text-[var(--color-secondary)]">{{ selectedProduct.category }}</span>
            <p class="body-md text-[var(--color-on-surface-variant)] mt-4">{{ selectedProduct.short_description }}</p>
            <p class="body-md text-[var(--color-on-surface-variant)] mt-2">{{ selectedProduct.description }}</p>

            <!-- Specifications -->
            <div v-if="selectedProduct.specifications?.length" class="mt-6">
              <h3 class="font-semibold text-sm mb-2">Specifications</h3>
              <div class="grid grid-cols-2 gap-2">
                <div v-for="spec in selectedProduct.specifications" :key="spec.name" class="flex justify-between py-1 border-b border-[var(--color-outline)]/20 text-sm">
                  <span class="text-[var(--color-on-surface-variant)]">{{ spec.name }}</span>
                  <span class="font-medium">{{ spec.value }}{{ spec.unit ? ' ' + spec.unit : '' }}</span>
                </div>
              </div>
            </div>

            <!-- Applications -->
            <div v-if="selectedProduct.applications?.length" class="mt-4">
              <h3 class="font-semibold text-sm mb-2">Applications</h3>
              <div class="flex flex-wrap gap-2">
                <span v-for="app in selectedProduct.applications" :key="app" class="px-3 py-1 bg-[var(--color-surface-container)] rounded-full text-xs">{{ app }}</span>
              </div>
            </div>

            <Button variant="whatsapp" size="md" class="mt-6 w-full justify-center" :href="`https://wa.me/6281234567890?text=I'm interested in ${selectedProduct.name}`">
              Inquire via WhatsApp
            </Button>
          </div>
        </div>
      </Transition>
    </Teleport>
  </Section>
</template>

<style scoped>
.overlay-enter-active, .overlay-leave-active { transition: opacity 0.2s ease; }
.overlay-enter-active > div:last-child, .overlay-leave-active > div:last-child { transition: transform 0.3s ease, opacity 0.3s ease; }
.overlay-enter, .overlay-leave-to { opacity: 0; }
.overlay-enter > div:last-child, .overlay-leave-to > div:last-child { transform: scale(0.95); opacity: 0; }
</style>
