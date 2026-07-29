<script setup lang="ts">
import { createClient } from '@supabase/supabase-js'

const config = useRuntimeConfig()
const supabase = createClient(config.public.supabaseUrl, config.public.supabaseKey)

const stats = ref({ products: 0, gallery: 0, messages: 0 })

onMounted(async () => {
  const [p, g, m] = await Promise.all([
    supabase.from('products').select('id', { count: 'exact', head: true }).eq('published', true),
    supabase.from('gallery_items').select('id', { count: 'exact', head: true }).eq('published', true),
    supabase.from('contact_submissions').select('id', { count: 'exact', head: true }),
  ])
  stats.value = {
    products: p.count || 0,
    gallery: g.count || 0,
    messages: m.count || 0,
  }
})
</script>

<template>
  <div>
    <h1 class="text-2xl font-bold mb-6">Dashboard</h1>
    <div class="grid grid-cols-3 gap-6">
      <div class="bg-white dark:bg-neutral-800 rounded-xl p-6 shadow-sm border border-neutral-200 dark:border-neutral-700">
        <p class="text-sm text-neutral-500">Products</p>
        <p class="text-3xl font-bold mt-1">{{ stats.products }}</p>
      </div>
      <div class="bg-white dark:bg-neutral-800 rounded-xl p-6 shadow-sm border border-neutral-200 dark:border-neutral-700">
        <p class="text-sm text-neutral-500">Gallery Items</p>
        <p class="text-3xl font-bold mt-1">{{ stats.gallery }}</p>
      </div>
      <div class="bg-white dark:bg-neutral-800 rounded-xl p-6 shadow-sm border border-neutral-200 dark:border-neutral-700">
        <p class="text-sm text-neutral-500">Messages</p>
        <p class="text-3xl font-bold mt-1">{{ stats.messages }}</p>
      </div>
    </div>
  </div>
</template>
