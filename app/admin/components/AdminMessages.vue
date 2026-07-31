<script setup lang="ts">
import { useSupabase } from '~/utils/supabase'

const supabase = useSupabase()

const messages = ref<any[]>([])
const loading = ref(true)

onMounted(async () => {
  const { data } = await supabase
    .from('contact_submissions')
    .select('*')
    .order('created_at', { ascending: false })
  if (data) messages.value = data
  loading.value = false
})

function formatDate(ts: string) {
  return new Date(ts).toLocaleDateString('en-US', {
    year: 'numeric', month: 'short', day: 'numeric',
    hour: '2-digit', minute: '2-digit'
  })
}

const inquiryColors: Record<string, string> = {
  general: '#434843',
  quote: '#1B3022',
  sample: '#7E562E',
  partnership: '#2E7D32',
  technical: '#BA1A1A',
}
</script>

<template>
  <div>
    <div style="margin-bottom: 28px;">
      <h1 style="font-family: 'Source Serif 4', serif; font-size: 24px; font-weight: 700; color: #1B3022; margin: 0;">Messages</h1>
      <p style="font-size: 14px; color: #737973; margin: 4px 0 0;">Contact form submissions from your website</p>
    </div>

    <div v-if="loading" style="text-align: center; padding: 48px 0;">
      <div style="width: 28px; height: 28px; border: 2px solid #1B3022; border-top-color: transparent; border-radius: 50%; animation: adminSpin 0.6s linear infinite; margin: 0 auto;"></div>
    </div>

    <div v-else-if="messages.length === 0" style="text-align: center; padding: 48px 0; color: #737973; font-size: 15px;">
      <p style="margin: 0;">No messages yet.</p>
    </div>

    <div v-else style="display: flex; flex-direction: column; gap: 16px;">
      <div v-for="msg in messages" :key="msg.id"
        style="background: white; border-radius: 16px; border: 1px solid rgba(24,28,29,0.08); padding: 24px; transition: all 0.15s;"
        @mouseenter="$el.style.boxShadow='0 4px 20px rgba(27,48,34,0.06)'" @mouseleave="$el.style.boxShadow='none'"
      >
        <div style="display: flex; align-items: flex-start; justify-content: space-between; margin-bottom: 12px;">
          <div style="display: flex; align-items: center; gap: 12px;">
            <div style="width: 40px; height: 40px; border-radius: 50%; background: #1B3022; display: flex; align-items: center; justify-content: center; color: white; font-size: 14px; font-weight: 600; flex-shrink: 0;">
              {{ (msg.name?.charAt(0) || '?').toUpperCase() }}
            </div>
            <div>
              <p style="font-size: 15px; font-weight: 600; color: #181C1D; margin: 0;">{{ msg.name }}</p>
              <p style="font-size: 13px; color: #737973; margin: 2px 0 0;">{{ msg.email }}</p>
            </div>
          </div>
          <span style="font-size: 12px; color: #737973; white-space: nowrap;">{{ formatDate(msg.created_at) }}</span>
        </div>

        <p style="font-size: 14px; color: #434843; line-height: 1.6; margin: 0 0 12px 52px;">{{ msg.message }}</p>

        <div style="display: flex; flex-wrap: wrap; gap: 8px; margin-left: 52px;">
          <span v-if="msg.company"
            style="padding: 4px 12px; border-radius: 100px; font-size: 12px; font-weight: 500; background: rgba(27,48,34,0.06); color: #434843;"
          >🏢 {{ msg.company }}</span>
          <span v-if="msg.inquiry_type"
            :style="{
              padding: '4px 12px',
              borderRadius: '100px',
              fontSize: '12px',
              fontWeight: 600,
              background: (inquiryColors[msg.inquiry_type] || '#434843') + '14',
              color: inquiryColors[msg.inquiry_type] || '#434843',
              textTransform: 'capitalize'
            }"
          >{{ msg.inquiry_type }}</span>
          <span v-if="msg.country"
            style="padding: 4px 12px; border-radius: 100px; font-size: 12px; font-weight: 500; background: rgba(27,48,34,0.06); color: #434843;"
          >🌍 {{ msg.country }}</span>
          <span v-if="msg.phone"
            style="padding: 4px 12px; border-radius: 100px; font-size: 12px; font-weight: 500; background: rgba(27,48,34,0.06); color: #434843;"
          >📞 {{ msg.phone }}</span>
        </div>
      </div>
    </div>
  </div>
</template>
