# Dynamic Admin Pages

## Overview
Configurable admin panel path that can be changed anytime via environment variable. Instead of hardcoded `/admin`, the admin path is dynamic and supports nested routes like `/{path}/content/{slug}`.

---

## Security & Flexibility

- **Configurable path**: Change admin URL anytime via env var (no rebuild needed)
- **Obfuscation layer**: Hide admin panel behind a custom path
- **Nested routes**: Full admin structure under dynamic base path
- **No impact on public routes**: Public SPA routes remain unchanged

---

## Implementation Strategy

### Option A: Middleware-Based (Recommended for Nuxt 4)

Uses a catch-all route with middleware that validates against runtime config.

**How it works:**
1. Admin pages live in `app/pages/[...admin].vue` (catch-all)
2. Middleware checks if the path prefix matches `NUXT_PUBLIC_ADMIN_PATH`
3. If match → render admin panel; if not → 404
4. Admin sub-routes like content/[slug] are parsed from the path

**Pros:**
- No build-time config needed
- Can change path anytime via env var
- One catch-all file, no route generation

**Cons:**
- Slightly more complex routing logic
- All admin routes go through one file

### Option B: Dynamic Route Generation (Build Time)

Uses a Nuxt module or hook to generate routes at build time based on env var.

**How it works:**
1. A Nuxt module reads `NUXT_ADMIN_PATH` at build time
2. Generates routes dynamically: `/{adminPath}/content/[slug].vue`
3. Rebuild required to change path

**Pros:**
- Clean route structure
- Nuxt auto-imports work naturally

**Cons:**
- Rebuild needed to change path
- More complex setup

---

## Recommended: Option A (Middleware-Based)

### Environment Variable

```env
# .env.production (can be changed anytime)
NUXT_PUBLIC_ADMIN_PATH="admin"  # Default; change to any string
```

### nuxt.config.ts
```typescript
export default defineNuxtConfig({
  runtimeConfig: {
    public: {
      adminPath: 'admin', // default; overridable via NUXT_PUBLIC_ADMIN_PATH
    }
  },
  
  // SPA mode (no server-side rendering)
  ssr: false,
})
```

### Route Structure

```
app/pages/
├── index.vue                # Public landing page (5 sections)
├── [...admin].vue           # Catch-all admin route
└── admin/                   # Admin files for auto-imports
    ├── components/
    ├── composables/
    ├── layouts/
    │   └── admin.vue        # Admin layout (sidebar, header)
    ├── middleware/
    │   └── auth.ts          # Admin auth guard
    ├── pages/
    │   ├── dashboard.vue    # /{adminPath}/dashboard
    │   ├── content/         # /{adminPath}/content/...
    │   │   ├── index.vue    # Content list
    │   │   └── [slug].vue   # Edit content
    │   ├── media.vue        # Media library
    │   └── settings.vue     # Settings
    └── stores/
        └── admin.ts         # Admin state
```

### Catch-All Route Logic (`[...admin].vue`)

```vue
<script setup lang="ts">
const route = useRoute()
const config = useRuntimeConfig()
const adminPath = config.public.adminPath

// Extract the admin path from route params
// route.params.admin = ['admin', 'content', 'my-page'] for /admin/content/my-page
const params = route.params.admin as string[]
const matched = params[0] === adminPath

if (!matched) {
  throw createError({ statusCode: 404, statusMessage: 'Page Not Found' })
}

// Extract sub-route
// ['admin', 'content', 'my-page'] → { section: 'content', slug: 'my-page' }
// ['admin', 'dashboard'] → { section: 'dashboard', slug: undefined }
// ['admin'] → { section: undefined, slug: undefined }
const subRoute = {
  section: params[1] || 'dashboard',
  slug: params.slice(2).join('/') || undefined,
}

// Use inline component imports matching sub-route
// Or use a dynamic component resolver
</script>

<template>
  <AdminLayout>
    <AdminDashboard v-if="subRoute.section === 'dashboard'" />
    <AdminContentList v-else-if="subRoute.section === 'content' && !subRoute.slug" />
    <AdminContentEditor v-else-if="subRoute.section === 'content' && subRoute.slug" :slug="subRoute.slug" />
    <AdminProducts v-else-if="subRoute.section === 'products' && !subRoute.slug" />
    <AdminProductEditor v-else-if="subRoute.section === 'products' && subRoute.slug" :id="subRoute.slug" />
    <AdminGallery v-else-if="subRoute.section === 'gallery'" />
    <AdminCompany v-else-if="subRoute.section === 'company'" />
    <AdminMedia v-else-if="subRoute.section === 'media'" />
    <AdminSettings v-else-if="subRoute.section === 'settings'" />
    <NuxtError :error="createError({ statusCode: 404 })" v-else />
  </AdminLayout>
</template>
```

---

## Admin Sub-Routes

| Path | Component | Description |
|------|-----------|-------------|
| `/{adminPath}` | Dashboard | Admin dashboard with stats |
| `/{adminPath}/dashboard` | Dashboard | Same as above |
| `/{adminPath}/content` | ContentList | Product/gallery/company CRUD |
| `/{adminPath}/content/{slug}` | ContentEditor | Edit specific content |
| `/{adminPath}/products` | AdminProducts | Product list + create/edit/delete |
| `/{adminPath}/products/{id}` | AdminProductEditor | Edit single product |
| `/{adminPath}/gallery` | AdminGallery | Gallery image CRUD |
| `/{adminPath}/company` | AdminCompany | Company profile editor |
| `/{adminPath}/media` | Media | Cloudflare R2 media library |
| `/{adminPath}/settings` | Settings | Admin settings |

