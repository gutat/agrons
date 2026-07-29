<template>
  <footer class="bg-[var(--color-forest)] text-white/80">
    <!-- Top section -->
    <div class="max-w-(--spacing-container) mx-auto px-(--spacing-gutter) py-12 md:py-16">
      <div class="grid md:grid-cols-3 gap-10">
        <!-- Brand -->
        <div>
          <div class="flex items-center gap-2.5 mb-4">
            <span class="w-8 h-8 rounded-lg bg-white/15 flex items-center justify-center text-white text-sm font-bold font-display">A</span>
            <span class="font-display text-lg font-bold text-white">Agro Nusa</span>
          </div>
          <p class="text-sm text-white/60 leading-relaxed max-w-xs">
            Premium cocopeat and cocofiber products from Indonesia. Committed to sustainable, high-quality coconut-based growing media for global agriculture.
          </p>
        </div>

        <!-- Quick Links -->
        <div>
          <h4 class="text-xs font-bold uppercase tracking-widest text-white/50 mb-4">Quick Links</h4>
          <ul class="space-y-2.5">
            <li v-for="link in links" :key="link.id">
              <a :href="`#${link.id}`" class="text-sm text-white/70 hover:text-white transition-colors no-underline">{{ link.label }}</a>
            </li>
          </ul>
        </div>

        <!-- Contact -->
        <div>
          <h4 class="text-xs font-bold uppercase tracking-widest text-white/50 mb-4">Contact</h4>
          <ul class="space-y-3 text-sm text-white/70">
            <li class="flex items-start gap-2.5">
              <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" fill="currentColor" viewBox="0 0 256 256" class="mt-0.5 flex-shrink-0 opacity-60"><path d="M128,16a88.1,88.1,0,0,0-88,88c0,75.3,80,132.17,83.41,134.55a8,8,0,0,0,9.18,0C136,236.17,216,179.3,216,104A88.1,88.1,0,0,0,128,16Z"/></svg>
              Medan Industrial Estate, Indonesia
            </li>
            <li class="flex items-center gap-2.5">
              <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" fill="currentColor" viewBox="0 0 256 256" class="flex-shrink-0 opacity-60"><path d="M224,48H32a8,8,0,0,0-8,8V192a16,16,0,0,0,16,16H216a16,16,0,0,0,16-16V56A8,8,0,0,0,224,48ZM203.43,64,128,127.72,52.57,64ZM216,192H40V74.19l82.59,75.71a8,8,0,0,0,10.82,0L216,74.19V192Z"/></svg>
              <a href="mailto:export@agronusa.co.id" class="hover:text-white transition-colors">export@agronusa.co.id</a>
            </li>
            <li class="flex items-center gap-2.5">
              <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" fill="currentColor" viewBox="0 0 256 256" class="flex-shrink-0 opacity-60"><path d="M187.58,144.84l-32-16a8,8,0,0,0-8,.5l-14.69,9.8a40.55,40.55,0,0,1-16-16l9.8-14.69a8,8,0,0,0,.5-8l-16-32A8,8,0,0,0,104,64a40,40,0,0,0-40,40,88.1,88.1,0,0,0,88,88,40,40,0,0,0,40-40A8,8,0,0,0,187.58,144.84Z"/></svg>
              <a href="https://wa.me/6281234567890" target="_blank" class="hover:text-white transition-colors">+62 812 3456 7890</a>
            </li>
          </ul>
        </div>
      </div>
    </div>

    <!-- Bottom bar -->
    <div class="border-t border-white/10">
      <div class="max-w-(--spacing-container) mx-auto px-(--spacing-gutter) py-4 flex flex-col md:flex-row items-center justify-between gap-3 text-xs text-white/40">
        <p>&copy; {{ new Date().getFullYear() }} PT Agro Nusa Sejahtera. All rights reserved.</p>
        <p>Sustainable coconut products for a greener tomorrow.</p>
      </div>
    </div>
  </footer>
</template>

<script setup lang="ts">
const links = [
  { id: 'company', label: 'About' },
  { id: 'products', label: 'Products' },
  { id: 'gallery', label: 'Gallery' },
  { id: 'contact', label: 'Contact' },
]
</script>
