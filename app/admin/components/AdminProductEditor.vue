<script setup lang="ts">
import { useSupabase } from '~/utils/supabase'
import type { Product, ProductMedia } from '~/types'
import { useStorage } from '~/composables/useStorage'

const supabase = useSupabase()
const { uploadFile, deleteFile } = useStorage()

const props = defineProps<{ id: string }>()
const isNew = props.id === 'new'

const form = reactive({
  name: '',
  category: 'cocopeat' as 'cocopeat' | 'cocofiber',
  slug: '',
  short_description: '',
  description: '',
  moq: '',
  lead_time: '',
  origin: 'Indonesia',
  thumbnail: '',
  video_url: '',
  specifications: [] as { name: string; value: string; unit?: string }[],
  applications: [] as string[],
  published: true,
  media: [] as ProductMedia[],
})
const loading = ref(!isNew)
const saving = ref(false)
const saved = ref(false)
const uploadState = ref<'idle' | 'uploading'>('idle')
const mediaType = ref<'image' | 'video'>('image')

async function loadProduct() {
  const { data } = await supabase.from('products').select('*').eq('id', props.id).single()
  if (data) {
    form.name = data.name
    form.category = data.category
    form.slug = data.slug
    form.short_description = data.short_description || ''
    form.description = data.description || ''
    form.moq = data.moq || ''
    form.lead_time = data.lead_time || ''
    form.origin = data.origin || 'Indonesia'
    form.thumbnail = data.thumbnail || ''
    form.video_url = data.video_url || ''
    form.specifications = data.specifications || []
    form.applications = data.applications || []
    form.published = data.published
    form.media = data.media || []
  }
  loading.value = false
}

function generateSlug(name: string) {
  return name.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '')
}

watch(() => form.name, (val) => {
  if (isNew && val) form.slug = generateSlug(val)
})

async function handleFileUpload(event: Event) {
  const input = event.target as HTMLInputElement
  if (!input.files?.length) return
  const file = input.files[0]
  uploadState.value = 'uploading'

  const ext = file.name.split('.').pop() || 'jpg'
  const timestamp = Date.now()
  const path = `${form.slug || 'product'}/${timestamp}.${ext}`

  const url = await uploadFile(file, path)
  if (url) {
    form.media.push({ type: mediaType.value, url })
  }
  uploadState.value = 'idle'
  input.value = ''
}

async function removeMedia(index: number) {
  const item = form.media[index]
  await deleteFile(item.url)
  form.media.splice(index, 1)
}

function moveMedia(from: number, to: number) {
  if (to < 0 || to >= form.media.length) return
  const [item] = form.media.splice(from, 1)
  form.media.splice(to, 0, item)
}

async function save() {
  saving.value = true
  const specs = form.specifications
  const apps = form.applications
  const record = {
    name: form.name,
    category: form.category,
    slug: form.slug,
    short_description: form.short_description,
    description: form.description,
    moq: form.moq,
    lead_time: form.lead_time,
    origin: form.origin,
    thumbnail: form.thumbnail || null,
    video_url: form.video_url || null,
    specifications: specs,
    applications: apps,
    published: form.published,
    media: form.media,
  }
  if (isNew) {
    await supabase.from('products').insert([record])
  } else {
    await supabase.from('products').update(record).eq('id', props.id)
  }
  saving.value = false
  saved.value = true
  setTimeout(() => saved.value = false, 3000)
}

onMounted(() => { if (!isNew) loadProduct() })
</script>

