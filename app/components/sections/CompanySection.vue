<script setup lang="ts">
import { createClient } from '@supabase/supabase-js'

const config = useRuntimeConfig()
const supabase = createClient(config.public.supabaseUrl, config.public.supabaseKey)

const company = ref({
  name: 'PT Agro Nusa Sejahtera',
  tagline: 'Premium Cocopeat & Cocofiber from Indonesia',
  mission: 'Loading...',
  vision: 'Loading...',
  values: [] as { icon: string; title: string; description: string }[],
})
const loading = ref(true)

onMounted(async () => {
  const { data } = await supabase.from('company_info').select('*').single()
  if (data) company.value = data
  loading.value = false
})
</script>

<template>
  <Section id="company">
    <div class="max-w-(--spacing-container) mx-auto px-(--spacing-gutter) w-full">
      <!-- Hero -->
      <div class="text-center mb-16 md:mb-20">
        <h1 class="display-lg text-[var(--color-primary)] mb-4">{{ company.name }}</h1>
        <p class="body-lg text-[var(--color-on-surface-variant)] max-w-2xl mx-auto">{{ company.tagline }}</p>
      </div>

      <!-- Mission & Vision -->
      <div v-if="!loading" class="grid md:grid-cols-2 gap-8 mb-16">
        <div class="glass rounded-xl p-8 bg-white/50 dark:bg-white/5">
          <h2 class="headline-md text-[var(--color-primary)] mb-4">Our Mission</h2>
          <p class="body-md text-[var(--color-on-surface-variant)]">{{ company.mission }}</p>
        </div>
        <div class="glass rounded-xl p-8 bg-white/50 dark:bg-white/5">
          <h2 class="headline-md text-[var(--color-primary)] mb-4">Our Vision</h2>
          <p class="body-md text-[var(--color-on-surface-variant)]">{{ company.vision }}</p>
        </div>
      </div>

      <!-- Values -->
      <div v-if="company.values?.length" class="grid grid-cols-2 md:grid-cols-4 gap-4 md:gap-6">
        <div
          v-for="value in company.values"
          :key="value.title"
          class="glass rounded-xl p-6 text-center bg-white/50 dark:bg-white/5"
        >
          <div class="text-2xl mb-2">🌿</div>
          <h3 class="font-semibold text-sm text-[var(--color-primary)] mb-1">{{ value.title }}</h3>
          <p class="text-xs text-[var(--color-on-surface-variant)]">{{ value.description }}</p>
        </div>
      </div>
    </div>
  </Section>
</template>
