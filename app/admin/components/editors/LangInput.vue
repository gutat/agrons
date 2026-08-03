<script setup lang="ts">
// Dual EN/ID input for a localized string.
// Accepts either a plain string (legacy) or a { en, id } object and
// writes back the object form, so existing data keeps working.
const props = withDefaults(
  defineProps<{
    enPlaceholder?: string
    idPlaceholder?: string
  }>(),
  { enPlaceholder: 'English', idPlaceholder: 'Indonesia' },
)

const model = defineModel<any>({ default: '' })

const enValue = computed({
  get: () => (typeof model.value === 'string' ? model.value : model.value?.en ?? ''),
  set: (v: string) => {
    const id = typeof model.value === 'object' && model.value ? (model.value.id ?? '') : ''
    model.value = { en: v, id }
  },
})

const idValue = computed({
  get: () => (typeof model.value === 'string' ? '' : model.value?.id ?? ''),
  set: (v: string) => {
    const en = typeof model.value === 'string' ? model.value : (model.value?.en ?? '')
    model.value = { en, id: v }
  },
})
</script>

<template>
  <div class="adm-lang-grid" style="display: grid; grid-template-columns: 1fr 1fr; gap: 8px;">
    <div style="position: relative;">
      <span style="position: absolute; top: 8px; left: 10px; font-size: 10px; font-weight: 700; color: #737973; letter-spacing: 0.05em;">EN</span>
      <input v-model="enValue"
        :placeholder="enPlaceholder"
        style="width: 100%; padding: 8px 12px 8px 38px; border-radius: 8px; border: 1px solid rgba(24,28,29,0.1); background: white; font-size: 13px; color: #181C1D; outline: none; box-sizing: border-box; font-family: inherit;"
      />
    </div>
    <div style="position: relative;">
      <span style="position: absolute; top: 8px; left: 10px; font-size: 10px; font-weight: 700; color: #7E562E; letter-spacing: 0.05em;">ID</span>
      <input v-model="idValue"
        :placeholder="idPlaceholder"
        style="width: 100%; padding: 8px 12px 8px 38px; border-radius: 8px; border: 1px solid rgba(24,28,29,0.1); background: white; font-size: 13px; color: #181C1D; outline: none; box-sizing: border-box; font-family: inherit;"
      />
    </div>
  </div>
</template>
