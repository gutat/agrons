<script setup lang="ts">
import { useSupabase } from '~/utils/supabase'
import type { Product } from '~/types'

const supabase = useSupabase()

const props = defineProps<{ id: string }>()
const isNew = props.id === 'new'

const form = reactive({
  name: '',
  category: 'cocopeat' as 'cocopeat' | 'cocofiber',
  slug: '',
  short_description: '',
  description: '',
  moq: '',
  lead_time: '',
  origin: 'Indonesia',
  published: true,
})
const loading = ref(!isNew)
const saving = ref(false)
const saved = ref(false)

async function loadProduct() {
  const { data } = await supabase.from('products').select('*').eq('id', props.id).single()
  if (data) {
    form.name = data.name
    form.category = data.category
    form.slug = data.slug
    form.short_description = data.short_description || ''
    form.description = data.description || ''
    form.moq = data.moq || ''
    form.lead_time = data.lead_time || ''
    form.origin = data.origin || 'Indonesia'
    form.published = data.published
  }
  loading.value = false
}

async function save() {
  saving.value = true
  const record = { ...form }
  if (isNew) {
    await supabase.from('products').insert([record])
  } else {
    await supabase.from('products').update(record).eq('id', props.id)
  }
  saving.value = false
  saved.value = true
}

onMounted(() => { if (!isNew) loadProduct() })
</script>

<template>
  <div>
    <h1 class="text-2xl font-bold mb-6">{{ isNew ? 'Add Product' : 'Edit Product' }}</h1>

    <div v-if="loading" class="text-center py-8 text-neutral-500">Loading...</div>

    <form v-else @submit.prevent="save" class="max-w-2xl space-y-4">
      <div class="grid grid-cols-2 gap-4">
        <div>
          <label class="block text-sm font-medium mb-1">Name *</label>
          <input v-model="form.name" required class="w-full px-3 py-2 rounded-lg border border-neutral-300 dark:border-neutral-700 bg-white dark:bg-neutral-800" />
        </div>
        <div>
          <label class="block text-sm font-medium mb-1">Category *</label>
          <select v-model="form.category" class="w-full px-3 py-2 rounded-lg border border-neutral-300 dark:border-neutral-700 bg-white dark:bg-neutral-800">
            <option value="cocopeat">Cocopeat</option>
            <option value="cocofiber">Cocofiber</option>
          </select>
        </div>
      </div>
      <div>
        <label class="block text-sm font-medium mb-1">Slug *</label>
        <input v-model="form.slug" required class="w-full px-3 py-2 rounded-lg border border-neutral-300 dark:border-neutral-700 bg-white dark:bg-neutral-800" />
      </div>
      <div>
        <label class="block text-sm font-medium mb-1">Short Description</label>
        <textarea v-model="form.short_description" rows="2" class="w-full px-3 py-2 rounded-lg border border-neutral-300 dark:border-neutral-700 bg-white dark:bg-neutral-800"></textarea>
      </div>
      <div>
        <label class="block text-sm font-medium mb-1">Description</label>
        <textarea v-model="form.description" rows="4" class="w-full px-3 py-2 rounded-lg border border-neutral-300 dark:border-neutral-700 bg-white dark:bg-neutral-800"></textarea>
      </div>
      <div class="grid grid-cols-2 gap-4">
        <div>
          <label class="block text-sm font-medium mb-1">MOQ</label>
          <input v-model="form.moq" class="w-full px-3 py-2 rounded-lg border border-neutral-300 dark:border-neutral-700 bg-white dark:bg-neutral-800" />
        </div>
        <div>
          <label class="block text-sm font-medium mb-1">Lead Time</label>
          <input v-model="form.lead_time" class="w-full px-3 py-2 rounded-lg border border-neutral-300 dark:border-neutral-700 bg-white dark:bg-neutral-800" />
        </div>
      </div>
      <div class="flex items-center gap-2">
        <input v-model="form.published" type="checkbox" id="published" class="rounded" />
        <label for="published" class="text-sm">Published</label>
      </div>

      <div class="flex gap-3 pt-4">
        <button type="submit" :disabled="saving" class="px-6 py-2 bg-[var(--color-primary)] text-white rounded-lg font-medium hover:opacity-90 disabled:opacity-50">
          {{ saving ? 'Saving...' : 'Save' }}
        </button>
        <NuxtLink to="../products" class="px-6 py-2 border border-neutral-300 rounded-lg text-sm hover:bg-neutral-50 dark:hover:bg-neutral-800">Cancel</NuxtLink>
      </div>

      <p v-if="saved" class="text-green-600 text-sm font-medium">Saved successfully!</p>
    </form>
  </div>
</template>
