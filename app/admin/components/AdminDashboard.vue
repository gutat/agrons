<script setup lang="ts">
import { useSupabase } from '~/utils/supabase'

const supabase = useSupabase()

const stats = ref({ products: 0, gallery: 0, messages: 0, home: 0, about: 0 })

onMounted(async () => {
  const [p, g, m, h, a] = await Promise.all([
    supabase.from('products').select('id', { count: 'exact', head: true }).eq('published', true),
    supabase.from('gallery_items').select('id', { count: 'exact', head: true }).eq('published', true),
    supabase.from('contact_submissions').select('id', { count: 'exact', head: true }),
    supabase.from('home_section').select('id', { count: 'exact', head: true }),
    supabase.from('about_section').select('id', { count: 'exact', head: true }),
  ])
  stats.value = {
    products: p.count || 0,
    gallery: g.count || 0,
    messages: m.count || 0,
    home: h.count || 0,
    about: a.count || 0,
  }
})

const cards = [
  { label: 'Products', value: 'products', icon: '📦', color: '#1B3022' },
  { label: 'Gallery Items', value: 'gallery', icon: '🖼️', color: '#7E562E' },
  { label: 'Messages', value: 'messages', icon: '✉️', color: '#2E7D32' },
  { label: 'Home Section', value: 'home', icon: '🏠', color: '#434843' },
  { label: 'About Section', value: 'about', icon: '📋', color: '#737973' },
]
</script>

<template>
  <div>
    <div style="margin-bottom: 28px;">
      <h1 style="font-family: 'Source Serif 4', serif; font-size: 24px; font-weight: 700; color: #1B3022; margin: 0;">Dashboard</h1>
      <p style="font-size: 14px; color: #737973; margin: 4px 0 0;">Overview of your site content</p>
    </div>

    <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 20px;">
      <div v-for="card in cards" :key="card.value"
        style="background: white; border-radius: 16px; border: 1px solid rgba(24,28,29,0.08); padding: 24px; transition: all 0.25s; cursor: default;"
        @mouseenter="$el.style.transform='translateY(-2px)'; $el.style.boxShadow='0 8px 32px rgba(27,48,34,0.1)'"
        @mouseleave="$el.style.transform='translateY(0)'; $el.style.boxShadow='none'"
      >
        <div style="font-size: 28px; margin-bottom: 12px;">{{ card.icon }}</div>
        <p style="font-size: 13px; color: #737973; font-weight: 500; margin: 0;">{{ card.label }}</p>
        <p style="font-size: 32px; font-weight: 700; color: card.color; margin: 4px 0 0; font-family: 'Source Serif 4', serif;"
          :style="{ color: card.color }"
        >{{ (stats as any)[card.value] }}</p>
      </div>
    </div>
  </div>
</template>
