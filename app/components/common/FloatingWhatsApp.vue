<script setup lang="ts">
import { useSupabase } from '~/utils/supabase'

const supabase = useSupabase()
const config = useRuntimeConfig()

const whatsappLink = ref('')
const visible = ref(false)

// Entrance animation: fade in slightly after load so it doesn't jump in
onMounted(async () => {
  // Prefer the number saved in company_info (same source as the contact section)
  const { data } = await supabase
    .from('company_info')
    .select('contact')
    .single()

  const raw = (data?.contact as any)?.whatsapp
    || config.public.whatsappNumber
    || ''

  const digits = String(raw).replace(/[^0-9]/g, '')
  if (!digits) return

  const message = encodeURIComponent(config.public.whatsappMessage || '')
  whatsappLink.value = `https://wa.me/${digits}${message ? `?text=${message}` : ''}`
  visible.value = true
})
</script>

<template>
  <Transition name="wa-fade">
    <a
      v-if="visible && whatsappLink"
      :href="whatsappLink"
      target="_blank"
      rel="noopener noreferrer"
      aria-label="Chat on WhatsApp"
      class="group fixed bottom-5 right-5 md:bottom-7 md:right-7 z-40 flex items-center justify-center w-14 h-14 md:w-16 md:h-16 rounded-full bg-[#25D366] text-white shadow-lg shadow-[#25D366]/30 hover:shadow-xl hover:shadow-[#25D366]/40 hover:scale-105 active:scale-95 transition-all"
    >
      <!-- Pulse ring -->
      <span class="absolute inset-0 rounded-full bg-[#25D366]/40 animate-ping opacity-40 pointer-events-none" aria-hidden="true" />
      <svg xmlns="http://www.w3.org/2000/svg" width="28" height="28" fill="currentColor" viewBox="0 0 256 256" class="relative z-10">
        <path d="M187.58,144.84l-32-16a8,8,0,0,0-8,.5l-14.69,9.8a40.55,40.55,0,0,1-16-16l9.8-14.69a8,8,0,0,0,.5-8l-16-32A8,8,0,0,0,104,64a40,40,0,0,0-40,40,88.1,88.1,0,0,0,88,88,40,40,0,0,0,40-40A8,8,0,0,0,187.58,144.84Z" />
      </svg>
      <!-- Hover tooltip (desktop only) -->
      <span class="absolute right-full mr-3 whitespace-nowrap rounded-lg bg-[#181C1D] text-white text-xs font-semibold px-3 py-1.5 opacity-0 translate-x-1 pointer-events-none transition-all group-hover:opacity-100 group-hover:translate-x-0 hidden md:block" aria-hidden="true">Chat on WhatsApp</span>
    </a>
  </Transition>
</template>

<style scoped>
.wa-fade-enter-active,
.wa-fade-leave-active {
  transition: opacity 0.4s ease, transform 0.4s ease;
}
.wa-fade-enter-from,
.wa-fade-leave-to {
  opacity: 0;
  transform: translateY(12px);
}
</style>
