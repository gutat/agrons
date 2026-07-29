<script setup lang="ts">
import { useSupabase } from '~/utils/supabase'
import type { Product } from '~/types'

const supabase = useSupabase()

const products = ref<Product[]>([])
const loading = ref(true)

onMounted(async () => {
  const { data } = await supabase.from('products').select('*').order('sort_order')
  if (data) products.value = data
  loading.value = false
})
</script>

<template>
  <div>
    <div class="flex items-center justify-between mb-6">
      <h1 class="text-2xl font-bold">Products</h1>
      <NuxtLink to="./products/new" class="px-4 py-2 bg-[var(--color-primary)] text-white rounded-lg text-sm font-medium hover:opacity-90">
        + Add Product
      </NuxtLink>
    </div>

    <div v-if="loading" class="text-center py-8 text-neutral-500">Loading...</div>

    <div v-else-if="products.length === 0" class="text-center py-8 text-neutral-500">No products yet.</div>

    <div v-else class="bg-white dark:bg-neutral-800 rounded-xl shadow-sm border border-neutral-200 dark:border-neutral-700 overflow-hidden">
      <table class="w-full text-sm">
        <thead class="bg-neutral-50 dark:bg-neutral-900">
          <tr>
            <th class="text-left px-4 py-3 font-medium">Name</th>
            <th class="text-left px-4 py-3 font-medium">Category</th>
            <th class="text-left px-4 py-3 font-medium">Slug</th>
            <th class="text-right px-4 py-3 font-medium">Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="p in products" :key="p.id" class="border-t border-neutral-200 dark:border-neutral-700 hover:bg-neutral-50 dark:hover:bg-neutral-700/50">
            <td class="px-4 py-3">{{ p.name }}</td>
            <td class="px-4 py-3 capitalize">{{ p.category }}</td>
            <td class="px-4 py-3 text-neutral-500">{{ p.slug }}</td>
            <td class="px-4 py-3 text-right">
              <NuxtLink :to="`./products/${p.id}`" class="text-blue-600 hover:underline text-sm">Edit</NuxtLink>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>
