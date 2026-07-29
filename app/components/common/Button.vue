<script setup lang="ts">
interface Props {
  variant?: 'primary' | 'secondary' | 'outline' | 'ghost' | 'whatsapp'
  size?: 'sm' | 'md' | 'lg'
  disabled?: boolean
  loading?: boolean
  type?: 'button' | 'submit' | 'reset'
  href?: string
  class?: string
}
const props = withDefaults(defineProps<Props>(), {
  variant: 'primary',
  size: 'md',
  disabled: false,
  loading: false,
  type: 'button',
})

const emit = defineEmits<{
  click: [e: MouseEvent]
}>()

const baseClasses = 'inline-flex items-center justify-center font-medium select-none transition-all duration-200 focus:outline-none focus-visible:ring-2 focus-visible:ring-primary/50'

const sizeClasses: Record<string, string> = {
  sm: 'px-3 py-1.5 text-sm rounded gap-1.5',
  md: 'px-4 py-2 text-base rounded gap-2',
  lg: 'px-6 py-3 text-lg rounded gap-2.5',
}

const variantClasses: Record<string, string> = {
  primary: 'bg-[var(--color-primary)] text-white hover:opacity-90 shadow-sm',
  secondary: 'bg-[var(--color-secondary)] text-white hover:opacity-90',
  outline: 'border border-[var(--color-outline)] text-[var(--color-on-surface)] hover:bg-[var(--color-surface-container)] dark:hover:bg-[var(--color-dark-surface-container)]',
  ghost: 'border border-transparent text-[var(--color-on-surface)] hover:bg-[var(--color-surface-container)] dark:hover:bg-[var(--color-dark-surface-container)]',
  whatsapp: 'bg-[#25D366] text-white hover:opacity-90',
}

function handleClick(e: MouseEvent) {
  if (!props.disabled && !props.loading) {
    emit('click', e)
  }
}
</script>

<template>
  <a
    v-if="href"
    :href="href"
    :class="[baseClasses, sizeClasses[size], variantClasses[variant], { 'opacity-50 cursor-not-allowed': disabled || loading }, props.class]"
    :target="href.startsWith('http') ? '_blank' : undefined"
    :rel="href.startsWith('http') ? 'noopener noreferrer' : undefined"
  >
    <slot />
  </a>
  <button
    v-else
    :type="type"
    :disabled="disabled || loading"
    :class="[baseClasses, sizeClasses[size], variantClasses[variant], { 'opacity-50 cursor-not-allowed': disabled || loading }, props.class]"
    @click="handleClick"
  >
    <slot />
  </button>
</template>
