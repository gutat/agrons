<script setup lang="ts">
import { createClient } from '@supabase/supabase-js'
import FloatingWhatsApp from '~/components/common/FloatingWhatsApp.vue'
import type { Product, GalleryItem } from '~/types'

// ===== UI State =====
const currentSection = ref(0)
const mobileMenuOpen = ref(false)
const sectionIds = ['company', 'products', 'gallery', 'contact']

// ===== Theme =====
const colorMode = useColorMode({ storageKey: 'agrons-theme' })
const preferredDark = usePreferredDark()

const theme = computed(() => colorMode.value)
const resolvedTheme = computed(() =>
  colorMode.value === 'auto'
    ? (preferredDark.value ? 'dark' : 'light')
    : colorMode.value
)

function setTheme(newTheme: 'light' | 'dark' | 'system') {
  colorMode.value = newTheme === 'system' ? 'auto' : newTheme
}

function toggleTheme() {
  colorMode.value = resolvedTheme.value === 'dark' ? 'light' : 'dark'
}

// ===== Supabase =====
const config = useRuntimeConfig()
const supabase = createClient(config.public.supabaseUrl, config.public.supabaseKey)

// ===== Products =====
const products = ref<Product[]>([])
const activeCategory = ref<'cocopeat' | 'cocofiber' | 'all'>('all')
const productsLoading = ref(false)

async function fetchProducts() {
  productsLoading.value = true
  const { data } = await supabase
    .from('products')
    .select('*')
    .eq('published', true)
    .order('sort_order')
  if (data) products.value = data
  productsLoading.value = false
}

const filteredProducts = computed(() =>
  activeCategory.value === 'all'
    ? products.value
    : products.value.filter(p => p.category === activeCategory.value)
)

// ===== Gallery =====
const galleryItems = ref<GalleryItem[]>([])
const activeGalleryCategory = ref<string>('all')
const galleryLoading = ref(false)

async function fetchGallery() {
  galleryLoading.value = true
  const { data } = await supabase
    .from('gallery_items')
    .select('*')
    .eq('published', true)
    .order('sort_order')
  if (data) galleryItems.value = data
  galleryLoading.value = false
}

const filteredGallery = computed(() =>
  activeGalleryCategory.value === 'all'
    ? galleryItems.value
    : galleryItems.value.filter(i => i.category === activeGalleryCategory.value)
)

// ===== GALLERY CATEGORIES =====
const galleryCategories = [
  { id: 'all', name: 'All' },
  { id: 'production', name: 'Production' },
  { id: 'factory', name: 'Factory' },
  { id: 'certifications', name: 'Certifications' },
  { id: 'team', name: 'Team' },
]

// ===== Fetch on mount =====
onMounted(() => {
  fetchProducts()
  fetchGallery()
})
</script>

<template>
  <div>
    <NuxtRouteAnnouncer />
    <NuxtPage />
    <FloatingWhatsApp />
  </div>
</template>