---

## Admin Layout (`admin/layouts/admin.vue`)

```vue
<template>
  <div class="admin-layout">
    <aside class="admin-sidebar">
      <nav>
        <NuxtLink :to="`/${adminPath}/dashboard`">Dashboard</NuxtLink>
        <NuxtLink :to="`/${adminPath}/content`">Content</NuxtLink>
        <NuxtLink :to="`/${adminPath}/media`">Media</NuxtLink>
        <NuxtLink :to="`/${adminPath}/settings`">Settings</NuxtLink>
      </nav>
    </aside>
    <main class="admin-main">
      <slot />
    </main>
  </div>
</template>
```

---

## Admin Auth Middleware (`admin/middleware/auth.ts`)

```typescript
export default defineNuxtRouteMiddleware((to, from) => {
  const config = useRuntimeConfig()
  const adminPath = config.public.adminPath
  const params = to.params.admin as string[]
  
  // Check if this is an admin route
  if (params?.[0] === adminPath) {
    // Check authentication (example)
    const token = useCookie('auth_token')
    if (!token.value) {
      return navigateTo('/')
    }
  }
})
```

---

## Admin Store (`admin/stores/admin.ts`)

```typescript
export const useAdminStore = defineStore('admin', () => {
  const config = useRuntimeConfig()
  const adminPath = config.public.adminPath
  
  const currentSection = ref('dashboard')
  const sidebarOpen = ref(true)
  
  const adminLinks = computed(() => [
    { label: 'Dashboard', icon: 'layout-dashboard', to: `/${adminPath}/dashboard` },
    { label: 'Products', icon: 'package', to: `/${adminPath}/products` },
    { label: 'Gallery', icon: 'image', to: `/${adminPath}/gallery` },
    { label: 'Company', icon: 'building', to: `/${adminPath}/company` },
    { label: 'Media', icon: 'cloud', to: `/${adminPath}/media` },
    { label: 'Settings', icon: 'settings', to: `/${adminPath}/settings` },
  ])
  
  return { adminPath, currentSection, sidebarOpen, adminLinks }
})
```

---

## Changing the Admin Path

### At Runtime (no rebuild)
```env
NUXT_PUBLIC_ADMIN_PATH="dashboard"    # /{path}?admin=true
NUXT_PUBLIC_ADMIN_PATH="cms"          # /cms/dashboard
NUXT_PUBLIC_ADMIN_PATH="portal"       # /portal/content/product-1
NUXT_PUBLIC_ADMIN_PATH="manage"       # /manage/media
```

Just update the environment variable in Cloudflare Pages dashboard → redeploy.

### Via UI (future enhancement)
```typescript
// Admin settings page
const updateAdminPath = async (newPath: string) => {
  await $fetch('/api/admin/update-path', {
    method: 'POST',
    body: { path: newPath }
  })
  // Cloudflare Pages rebuild triggered via webhook
  // Or use Cloudflare KV to store dynamic config
}
```

---

## Security Considerations

| Concern | Solution |
|---------|----------|
| Path guessing | Use UUID-like path: `NUXT_PUBLIC_ADMIN_PATH="a7x9k2m"` |
| Brute force | Rate limiting on auth endpoint |
| Unauthenticated access | Middleware redirects to `/` |
| Session hijacking | HTTP-only cookies, CSRF tokens |
| XSS | Output encoding, CSP headers |

---

## File Structure

```
app/
├── pages/
│   ├── index.vue                    # Public SPA landing page
│   └── [...admin].vue               # Catch-all admin route
├── admin/                           # Admin components (auto-imported)
│   ├── layouts/
│   │   └── admin.vue                # Admin layout
│   ├── middleware/
│   │   └── auth.ts                  # Admin auth guard
│   ├── components/
│   │   ├── AdminSidebar.vue
│   │   ├── AdminHeader.vue
│   │   ├── AdminDashboard.vue
│   │   ├── AdminContentList.vue
│   │   ├── AdminContentEditor.vue
│   │   ├── AdminMedia.vue
│   │   └── AdminSettings.vue
│   ├── composables/
│   │   └── useAdminMenu.ts
│   └── stores/
│       └── admin.ts
├── components/                      # Public components
│   └── ...                          # Existing public components
└── composables/                     # Public composables
    └── ...                          # Existing public composables
```

---

## How It Works (User Flow)

1. User navigates to `/{adminPath}/content/my-product`
2. Vue Router matches `[...admin].vue` catch-all
3. Middleware checks `params[0] === adminPath` → if not, 404
4. Admin layout renders with sidebar navigation
5. Dynamic component loads based on sub-route
6. Auth middleware checks for valid session
7. If authenticated → admin panel renders
8. If not → redirect to public landing page

---

## Updating the Plan Document (PROJECT_PLAN.md)

Add to the Project Structure section in PROJECT_PLAN.md:

```
├── app/
│   ├── pages/
│   │   ├── index.vue                    # Public landing page
│   │   └── [...admin].vue               # Dynamic admin catch-all
│   ├── admin/                           # Admin components
│   │   ├── layouts/admin.vue
│   │   ├── middleware/auth.ts
│   │   ├── components/
│   │   ├── composables/
│   │   └── stores/admin.ts
│   └── ...                              # Public components
```

Add to Key Features:
```
- **Dynamic admin path** - Configurable via env var, change anytime
- **Admin sub-routes** - Content, Media, Settings under custom path
- **Auth middleware** - Protects admin routes from unauthorized access
```