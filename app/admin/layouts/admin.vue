<script setup lang="ts">
import '~/admin/assets/admin.css'
import { useSupabase } from '~/utils/supabase'
import AdminDashboard from '~/admin/components/AdminDashboard.vue'
import AdminProducts from '~/admin/components/AdminProducts.vue'
import AdminProductEditor from '~/admin/components/AdminProductEditor.vue'
import AdminGallery from '~/admin/components/AdminGallery.vue'
import AdminHome from '~/admin/components/AdminHome.vue'
import AdminAbout from '~/admin/components/AdminAbout.vue'
import AdminCompany from '~/admin/components/AdminCompany.vue'
import AdminMessages from '~/admin/components/AdminMessages.vue'

const supabase = useSupabase()
const config = useRuntimeConfig()
const adminPath = config.public.adminPath || 'admin'

const props = defineProps<{
  section: string
  slug?: string
}>()

const user = ref<any>(null)
const loading = ref(true)
const email = ref('')
const password = ref('')
const authError = ref('')
const showUserMenu = ref(false)
const mobileNavOpen = ref(false)

// Company branding — fetched from company_info (admin-editable)
const companyName = ref('Agro Nusa Sejahtera')
const companyLogo = ref('')

async function fetchCompany() {
  const { data } = await supabase.from('company_info').select('name, logo_url').single()
  if (data) {
    if (data.name) companyName.value = data.name
    if (data.logo_url) companyLogo.value = data.logo_url
  }
}

onMounted(() => {
  fetchCompany()
  checkSession()
})

watch(mobileNavOpen, (open) => {
  document.body.style.overflow = open ? 'hidden' : ''
})
onUnmounted(() => {
  document.body.style.overflow = ''
})

async function checkSession() {
  const { data } = await supabase.auth.getSession()
  user.value = data.session?.user || null
  loading.value = false
}

async function signIn() {
  authError.value = ''
  const { error } = await supabase.auth.signInWithPassword({ email: email.value, password: password.value })
  if (error) authError.value = error.message
  else { await checkSession() }
}

async function signOut() {
  await supabase.auth.signOut()
  user.value = null
}

function navClass(path: string) {
  const active = props.section === path
  return active
    ? 'px-4 py-2 rounded-xl text-sm font-semibold bg-[#1B3022] text-white transition-all'
    : 'px-4 py-2 rounded-xl text-sm font-medium text-[#434843] hover:bg-[#1B3022]/5 dark:hover:bg-white/10 transition-all'
}
</script>

