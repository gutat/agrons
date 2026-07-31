<script setup lang="ts">
// Renders an SVG icon by name (used for AboutSection company values).
// Names match the icon options in AdminAbout's ValuesCardsEditor.
const props = defineProps<{
    name: string
    size?: number
    color?: string
}>()

const paths: Record<string, string[]> = {
    leaf: [
        "M12 2C7 2 3 6 3 11c0 5 4 9 9 9 4 0 7-3 8-7 1-5-2-10-8-11z",
        "M3 21c3-6 7-9 12-11",
    ],
    shield: [
        "M12 2l7 3v6c0 5-3 8-7 10-4-2-7-5-7-10V5l7-3z",
        "M9 12l2 2 4-4",
    ],
    users: [
        "M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2",
        "M9 11a4 4 0 1 0 0-8 4 4 0 0 0 0 8z",
        "M22 21v-2a4 4 0 0 0-3-3.87",
        "M16 3.13a4 4 0 0 1 0 7.75",
    ],
    globe: [
        "M12 22a10 10 0 1 0 0-20 10 10 0 0 0 0 20z",
        "M2 12h20",
        "M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z",
    ],
    clock: [
        "M12 22a10 10 0 1 0 0-20 10 10 0 0 0 0 20z",
        "M12 6v6l4 2",
    ],
    handshake: [
        "M11 17l2 2a1 1 0 0 0 1.4 0l4.3-4.3a2.5 2.5 0 0 0-3.5-3.5L12 14l-2-2a2.5 2.5 0 0 0-3.5-3.5L2 12.5",
        "M2 12.5L5.5 16",
        "M22 12.5L18.5 9",
    ],
    star: [
        "M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z",
    ],
    award: [
        "M12 15a6 6 0 1 0 0-12 6 6 0 0 0 0 12z",
        "M8.5 14.5L7 22l5-3 5 3-1.5-7.5",
    ],
    heart: [
        "M12 21C7 17 3 13.5 3 9.5 3 6.5 5.5 4 8.5 4c1.3 0 2.6.6 3.5 1.6C12.9 4.6 14.2 4 15.5 4 18.5 4 21 6.5 21 9.5c0 4-4 7.5-9 11.5z",
    ],
    seedling: [
        "M12 22V12",
        "M12 12C12 8 9.5 5 5 5c0 4 2.5 7 7 7z",
        "M12 12c0-4 2.5-7 7-7 0 4-2.5 7-7 7z",
    ],
}

const fallback = ['M4 4h16v16H4z', 'M4 4l16 16']

const iconPaths = computed(() => paths[props.name] || fallback)
</script>

<template>
    <svg
        :width="size || 16"
        :height="size || 16"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        stroke-width="2"
        stroke-linecap="round"
        stroke-linejoin="round"
        class="block"
        aria-hidden="true"
    >
        <path v-for="(d, i) in iconPaths" :key="i" :d="d" />
    </svg>
</template>
