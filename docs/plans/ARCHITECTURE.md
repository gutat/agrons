# Architecture Overview

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Browser / SPA                            │
├─────────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │  Nuxt App    │  │  Vue Router  │  │  Pinia Store (ui)    │  │
│  │  (SPA/SSG)   │◄─┤  (auto)      │  │  - overlay state     │  │
│  └──────┬───────┘  └──────────────┘  │  - viewport state    │  │
│         │                             │  - mobile menu       │  │
│         ▼                             └──────────────────────┘  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    Components Layer                       │  │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌───────────────┐  │  │
│  │  │ Layout  │ │ Sections│ │ Products│ │   Gallery     │  │  │
│  │  │ Header/ │ │ Company │ │ Swiper/ │ │   Swiper/     │  │  │
│  │  │ Footer  │ │ About/  │ │ Overlay │ │   Overlay     │  │  │
│  │  └─────────┘ └─────────┘ └─────────┘ └───────────────┘  │  │
│  └──────────────────────────────────────────────────────────┘  │
│         │                              │                        │
│         ▼                              ▼                        │
│  ┌──────────────────┐       ┌──────────────────┐               │
│  │   Composables    │       │   Data Layer     │               │
│  │  useProducts()   │       │  products.ts     │               │
│  │  useGallery()    │       │  gallery.ts      │               │
│  │  useOverlay()    │       │  company.ts      │               │
│  │  useViewport()   │       └──────────────────┘               │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Cloudflare R2 (Images)                        │
│  ┌──────────────────────────────────────────────────────────┐  │
│  Bucket: agro-nusa-images                                │  │
│  Paths: products/, gallery/, company/          │  │
│  Public: https://pub-<hash>.r2.dev                       │  │
└──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

## Data Flow

### Supabase (via @supabase/supabase-js)
- **Products**, **Gallery items**, **Company profile** stored in Supabase PostgreSQL
- Fetched at runtime via `createClient()` from `@supabase/supabase-js`
- Public anon key + RLS policies allow read access to published content
- Admin users authenticate to write/update content

### Client-Side Fetching Pattern
```typescript
// app/utils/supabase.ts
import { createClient } from '@supabase/supabase-js'

const config = useRuntimeConfig()
export const supabase = createClient(config.public.supabaseUrl, config.public.supabaseKey)

// app/composables/useProducts.ts
const { data: products } = await supabase.from('products').select('*').order('sort_order')
```
- Supabase client initialized once in `app/utils/supabase.ts`
- Data fetched on component mount
- Cached in Pinia store for session persistence
- No static data files — all content lives in DB

### Image Data (Cloudflare R2)
- All images stored in Cloudflare R2 bucket
- Public URLs: `https://pub-<hash>.r2.dev/products/image.webp`
- Image URLs stored in Supabase rows (products.images, gallery_items.image)

### Runtime State (Pinia)
- `uiStore`: Overlay visibility, current product/gallery item, viewport section, mobile menu
- **Content cache**: Products, gallery, company data cached after first fetch
- Auto-imported via `@pinia/nuxt`

### Component Communication
- **Parent → Child**: Props (typed interfaces)
- **Child → Parent**: Emits (typed events)
- **Cross-component**: Pinia store (overlay, viewport, cached content)
- **Auto-imports**: Vue/Nuxt composables (`ref`, `computed`, `onMounted`, etc.)

## Nuxt 4 Configuration

### nuxt.config.ts
```typescript
export default defineNuxtConfig({
  compatibilityDate: '2025-07-15',
  devtools: { enabled: true },
  
  // SPA mode (no server-side rendering)
  ssr: false,
  
  // Modules
  modules: [
    '@pinia/nuxt',
  ],
  
  // CSS
  css: ['~/assets/css/main.css'],
  
  // Runtime config
  runtimeConfig: {
    // Server-side only (not exposed to client)
    r2AccessKeyId: '',
    r2SecretAccessKey: '',
    r2BucketName: '',
    r2AccountId: '',
    
    // Exposed to client
    public: {
      appUrl: '',
      r2PublicUrl: '',
      supabaseUrl: '',
      supabaseKey: '',
      whatsappNumber: '',
      whatsappMessage: '',
      mapEmbedUrl: '',
      adminPath: 'admin',
      defaultTheme: 'system',
    }
  },
  
  // App config
  app: {
    head: {
      title: 'PT Agro Nusa Sejahtera',
      meta: [
        { name: 'description', content: 'Premium Cocopeat & Cocofiber from Indonesia' },
        { property: 'og:title', content: 'PT Agro Nusa Sejahtera' },
        { property: 'og:description', content: 'Premium Cocopeat & Cocofiber from Indonesia' },
        { property: 'og:type', content: 'website' },
        { name: 'twitter:card', content: 'summary_large_image' },
      ],
      link: [
        { rel: 'icon', type: 'image/x-icon', href: '/favicon.ico' },
      ]
    }
  },
  
  // Nitro config (for static generation)
  nitro: {
    prerender: {
      routes: ['/']
    }
  }
})
```

