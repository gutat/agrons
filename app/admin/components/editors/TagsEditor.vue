<script setup lang="ts">
// Chip editor for localized string arrays (applications: [{en, id}, ...])
const model = defineModel<any[]>({ default: [] })

const newEn = ref('')
const newId = ref('')

function addTag() {
  const en = newEn.value.trim()
  const id = newId.value.trim()
  if (!en) return
  model.value.push({ en, id })
  newEn.value = ''
  newId.value = ''
}

function removeTag(index: number) {
  model.value.splice(index, 1)
}

function onKeydown(e: KeyboardEvent) {
  if (e.key === 'Enter' || e.key === ',') {
    e.preventDefault()
    addTag()
  }
}
</script>

<template>
  <div>
    <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 12px;">
      <label style="font-size: 13px; font-weight: 600; color: #434843;">Applications</label>
    </div>

    <div class="adm-tag-add" style="display: flex; align-items: center; gap: 8px; margin-bottom: 12px;">
      <div style="flex: 1; min-width: 0; position: relative;">
        <span style="position: absolute; top: 10px; left: 12px; font-size: 10px; font-weight: 700; color: #737973; letter-spacing: 0.05em;">EN</span>
        <input v-model="newEn" placeholder="English (e.g. Greenhouse growing)"
          @keydown="onKeydown"
          style="width: 100%; padding: 10px 14px 10px 40px; border-radius: 10px; border: 1px solid rgba(24,28,29,0.1); background: #F7FAFB; font-size: 13px; color: #181C1D; outline: none; box-sizing: border-box; font-family: inherit;"
        />
      </div>
      <div style="flex: 1; min-width: 0; position: relative;">
        <span style="position: absolute; top: 10px; left: 12px; font-size: 10px; font-weight: 700; color: #7E562E; letter-spacing: 0.05em;">ID</span>
        <input v-model="newId" placeholder="Indonesia (optional)"
          @keydown="onKeydown"
          style="width: 100%; padding: 10px 14px 10px 40px; border-radius: 10px; border: 1px solid rgba(24,28,29,0.1); background: #F7FAFB; font-size: 13px; color: #181C1D; outline: none; box-sizing: border-box; font-family: inherit;"
        />
      </div>
      <button type="button" @click="addTag"
        style="padding: 10px 16px; border-radius: 10px; background: #1B3022; color: white; font-size: 13px; font-weight: 600; cursor: pointer; border: none; transition: opacity 0.2s;"
        @mouseenter="$el.style.opacity='0.9'" @mouseleave="$el.style.opacity='1'"
      >Add</button>
    </div>

    <div v-if="model.length === 0" style="text-align: center; padding: 24px; background: #F7FAFB; border-radius: 12px; border: 1px dashed rgba(24,28,29,0.15);">
      <p style="font-size: 13px; color: #737973; margin: 0;">No applications yet.</p>
    </div>

    <div v-else style="display: flex; flex-wrap: wrap; gap: 8px;">
      <span v-for="(tag, index) in model" :key="index"
        style="display: inline-flex; align-items: center; gap: 6px; padding: 6px 10px 6px 14px; border-radius: 100px; background: rgba(27,48,34,0.08); color: #1B3022; font-size: 13px; font-weight: 500;"
      >
        {{ typeof tag === 'string' ? tag : tag.en }}
        <span v-if="typeof tag !== 'string' && tag.id" style="color: #7E562E; font-weight: 600;">/ {{ tag.id }}</span>
        <button type="button" @click="removeTag(index)"
          style="width: 18px; height: 18px; border: none; border-radius: 50%; background: rgba(27,48,34,0.12); color: #1B3022; cursor: pointer; font-size: 11px; line-height: 1; display: flex; align-items: center; justify-content: center; transition: background 0.15s;"
          @mouseenter="$el.style.background='rgba(27,48,34,0.25)'" @mouseleave="$el.style.background='rgba(27,48,34,0.12)'"
        >✕</button>
      </span>
    </div>
  </div>
</template>
