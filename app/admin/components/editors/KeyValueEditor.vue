<script setup lang="ts">
// Key-value row editor for objects: Record<string, string> (e.g. social links)
const model = defineModel<Record<string, string>>({ default: {} })

const newKey = ref('')
const newValue = ref('')
const keyPlaceholder = ref('platform (e.g. linkedin)')
const valuePlaceholder = ref('url (e.g. https://...)')

defineProps<{
  title?: string
  keyPlaceholder?: string
  valuePlaceholder?: string
}>()

const entries = computed(() => Object.entries(model.value))

function addEntry() {
  const key = newKey.value.trim()
  const value = newValue.value.trim()
  if (!key || !value) return
  model.value[key] = value
  newKey.value = ''
  newValue.value = ''
}

function removeEntry(key: string) {
  delete model.value[key]
}

function updateKey(oldKey: string, newKey: string) {
  if (!newKey.trim() || newKey === oldKey) return
  const val = model.value[oldKey]
  delete model.value[oldKey]
  model.value[newKey.trim()] = val
}
</script>

<template>
  <div>
    <div v-if="title" style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 12px;">
      <label style="font-size: 13px; font-weight: 600; color: #434843;">{{ title }}</label>
    </div>

    <div style="display: flex; align-items: center; gap: 8px; margin-bottom: 12px;">
      <input v-model="newKey" :placeholder="keyPlaceholder"
        style="flex: 1; min-width: 0; padding: 10px 14px; border-radius: 10px; border: 1px solid rgba(24,28,29,0.1); background: #F7FAFB; font-size: 13px; color: #181C1D; outline: none; box-sizing: border-box; font-family: inherit;"
      />
      <input v-model="newValue" :placeholder="valuePlaceholder"
        style="flex: 1.5; min-width: 0; padding: 10px 14px; border-radius: 10px; border: 1px solid rgba(24,28,29,0.1); background: #F7FAFB; font-size: 13px; color: #181C1D; outline: none; box-sizing: border-box; font-family: inherit;"
      />
      <button type="button" @click="addEntry"
        style="padding: 10px 16px; border-radius: 10px; background: #1B3022; color: white; font-size: 13px; font-weight: 600; cursor: pointer; border: none; transition: opacity 0.2s;"
        @mouseenter="$el.style.opacity='0.9'" @mouseleave="$el.style.opacity='1'"
      >Add</button>
    </div>

    <div v-if="entries.length === 0" style="text-align: center; padding: 24px; background: #F7FAFB; border-radius: 12px; border: 1px dashed rgba(24,28,29,0.15);">
      <p style="font-size: 13px; color: #737973; margin: 0;">No items yet.</p>
    </div>

    <div v-else style="display: flex; flex-direction: column; gap: 8px;">
      <div v-for="[key, value] in entries" :key="key"
        style="display: flex; align-items: center; gap: 8px; padding: 8px; background: #F7FAFB; border-radius: 10px; border: 1px solid rgba(24,28,29,0.06);"
      >
        <input :value="key" @change="(e) => updateKey(key, (e.target as HTMLInputElement).value)"
          placeholder="key"
          style="flex: 1; min-width: 0; padding: 8px 12px; border-radius: 8px; border: 1px solid rgba(24,28,29,0.1); background: white; font-size: 13px; color: #181C1D; outline: none; box-sizing: border-box; font-family: inherit;"
        />
        <input v-model="model[key]" placeholder="value"
          style="flex: 1.5; min-width: 0; padding: 8px 12px; border-radius: 8px; border: 1px solid rgba(24,28,29,0.1); background: white; font-size: 13px; color: #181C1D; outline: none; box-sizing: border-box; font-family: inherit;"
        />
        <button type="button" @click="removeEntry(key)"
          style="padding: 6px 8px; border: none; border-radius: 6px; background: transparent; color: #BA1A1A; cursor: pointer; font-size: 13px; transition: background 0.15s;"
          @mouseenter="$el.style.background='rgba(186,26,26,0.08)'" @mouseleave="$el.style.background='transparent'"
        >✕</button>
      </div>
    </div>
  </div>
</template>
