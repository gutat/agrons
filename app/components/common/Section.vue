<script setup lang="ts">
interface Props {
  id: string
  fullViewport?: boolean
  dark?: boolean
  class?: string
  'aria-label'?: string
}
const props = withDefaults(defineProps<Props>(), {
  fullViewport: true,
  dark: false,
})
</script>

<template>
  <section
    :id="props.id"
    :class="[
      'section relative',
      { 'dark': dark },
      props.class,
    ]"
    :aria-label="ariaLabel"
  >
    <slot />
  </section>
</template>