<template>
  <div>
    <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 28px;">
      <div>
        <h1 style="font-family: 'Source Serif 4', serif; font-size: 24px; font-weight: 700; color: #1B3022; margin: 0;">{{ isNew ? 'Add Product' : 'Edit Product' }}</h1>
        <p style="font-size: 14px; color: #737973; margin: 4px 0 0;">{{ isNew ? 'Create a new product listing' : 'Update product details' }}</p>
      </div>
      <NuxtLink to="../products"
        style="padding: 10px 20px; border-radius: 10px; border: 1px solid rgba(24,28,29,0.1); color: #434843; font-size: 13px; font-weight: 500; text-decoration: none; transition: all 0.15s;"
        @mouseenter="$el.style.background='rgba(27,48,34,0.04)'" @mouseleave="$el.style.background='transparent'"
      >← Back to Products</NuxtLink>
    </div>

    <div v-if="loading" style="text-align: center; padding: 48px 0;">
      <div style="width: 28px; height: 28px; border: 2px solid #1B3022; border-top-color: transparent; border-radius: 50%; animation: adminSpin 0.6s linear infinite; margin: 0 auto;"></div>
    </div>

    <form v-else @submit.prevent="save" style="max-width: 720px; display: flex; flex-direction: column; gap: 20px;">
      <!-- Name + Category -->
      <div style="background: white; border-radius: 16px; border: 1px solid rgba(24,28,29,0.08); padding: 24px; display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
        <div>
          <label style="display: block; font-size: 13px; font-weight: 600; color: #434843; margin-bottom: 6px;">Name *</label>
          <input v-model="form.name" required
            style="width: 100%; padding: 12px 16px; border-radius: 10px; border: 1px solid rgba(24,28,29,0.1); background: #F7FAFB; font-size: 15px; color: #181C1D; outline: none; box-sizing: border-box; font-family: inherit; transition: border-color 0.2s;"
            @focus="$el.style.borderColor='#1B3022'; $el.style.boxShadow='0 0 0 3px rgba(27,48,34,0.1)'"
            @blur="$el.style.borderColor='rgba(24,28,29,0.1)'; $el.style.boxShadow='none'"
          />
        </div>
        <div>
          <label style="display: block; font-size: 13px; font-weight: 600; color: #434843; margin-bottom: 6px;">Category *</label>
          <select v-model="form.category"
            style="width: 100%; padding: 12px 16px; border-radius: 10px; border: 1px solid rgba(24,28,29,0.1); background: #F7FAFB; font-size: 15px; color: #181C1D; outline: none; box-sizing: border-box; font-family: inherit; cursor: pointer; transition: border-color 0.2s;"
            @focus="$el.style.borderColor='#1B3022'"
            @blur="$el.style.borderColor='rgba(24,28,29,0.1)'"
          >
            <option value="cocopeat">Cocopeat</option>
            <option value="cocofiber">Cocofiber</option>
          </select>
        </div>
      </div>

      <!-- Slug + Origin -->
      <div style="background: white; border-radius: 16px; border: 1px solid rgba(24,28,29,0.08); padding: 24px; display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
        <div>
          <label style="display: block; font-size: 13px; font-weight: 600; color: #434843; margin-bottom: 6px;">Slug *</label>
          <input v-model="form.slug" required
            style="width: 100%; padding: 12px 16px; border-radius: 10px; border: 1px solid rgba(24,28,29,0.1); background: #F7FAFB; font-size: 15px; color: #181C1D; outline: none; box-sizing: border-box; font-family: inherit; transition: border-color 0.2s;"
            @focus="$el.style.borderColor='#1B3022'; $el.style.boxShadow='0 0 0 3px rgba(27,48,34,0.1)'"
            @blur="$el.style.borderColor='rgba(24,28,29,0.1)'; $el.style.boxShadow='none'"
          />
        </div>
        <div>
          <label style="display: block; font-size: 13px; font-weight: 600; color: #434843; margin-bottom: 6px;">Origin</label>
          <input v-model="form.origin"
            style="width: 100%; padding: 12px 16px; border-radius: 10px; border: 1px solid rgba(24,28,29,0.1); background: #F7FAFB; font-size: 15px; color: #181C1D; outline: none; box-sizing: border-box; font-family: inherit; transition: border-color 0.2s;"
            @focus="$el.style.borderColor='#1B3022'; $el.style.boxShadow='0 0 0 3px rgba(27,48,34,0.1)'"
            @blur="$el.style.borderColor='rgba(24,28,29,0.1)'; $el.style.boxShadow='none'"
          />
        </div>
      </div>

      <!-- Short Description -->
      <div style="background: white; border-radius: 16px; border: 1px solid rgba(24,28,29,0.08); padding: 24px;">
        <label style="display: block; font-size: 13px; font-weight: 600; color: #434843; margin-bottom: 6px;">Short Description</label>
        <textarea v-model="form.short_description" rows="2"
          style="width: 100%; padding: 12px 16px; border-radius: 10px; border: 1px solid rgba(24,28,29,0.1); background: #F7FAFB; font-size: 15px; color: #181C1D; outline: none; box-sizing: border-box; font-family: inherit; resize: vertical; transition: border-color 0.2s;"
          @focus="$el.style.borderColor='#1B3022'; $el.style.boxShadow='0 0 0 3px rgba(27,48,34,0.1)'"
          @blur="$el.style.borderColor='rgba(24,28,29,0.1)'; $el.style.boxShadow='none'"
        ></textarea>
      </div>

      <!-- Full Description -->
      <div style="background: white; border-radius: 16px; border: 1px solid rgba(24,28,29,0.08); padding: 24px;">
        <label style="display: block; font-size: 13px; font-weight: 600; color: #434843; margin-bottom: 6px;">Description</label>
        <textarea v-model="form.description" rows="4"
          style="width: 100%; padding: 12px 16px; border-radius: 10px; border: 1px solid rgba(24,28,29,0.1); background: #F7FAFB; font-size: 15px; color: #181C1D; outline: none; box-sizing: border-box; font-family: inherit; resize: vertical; transition: border-color 0.2s;"
          @focus="$el.style.borderColor='#1B3022'; $el.style.boxShadow='0 0 0 3px rgba(27,48,34,0.1)'"
          @blur="$el.style.borderColor='rgba(24,28,29,0.1)'; $el.style.boxShadow='none'"
        ></textarea>
      </div>

      <!-- Thumbnail + Video -->
      <div style="background: white; border-radius: 16px; border: 1px solid rgba(24,28,29,0.08); padding: 24px; display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
        <div>
          <label style="display: block; font-size: 13px; font-weight: 600; color: #434843; margin-bottom: 6px;">Thumbnail URL</label>
          <input v-model="form.thumbnail" placeholder="https://..."
            style="width: 100%; padding: 12px 16px; border-radius: 10px; border: 1px solid rgba(24,28,29,0.1); background: #F7FAFB; font-size: 14px; color: #181C1D; outline: none; box-sizing: border-box; font-family: inherit; transition: border-color 0.2s;"
            @focus="$el.style.borderColor='#1B3022'; $el.style.boxShadow='0 0 0 3px rgba(27,48,34,0.1)'"
            @blur="$el.style.borderColor='rgba(24,28,29,0.1)'; $el.style.boxShadow='none'"
          />
        </div>
        <div>
          <label style="display: block; font-size: 13px; font-weight: 600; color: #434843; margin-bottom: 6px;">Video URL</label>
          <input v-model="form.video_url" placeholder="https://..."
            style="width: 100%; padding: 12px 16px; border-radius: 10px; border: 1px solid rgba(24,28,29,0.1); background: #F7FAFB; font-size: 14px; color: #181C1D; outline: none; box-sizing: border-box; font-family: inherit; transition: border-color 0.2s;"
            @focus="$el.style.borderColor='#1B3022'; $el.style.boxShadow='0 0 0 3px rgba(27,48,34,0.1)'"
            @blur="$el.style.borderColor='rgba(24,28,29,0.1)'; $el.style.boxShadow='none'"
          />
        </div>
      </div>

      <!-- Product Media Manager -->
      <div style="background: white; border-radius: 16px; border: 1px solid rgba(24,28,29,0.08); padding: 24px;">
        <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 16px;">
          <div>
            <label style="font-size: 13px; font-weight: 600; color: #434843;">Product Media</label>
            <p style="font-size: 12px; color: #737973; margin: 2px 0 0;">Images and videos shown in the product gallery</p>
          </div>
          <div style="display: flex; align-items: center; gap: 8px;">
            <select v-model="mediaType"
              style="padding: 8px 12px; border-radius: 8px; border: 1px solid rgba(24,28,29,0.1); background: #F7FAFB; font-size: 13px; color: #434843; outline: none; cursor: pointer;"
            >
              <option value="image">Image</option>
              <option value="video">Video</option>
            </select>
            <label
              style="padding: 8px 16px; border-radius: 8px; background: #1B3022; color: white; font-size: 13px; font-weight: 600; cursor: pointer; transition: opacity 0.2s; display: flex; align-items: center; gap: 6px;"
              :style="uploadState === 'uploading' ? 'opacity: 0.6; pointer-events: none;' : ''"
              @mouseenter="uploadState !== 'uploading' && ($el.style.opacity='0.9')"
              @mouseleave="uploadState !== 'uploading' && ($el.style.opacity='1')"
            >
              {{ uploadState === 'uploading' ? 'Uploading...' : '+ Add' }}
              <input type="file" accept="image/*,video/mp4" hidden @change="handleFileUpload" />
            </label>
          </div>
        </div>

        <div v-if="form.media.length === 0" style="text-align: center; padding: 32px; background: #F7FAFB; border-radius: 12px; border: 1px dashed rgba(24,28,29,0.15);">
          <p style="font-size: 13px; color: #737973; margin: 0;">No media yet. Click "+ Add" to upload an image or video.</p>
        </div>

        <div v-else style="display: flex; flex-direction: column; gap: 8px;">
          <div v-for="(item, index) in form.media" :key="index"
            style="display: flex; align-items: center; gap: 12px; padding: 12px; background: #F7FAFB; border-radius: 12px; border: 1px solid rgba(24,28,29,0.06); transition: all 0.15s;"
            @mouseenter="$el.style.borderColor='rgba(27,48,34,0.2)'" @mouseleave="$el.style.borderColor='rgba(24,28,29,0.06)'"
          >
            <div style="width: 56px; height: 56px; border-radius: 8px; overflow: hidden; flex-shrink: 0; background: rgba(24,28,29,0.04); display: flex; align-items: center; justify-content: center;">
              <img v-if="item.type === 'image'" :src="item.url" style="width: 100%; height: 100%; object-fit: cover;" loading="lazy" />
              <span v-else style="font-size: 24px;">🎬</span>
            </div>
            <div style="flex: 1; min-width: 0;">
              <span style="display: inline-block; padding: 2px 8px; border-radius: 4px; font-size: 11px; font-weight: 600; text-transform: uppercase; background: rgba(27,48,34,0.08); color: #1B3022; margin-bottom: 4px;">{{ item.type }}</span>
              <p style="font-size: 12px; color: #737973; margin: 0; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">{{ item.url }}</p>
            </div>
            <div style="display: flex; gap: 4px; flex-shrink: 0;">
              <button type="button" @click="moveMedia(index, index - 1)" :disabled="index === 0"
                style="padding: 6px 8px; border: none; border-radius: 6px; background: transparent; cursor: pointer; font-size: 14px; transition: background 0.15s;"
                :style="index === 0 ? 'opacity: 0.3; cursor: not-allowed;' : ''"
                @mouseenter="index > 0 && ($el.style.background='rgba(27,48,34,0.06)')" @mouseleave="index > 0 && ($el.style.background='transparent')"
              >↑</button>
              <button type="button" @click="moveMedia(index, index + 1)" :disabled="index === form.media.length - 1"
                style="padding: 6px 8px; border: none; border-radius: 6px; background: transparent; cursor: pointer; font-size: 14px; transition: background 0.15s;"
                :style="index === form.media.length - 1 ? 'opacity: 0.3; cursor: not-allowed;' : ''"
                @mouseenter="index < form.media.length - 1 && ($el.style.background='rgba(27,48,34,0.06)')" @mouseleave="index < form.media.length - 1 && ($el.style.background='transparent')"
              >↓</button>
              <button type="button" @click="removeMedia(index)"
                style="padding: 6px 8px; border: none; border-radius: 6px; background: transparent; color: #BA1A1A; cursor: pointer; font-size: 14px; transition: background 0.15s;"
                @mouseenter="$el.style.background='rgba(186,26,26,0.08)'" @mouseleave="$el.style.background='transparent'"
              >✕</button>
            </div>
          </div>
        </div>
      </div>

      <!-- MOQ + Lead Time -->
      <div style="background: white; border-radius: 16px; border: 1px solid rgba(24,28,29,0.08); padding: 24px; display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
        <div>
          <label style="display: block; font-size: 13px; font-weight: 600; color: #434843; margin-bottom: 6px;">MOQ</label>
          <input v-model="form.moq" placeholder="e.g. 100 kg"
            style="width: 100%; padding: 12px 16px; border-radius: 10px; border: 1px solid rgba(24,28,29,0.1); background: #F7FAFB; font-size: 15px; color: #181C1D; outline: none; box-sizing: border-box; font-family: inherit; transition: border-color 0.2s;"
            @focus="$el.style.borderColor='#1B3022'; $el.style.boxShadow='0 0 0 3px rgba(27,48,34,0.1)'"
            @blur="$el.style.borderColor='rgba(24,28,29,0.1)'; $el.style.boxShadow='none'"
          />
        </div>
        <div>
          <label style="display: block; font-size: 13px; font-weight: 600; color: #434843; margin-bottom: 6px;">Lead Time</label>
          <input v-model="form.lead_time" placeholder="e.g. 7-14 days"
            style="width: 100%; padding: 12px 16px; border-radius: 10px; border: 1px solid rgba(24,28,29,0.1); background: #F7FAFB; font-size: 15px; color: #181C1D; outline: none; box-sizing: border-box; font-family: inherit; transition: border-color 0.2s;"
            @focus="$el.style.borderColor='#1B3022'; $el.style.boxShadow='0 0 0 3px rgba(27,48,34,0.1)'"
            @blur="$el.style.borderColor='rgba(24,28,29,0.1)'; $el.style.boxShadow='none'"
          />
        </div>
      </div>

      <!-- Specifications -->
      <div style="background: white; border-radius: 16px; border: 1px solid rgba(24,28,29,0.08); padding: 24px;">
        <SpecsEditor v-model="form.specifications" />
      </div>

      <!-- Applications -->
      <div style="background: white; border-radius: 16px; border: 1px solid rgba(24,28,29,0.08); padding: 24px;">
        <TagsEditor v-model="form.applications" />
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