## Design System

See `DESIGN.md` for the full color palette, typography specs, spacing, and component styles.

### Font Loading
- **Source Serif 4** (Google Fonts) — Display/headline weights: 600, 700
- **Hanken Grotesk** (Google Fonts) — Body/label weights: 400, 700
- Preloaded via `app.head.link` in `nuxt.config.ts`
- `font-display: swap` for performance

### Color Tokens (Tailwind CSS)
Colors are defined in Tailwind CSS config. Light and dark mode via `dark:` variant.

| Token Role | Light Mode | Dark Mode | Usage |
|-----------|------------|-----------|-------|
| **Primary** | `#1B3022` | `#B4CDB8` | Main CTAs, header text |
| **Surface** | `#F7FAFB` | `#121414` | Page background |
| **Surface Container** | `#EBEEEF` | `#1E2021` | Cards, panels |
| **Secondary** | `#7E562E` | `#F1BC8C` | Accents, icons |
| **On Surface** | `#181C1D` | `#EEF1F2` | Body text |
| **Outline** | `#737973` | `#8D938D` | Borders, dividers |

### Typography
| Style | Font | Size | Weight | Line Ht | Usage |
|-------|------|------|--------|---------|-------|
| `display-lg` | Source Serif 4 | 64px (40px mob) | 700 | 72px | Hero headline |
| `headline-md` | Source Serif 4 | 32px | 600 | 40px | Section headings |
| `body-lg` | Hanken Grotesk | 18px | 400 | 28px | Body text |
| `body-md` | Hanken Grotesk | 16px | 400 | 24px | Cards, descriptions |
| `label-caps` | Hanken Grotesk | 12px | 700 | 16px | UI labels, badges |

### Spacing & Layout
- Container max: 1280px, gutter: 24px, mobile margin: 20px
- Section gap: 120px desktop / 64px mobile
- 12-column grid desktop, single-column mobile

### Elevation (Glassmorphism)
- Cards: `backdrop-filter: blur(12px-20px)` with semi-transparent fill
- Borders: 1px, low-contrast at 10% opacity
- CTA shadows: diffused, tinted with Primary Green

## Cloudflare R2 Integration

### R2 Client Setup (`server/utils/r2.ts`)
```typescript
import { S3Client, GetObjectCommand, PutObjectCommand } from '@aws-sdk/client-s3'
import { getSignedUrl } from '@aws-sdk/s3-request-presigner'

const config = useRuntimeConfig()

const r2 = new S3Client({
  region: 'auto',
  endpoint: `https://${config.r2AccountId}.r2.cloudflarestorage.com`,
  credentials: {
    accessKeyId: config.r2AccessKeyId,
    secretAccessKey: config.r2SecretAccessKey,
  },
})

export async function getPresignedUploadUrl(key: string, contentType: string) {
  const command = new PutObjectCommand({
    Bucket: config.r2BucketName,
    Key: key,
    ContentType: contentType,
  })
  return getSignedUrl(r2, command, { expiresIn: 3600 })
}

