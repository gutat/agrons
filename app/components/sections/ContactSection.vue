<script setup lang="ts">
import { createClient } from '@supabase/supabase-js'

const config = useRuntimeConfig()
const supabase = createClient(config.public.supabaseUrl, config.public.supabaseKey)

const form = reactive({
  name: '',
  email: '',
  company: '',
  phone: '',
  message: '',
})
const submitting = ref(false)
const submitted = ref(false)

async function submitForm() {
  submitting.value = true
  const { error } = await supabase.from('contact_submissions').insert([{
    name: form.name,
    email: form.email,
    company: form.company || null,
    phone: form.phone || null,
    message: form.message,
    inquiry_type: 'general',
    source: 'website',
  }])
  submitting.value = false
  if (!error) {
    submitted.value = true
    form.name = ''; form.email = ''; form.company = ''; form.phone = ''; form.message = ''
  }
}
</script>

<template>
  <Section id="contact">
    <div class="max-w-(--spacing-container) mx-auto px-(--spacing-gutter) w-full">
      <h2 class="headline-md text-[var(--color-primary)] text-center mb-2">Contact Us</h2>
      <p class="body-md text-[var(--color-on-surface-variant)] text-center mb-8">Get in touch for inquiries and partnerships</p>

      <div class="grid md:grid-cols-2 gap-8 max-w-4xl mx-auto">
        <!-- Contact Info -->
        <div class="glass rounded-xl p-8 bg-white/50 dark:bg-white/5">
          <h3 class="font-semibold text-[var(--color-primary)] mb-4">Get in Touch</h3>
          <div class="space-y-4">
            <div>
              <p class="label-caps text-[var(--color-secondary)]">Address</p>
              <p class="body-md text-[var(--color-on-surface-variant)]">Medan Industrial Estate, Indonesia</p>
            </div>
            <div>
              <p class="label-caps text-[var(--color-secondary)]">Email</p>
              <p class="body-md text-[var(--color-on-surface-variant)]">export@agronusa.co.id</p>
            </div>
            <div>
              <p class="label-caps text-[var(--color-secondary)]">WhatsApp</p>
              <a href="https://wa.me/6281234567890" target="_blank" class="body-md text-[var(--color-primary)] no-underline hover:underline">+62 812 3456 7890</a>
            </div>
          </div>
          <Button variant="whatsapp" size="md" class="mt-6 w-full justify-center" href="https://wa.me/6281234567890">
            Chat on WhatsApp
          </Button>
        </div>

        <!-- Contact Form -->
        <div class="glass rounded-xl p-8 bg-white/50 dark:bg-white/5">
          <h3 class="font-semibold text-[var(--color-primary)] mb-4">Send a Message</h3>
          <form v-if="!submitted" @submit.prevent="submitForm" class="space-y-4">
            <div>
              <label class="label-caps text-[var(--color-secondary)] block mb-1">Name *</label>
              <input v-model="form.name" required class="w-full px-4 py-2 rounded-lg border border-[var(--color-outline)] bg-transparent focus:border-[var(--color-primary)] focus:ring-1 focus:ring-[var(--color-primary)] outline-none transition-colors" />
            </div>
            <div>
              <label class="label-caps text-[var(--color-secondary)] block mb-1">Email *</label>
              <input v-model="form.email" type="email" required class="w-full px-4 py-2 rounded-lg border border-[var(--color-outline)] bg-transparent focus:border-[var(--color-primary)] focus:ring-1 focus:ring-[var(--color-primary)] outline-none transition-colors" />
            </div>
            <div>
              <label class="label-caps text-[var(--color-secondary)] block mb-1">Company</label>
              <input v-model="form.company" class="w-full px-4 py-2 rounded-lg border border-[var(--color-outline)] bg-transparent focus:border-[var(--color-primary)] focus:ring-1 focus:ring-[var(--color-primary)] outline-none transition-colors" />
            </div>
            <div>
              <label class="label-caps text-[var(--color-secondary)] block mb-1">Phone</label>
              <input v-model="form.phone" type="tel" class="w-full px-4 py-2 rounded-lg border border-[var(--color-outline)] bg-transparent focus:border-[var(--color-primary)] focus:ring-1 focus:ring-[var(--color-primary)] outline-none transition-colors" />
            </div>
            <div>
              <label class="label-caps text-[var(--color-secondary)] block mb-1">Message *</label>
              <textarea v-model="form.message" rows="3" required class="w-full px-4 py-2 rounded-lg border border-[var(--color-outline)] bg-transparent focus:border-[var(--color-primary)] focus:ring-1 focus:ring-[var(--color-primary)] outline-none transition-colors resize-none"></textarea>
            </div>
            <Button type="submit" variant="primary" size="md" class="w-full justify-center" :loading="submitting" :disabled="submitting">
              {{ submitting ? 'Sending...' : 'Send Message' }}
            </Button>
          </form>
          <div v-else class="text-center py-8">
            <p class="text-lg font-medium text-[var(--color-primary)]">Thank you!</p>
            <p class="text-sm text-[var(--color-on-surface-variant)] mt-2">Your message has been sent. We'll get back to you soon.</p>
            <Button variant="outline" size="sm" class="mt-4" @click="submitted = false">Send another</Button>
          </div>
        </div>
      </div>
    </div>
  </Section>
</template>
