<script setup lang="ts">
import { createClient } from '@supabase/supabase-js'

const config = useRuntimeConfig()
const supabase = createClient(config.public.supabaseUrl, config.public.supabaseKey)

const form = reactive({
  name: '',
  tagline: '',
  mission: '',
  vision: '',
  values: '',
  description: '',
})
const loading = ref(true)
const saving = ref(false)
const saved = ref(false)

onMounted(async () => {
  const { data } = await supabase.from('company_info').select('*').single()
  if (data) {
    form.name = data.name || ''
    form.tagline = data.tagline || ''
    form.mission = data.mission || ''
    form.vision = data.vision || ''
    form.values = data.values ? JSON.stringify(data.values, null, 2) : '[]'
    form.description = data.description || ''
  }
  loading.value = false
})

async function save() {
  saving.value = true
  let values: any[]
  try { values = JSON.parse(form.values) } catch { values = [] }
  await supabase.from('company_info').update({
    name: form.name,
    tagline: form.tagline,
    mission: form.mission,
    vision: form.vision,
    values,
    description: form.description,
  }).eq('id', 1)
  saving.value = false
  saved.value = true
}
</script>

<template>
  <div>
    <h1 class="text-2xl font-bold mb-6">Company Profile</h1>

    <div v-if="loading" class="text-center py-8 text-neutral-500">Loading...</div>

    <form v-else @submit.prevent="save" class="max-w-2xl space-y-4">
      <div class="grid grid-cols-2 gap-4">
        <div>
          <label class="block text-sm font-medium mb-1">Company Name</label>
          <input v-model="form.name" class="w-full px-3 py-2 rounded-lg border border-neutral-300 dark:border-neutral-700 bg-white dark:bg-neutral-800" />
        </div>
        <div>
          <label class="block text-sm font-medium mb-1">Tagline</label>
          <input v-model="form.tagline" class="w-full px-3 py-2 rounded-lg border border-neutral-300 dark:border-neutral-700 bg-white dark:bg-neutral-800" />
        </div>
      </div>
      <div>
        <label class="block text-sm font-medium mb-1">Mission</label>
        <textarea v-model="form.mission" rows="2" class="w-full px-3 py-2 rounded-lg border border-neutral-300 dark:border-neutral-700 bg-white dark:bg-neutral-800"></textarea>
      </div>
      <div>
        <label class="block text-sm font-medium mb-1">Vision</label>
        <textarea v-model="form.vision" rows="2" class="w-full px-3 py-2 rounded-lg border border-neutral-300 dark:border-neutral-700 bg-white dark:bg-neutral-800"></textarea>
      </div>
      <div>
        <label class="block text-sm font-medium mb-1">Values (JSON array)</label>
        <textarea v-model="form.values" rows="6" class="w-full px-3 py-2 rounded-lg border border-neutral-300 dark:border-neutral-700 bg-white dark:bg-neutral-800 font-mono text-sm"></textarea>
      </div>

      <div class="flex gap-3 pt-4">
        <button type="submit" :disabled="saving" class="px-6 py-2 bg-[var(--color-primary)] text-white rounded-lg font-medium hover:opacity-90 disabled:opacity-50">
          {{ saving ? 'Saving...' : 'Save' }}
        </button>
      </div>

      <p v-if="saved" class="text-green-600 text-sm font-medium">Saved successfully!</p>
    </form>
  </div>
</template>
