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

const baseClasses = 'inline-flex items-center justify-center font-semibold select-none transition-all duration-200 focus:outline-none focus-visible:ring-2 focus-visible:ring-[var(--color-forest)]/50 cursor-pointer no-underline'

const sizeClasses: Record<string, string> = {
  sm: 'px-3.5 py-2 text-sm rounded-lg gap-1.5',
  md: 'px-5 py-2.5 text-sm rounded-xl gap-2',
  lg: 'px-6 py-3 text-base rounded-xl gap-2.5',
}

const variantClasses: Record<string, string> = {
  primary: 'bg-[var(--color-forest)] text-white shadow-md hover:shadow-lg hover:-translate-y-0.5 active:translate-y-0',
  secondary: 'bg-[var(--color-husk)] text-white hover:opacity-90',
  outline: 'border-2 border-[var(--color-ink)]/20 bg-[var(--color-parchment-raised)]/50 dark:bg-white/5 text-[var(--color-ink)] dark:text-[var(--color-charcoal-ink)] hover:border-[var(--color-ink)]/50 dark:hover:border-white/40 hover:bg-[var(--color-parchment-raised)] dark:hover:bg-white/10 hover:-translate-y-0.5 active:translate-y-0',
  ghost: 'border border-transparent text-[var(--color-ink)] hover:bg-[var(--color-ink)]/5 dark:text-[var(--color-charcoal-ink)]',
  whatsapp: 'bg-[#25D366] text-white shadow-md hover:shadow-lg hover:-translate-y-0.5 active:translate-y-0',
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
    :class="[baseClasses, sizeClasses[size], variantClasses[variant], { 'opacity-50 pointer-events-none': disabled || loading }, props.class]"
    :target="href.startsWith('http') ? '_blank' : undefined"
    :rel="href.startsWith('http') ? 'noopener noreferrer' : undefined"
  >
    <slot />
  </a>
  <button
    v-else
    :type="type"
    :disabled="disabled || loading"
    :class="[baseClasses, sizeClasses[size], variantClasses[variant], { 'opacity-50 pointer-events-none': disabled || loading }, props.class]"
    @click="handleClick"
  >
    <slot />
  </button>
</template>
