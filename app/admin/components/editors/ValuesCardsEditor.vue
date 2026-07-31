<script setup lang="ts">
// Card editor for company values: [{ icon, title, description }, ...]
const model = defineModel<{ icon: string; title: string; description: string }[]>({ default: [] })

const newItem = reactive({ icon: '', title: '', description: '' })

function addItem() {
  if (!newItem.title.trim()) return
  model.value.push({ ...newItem })
  newItem.icon = ''
  newItem.title = ''
  newItem.description = ''
}

function removeItem(index: number) {
  model.value.splice(index, 1)
}

function moveItem(from: number, to: number) {
  if (to < 0 || to >= model.value.length) return
  const [item] = model.value.splice(from, 1)
  model.value.splice(to, 0, item)
}

const iconOptions = ['leaf', 'shield', 'users', 'globe', 'clock', 'handshake', 'star', 'award', 'heart', 'seedling']
</script>

<template>
  <div>
    <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 12px;">
      <label style="font-size: 13px; font-weight: 600; color: #434843;">Company Values</label>
    </div>

    <!-- Add new value card -->
    <div style="padding: 16px; background: #F7FAFB; border-radius: 12px; border: 1px dashed rgba(27,48,34,0.2); margin-bottom: 12px;">
      <p style="font-size: 12px; font-weight: 600; color: #1B3022; margin: 0 0 10px;">Add New Value</p>
      <div style="display: grid; grid-template-columns: 1fr 2fr; gap: 8px; margin-bottom: 8px;">
        <select v-model="newItem.icon"
          style="padding: 8px 12px; border-radius: 8px; border: 1px solid rgba(24,28,29,0.1); background: white; font-size: 13px; color: #181C1D; outline: none; cursor: pointer;"
        >
          <option value="" disabled>Icon…</option>
          <option v-for="opt in iconOptions" :key="opt" :value="opt">{{ opt }}</option>
        </select>
        <input v-model="newItem.title" placeholder="Title (e.g. Sustainability)"
          style="padding: 8px 12px; border-radius: 8px; border: 1px solid rgba(24,28,29,0.1); background: white; font-size: 13px; color: #181C1D; outline: none; box-sizing: border-box; font-family: inherit;"
        />
      </div>
      <textarea v-model="newItem.description" placeholder="Description (e.g. Zero-waste coconut processing)"
        rows="2"
        style="width: 100%; padding: 8px 12px; border-radius: 8px; border: 1px solid rgba(24,28,29,0.1); background: white; font-size: 13px; color: #181C1D; outline: none; box-sizing: border-box; font-family: inherit; resize: vertical; margin-bottom: 8px;"
      ></textarea>
      <button type="button" @click="addItem"
        style="padding: 8px 16px; border-radius: 8px; background: #1B3022; color: white; font-size: 13px; font-weight: 600; cursor: pointer; border: none; transition: opacity 0.2s;"
        @mouseenter="$el.style.opacity='0.9'" @mouseleave="$el.style.opacity='1'"
      >+ Add Value</button>
    </div>

    <!-- Existing values as cards -->
    <div v-if="model.length === 0" style="text-align: center; padding: 24px; background: #F7FAFB; border-radius: 12px; border: 1px dashed rgba(24,28,29,0.15);">
      <p style="font-size: 13px; color: #737973; margin: 0;">No values yet. Add one above.</p>
    </div>

    <div v-else style="display: grid; grid-template-columns: 1fr 1fr; gap: 10px;">
      <div v-for="(item, index) in model" :key="index"
        style="background: #F7FAFB; border-radius: 12px; border: 1px solid rgba(24,28,29,0.08); padding: 14px; display: flex; flex-direction: column; gap: 8px;"
      >
        <div style="display: flex; align-items: center; gap: 8px;">
          <span style="display: inline-block; padding: 4px 10px; border-radius: 6px; background: rgba(126,86,46,0.1); color: #7E562E; font-size: 11px; font-weight: 700; text-transform: uppercase;">{{ item.icon }}</span>
          <input v-model="item.title" placeholder="Title"
            style="flex: 1; min-width: 0; padding: 6px 10px; border-radius: 6px; border: 1px solid rgba(24,28,29,0.1); background: white; font-size: 13px; font-weight: 600; color: #181C1D; outline: none; box-sizing: border-box; font-family: inherit;"
          />
          <div style="display: flex; gap: 2px; flex-shrink: 0;">
            <button type="button" @click="moveItem(index, index - 1)" :disabled="index === 0"
              style="padding: 4px 6px; border: none; border-radius: 4px; background: transparent; cursor: pointer; font-size: 12px;"
              :style="index === 0 ? 'opacity: 0.3; cursor: not-allowed;' : ''"
            >↑</button>
            <button type="button" @click="moveItem(index, index + 1)" :disabled="index === model.length - 1"
              style="padding: 4px 6px; border: none; border-radius: 4px; background: transparent; cursor: pointer; font-size: 12px;"
              :style="index === model.length - 1 ? 'opacity: 0.3; cursor: not-allowed;' : ''"
            >↓</button>
            <button type="button" @click="removeItem(index)"
              style="padding: 4px 6px; border: none; border-radius: 4px; background: transparent; color: #BA1A1A; cursor: pointer; font-size: 12px;"
            >✕</button>
          </div>
        </div>
        <textarea v-model="item.description" placeholder="Description" rows="2"
          style="width: 100%; padding: 6px 10px; border-radius: 6px; border: 1px solid rgba(24,28,29,0.1); background: white; font-size: 12px; color: #434843; outline: none; box-sizing: border-box; font-family: inherit; resize: vertical;"
        ></textarea>
      </div>
    </div>
  </div>
</template>
