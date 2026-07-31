<script setup lang="ts">
import { useSupabase } from '~/utils/supabase'
import { useStorage } from '~/composables/useStorage'

const supabase = useSupabase()
const { uploadFile } = useStorage()

const items = ref<any[]>([])
const loading = ref(true)
const saving = ref(false)
const showForm = ref(false)
const editingId = ref<string | null>(null)
const uploadState = ref<'idle' | 'uploading'>('idle')

const categoryOptions = ['production', 'factory', 'certifications', 'team']

const emptyForm = () => ({
  category: 'production',
  title: '',
  description: '',
  image: '',
  thumbnail: '',
  alt: '',
  type: 'image' as 'image' | 'video',
  sort_order: items.value.length + 1,
  published: true,
})

const form = reactive(emptyForm())

async function loadItems() {
  loading.value = true
  const { data } = await supabase.from('gallery_items').select('*').order('sort_order')
  if (data) items.value = data
  loading.value = false
}

function openNew() {
  editingId.value = null
  Object.assign(form, emptyForm())
  showForm.value = true
}

function openEdit(item: any) {
  editingId.value = item.id
  Object.assign(form, {
    category: item.category || 'production',
    title: item.title || '',
    description: item.description || '',
    image: item.image || '',
    thumbnail: item.thumbnail || '',
    alt: item.alt || '',
    type: item.type || 'image',
    sort_order: item.sort_order ?? items.value.length + 1,
    published: item.published ?? true,
  })
  showForm.value = true
}

function closeForm() {
  showForm.value = false
  editingId.value = null
}

async function save() {
  if (!form.title.trim()) return
  saving.value = true
  const record = {
    category: form.category,
    title: form.title,
    description: form.description,
    image: form.image || null,
    thumbnail: form.thumbnail || null,
    alt: form.alt,
    type: form.type,
    sort_order: form.sort_order,
    published: form.published,
  }
  if (editingId.value) {
    await supabase.from('gallery_items').update(record).eq('id', editingId.value)
  } else {
    await supabase.from('gallery_items').insert([record])
  }
  saving.value = false
  closeForm()
  await loadItems()
}

async function removeItem(item: any) {
  if (!confirm(`Delete "${item.title}"? This cannot be undone.`)) return
  await supabase.from('gallery_items').delete().eq('id', item.id)
  await loadItems()
}

async function handleImageUpload(event: Event) {
  const input = event.target as HTMLInputElement
  if (!input.files?.length) return
  const file = input.files[0]
  uploadState.value = 'uploading'
  const ext = file.name.split('.').pop() || 'jpg'
  const path = `gallery/${Date.now()}.${ext}`
  const url = await uploadFile(file, path)
  if (url) {
    form.image = url
    if (!form.thumbnail) form.thumbnail = url
  }
  uploadState.value = 'idle'
  input.value = ''
}

onMounted(loadItems)
</script>

