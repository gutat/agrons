<script setup lang="ts">
import { useSupabase } from '~/utils/supabase'

const supabase = useSupabase()

const form = reactive({
  company_name: '',
  tagline: '',
  description: '',
  subtitle: '',
  hero_video_url: '',
  hero_image_url: '',
  published: true,
})
const loading = ref(true)
const saving = ref(false)
const saved = ref(false)

onMounted(async () => {
  const { data } = await supabase.from('home_section').select('*').single()
  if (data) {
    form.company_name = data.company_name || ''
    form.tagline = data.tagline || ''
    form.description = data.description || ''
    form.subtitle = data.subtitle || ''
    form.hero_video_url = data.hero_video_url || ''
    form.hero_image_url = data.hero_image_url || ''
    form.published = data.published ?? true
  }
  loading.value = false
})

async function save() {
  saving.value = true
  await supabase.from('home_section').update({
    company_name: form.company_name,
    tagline: form.tagline,
    description: form.description,
    subtitle: form.subtitle,
    hero_video_url: form.hero_video_url || null,
    hero_image_url: form.hero_image_url || null,
    published: form.published,
  }).eq('id', 1)
  saving.value = false
  saved.value = true
  setTimeout(() => saved.value = false, 3000)
}
</script>

<template>
  <div>
    <div style="margin-bottom: 28px;">
      <h1 style="font-family: 'Source Serif 4', serif; font-size: 24px; font-weight: 700; color: #1B3022; margin: 0;">Home Section</h1>
      <p style="font-size: 14px; color: #737973; margin: 4px 0 0;">Manage the hero banner and company tagline</p>
    </div>

    <div v-if="loading" style="text-align: center; padding: 48px 0;">
      <div style="width: 28px; height: 28px; border: 2px solid #1B3022; border-top-color: transparent; border-radius: 50%; animation: adminSpin 0.6s linear infinite; margin: 0 auto;"></div>
    </div>

    <form v-else @submit.prevent="save" style="max-width: 720px; display: flex; flex-direction: column; gap: 20px;">
      <!-- Company Name -->
      <div style="background: white; border-radius: 16px; border: 1px solid rgba(24,28,29,0.08); padding: 24px;">
        <label style="display: block; font-size: 13px; font-weight: 600; color: #434843; margin-bottom: 6px;">Company Name</label>
        <input v-model="form.company_name" required
          style="width: 100%; padding: 12px 16px; border-radius: 10px; border: 1px solid rgba(24,28,29,0.1); background: #F7FAFB; font-size: 15px; color: #181C1D; outline: none; box-sizing: border-box; font-family: inherit; transition: border-color 0.2s;"
          @focus="$el.style.borderColor='#1B3022'; $el.style.boxShadow='0 0 0 3px rgba(27,48,34,0.1)'"
          @blur="$el.style.borderColor='rgba(24,28,29,0.1)'; $el.style.boxShadow='none'"
        />
      </div>

      <!-- Tagline + Subtitle -->
      <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
        <div style="background: white; border-radius: 16px; border: 1px solid rgba(24,28,29,0.08); padding: 24px;">
          <label style="display: block; font-size: 13px; font-weight: 600; color: #434843; margin-bottom: 6px;">Tagline</label>
          <input v-model="form.tagline"
            style="width: 100%; padding: 12px 16px; border-radius: 10px; border: 1px solid rgba(24,28,29,0.1); background: #F7FAFB; font-size: 15px; color: #181C1D; outline: none; box-sizing: border-box; font-family: inherit; transition: border-color 0.2s;"
            @focus="$el.style.borderColor='#1B3022'; $el.style.boxShadow='0 0 0 3px rgba(27,48,34,0.1)'"
            @blur="$el.style.borderColor='rgba(24,28,29,0.1)'; $el.style.boxShadow='none'"
          />
        </div>
        <div style="background: white; border-radius: 16px; border: 1px solid rgba(24,28,29,0.08); padding: 24px;">
          <label style="display: block; font-size: 13px; font-weight: 600; color: #434843; margin-bottom: 6px;">Subtitle</label>
          <input v-model="form.subtitle"
            style="width: 100%; padding: 12px 16px; border-radius: 10px; border: 1px solid rgba(24,28,29,0.1); background: #F7FAFB; font-size: 15px; color: #181C1D; outline: none; box-sizing: border-box; font-family: inherit; transition: border-color 0.2s;"
            @focus="$el.style.borderColor='#1B3022'; $el.style.boxShadow='0 0 0 3px rgba(27,48,34,0.1)'"
            @blur="$el.style.borderColor='rgba(24,28,29,0.1)'; $el.style.boxShadow='none'"
          />
        </div>
      </div>

      <!-- Description -->
      <div style="background: white; border-radius: 16px; border: 1px solid rgba(24,28,29,0.08); padding: 24px;">
        <label style="display: block; font-size: 13px; font-weight: 600; color: #434843; margin-bottom: 6px;">Description</label>
        <textarea v-model="form.description" rows="3"
          style="width: 100%; padding: 12px 16px; border-radius: 10px; border: 1px solid rgba(24,28,29,0.1); background: #F7FAFB; font-size: 15px; color: #181C1D; outline: none; box-sizing: border-box; font-family: inherit; resize: vertical; transition: border-color 0.2s;"
          @focus="$el.style.borderColor='#1B3022'; $el.style.boxShadow='0 0 0 3px rgba(27,48,34,0.1)'"
          @blur="$el.style.borderColor='rgba(24,28,29,0.1)'; $el.style.boxShadow='none'"
        ></textarea>
      </div>

      <!-- Hero URLs -->
      <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
        <div style="background: white; border-radius: 16px; border: 1px solid rgba(24,28,29,0.08); padding: 24px;">
          <label style="display: block; font-size: 13px; font-weight: 600; color: #434843; margin-bottom: 6px;">Hero Image URL</label>
          <input v-model="form.hero_image_url" placeholder="https://..."
            style="width: 100%; padding: 12px 16px; border-radius: 10px; border: 1px solid rgba(24,28,29,0.1); background: #F7FAFB; font-size: 14px; color: #181C1D; outline: none; box-sizing: border-box; font-family: inherit; transition: border-color 0.2s;"
            @focus="$el.style.borderColor='#1B3022'; $el.style.boxShadow='0 0 0 3px rgba(27,48,34,0.1)'"
            @blur="$el.style.borderColor='rgba(24,28,29,0.1)'; $el.style.boxShadow='none'"
          />
        </div>
        <div style="background: white; border-radius: 16px; border: 1px solid rgba(24,28,29,0.08); padding: 24px;">
          <label style="display: block; font-size: 13px; font-weight: 600; color: #434843; margin-bottom: 6px;">Hero Video URL</label>
          <input v-model="form.hero_video_url" placeholder="https://..."
            style="width: 100%; padding: 12px 16px; border-radius: 10px; border: 1px solid rgba(24,28,29,0.1); background: #F7FAFB; font-size: 14px; color: #181C1D; outline: none; box-sizing: border-box; font-family: inherit; transition: border-color 0.2s;"
            @focus="$el.style.borderColor='#1B3022'; $el.style.boxShadow='0 0 0 3px rgba(27,48,34,0.1)'"
            @blur="$el.style.borderColor='rgba(24,28,29,0.1)'; $el.style.boxShadow='none'"
          />
        </div>
      </div>

      <!-- Published toggle + Save -->
      <div style="background: white; border-radius: 16px; border: 1px solid rgba(24,28,29,0.08); padding: 24px; display: flex; align-items: center; justify-content: space-between;">
        <label style="display: flex; align-items: center; gap: 10px; cursor: pointer; font-size: 14px; color: #434843; font-weight: 500;">
          <input v-model="form.published" type="checkbox"
            style="width: 18px; height: 18px; accent-color: #1B3022; border-radius: 4px; cursor: pointer;"
          />
          Published
        </label>
        <div style="display: flex; align-items: center; gap: 12px;">
          <span v-if="saved" style="font-size: 13px; font-weight: 600; color: #2E7D32;">Saved successfully!</span>
          <button type="submit" :disabled="saving"
            style="padding: 12px 28px; border: none; border-radius: 12px; background: #1B3022; color: white; font-size: 14px; font-weight: 600; cursor: pointer; transition: all 0.2s; opacity: 1;"
            :style="saving ? 'opacity: 0.6; cursor: not-allowed;' : ''"
            @mouseenter="!saving && ($el.style.opacity='0.9')" @mouseleave="!saving && ($el.style.opacity='1')"
          >
            {{ saving ? 'Saving...' : 'Save Changes' }}
          </button>
        </div>
      </div>
    </form>
  </div>
</template>
