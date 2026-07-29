<script setup lang="ts">
import { createClient } from '@supabase/supabase-js'

const config = useRuntimeConfig()
const supabase = createClient(config.public.supabaseUrl, config.public.supabaseKey)

const items = ref<any[]>([])
const loading = ref(true)

onMounted(async () => {
  const { data } = await supabase.from('gallery_items').select('*').order('sort_order')
  if (data) items.value = data
  loading.value = false
})
</script>

<template>
  <div>
    <h1 class="text-2xl font-bold mb-6">Gallery</h1>

    <div v-if="loading" class="text-center py-8 text-neutral-500">Loading...</div>

    <div v-else-if="items.length === 0" class="text-center py-8 text-neutral-500">No gallery items yet.</div>

    <div v-else class="grid grid-cols-3 gap-4">
      <div v-for="item in items" :key="item.id" class="bg-white dark:bg-neutral-800 rounded-xl overflow-hidden shadow-sm border border-neutral-200 dark:border-neutral-700">
        <img
          :src="item.image"
          :alt="item.alt || item.title"
          class="w-full h-40 object-cover"
          loading="lazy"
        />
        <div class="p-3">
          <p class="text-sm font-medium">{{ item.title }}</p>
          <p class="text-xs text-neutral-500 mt-1 capitalize">{{ item.category }}</p>
        </div>
      </div>
    </div>
  </div>
</template>