export async function deleteR2Object(key: string) {
  const command = new DeleteObjectCommand({
    Bucket: config.r2BucketName,
    Key: key,
  })
  await r2.send(command)
}
```

### Image URL Pattern
```
https://pub-<hash>.r2.dev/
├── products/
│   ├── cocopeat-block-5kg-hero.webp
│   ├── cocopeat-block-5kg-thumb.webp
│   └── ...
├── gallery/
│   ├── production-1.webp
│   └── ...
├── company/
│   ├── logo.svg
│   ├── hero.webp
│   └── ...
```

### Environment Variables
```env
# Server-side (not exposed to client)
R2_ACCESS_KEY_ID="..."
R2_SECRET_ACCESS_KEY="..."
R2_BUCKET_NAME="agro-nusa-images"
R2_ACCOUNT_ID="..."

# Client-side (public URL)
NUXT_PUBLIC_R2_PUBLIC_URL="https://pub-<hash>.r2.dev"
```

## Rendering Strategy

### SPA Mode + Static Generation
- **`ssr: false`**: All pages render client-side (SPA behavior)
- **`nuxt generate`**: Pre-renders HTML shell at build time
- **Hydration**: Client-side JavaScript takes over after initial HTML load
- **Benefits**: SEO-friendly initial HTML, fast client-side navigation

### Full-Viewport Sections with CSS Scroll Snap
```css
/* Root scroll container */
html {
  scroll-snap-type: y mandatory;
  scroll-behavior: smooth;
  overflow-y: auto;
  overflow-x: hidden;
}

body {
  height: 100%;
}

.section {
  height: 100vh;
  height: 100dvh; /* Dynamic viewport for mobile */
  scroll-snap-align: start;
  scroll-snap-stop: always; /* Prevent skipping sections on fast scroll */
  display: flex;
  flex-direction: column;
  justify-content: center;
  position: relative;
}

/* Reduced motion support */
@media (prefers-reduced-motion: reduce) {
  html {
    scroll-behavior: auto;
  }
}
```

**Key Features:**
- **Auto-snap on scroll/wheel/touch** - Each section locks into view
- **No page reload** - Pure SPA, anchor links (`#section-id`) trigger smooth scroll
- **Keyboard navigation** - ArrowUp/Down, Home, End, PageUp/PageDown
- **Scroll spy** - IntersectionObserver updates active section in header
- **Mobile touch** - Native scroll with snap, no JS interference

## VueUse Integration

### Module Setup
```bash
bun add @vueuse/core @vueuse/motion @vueuse/nuxt
```

```typescript
// nuxt.config.ts
modules: [
  '@pinia/nuxt',
  '@vueuse/nuxt',
],
```

### Replacing Custom Composables with VueUse

| Custom Composable | Replaced By | Benefit |
|-------------------|-------------|---------|
| `useViewport()` — IntersectionObserver | `useIntersectionObserver()` from @vueuse/core | Simpler, tested, SSR-safe |
| `useViewport()` — `isMobile/Tablet/Desktop` | `useBreakpoints()` + `useMediaQuery()` | Tailwind breakpoint sync, reactive |
| `useViewport()` — keyboard nav | Keep custom (simple) | — |
| `useTheme()` — `prefers-color-scheme` | `usePreferredDark()` + `useColorMode()` | Auto-sync, persisted |
| Custom swipe detection | `useSwipe()` from @vueuse/core | Touch-native, direction detection |
| Custom scroll spy | `useScroll()` + `useIntersectionObserver()` | Reactive scroll position |

### Section Entry Animations (v-motion)

```vue
<template>
  <section v-motion-fade-visible-once class="section" :id="id">
    <div v-motion-slide-visible-left class="content">
      <slot />
    </div>
  </section>
</template>
```

### Swipe Between Sections (Mobile)

```typescript
import { useSwipe } from '@vueuse/core'

const target = ref(null)
const { direction, length } = useSwipe(target)

watch(direction, (dir) => {
  if (dir === 'up') scrollToSection(currentSection.value + 1)
  if (dir === 'down') scrollToSection(currentSection.value - 1)
})
```

## Decorative Swiper

### Product Swiper
- Horizontal loop carousel
- 1 slide mobile, 2 tablet, 3 desktop
- Click card → open `ProductDetailOverlay`
- Keyboard accessible (Enter/Space to open)
- Category tabs (Cocopeat / Cocofiber) filter the swiper

### Gallery Swiper
- Horizontal loop with thumbnails or pagination
- Click → open `GalleryDetailOverlay` (fullscreen lightbox)
- Swipe to navigate in overlay
- Category filter (production, factory, certifications, team)

