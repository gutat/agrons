<template>
  <footer class="bg-[var(--color-primary)] text-white py-8">
    <div class="max-w-(--spacing-container) mx-auto px-(--spacing-gutter)">
      <div class="flex flex-col md:flex-row items-center justify-between gap-4">
        <div class="text-center md:text-left">
          <p class="text-sm opacity-80">PT Agro Nusa Sejahtera</p>
          <p class="text-xs opacity-60 mt-1">&copy; {{ new Date().getFullYear() }} All rights reserved</p>
        </div>
        <div class="flex items-center gap-4">
          <a
            href="https://wa.me/6281234567890"
            target="_blank"
            rel="noopener noreferrer"
            class="text-white/80 hover:text-white transition-colors"
            aria-label="WhatsApp"
          >
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="currentColor" viewBox="0 0 256 256">
              <path d="M187.58,144.84l-32-16a8,8,0,0,0-8,.5l-14.69,9.8a40.55,40.55,0,0,1-16-16l9.8-14.69a8,8,0,0,0,.5-8l-16-32A8,8,0,0,0,104,64a40,40,0,0,0-40,40,88.1,88.1,0,0,0,88,88,40,40,0,0,0,40-40A8,8,0,0,0,187.58,144.84Z" />
            </svg>
          </a>
          <a
            v-if="config?.public?.mapEmbedUrl"
            :href="config.public.mapEmbedUrl"
            target="_blank"
            rel="noopener noreferrer"
            class="text-white/80 hover:text-white transition-colors"
            aria-label="Location"
          >
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="currentColor" viewBox="0 0 256 256">
              <path d="M128,16a88.1,88.1,0,0,0-88,88c0,75.3,80,132.17,83.41,134.55a8,8,0,0,0,9.18,0C136,236.17,216,179.3,216,104A88.1,88.1,0,0,0,128,16Zm0,56a32,32,0,1,1-32,32A32,32,0,0,1,128,72Z" />
            </svg>
          </a>
        </div>
      </div>
    </div>
  </footer>
</template>

<script setup lang="ts">
const config = useRuntimeConfig()
</script>
