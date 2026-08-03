<script setup lang="ts">
// Scalar field with EN/ID support.
//   en           → legacy column (v-model:en)
//   translations → the row's translations JSONB (v-model:translations);
//                  writes translations[field].id
const props = withDefaults(
  defineProps<{
    field: string
    label?: string
    placeholder?: string
    textarea?: boolean
    rows?: number
  }>(),
  { label: '', placeholder: '', textarea: false, rows: 3 },
)

const en = defineModel<string>('en', { default: '' })
const translations = defineModel<Record<string, any>>('translations', { default: () => ({}) })

const idValue = computed({
  get: () => translations.value?.[props.field]?.id ?? '',
  set: (v: string) => {
    const next = { ...(translations.value || {}) }
    const cur = { ...(next[props.field] || {}) }
    cur.id = v
    next[props.field] = cur
    translations.value = next
  },
})
</script>

<template>
  <div>
    <label v-if="label" style="display: block; font-size: 13px; font-weight: 600; color: #434843; margin-bottom: 6px;">{{ label }}</label>
    <div class="adm-lang-grid" style="display: grid; grid-template-columns: 1fr 1fr; gap: 10px;">
      <div style="position: relative;">
        <span style="position: absolute; top: 10px; left: 12px; font-size: 10px; font-weight: 700; color: #737973; letter-spacing: 0.05em; z-index: 1;">EN</span>
        <textarea
          v-if="textarea"
          v-model="en"
          :placeholder="placeholder || 'English'"
          :rows="rows"
          style="width: 100%; padding: 10px 12px 10px 40px; border-radius: 10px; border: 1px solid rgba(24,28,29,0.1); background: #F7FAFB; font-size: 14px; color: #181C1D; outline: none; box-sizing: border-box; font-family: inherit; resize: vertical;"
        ></textarea>
        <input
          v-else
          v-model="en"
          :placeholder="placeholder || 'English'"
          style="width: 100%; padding: 12px 16px 12px 40px; border-radius: 10px; border: 1px solid rgba(24,28,29,0.1); background: #F7FAFB; font-size: 14px; color: #181C1D; outline: none; box-sizing: border-box; font-family: inherit;"
        />
      </div>
      <div style="position: relative;">
        <span style="position: absolute; top: 10px; left: 12px; font-size: 10px; font-weight: 700; color: #7E562E; letter-spacing: 0.05em; z-index: 1;">ID</span>
        <textarea
          v-if="textarea"
          v-model="idValue"
          :placeholder="placeholder || 'Indonesia'"
          :rows="rows"
          style="width: 100%; padding: 10px 12px 10px 40px; border-radius: 10px; border: 1px solid rgba(24,28,29,0.1); background: #F7FAFB; font-size: 14px; color: #181C1D; outline: none; box-sizing: border-box; font-family: inherit; resize: vertical;"
        ></textarea>
        <input
          v-else
          v-model="idValue"
          :placeholder="placeholder || 'Indonesia'"
          style="width: 100%; padding: 12px 16px 12px 40px; border-radius: 10px; border: 1px solid rgba(24,28,29,0.1); background: #F7FAFB; font-size: 14px; color: #181C1D; outline: none; box-sizing: border-box; font-family: inherit;"
        />
      </div>
    </div>
  </div>
</template>