<template>
  <div>
    <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 28px;">
      <div>
        <h1 style="font-family: 'Source Serif 4', serif; font-size: 24px; font-weight: 700; color: #1B3022; margin: 0;">Gallery</h1>
        <p style="font-size: 14px; color: #737973; margin: 4px 0 0;">Manage gallery images and videos</p>
      </div>
      <button @click="openNew"
        style="padding: 12px 24px; border-radius: 12px; background: #1B3022; color: white; font-size: 14px; font-weight: 600; cursor: pointer; border: none; transition: opacity 0.2s; display: flex; align-items: center; gap: 8px;"
        @mouseenter="$el.style.opacity='0.9'" @mouseleave="$el.style.opacity='1'"
      >
        <span style="font-size: 18px; line-height: 1;">+</span> Add Item
      </button>
    </div>

    <!-- Add/Edit Form -->
    <div v-if="showForm" style="background: white; border-radius: 16px; border: 1px solid rgba(24,28,29,0.08); padding: 24px; margin-bottom: 24px;">
      <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 16px;">
        <h2 style="font-family: 'Source Serif 4', serif; font-size: 18px; font-weight: 700; color: #1B3022; margin: 0;">{{ editingId ? 'Edit Gallery Item' : 'Add Gallery Item' }}</h2>
        <button @click="closeForm"
          style="padding: 6px 12px; border-radius: 8px; border: 1px solid rgba(24,28,29,0.1); background: transparent; color: #737973; font-size: 13px; cursor: pointer;"
          @mouseenter="$el.style.background='rgba(24,28,29,0.04)'" @mouseleave="$el.style.background='transparent'"
        >✕ Close</button>
      </div>

      <div class="adm-grid" style="display: grid; grid-template-columns: 1fr 1fr; gap: 14px; margin-bottom: 14px;">
        <div>
          <label style="display: block; font-size: 12px; font-weight: 600; color: #737973; margin-bottom: 5px;">Title *</label>
          <input v-model="form.title" required placeholder="e.g. Cocopeat Block Production"
            style="width: 100%; padding: 10px 14px; border-radius: 10px; border: 1px solid rgba(24,28,29,0.1); background: #F7FAFB; font-size: 14px; color: #181C1D; outline: none; box-sizing: border-box; font-family: inherit;"
          />
        </div>
        <div>
          <label style="display: block; font-size: 12px; font-weight: 600; color: #737973; margin-bottom: 5px;">Category</label>
          <select v-model="form.category"
            style="width: 100%; padding: 10px 14px; border-radius: 10px; border: 1px solid rgba(24,28,29,0.1); background: #F7FAFB; font-size: 14px; color: #181C1D; outline: none; cursor: pointer;"
          >
            <option v-for="cat in categoryOptions" :key="cat" :value="cat">{{ cat }}</option>
          </select>
        </div>
      </div>

      <div class="adm-grid" style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 14px; margin-bottom: 14px;">
        <div>
          <label style="display: block; font-size: 12px; font-weight: 600; color: #737973; margin-bottom: 5px;">Type</label>
          <select v-model="form.type"
            style="width: 100%; padding: 10px 14px; border-radius: 10px; border: 1px solid rgba(24,28,29,0.1); background: #F7FAFB; font-size: 14px; color: #181C1D; outline: none; cursor: pointer;"
          >
            <option value="image">Image</option>
            <option value="video">Video</option>
          </select>
        </div>
        <div>
          <label style="display: block; font-size: 12px; font-weight: 600; color: #737973; margin-bottom: 5px;">Sort Order</label>
          <input v-model.number="form.sort_order" type="number"
            style="width: 100%; padding: 10px 14px; border-radius: 10px; border: 1px solid rgba(24,28,29,0.1); background: #F7FAFB; font-size: 14px; color: #181C1D; outline: none; box-sizing: border-box; font-family: inherit;"
          />
        </div>
        <div>
          <label style="display: block; font-size: 12px; font-weight: 600; color: #737973; margin-bottom: 5px;">Alt Text</label>
          <input v-model="form.alt" placeholder="Accessibility text"
            style="width: 100%; padding: 10px 14px; border-radius: 10px; border: 1px solid rgba(24,28,29,0.1); background: #F7FAFB; font-size: 14px; color: #181C1D; outline: none; box-sizing: border-box; font-family: inherit;"
          />
        </div>
      </div>

      <div style="margin-bottom: 14px;">
        <label style="display: block; font-size: 12px; font-weight: 600; color: #737973; margin-bottom: 5px;">Description</label>
        <textarea v-model="form.description" rows="2" placeholder="Short description"
          style="width: 100%; padding: 10px 14px; border-radius: 10px; border: 1px solid rgba(24,28,29,0.1); background: #F7FAFB; font-size: 14px; color: #181C1D; outline: none; box-sizing: border-box; font-family: inherit; resize: vertical;"
        ></textarea>
      </div>

      <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 14px; margin-bottom: 14px;">
        <div>
          <label style="display: block; font-size: 12px; font-weight: 600; color: #737973; margin-bottom: 5px;">Image URL *</label>
          <input v-model="form.image" placeholder="https://..."
            style="width: 100%; padding: 10px 14px; border-radius: 10px; border: 1px solid rgba(24,28,29,0.1); background: #F7FAFB; font-size: 14px; color: #181C1D; outline: none; box-sizing: border-box; font-family: inherit;"
          />
        </div>
        <div style="display: flex; align-items: flex-end;">
          <label
            style="width: 100%; padding: 10px 14px; border-radius: 10px; background: #1B3022; color: white; font-size: 13px; font-weight: 600; cursor: pointer; transition: opacity 0.2s; text-align: center; box-sizing: border-box;"
            :style="uploadState === 'uploading' ? 'opacity: 0.6; pointer-events: none;' : ''"
            @mouseenter="uploadState !== 'uploading' && ($el.style.opacity='0.9')"
            @mouseleave="uploadState !== 'uploading' && ($el.style.opacity='1')"
          >
            {{ uploadState === 'uploading' ? 'Uploading...' : 'Upload Image' }}
            <input type="file" accept="image/*" hidden @change="handleImageUpload" />
          </label>
        </div>
      </div>

      <div style="display: flex; align-items: center; justify-content: space-between;">
        <label style="display: flex; align-items: center; gap: 10px; cursor: pointer; font-size: 14px; color: #434843; font-weight: 500;">
          <input v-model="form.published" type="checkbox"
            style="width: 18px; height: 18px; accent-color: #1B3022; border-radius: 4px; cursor: pointer;"
          />
          Published
        </label>
        <div style="display: flex; gap: 10px;">
          <button @click="closeForm"
            style="padding: 10px 20px; border-radius: 10px; border: 1px solid rgba(24,28,29,0.1); background: transparent; color: #434843; font-size: 13px; font-weight: 500; cursor: pointer;"
            @mouseenter="$el.style.background='rgba(24,28,29,0.04)'" @mouseleave="$el.style.background='transparent'"
          >Cancel</button>
          <button @click="save" :disabled="saving"
            style="padding: 10px 24px; border-radius: 10px; background: #1B3022; color: white; font-size: 13px; font-weight: 600; cursor: pointer; border: none; transition: opacity 0.2s;"
            :style="saving ? 'opacity: 0.6; cursor: not-allowed;' : ''"
            @mouseenter="!saving && ($el.style.opacity='0.9')" @mouseleave="!saving && ($el.style.opacity='1')"
          >{{ saving ? 'Saving...' : 'Save Item' }}</button>
        </div>
      </div>
    </div>

    <!-- Loading -->
    <div v-if="loading" style="text-align: center; padding: 48px 0;">
      <div style="width: 28px; height: 28px; border: 2px solid #1B3022; border-top-color: transparent; border-radius: 50%; animation: adminSpin 0.6s linear infinite; margin: 0 auto;"></div>
    </div>

    <!-- Empty -->
    <div v-else-if="items.length === 0" style="text-align: center; padding: 48px 0; color: #737973; font-size: 15px;">
      <p style="margin: 0;">No gallery items yet.</p>
      <button @click="openNew" style="color: #1B3022; font-weight: 600; font-size: 14px; margin-top: 8px; background: none; border: none; cursor: pointer; text-decoration: underline;">Add your first item →</button>
    </div>

    <!-- Cards -->
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
            <span v-if="!item.published" style="font-size: 11px; color: #737973; font-weight: 600;">○ Draft</span>
          </div>
          <p v-if="item.description" style="font-size: 13px; color: #737973; margin: 6px 0 0; line-height: 1.4;">{{ item.description }}</p>
          <div style="display: flex; gap: 8px; margin-top: 12px;">
            <button @click="openEdit(item)"
              style="flex: 1; padding: 8px; border-radius: 8px; border: 1px solid rgba(24,28,29,0.1); background: transparent; color: #434843; font-size: 13px; font-weight: 600; cursor: pointer; transition: all 0.15s;"
              @mouseenter="$el.style.background='rgba(27,48,34,0.06)'" @mouseleave="$el.style.background='transparent'"
            >Edit</button>
            <button @click="removeItem(item)"
              style="flex: 1; padding: 8px; border-radius: 8px; border: 1px solid rgba(186,26,26,0.15); background: transparent; color: #BA1A1A; font-size: 13px; font-weight: 600; cursor: pointer; transition: all 0.15s;"
              @mouseenter="$el.style.background='rgba(186,26,26,0.06)'" @mouseleave="$el.style.background='transparent'"
            >Delete</button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
