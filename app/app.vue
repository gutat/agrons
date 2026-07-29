<script setup>
import { ref, onMounted } from 'vue'
import { createClient } from '@supabase/supabase-js'

const config = useRuntimeConfig()
const supabaseUrl = config.public.supabaseUrl
const supabaseKey = config.public.supabaseKey

const todos = ref([])
const error = ref(null)

async function getTodos() {
  if (!supabaseUrl || !supabaseKey) {
    error.value = 'Supabase not configured — set SUPABASE_URL and SUPABASE_KEY env vars'
    return
  }
  const supabase = createClient(supabaseUrl, supabaseKey)
  const { data, error: err } = await supabase.from('todos').select()
  if (err) error.value = err.message
  else todos.value = data
}

onMounted(() => {
  getTodos()
})
</script>

<template>
  <div>
    <p v-if="error" style="color: #ba1a1a; padding: 1rem;">{{ error }}</p>
    <ul v-else>
      <li v-for="todo in todos" :key="todo.id">{{ todo.name }}</li>
    </ul>
  </div>
</template>