<template>
  <div style="min-height: 100vh; background: #F7FAFB;">
    <!-- Login screen -->
    <div v-if="!loading && !user" style="min-height: 100vh; display: flex; align-items: center; justify-content: center; padding: 16px;">
      <div style="width: 100%; max-width: 400px;">
        <div style="text-align: center; margin-bottom: 32px;">
          <div style="width: 48px; height: 48px; border-radius: 14px; background: #1B3022; display: flex; align-items: center; justify-content: center; margin: 0 auto 16px;">
            <img v-if="companyLogo" :src="companyLogo" alt="" style="width: 28px; height: 28px; object-fit: contain;" />
            <svg v-else width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2"><path d="M12 2L2 7l10 5 10-5-10-5z"/><path d="M2 17l10 5 10-5"/><path d="M2 12l10 5 10-5"/></svg>
          </div>
          <h1 style="font-family: 'Source Serif 4', serif; font-size: 22px; font-weight: 700; color: #1B3022; margin: 0;">Admin Login</h1>
          <p style="font-size: 14px; color: #737973; margin-top: 4px;">{{ companyName }}</p>
        </div>
        <form @submit.prevent="signIn" style="display: flex; flex-direction: column; gap: 16px;">
          <div>
            <label style="display: block; font-size: 13px; font-weight: 600; color: #434843; margin-bottom: 6px;">Email</label>
            <input v-model="email" type="email" required placeholder="admin@agronusa.co.id"
              style="width: 100%; padding: 12px 16px; border-radius: 10px; border: 1px solid rgba(24,28,29,0.12); background: white; font-size: 15px; color: #181C1D; outline: none; box-sizing: border-box;"
              @focus="$el.style.borderColor='#1B3022'; $el.style.boxShadow='0 0 0 3px rgba(27,48,34,0.12)'"
            />
          </div>
          <div>
            <label style="display: block; font-size: 13px; font-weight: 600; color: #434843; margin-bottom: 6px;">Password</label>
            <input v-model="password" type="password" required placeholder="••••••••"
              style="width: 100%; padding: 12px 16px; border-radius: 10px; border: 1px solid rgba(24,28,29,0.12); background: white; font-size: 15px; color: #181C1D; outline: none; box-sizing: border-box;"
              @focus="$el.style.borderColor='#1B3022'; $el.style.boxShadow='0 0 0 3px rgba(27,48,34,0.12)'"
            />
          </div>
          <p v-if="authError" style="color: #BA1A1A; font-size: 13px; margin: 0;">{{ authError }}</p>
          <button type="submit" style="width: 100%; padding: 12px; border: none; border-radius: 12px; background: #1B3022; color: white; font-size: 15px; font-weight: 600; cursor: pointer; transition: all 0.2s;"
            @mouseenter="$el.style.opacity='0.9'" @mouseleave="$el.style.opacity='1'">
            Sign In
          </button>
        </form>
      </div>
    </div>

    <!-- Admin dashboard -->
    <div v-else-if="user" style="display: flex; flex-direction: column; min-height: 100vh;">
      <!-- Top Bar Navigation -->
      <header style="position: sticky; top: 0; z-index: 50; backdrop-filter: blur(24px) saturate(180%); -webkit-backdrop-filter: blur(24px) saturate(180%); background: rgba(255,255,255,0.85); border-bottom: 1px solid rgba(24,28,29,0.06); box-shadow: 0 4px 24px rgba(24,28,29,0.04);">
        <div style="max-width: 1440px; margin: 0 auto; padding: 0 24px; height: 64px; display: flex; align-items: center; justify-content: space-between;">
          <!-- Left: Hamburger (mobile) + Logo + Company Name -->
          <button class="adm-hamburger" @click="mobileNavOpen = !mobileNavOpen" aria-label="Open menu">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#181C1D" stroke-width="2" stroke-linecap="round"><line x1="3" y1="6" x2="21" y2="6"/><line x1="3" y1="12" x2="21" y2="12"/><line x1="3" y1="18" x2="21" y2="18"/></svg>
          </button>
          <NuxtLink :to="`/${adminPath}/dashboard`" style="display: flex; align-items: center; gap: 12px; text-decoration: none; flex-shrink: 0;">
            <div style="width: 36px; height: 36px; border-radius: 10px; background: #1B3022; display: flex; align-items: center; justify-content: center; overflow: hidden;">
              <img v-if="companyLogo" :src="companyLogo" alt="" style="width: 100%; height: 100%; object-fit: contain;" />
              <svg v-else width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2"><path d="M12 2L2 7l10 5 10-5-10-5z"/><path d="M2 17l10 5 10-5"/><path d="M2 12l10 5 10-5"/></svg>
            </div>
            <span class="adm-brand-text" style="font-family: 'Source Serif 4', serif; font-size: 17px; font-weight: 700; color: #1B3022; white-space: nowrap;">{{ companyName }}</span>
          </NuxtLink>

          <!-- Center: Nav Menu (desktop only; drawer on mobile) -->
          <nav class="adm-nav" style="display: flex; align-items: center; gap: 4px;">
            <NuxtLink :to="`/${adminPath}/dashboard`" :class="navClass('dashboard')">Dashboard</NuxtLink>
            <NuxtLink :to="`/${adminPath}/products`" :class="navClass('products')">Products</NuxtLink>
            <NuxtLink :to="`/${adminPath}/gallery`" :class="navClass('gallery')">Gallery</NuxtLink>
            <NuxtLink :to="`/${adminPath}/home`" :class="navClass('home')">Home</NuxtLink>
            <NuxtLink :to="`/${adminPath}/about`" :class="navClass('about')">About</NuxtLink>
            <NuxtLink :to="`/${adminPath}/company`" :class="navClass('company')">Company</NuxtLink>
            <NuxtLink :to="`/${adminPath}/messages`" :class="navClass('messages')">Messages</NuxtLink>
          </nav>

          <!-- Right: User Avatar + Name + Sign Out (desktop only; drawer has sign out on mobile) -->
          <div class="adm-user-menu" style="position: relative; flex-shrink: 0;">
            <button @click="showUserMenu = !showUserMenu"
              style="display: flex; align-items: center; gap: 10px; padding: 6px 12px 6px 6px; border: 1px solid rgba(24,28,29,0.08); border-radius: 100px; background: transparent; cursor: pointer; transition: all 0.2s;"
              @mouseenter="$el.style.background='rgba(27,48,34,0.04)'" @mouseleave="$el.style.background='transparent'">
              <div style="width: 32px; height: 32px; border-radius: 50%; background: #1B3022; display: flex; align-items: center; justify-content: center; color: white; font-size: 13px; font-weight: 600;">
                {{ (user.email?.charAt(0) || 'A').toUpperCase() }}
              </div>
              <span style="font-size: 13px; font-weight: 500; color: #181C1D; max-width: 140px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">{{ user.email }}</span>
              <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#737973" stroke-width="2" style="transition: transform 0.2s;" :style="showUserMenu ? 'transform: rotate(180deg)' : ''"><path d="M6 9l6 6 6-6"/></svg>
            </button>

            <!-- Dropdown -->
            <div v-if="showUserMenu" style="position: absolute; right: 0; top: calc(100% + 8px); width: 200px; background: white; border-radius: 12px; box-shadow: 0 8px 32px rgba(24,28,29,0.12); border: 1px solid rgba(24,28,29,0.06); padding: 6px; z-index: 60;">
              <div style="padding: 10px 12px; border-bottom: 1px solid rgba(24,28,29,0.06); margin-bottom: 4px;">
                <p style="font-size: 13px; font-weight: 600; color: #181C1D; margin: 0;">{{ user.email }}</p>
                <p style="font-size: 11px; color: #737973; margin: 2px 0 0;">Administrator</p>
              </div>
              <button @click="signOut"
                style="width: 100%; padding: 10px 12px; border: none; border-radius: 8px; background: transparent; font-size: 13px; color: #BA1A1A; font-weight: 500; cursor: pointer; text-align: left; display: flex; align-items: center; gap: 8px; transition: background 0.15s;"
                @mouseenter="$el.style.background='rgba(186,26,26,0.06)'" @mouseleave="$el.style.background='transparent'">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#BA1A1A" stroke-width="2"><path d="M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
                Sign Out
              </button>
            </div>
          </div>
        </div>
      </header>

      <!-- Mobile drawer (aside) + backdrop -->
      <Teleport to="body">
        <aside class="adm-drawer" :class="{ open: mobileNavOpen }">
          <div style="display: flex; align-items: center; justify-content: space-between; padding: 16px 20px; border-bottom: 1px solid rgba(24,28,29,0.06); flex-shrink: 0;">
            <div style="display: flex; align-items: center; gap: 10px;">
              <div style="width: 34px; height: 34px; border-radius: 10px; background: #1B3022; display: flex; align-items: center; justify-content: center; overflow: hidden;">
                <img v-if="companyLogo" :src="companyLogo" alt="" style="width: 100%; height: 100%; object-fit: contain;" />
                <svg v-else width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2"><path d="M12 2L2 7l10 5 10-5-10-5z"/><path d="M2 17l10 5 10-5"/><path d="M2 12l10 5 10-5"/></svg>
              </div>
              <span style="font-family: 'Source Serif 4', serif; font-size: 16px; font-weight: 700; color: #1B3022; white-space: nowrap;">{{ companyName }}</span>
            </div>
            <button @click="mobileNavOpen = false" aria-label="Close menu" style="width: 34px; height: 34px; border-radius: 8px; border: none; background: rgba(24,28,29,0.05); cursor: pointer; display: flex; align-items: center; justify-content: center;">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#434843" stroke-width="2" stroke-linecap="round"><path d="M6 6l12 12M18 6l-12 12"/></svg>
            </button>
          </div>
          <nav style="flex: 1; overflow-y: auto; padding: 12px; display: flex; flex-direction: column; gap: 4px;">
            <NuxtLink :to="`/${adminPath}/dashboard`" :class="navClass('dashboard')" @click="mobileNavOpen = false">Dashboard</NuxtLink>
            <NuxtLink :to="`/${adminPath}/products`" :class="navClass('products')" @click="mobileNavOpen = false">Products</NuxtLink>
            <NuxtLink :to="`/${adminPath}/gallery`" :class="navClass('gallery')" @click="mobileNavOpen = false">Gallery</NuxtLink>
            <NuxtLink :to="`/${adminPath}/home`" :class="navClass('home')" @click="mobileNavOpen = false">Home</NuxtLink>
            <NuxtLink :to="`/${adminPath}/about`" :class="navClass('about')" @click="mobileNavOpen = false">About</NuxtLink>
            <NuxtLink :to="`/${adminPath}/company`" :class="navClass('company')" @click="mobileNavOpen = false">Company</NuxtLink>
            <NuxtLink :to="`/${adminPath}/messages`" :class="navClass('messages')" @click="mobileNavOpen = false">Messages</NuxtLink>
          </nav>
          <div style="padding: 12px; border-top: 1px solid rgba(24,28,29,0.06); flex-shrink: 0;">
            <button @click="signOut"
              style="width: 100%; padding: 10px 12px; border: none; border-radius: 8px; background: rgba(186,26,26,0.06); font-size: 13px; color: #BA1A1A; font-weight: 600; cursor: pointer; display: flex; align-items: center; gap: 8px; justify-content: center;">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#BA1A1A" stroke-width="2"><path d="M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
              Sign Out
            </button>
          </div>
        </aside>
        <div class="adm-backdrop" :class="{ open: mobileNavOpen }" @click="mobileNavOpen = false"></div>
      </Teleport>

      <!-- Main content -->
      <main class="adm-main" style="flex: 1; padding: 32px 24px; max-width: 1440px; margin: 0 auto; width: 100%; box-sizing: border-box;">
        <AdminDashboard v-if="section === 'dashboard'" />
        <AdminProducts v-else-if="section === 'products' && !slug" />
        <AdminProductEditor v-else-if="section === 'products' && slug" :id="slug" />
        <AdminGallery v-else-if="section === 'gallery'" />
        <AdminHome v-else-if="section === 'home'" />
        <AdminAbout v-else-if="section === 'about'" />
        <AdminCompany v-else-if="section === 'company'" />
        <AdminMessages v-else-if="section === 'messages'" />
        <div v-else style="text-align: center; padding: 48px 0; color: #737973; font-size: 15px;">Select a section from the navigation.</div>
      </main>
    </div>

    <!-- Loading -->
    <div v-else style="min-height: 100vh; display: flex; align-items: center; justify-content: center;">
      <div style="width: 28px; height: 28px; border: 2px solid #1B3022; border-top-color: transparent; border-radius: 50%; animation: adminSpin 0.6s linear infinite;"></div>
    </div>
  </div>
</template>

<style>
@keyframes adminSpin {
  to { transform: rotate(360deg); }
}
</style>
