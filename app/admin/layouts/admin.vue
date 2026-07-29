<script setup lang="ts">
import { createClient } from '@supabase/supabase-js'

const config = useRuntimeConfig()
const supabase = createClient(config.public.supabaseUrl, config.public.supabaseKey)
const adminPath = config.public.adminPath || 'admin'

const props = defineProps<{
  section: string
  slug?: string
}>()

const user = ref<any>(null)
const loading = ref(true)
const email = ref('')
const password = ref('')
const authError = ref('')

async function checkSession() {
  const { data } = await supabase.auth.getSession()
  user.value = data.session?.user || null
  loading.value = false
}

async function signIn() {
  authError.value = ''
  const { error } = await supabase.auth.signInWithPassword({ email: email.value, password: password.value })
  if (error) authError.value = error.message
  else { await checkSession() }
}

async function signOut() {
  await supabase.auth.signOut()
  user.value = null
}

onMounted(checkSession)
</script>

<template>
  <div class="min-h-screen bg-gray-50 dark:bg-neutral-900">
    <!-- Login screen -->
    <div v-if="!loading && !user" class="min-h-screen flex items-center justify-center p-4">
      <div class="w-full max-w-sm">
        <h1 class="text-2xl font-bold text-center mb-6">Admin Login</h1>
        <form @submit.prevent="signIn" class="space-y-4">
          <div>
            <label class="block text-sm font-medium mb-1">Email</label>
            <input v-model="email" type="email" required class="w-full px-4 py-2 rounded-lg border border-neutral-300 dark:border-neutral-700 bg-white dark:bg-neutral-800" />
          </div>
          <div>
            <label class="block text-sm font-medium mb-1">Password</label>
            <input v-model="password" type="password" required class="w-full px-4 py-2 rounded-lg border border-neutral-300 dark:border-neutral-700 bg-white dark:bg-neutral-800" />
          </div>
          <p v-if="authError" class="text-red-500 text-sm">{{ authError }}</p>
          <button type="submit" class="w-full py-2 px-4 bg-[var(--color-primary)] text-white rounded-lg font-medium hover:opacity-90">
            Sign In
          </button>
        </form>
      </div>
    </div>

    <!-- Admin dashboard -->
    <div v-else-if="user" class="flex">
      <!-- Sidebar -->
      <aside class="w-64 min-h-screen bg-white dark:bg-neutral-800 border-r border-neutral-200 dark:border-neutral-700 p-4 shrink-0">
        <h2 class="font-bold text-lg mb-6">Admin Panel</h2>
        <nav class="space-y-1">
          <NuxtLink :to="`/${adminPath}/dashboard`" class="block px-3 py-2 rounded-lg text-sm hover:bg-neutral-100 dark:hover:bg-neutral-700">Dashboard</NuxtLink>
          <NuxtLink :to="`/${adminPath}/products`" class="block px-3 py-2 rounded-lg text-sm hover:bg-neutral-100 dark:hover:bg-neutral-700">Products</NuxtLink>
          <NuxtLink :to="`/${adminPath}/gallery`" class="block px-3 py-2 rounded-lg text-sm hover:bg-neutral-100 dark:hover:bg-neutral-700">Gallery</NuxtLink>
          <NuxtLink :to="`/${adminPath}/company`" class="block px-3 py-2 rounded-lg text-sm hover:bg-neutral-100 dark:hover:bg-neutral-700">Company</NuxtLink>
          <NuxtLink :to="`/${adminPath}/messages`" class="block px-3 py-2 rounded-lg text-sm hover:bg-neutral-100 dark:hover:bg-neutral-700">Messages</NuxtLink>
        </nav>
        <button @click="signOut" class="mt-8 text-sm text-red-500 hover:underline">Sign Out</button>
      </aside>

      <!-- Main content -->
      <main class="flex-1 p-8">
        <AdminDashboard v-if="section === 'dashboard'" />
        <AdminProducts v-else-if="section === 'products' && !slug" />
        <AdminProductEditor v-else-if="section === 'products' && slug" :id="slug" />
        <AdminGallery v-else-if="section === 'gallery'" />
        <AdminCompany v-else-if="section === 'company'" />
        <AdminMessages v-else-if="section === 'messages'" />
        <div v-else class="text-center py-12 text-neutral-500">Select a section from the sidebar.</div>
      </main>
    </div>

    <!-- Loading -->
    <div v-else class="min-h-screen flex items-center justify-center">
      <p class="text-neutral-500">Loading...</p>
    </div>
  </div>
</template>