## State Management (Pinia)

```typescript
// app/stores/ui.ts
export const useUiStore = defineStore('ui', () => {
  // Overlay
  const productOverlay = ref({ open: false, product: null })
  const galleryOverlay = ref({ open: false, items: [], index: 0 })
  
  // Viewport
  const currentSection = ref(0)
  const sectionCount = ref(4)
  const sectionIds = ref(['company', 'products', 'gallery', 'contact'])

  // Theme
  const theme = ref<'light' | 'dark' | 'system'>('system')
  const resolvedTheme = computed(() => theme.value === 'system' 
    ? (window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light')
    : theme.value)

  // Mobile
  const mobileMenuOpen = ref(false)
  
  // Actions
  function openProductOverlay(product) { ... }
  function closeProductOverlay() { ... }
  function openGalleryOverlay(index, items) { ... }
  function closeGalleryOverlay() { ... }
  function scrollToSection(index) { ... }

  // Theme actions
  function setTheme(newTheme: 'light' | 'dark' | 'system') {
    theme.value = newTheme
    applyTheme()
  }
  function toggleTheme() {
    theme.value = resolvedTheme.value === 'dark' ? 'light' : 'dark'
    applyTheme()
  }
  function applyTheme() {
    const html = document.documentElement
    if (resolvedTheme.value === 'dark') {
      html.classList.add('dark')
    } else {
      html.classList.remove('dark')
    }
  }

  return { productOverlay, galleryOverlay, currentSection, sectionCount, sectionIds, mobileMenuOpen, theme, resolvedTheme, openProductOverlay, closeProductOverlay, openGalleryOverlay, closeGalleryOverlay, scrollToSection, setTheme, toggleTheme }
})
```

## Nuxt Auto-Imports

Nuxt 4 auto-imports Vue and Nuxt composables:
- **Vue**: `ref`, `computed`, `onMounted`, `watch`, `nextTick`, etc.
- **Nuxt**: `useRoute`, `useRouter`, `useHead`, `useSeoMeta`, `useRuntimeConfig`, `useState`, etc.
- **Custom composables**: Place in `app/composables/` for auto-import
- **Components**: Place in `app/components/` for auto-import (nested dirs supported)

## TypeScript Strategy

- **Strict mode** enabled via `tsconfig.json`
- **Nuxt types**: Auto-generated in `.nuxt/` directory
- **Component props/emits**: Fully typed via `defineProps<>()` / `defineEmits<>()`
- **Composables**: Return typed refs/computed
- **Data files**: Export typed constants with `as const`
- **Runtime config**: Typed via `useRuntimeConfig()`

## Performance

- **Code splitting**: Dynamic imports for overlays, heavy sections
- **Image optimization**: WebP/AVIF, responsive sizes, lazy load (via R2 CDN)
- **Font optimization**: Preload, `font-display: swap`
- **CSS**: Tailwind CSS via Nuxt UI, purge unused
- **Dark Mode**: Tailwind `dark:` variant, `class` strategy, system preference detection via `useTheme()`
- **Bundle**: Nitro rollup chunks (vendor, swiper, app)
- **CDN**: Cloudflare R2 for images (global edge delivery)

## Accessibility (WCAG 2.1 AA)

- Semantic HTML5 (`<section>`, `<header>`, `<footer>`, `<main>`)
- ARIA labels on interactive elements
- Focus management in overlays (trap focus, restore on close)
- Keyboard navigation throughout
- Color contrast ratios
- Reduced motion support (`prefers-reduced-motion`)
- Screen reader announcements for section changes

## SEO & Meta

- **Per-route meta**: `useHead()` / `useSeoMeta()` in pages/components
- **JSON-LD**: Organization, Product, WebSite
- **Sitemap**: `@nuxtjs/sitemap` module (optional)
- **Robots.txt**: `@nuxtjs/robots` module (optional)
- **Canonical URLs**: Set via `useHead()`

## PWA Features (Optional)

- **@vite-pwa/nuxt**: PWA support for Nuxt
- **Manifest**: `display: standalone`, theme colors, icons
- **Service Worker**: Workbox (cache-first static, stale-while-revalidate images)
- **Offline**: Fallback page, cached content
- **Install prompt**: Beforeinstallprompt handling