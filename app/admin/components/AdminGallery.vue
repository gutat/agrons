<script setup lang="ts">
import { useSupabase } from '~/utils/supabase'

const supabase = useSupabase()

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
    <div style="margin-bottom: 28px;">
      <h1 style="font-family: 'Source Serif 4', serif; font-size: 24px; font-weight: 700; color: #1B3022; margin: 0;">Gallery</h1>
      <p style="font-size: 14px; color: #737973; margin: 4px 0 0;">Manage gallery images and videos</p>
    </div>

    <div v-if="loading" style="text-align: center; padding: 48px 0;">
      <div style="width: 28px; height: 28px; border: 2px solid #1B3022; border-top-color: transparent; border-radius: 50%; animation: adminSpin 0.6s linear infinite; margin: 0 auto;"></div>
    </div>

    <div v-else-if="items.length === 0" style="text-align: center; padding: 48px 0; color: #737973; font-size: 15px;">
      <p style="margin: 0;">No gallery items yet.</p>
    </div>

    <div v-else style="display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 20px;">
      <div v-for="item in items" :key="item.id"
        style="background: white; border-radius: 16px; border: 1px solid rgba(24,28,29,0.08); overflow: hidden; transition: all 0.25s;"
        @mouseenter="$el.style.transform='translateY(-2px)'; $el.style.boxShadow='0 8px 32px rgba(27,48,34,0.08)'"
        @mouseleave="$el.style.transform='translateY(0)'; $el.style.boxShadow='none'"
      >
        <img :src="item.image" :alt="item.alt || item.title"
          style="width: 100%; height: 180px; object-fit: cover; display: block;"
          loading="lazy"
        />
        <div style="padding: 16px;">
          <p style="font-size: 15px; font-weight: 600; color: #181C1D; margin: 0;">{{ item.title }}</p>
          <div style="display: flex; align-items: center; gap: 8px; margin-top: 6px;">
            <span style="display: inline-block; padding: 3px 10px; border-radius: 100px; font-size: 11px; font-weight: 600; background: rgba(27,48,34,0.08); color: #1B3022; text-transform: capitalize;">{{ item.category }}</span>
            <span v-if="item.type === 'video'" style="font-size: 11px; color: #7E562E; font-weight: 600;">🎬 Video</span>
          </div>
          <p v-if="item.description" style="font-size: 13px; color: #737973; margin: 6px 0 0; line-height: 1.4;">{{ item.description }}</p>
        </div>
      </div>
    </div>
  </div>
</template>
