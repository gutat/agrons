<script setup lang="ts">
import { createClient } from '@supabase/supabase-js'

const config = useRuntimeConfig()
const supabase = createClient(config.public.supabaseUrl, config.public.supabaseKey)

const messages = ref<any[]>([])
const loading = ref(true)

onMounted(async () => {
  const { data } = await supabase
    .from('contact_submissions')
    .select('*')
    .order('created_at', { ascending: false })
  if (data) messages.value = data
  loading.value = false
})
</script>

<template>
  <div>
    <h1 class="text-2xl font-bold mb-6">Messages</h1>

    <div v-if="loading" class="text-center py-8 text-neutral-500">Loading...</div>

    <div v-else-if="messages.length === 0" class="text-center py-8 text-neutral-500">No messages yet.</div>

    <div v-else class="space-y-4">
      <div v-for="msg in messages" :key="msg.id" class="bg-white dark:bg-neutral-800 rounded-xl p-6 shadow-sm border border-neutral-200 dark:border-neutral-700">
        <div class="flex items-start justify-between">
          <div>
            <p class="font-medium">{{ msg.name }}</p>
            <p class="text-sm text-neutral-500">{{ msg.email }}</p>
          </div>
          <span class="text-xs text-neutral-400">{{ new Date(msg.created_at).toLocaleDateString() }}</span>
        </div>
        <p class="mt-3 text-sm">{{ msg.message }}</p>
        <div class="flex gap-2 mt-3">
          <span v-if="msg.company" class="text-xs px-2 py-1 bg-neutral-100 dark:bg-neutral-700 rounded">{{ msg.company }}</span>
          <span v-if="msg.inquiry_type" class="text-xs px-2 py-1 bg-neutral-100 dark:bg-neutral-700 rounded capitalize">{{ msg.inquiry_type }}</span>
        </div>
      </div>
    </div>
  </div>
</template>
