<script setup lang="ts">
// Table editor for specifications: [{ name: {en,id}, value: {en,id}, unit? }, ...]
import LangInput from '~/admin/components/editors/LangInput.vue'

const model = defineModel<{ name: any; value: any; unit?: string }[]>({ default: [] })

function addRow() {
  model.value.push({ name: { en: '', id: '' }, value: { en: '', id: '' }, unit: '' })
}

function removeRow(index: number) {
  model.value.splice(index, 1)
}

function moveRow(from: number, to: number) {
  if (to < 0 || to >= model.value.length) return
  const [item] = model.value.splice(from, 1)
  model.value.splice(to, 0, item)
}
</script>

<template>
  <div>
    <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 12px;">
      <label style="font-size: 13px; font-weight: 600; color: #434843;">Specifications</label>
      <button type="button" @click="addRow"
        style="padding: 6px 14px; border-radius: 8px; background: #1B3022; color: white; font-size: 12px; font-weight: 600; cursor: pointer; border: none; transition: opacity 0.2s;"
        @mouseenter="$el.style.opacity='0.9'" @mouseleave="$el.style.opacity='1'"
      >+ Add Row</button>
    </div>

    <div v-if="model.length === 0" style="text-align: center; padding: 24px; background: #F7FAFB; border-radius: 12px; border: 1px dashed rgba(24,28,29,0.15);">
      <p style="font-size: 13px; color: #737973; margin: 0;">No specifications yet. Click "+ Add Row".</p>
    </div>

    <div v-else style="display: flex; flex-direction: column; gap: 8px;">
      <div v-for="(row, index) in model" :key="index"
        class="adm-spec-row"
        style="display: flex; align-items: center; gap: 8px; padding: 10px; background: #F7FAFB; border-radius: 10px; border: 1px solid rgba(24,28,29,0.06);"
      >
        <div class="adm-spec-grid" style="display: grid; grid-template-columns: 1.4fr 1.4fr 0.8fr; gap: 8px; flex: 1; min-width: 0;">
          <LangInput v-model="row.name" en-placeholder="Name (e.g. EC)" id-placeholder="Nama (cth. EC)" />
          <LangInput v-model="row.value" en-placeholder="Value (e.g. < 0.5)" id-placeholder="Nilai (cth. < 0.5)" />
          <input v-model="row.unit" placeholder="Unit"
            style="width: 100%; min-width: 0; padding: 8px 12px; border-radius: 8px; border: 1px solid rgba(24,28,29,0.1); background: white; font-size: 13px; color: #181C1D; outline: none; box-sizing: border-box; font-family: inherit;"
          />
        </div>
        <div style="display: flex; gap: 4px; flex-shrink: 0;">
          <button type="button" @click="moveRow(index, index - 1)" :disabled="index === 0"
            style="padding: 6px 8px; border: none; border-radius: 6px; background: transparent; cursor: pointer; font-size: 13px; transition: background 0.15s;"
            :style="index === 0 ? 'opacity: 0.3; cursor: not-allowed;' : ''"
            @mouseenter="index > 0 && ($el.style.background='rgba(27,48,34,0.06)')" @mouseleave="index > 0 && ($el.style.background='transparent')"
          >↑</button>
          <button type="button" @click="moveRow(index, index + 1)" :disabled="index === model.length - 1"
            style="padding: 6px 8px; border: none; border-radius: 6px; background: transparent; cursor: pointer; font-size: 13px; transition: background 0.15s;"
            :style="index === model.length - 1 ? 'opacity: 0.3; cursor: not-allowed;' : ''"
            @mouseenter="index < model.length - 1 && ($el.style.background='rgba(27,48,34,0.06)')" @mouseleave="index < model.length - 1 && ($el.style.background='transparent')"
          >↓</button>
          <button type="button" @click="removeRow(index)"
            style="padding: 6px 8px; border: none; border-radius: 6px; background: transparent; color: #BA1A1A; cursor: pointer; font-size: 13px; transition: background 0.15s;"
            @mouseenter="$el.style.background='rgba(186,26,26,0.08)'" @mouseleave="$el.style.background='transparent'"
          >✕</button>
        </div>
      </div>
    </div>
  </div>
</template>
