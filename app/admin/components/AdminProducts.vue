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
    <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 28px;">
      <div>
        <h1 style="font-family: 'Source Serif 4', serif; font-size: 24px; font-weight: 700; color: #1B3022; margin: 0;">Products</h1>
        <p style="font-size: 14px; color: #737973; margin: 4px 0 0;">Manage your cocopeat and cocofiber products</p>
      </div>
      <NuxtLink to="./products/new"
        style="padding: 12px 24px; border-radius: 12px; background: #1B3022; color: white; font-size: 14px; font-weight: 600; text-decoration: none; transition: opacity 0.2s; display: flex; align-items: center; gap: 8px;"
        @mouseenter="$el.style.opacity='0.9'" @mouseleave="$el.style.opacity='1'"
      >
        <span style="font-size: 18px; line-height: 1;">+</span> Add Product
      </NuxtLink>
    </div>

    <div v-if="loading" style="text-align: center; padding: 48px 0;">
      <div style="width: 28px; height: 28px; border: 2px solid #1B3022; border-top-color: transparent; border-radius: 50%; animation: adminSpin 0.6s linear infinite; margin: 0 auto;"></div>
    </div>

    <div v-else-if="products.length === 0" style="text-align: center; padding: 48px 0; color: #737973; font-size: 15px;">
      <p style="margin: 0;">No products yet.</p>
      <NuxtLink to="./products/new" style="color: #1B3022; font-weight: 600; font-size: 14px; margin-top: 8px; display: inline-block;">Add your first product →</NuxtLink>
    </div>

    <div v-else style="background: white; border-radius: 16px; border: 1px solid rgba(24,28,29,0.08); overflow: hidden;">
      <table style="width: 100%; border-collapse: collapse; font-size: 14px;">
        <thead>
          <tr style="background: #F7FAFB;">
            <th style="text-align: left; padding: 14px 20px; font-weight: 600; color: #434843; font-size: 12px; text-transform: uppercase; letter-spacing: 0.05em;">Name</th>
            <th style="text-align: left; padding: 14px 20px; font-weight: 600; color: #434843; font-size: 12px; text-transform: uppercase; letter-spacing: 0.05em;">Category</th>
            <th style="text-align: left; padding: 14px 20px; font-weight: 600; color: #434843; font-size: 12px; text-transform: uppercase; letter-spacing: 0.05em;">Published</th>
            <th style="text-align: right; padding: 14px 20px; font-weight: 600; color: #434843; font-size: 12px; text-transform: uppercase; letter-spacing: 0.05em;">Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="p in products" :key="p.id"
            style="border-top: 1px solid rgba(24,28,29,0.06); transition: background 0.15s;"
            @mouseenter="$el.style.background='rgba(27,48,34,0.02)'" @mouseleave="$el.style.background='transparent'"
          >
            <td style="padding: 14px 20px; font-weight: 500; color: #181C1D;">{{ p.name }}</td>
            <td style="padding: 14px 20px;">
              <span style="display: inline-block; padding: 4px 12px; border-radius: 100px; font-size: 12px; font-weight: 600; text-transform: capitalize; background: rgba(27,48,34,0.08); color: #1B3022;">{{ p.category }}</span>
            </td>
            <td style="padding: 14px 20px;">
              <span v-if="p.published" style="color: #2E7D32; font-size: 12px; font-weight: 600;">● Published</span>
              <span v-else style="color: #737973; font-size: 12px; font-weight: 600;">○ Draft</span>
            </td>
            <td style="padding: 14px 20px; text-align: right;">
              <NuxtLink :to="`./products/${p.id}`"
                style="padding: 6px 16px; border-radius: 8px; background: rgba(27,48,34,0.08); color: #1B3022; font-size: 13px; font-weight: 600; text-decoration: none; transition: all 0.15s;"
                @mouseenter="$el.style.background='#1B3022'; $el.style.color='white'" @mouseleave="$el.style.background='rgba(27,48,34,0.08)'; $el.style.color='#1B3022'"
              >Edit</NuxtLink>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>
