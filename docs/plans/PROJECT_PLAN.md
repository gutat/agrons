# PT Agro Nusa Sejahtera - Project Plan

## Project Overview
Single Page Application (SPA) for PT Agro Nusa Sejahtera - Premium Cocopeat and Cocofiber Products from Indonesia. Public landing page with 5 full-viewport sections + dynamic admin panel at configurable path. All content managed via Supabase (no static data files).

## Tech Stack
- **Nuxt 4** (Vue 3, Nitro, TypeScript)
- **Vue 3** (Composition API, `<script setup>`)
- **Nuxt UI** (component library)
- **Tailwind CSS 4** with custom design tokens (colors, typography, spacing)
- **Pinia** (state management, `@pinia/nuxt`)
- **SwiperJS 11** (touch carousels)
- **VueUse** (`@vueuse/core` + `@vueuse/motion`) — scroll spy, swipe detection, scroll-triggered animations
- **Supabase** (`@supabase/supabase-js`) — PostgreSQL database for all content + admin auth
- **Cloudflare R2** (image storage via S3-compatible API)
- **TypeScript** (strict mode)
- **Bun** (package manager)

## Rendering Mode
- **SPA mode** (`ssr: false`) - Client-side rendering, no server-side rendering
- **Static generation** (`nuxt generate`) - Pre-rendered HTML at build time
- **SSG + SPA hybrid** - Static HTML shell, content fetched from Supabase at runtime
- **Runtime data** - Products, gallery, and company profile fetched from Supabase via `createClient()`

## Project Structure
```
agrons/
├── docs/                    # Documentation
│   ├── plans/               # Plan files
├── public/                  # Static assets (served as-is)
│   ├── favicon.ico
│   ├── _headers
│   ├── _redirects
│   └── robots.txt
├── app/                     # Nuxt 4 app directory
│   ├── app.vue              # Root app component
│   ├── pages/
│   │   ├── index.vue        # Public landing page (all sections)
│   │   └── [...admin].vue   # Dynamic admin catch-all
│   ├── admin/               # Admin components
│   │   ├── layouts/admin.vue
│   │   ├── middleware/auth.ts
│   │   ├── components/
│   │   │   ├── AdminDashboard.vue
│   │   │   ├── AdminContentList.vue
│   │   │   ├── AdminContentEditor.vue
│   │   │   ├── AdminProducts.vue
│   │   │   ├── AdminGallery.vue
│   │   │   ├── AdminCompany.vue
│   │   │   └── AdminSettings.vue
│   │   ├── composables/
│   │   │   └── useAdminMenu.ts
│   │   └── stores/
│   │       └── admin.ts
│   ├── components/          # Public Vue components (auto-imported)
│   │   ├── common/
│   │   │   ├── Button.vue, Container.vue, Section.vue, Icon.vue
│   │   ├── layout/
│   │   │   ├── AppHeader.vue, AppFooter.vue, MobileMenu.vue, ThemeSwitcher.vue
│   │   ├── sections/
│   │   │   ├── CompanySection.vue, ProductsSection.vue
│   │   │   ├── GallerySection.vue, ContactSection.vue
│   │   ├── products/
│   │   │   ├── ProductCard.vue, ProductSwiper.vue, ProductDetailOverlay.vue
│   │   └── gallery/
│   │       ├── GallerySwiper.vue, GalleryDetailOverlay.vue
│   ├── composables/
│   │   ├── useProducts.ts, useGallery.ts, useOverlay.ts, useViewport.ts
│   ├── stores/
│   │   └── ui.ts
│   ├── assets/css/main.css
│   └── types/index.ts
├── server/
│   ├── api/r2/
│   └── utils/r2.ts
├── nuxt.config.ts
├── package.json
└── README.md
```

## Sections
1. **Home** - Hero section with brand intro, RotatingText tagline, CTA buttons
2. **About** - Mission, vision, values, company background
3. **Products** - Cocopeat & Cocofiber tabs, CircularGallery, tap overlay
4. **Gallery** - Masonry grid, tap fullscreen overlay
5. **Contact** - Reach out card, WhatsApp integration, map

## Database (Supabase)
All content stored in Supabase PostgreSQL tables:
- **products** - id, name, category, description, specs, images, slug
- **gallery_items** - id, category, title, description, image
- **company_info** - single row: name, tagline, mission, vision, values, contact
- **contact_submissions** - form submissions from visitors
- **admin_users** - authenticated admin accounts


## Key Features
- **Full-viewport CSS Scroll Snap** — 5 sections, auto-snap
- **Animated section entry** — via BlurText, vue-bits animations
- **Supabase content** — All data fetched at runtime, editable via admin
- **Dynamic admin** — CRUD pages for products, gallery, company profile
- **vue-bits animations** — Aurora, LightPillar, CircularGallery, Masonry, BlurText, RotatingText, TrueFocus, ShinyText
- **Dark/Light theme** — System preference + manual toggle
- **Cloudflare R2** — Image storage
- **WhatsApp integration** — Floating button, prefilled inquiries
