<script setup lang="ts">
import { useSupabase } from '~/utils/supabase'
import ValuesCardsEditor from '~/admin/components/editors/ValuesCardsEditor.vue'

const supabase = useSupabase()

const form = reactive({
  title: '',
  mission: '',
  vision: '',
  values: [] as { icon: string; title: string; description: string }[],
  hero_video_url: '',
  hero_image_url: '',
  published: true,
})
const loading = ref(true)
const saving = ref(false)
const saved = ref(false)

onMounted(async () => {
  const { data } = await supabase.from('about_section').select('*').single()
  if (data) {
    form.title = data.title || ''
    form.mission = data.mission || ''
    form.vision = data.vision || ''
    form.values = data.values || []
    form.hero_video_url = data.hero_video_url || ''
    form.hero_image_url = data.hero_image_url || ''
    form.published = data.published ?? true
  }
  loading.value = false
})

async function save() {
  saving.value = true
  const values = form.values
  await supabase.from('about_section').update({
    title: form.title,
    mission: form.mission,
    vision: form.vision,
    values,
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
      <h1 style="font-family: 'Source Serif 4', serif; font-size: 24px; font-weight: 700; color: #1B3022; margin: 0;">About Section</h1>
      <p style="font-size: 14px; color: #737973; margin: 4px 0 0;">Manage mission, vision, company values, and hero media</p>
    </div>

    <div v-if="loading" style="text-align: center; padding: 48px 0;">
      <div style="width: 28px; height: 28px; border: 2px solid #1B3022; border-top-color: transparent; border-radius: 50%; animation: adminSpin 0.6s linear infinite; margin: 0 auto;"></div>
    </div>

    <form v-else @submit.prevent="save" style="max-width: 720px; display: flex; flex-direction: column; gap: 20px;">
      <!-- Title -->
      <div style="background: white; border-radius: 16px; border: 1px solid rgba(24,28,29,0.08); padding: 24px;">
        <label style="display: block; font-size: 13px; font-weight: 600; color: #434843; margin-bottom: 6px;">Section Title</label>
        <input v-model="form.title" required
          style="width: 100%; padding: 12px 16px; border-radius: 10px; border: 1px solid rgba(24,28,29,0.1); background: #F7FAFB; font-size: 15px; color: #181C1D; outline: none; box-sizing: border-box; font-family: inherit; transition: border-color 0.2s;"
          @focus="$el.style.borderColor='#1B3022'; $el.style.boxShadow='0 0 0 3px rgba(27,48,34,0.1)'"
          @blur="$el.style.borderColor='rgba(24,28,29,0.1)'; $el.style.boxShadow='none'"
        />
      </div>

      <!-- Mission + Vision -->
      <div class="adm-grid" style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
        <div style="background: white; border-radius: 16px; border: 1px solid rgba(24,28,29,0.08); padding: 24px;">
          <label style="display: block; font-size: 13px; font-weight: 600; color: #434843; margin-bottom: 6px;">Mission</label>
          <textarea v-model="form.mission" rows="3"
            style="width: 100%; padding: 12px 16px; border-radius: 10px; border: 1px solid rgba(24,28,29,0.1); background: #F7FAFB; font-size: 15px; color: #181C1D; outline: none; box-sizing: border-box; font-family: inherit; resize: vertical; transition: border-color 0.2s;"
            @focus="$el.style.borderColor='#1B3022'; $el.style.boxShadow='0 0 0 3px rgba(27,48,34,0.1)'"
            @blur="$el.style.borderColor='rgba(24,28,29,0.1)'; $el.style.boxShadow='none'"
          ></textarea>
        </div>
        <div style="background: white; border-radius: 16px; border: 1px solid rgba(24,28,29,0.08); padding: 24px;">
          <label style="display: block; font-size: 13px; font-weight: 600; color: #434843; margin-bottom: 6px;">Vision</label>
          <textarea v-model="form.vision" rows="3"
            style="width: 100%; padding: 12px 16px; border-radius: 10px; border: 1px solid rgba(24,28,29,0.1); background: #F7FAFB; font-size: 15px; color: #181C1D; outline: none; box-sizing: border-box; font-family: inherit; resize: vertical; transition: border-color 0.2s;"
            @focus="$el.style.borderColor='#1B3022'; $el.style.boxShadow='0 0 0 3px rgba(27,48,34,0.1)'"
            @blur="$el.style.borderColor='rgba(24,28,29,0.1)'; $el.style.boxShadow='none'"
          ></textarea>
        </div>
      </div>

      <!-- Hero URLs -->
      <div class="adm-grid" style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
        <div style="background: white; border-radius: 16px; border: 1px solid rgba(24,28,29,0.08); padding: 24px;">
          <label style="display: block; font-size: 13px; font-weight: 600; color: #434843; margin-bottom: 6px;">Background Image URL</label>
          <input v-model="form.hero_image_url" placeholder="https://..."
            style="width: 100%; padding: 12px 16px; border-radius: 10px; border: 1px solid rgba(24,28,29,0.1); background: #F7FAFB; font-size: 14px; color: #181C1D; outline: none; box-sizing: border-box; font-family: inherit; transition: border-color 0.2s;"
            @focus="$el.style.borderColor='#1B3022'; $el.style.boxShadow='0 0 0 3px rgba(27,48,34,0.1)'"
            @blur="$el.style.borderColor='rgba(24,28,29,0.1)'; $el.style.boxShadow='none'"
          />
        </div>
        <div style="background: white; border-radius: 16px; border: 1px solid rgba(24,28,29,0.08); padding: 24px;">
          <label style="display: block; font-size: 13px; font-weight: 600; color: #434843; margin-bottom: 6px;">Background Video URL</label>
          <input v-model="form.hero_video_url" placeholder="https://..."
            style="width: 100%; padding: 12px 16px; border-radius: 10px; border: 1px solid rgba(24,28,29,0.1); background: #F7FAFB; font-size: 14px; color: #181C1D; outline: none; box-sizing: border-box; font-family: inherit; transition: border-color 0.2s;"
            @focus="$el.style.borderColor='#1B3022'; $el.style.boxShadow='0 0 0 3px rgba(27,48,34,0.1)'"
            @blur="$el.style.borderColor='rgba(24,28,29,0.1)'; $el.style.boxShadow='none'"
          />
        </div>
      </div>

      <!-- Values -->
      <div style="background: white; border-radius: 16px; border: 1px solid rgba(24,28,29,0.08); padding: 24px;">
        <ValuesCardsEditor v-model="form.values" />
      </div>

      <!-- Published + Save -->
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
            style="padding: 12px 28px; border: none; border-radius: 12px; background: #1B3022; color: white; font-size: 14px; font-weight: 600; cursor: pointer; transition: all 0.2s;"
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
