<script setup lang="ts">
import { useSupabase } from '~/utils/supabase'
import KeyValueEditor from '~/admin/components/editors/KeyValueEditor.vue'

const supabase = useSupabase()

const form = reactive({
  name: '',
  logo_url: '',
  contact: {
    address: '',
    phone: '',
    email: '',
    whatsapp: '',
  },
  social: {} as Record<string, string>,
})
const loading = ref(true)
const saving = ref(false)
const saved = ref(false)

onMounted(async () => {
  try {
    const { data, error } = await supabase.from('company_info').select('*').maybeSingle()
    if (error) {
      console.error('company_info load failed:', error)
    } else if (data) {
      form.name = data.name || ''
      form.logo_url = data.logo_url || ''
      form.contact = { address: '', phone: '', email: '', whatsapp: '', ...(data.contact || {}) }
      form.social = data.social || {}
    }
  } catch (e) {
    console.error('company_info load failed:', e)
  } finally {
    loading.value = false
  }
})

async function save() {
  saving.value = true
  const contact = form.contact
  const social = form.social
  await supabase.from('company_info').update({
    name: form.name,
    logo_url: form.logo_url || null,
    contact,
    social,
  }).eq('id', 1)
  saving.value = false
  saved.value = true
  setTimeout(() => saved.value = false, 3000)
}
</script>

<template>
  <div>
    <div style="margin-bottom: 28px;">
      <h1 style="font-family: 'Source Serif 4', serif; font-size: 24px; font-weight: 700; color: #1B3022; margin: 0;">Company Info</h1>
      <p style="font-size: 14px; color: #737973; margin: 4px 0 0;">Manage company name, logo, contact details, and social media links</p>
    </div>

    <div v-if="loading" style="text-align: center; padding: 48px 0;">
      <div style="width: 28px; height: 28px; border: 2px solid #1B3022; border-top-color: transparent; border-radius: 50%; animation: adminSpin 0.6s linear infinite; margin: 0 auto;"></div>
    </div>

    <form v-else @submit.prevent="save" style="width: 100%; display: flex; flex-direction: column; gap: 20px;">
      <!-- Name + Logo -->
      <div class="adm-grid" style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
        <div style="background: white; border-radius: 16px; border: 1px solid rgba(24,28,29,0.08); padding: 24px;">
          <label style="display: block; font-size: 13px; font-weight: 600; color: #434843; margin-bottom: 6px;">Company Name</label>
          <input v-model="form.name"
            style="width: 100%; padding: 12px 16px; border-radius: 10px; border: 1px solid rgba(24,28,29,0.1); background: #F7FAFB; font-size: 15px; color: #181C1D; outline: none; box-sizing: border-box; font-family: inherit; transition: border-color 0.2s;"
            @focus="$el.style.borderColor='#1B3022'; $el.style.boxShadow='0 0 0 3px rgba(27,48,34,0.1)'"
            @blur="$el.style.borderColor='rgba(24,28,29,0.1)'; $el.style.boxShadow='none'"
          />
        </div>
        <div style="background: white; border-radius: 16px; border: 1px solid rgba(24,28,29,0.08); padding: 24px;">
          <label style="display: block; font-size: 13px; font-weight: 600; color: #434843; margin-bottom: 6px;">Logo URL</label>
          <input v-model="form.logo_url" placeholder="https://..."
            style="width: 100%; padding: 12px 16px; border-radius: 10px; border: 1px solid rgba(24,28,29,0.1); background: #F7FAFB; font-size: 14px; color: #181C1D; outline: none; box-sizing: border-box; font-family: inherit; transition: border-color 0.2s;"
            @focus="$el.style.borderColor='#1B3022'; $el.style.boxShadow='0 0 0 3px rgba(27,48,34,0.1)'"
            @blur="$el.style.borderColor='rgba(24,28,29,0.1)'; $el.style.boxShadow='none'"
          />
        </div>
      </div>

      <!-- Contact Info -->
      <div style="background: white; border-radius: 16px; border: 1px solid rgba(24,28,29,0.08); padding: 24px;">
        <label style="display: block; font-size: 13px; font-weight: 600; color: #434843; margin-bottom: 14px;">Contact Info</label>
        <div class="adm-grid" style="display: grid; grid-template-columns: 1fr 1fr; gap: 14px;">
          <div>
            <label style="display: block; font-size: 12px; font-weight: 600; color: #737973; margin-bottom: 5px;">Address</label>
            <input v-model="form.contact.address" placeholder="e.g. Pekanbaru, Indonesia"
              style="width: 100%; padding: 10px 14px; border-radius: 10px; border: 1px solid rgba(24,28,29,0.1); background: #F7FAFB; font-size: 14px; color: #181C1D; outline: none; box-sizing: border-box; font-family: inherit;"
            />
          </div>
          <div>
            <label style="display: block; font-size: 12px; font-weight: 600; color: #737973; margin-bottom: 5px;">Phone</label>
            <input v-model="form.contact.phone" placeholder="e.g. +62"
              style="width: 100%; padding: 10px 14px; border-radius: 10px; border: 1px solid rgba(24,28,29,0.1); background: #F7FAFB; font-size: 14px; color: #181C1D; outline: none; box-sizing: border-box; font-family: inherit;"
            />
          </div>
          <div>
            <label style="display: block; font-size: 12px; font-weight: 600; color: #737973; margin-bottom: 5px;">Email</label>
            <input v-model="form.contact.email" type="email" placeholder="e.g. export@agronusa.co.id"
              style="width: 100%; padding: 10px 14px; border-radius: 10px; border: 1px solid rgba(24,28,29,0.1); background: #F7FAFB; font-size: 14px; color: #181C1D; outline: none; box-sizing: border-box; font-family: inherit;"
            />
          </div>
          <div>
            <label style="display: block; font-size: 12px; font-weight: 600; color: #737973; margin-bottom: 5px;">WhatsApp</label>
            <input v-model="form.contact.whatsapp" placeholder="e.g. +62"
              style="width: 100%; padding: 10px 14px; border-radius: 10px; border: 1px solid rgba(24,28,29,0.1); background: #F7FAFB; font-size: 14px; color: #181C1D; outline: none; box-sizing: border-box; font-family: inherit;"
            />
          </div>
        </div>
      </div>

      <!-- Social Media Links -->
      <div style="background: white; border-radius: 16px; border: 1px solid rgba(24,28,29,0.08); padding: 24px;">
        <KeyValueEditor v-model="form.social" title="Social Media Links" key-placeholder="platform (linkedin, instagram, facebook, youtube, twitter/x, whatsapp, tiktok, telegram)" value-placeholder="url (e.g. https://linkedin.com/company/...)" />
      </div>

      <!-- Save -->
      <div style="background: white; border-radius: 16px; border: 1px solid rgba(24,28,29,0.08); padding: 24px; display: flex; align-items: center; justify-content: flex-end;">
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
