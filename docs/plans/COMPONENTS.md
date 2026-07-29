# Component Catalog

> All components are auto-imported by Nuxt 4 from `app/components/`. No manual imports needed.

## Layout Components

### AppHeader.vue
**Location**: `app/components/layout/AppHeader.vue`

**Props**: None (uses `useViewport()`, `useTheme()` composables)

**Emits**:
```typescript
interface Emits {
  'toggle-menu': []
  'navigate': [sectionId: string]
}
```

**Features**:
- Fixed top, transparent → solid on scroll
- Logo + navigation links (anchor to `#section-id`)
- Active section highlight via IntersectionObserver (scroll spy)
- Mobile hamburger menu toggle
- **Theme switcher (dark/light/system)**
- Keyboard accessible (focus visible)

---

### AppFooter.vue
**Location**: `app/components/layout/AppFooter.vue`

**Props**: None (uses `useRuntimeConfig()` for company info)

**Features**:
- Company info, contact, social links
- Copyright notice
- WhatsApp link

---

### MobileMenu.vue
**Location**: `app/components/layout/MobileMenu.vue`

**Props**: None (reads `useUiStore().mobileMenuOpen`)

**Emits**: `close`, `navigate`

**Features**:
- Full-screen overlay (mobile)
- Slide-in animation
- Section navigation
- Auto-close on navigation
- Focus trap

---

### ThemeSwitcher.vue
**Location**: `app/components/layout/ThemeSwitcher.vue`

**Props**:
```typescript
interface Props {
  variant?: 'icon' | 'text' | 'dropdown'
  showLabel?: boolean
}
```

**Emits**:
```typescript
interface Emits {
  'theme-change': [theme: ThemeMode]
}
```

**Features**:
- Three modes: dark / light / system
- Persists preference in localStorage
- Syncs with OS preference via `prefers-color-scheme`
- Icon-based toggle (sun/moon/monitor)
- Keyboard accessible
- Updates `html.dark` class for Tailwind dark mode

---

### Container.vue
**Location**: `app/components/common/Container.vue`

**Props**:
```typescript
interface Props {
  size?: 'sm' | 'md' | 'lg' | 'xl' | 'full'
  tag?: 'div' | 'section' | 'main' | 'article'
}
```

**Features**:
- Max-width constraints per size
- Horizontal padding responsive
- Centered content

---

### Section.vue
**Location**: `app/components/common/Section.vue`

**Props**:
```typescript
interface Props {
  id: string
  class?: string
  fullViewport?: boolean
  'aria-label'?: string
}
```

**Features**:
- `height: 100dvh` when `fullViewport`
- `scroll-snap-align: start` for CSS scroll snap
- `scroll-snap-stop: always` to prevent skipping
- Semantic `<section>` with ARIA label
- **Design**: section-gap (120px desktop / 64px mobile) for breathing room between sections

---

### Button.vue
**Location**: `app/components/common/Button.vue`

**Props**:
```typescript
interface Props {
  variant?: 'primary' | 'secondary' | 'outline' | 'ghost' | 'whatsapp'
  size?: 'sm' | 'md' | 'lg'
  disabled?: boolean
  loading?: boolean
  type?: 'button' | 'submit' | 'reset'
  href?: string
}
```

**Emits**: `click`

**Features**:
- Tailwind variants
- Loading spinner
- WhatsApp variant (green, icon)
- **Design**: Deep Forest Green (#1B3022) bg with white text; 4px rounded (slightly sharp); ghost variant with 1px border for secondary actions

---

### Icon.vue
**Location**: `app/components/common/Icon.vue`

**Props**:
```typescript
interface Props {
  name: string
  size?: number | string
  class?: string
}
```

**Features**:
- SVG sprite or component-based icons
- Size prop (default 24)

---

## Section Components

### CompanySection.vue
**Location**: `app/components/sections/CompanySection.vue`

**Props**: None (fetches company data from Supabase via `createClient()`)

**Features**:
- Full viewport (100dvh) with hero background
- Headline + subheadline + CTA buttons
- Company story, mission, vision, values
- Two-column layout (desktop), stacked (mobile)
- Value cards with icons
- Scroll indicator (animated arrow)
- **Design**: display-lg typography for headline; glassmorphism card for value cards with backdrop-blur

---

### ProductsSection.vue
**Location**: `app/components/sections/ProductsSection.vue`

**Props**: None (uses `useProducts()` composable)

**Features**:
- Category filter tabs (All, Cocopeat, Cocofiber)
- ProductSwiper for each category
- Click → open ProductDetailOverlay

---

### GallerySection.vue
**Location**: `app/components/sections/GallerySection.vue`

**Props**: None (uses `useGallery()` composable)

**Features**:
- Category filter
- GallerySwiper component
- Click → open GalleryDetailOverlay

---

### ContactSection.vue
**Location**: `app/components/sections/ContactSection.vue`

**Props**: None (uses `useRuntimeConfig()` for contact info)

**Features**:
- Contact form (Formspree / Cloudflare Functions)
- WhatsApp click-to-chat with prefilled message
- Office info cards
- Embedded map (iframe)
- **Design**: Form inputs use bottom-border-only focus state in Deep Forest Green; Hanken Grotesk body-md for labels

---

## Product Components

### ProductCard.vue
**Location**: `app/components/products/ProductCard.vue`

**Props**:
```typescript
interface Props {
  product: Product
  variant?: 'default' | 'compact'
}
```

**Emits**:
```typescript
interface Emits {
  select: [product: Product]
}
```

**Features**:
- Product image (lazy load, WebP)
- Category badge
- Name, short description
- Specs preview (3 key specs)
- "View Details" button

---

### ProductSwiper.vue
**Location**: `app/components/products/ProductSwiper.vue`

**Props**:
```typescript
interface Props {
  products: Product[]
  category?: ProductCategory
  slidesPerView?: {
    mobile: number
    tablet: number
    desktop: number
  }
}
```

**Emits**:
```typescript
interface Emits {
  select: [product: Product]
}
```

**Features**:
- SwiperJS integration
- Loop mode
- Navigation arrows
- Pagination bullets (active: Primary Green, inactive: Slate Gray)
- Breakpoint-responsive slidesPerView
- **Design**: Glassmorphic product cards with backdrop-blur; label-caps for product badges

---

### ProductDetailOverlay.vue
**Location**: `app/components/products/ProductDetailOverlay.vue`

**Props**: None (reads from `useUiStore().productOverlay`)

**Emits**:
```typescript
interface Emits {
  close: []
  inquire: [product: Product]
}
```

**Features**:
- Full-screen overlay (fixed inset-0, z-50)
- Backdrop blur + click to close
- Focus trap
- Escape key to close
- Product gallery (thumbnails + main image)
- Full specifications table
- Applications list
- Certifications badges
- WhatsApp inquiry button

---

## Gallery Components

### GallerySwiper.vue
**Location**: `app/components/gallery/GallerySwiper.vue`

**Props**:
```typescript
interface Props {
  items: GalleryItem[]
  category?: GalleryCategory
}
```

**Emits**:
```typescript
interface Emits {
  open: [index: number]
}
```

**Features**:
- Thumbnail strip + main view
- SwiperJS with loop
- Category filter
- Click → emit open with index
- **Design**: Glassmorphic card style; pagination bullets use Primary Green active, Slate Gray inactive

---

### GalleryDetailOverlay.vue
**Location**: `app/components/gallery/GalleryDetailOverlay.vue`

**Props**: None (reads from `useUiStore().galleryOverlay`)

**Emits**:
```typescript
interface Emits {
  close: []
  navigate: [index: number]
}
```

**Features**:
- Fullscreen lightbox
- Swipe navigation
- Keyboard arrows (← →)
- Zoom/pan on image
- Caption with title, description
- Close button (top-right)
- Counter (X of Y)
- Focus trap

---

## Composables (Auto-imported from `app/composables/`)

### useProducts.ts
```typescript
export function useProducts() {
  const config = useRuntimeConfig()
  const supabase = createClient(config.public.supabaseUrl, config.public.supabaseKey)
  const products = ref<Product[]>([])
  const categories = ref<ProductCategoryInfo[]>([])
  const activeCategory = ref<ProductCategory | 'all'>('all')
  const loading = ref(false)

  const fetchProducts = async () => {
    loading.value = true
    const { data } = await supabase
      .from('products')
      .select('*')
      .order('sort_order')
    if (data) products.value = data
    loading.value = false
  }

  const filtered = computed(() =>
    activeCategory.value === 'all'
      ? products.value
      : products.value.filter(p => p.category === activeCategory.value)
  )

  const getBySlug = (slug: string) => products.value.find(p => p.slug === slug)
  const getByCategory = (cat: ProductCategory) => products.value.filter(p => p.category === cat)

  return { products, categories, activeCategory, filtered, loading, fetchProducts, getBySlug, getByCategory }
}
```

---

### useGallery.ts
```typescript
export function useGallery() {
  const config = useRuntimeConfig()
  const supabase = createClient(config.public.supabaseUrl, config.public.supabaseKey)
  const items = ref<GalleryItem[]>([])
  const categories = ref<GalleryCategoryInfo[]>([])
  const activeCategory = ref<GalleryCategory | 'all'>('all')
  const loading = ref(false)

  const fetchItems = async () => {
    loading.value = true
    const { data } = await supabase
      .from('gallery_items')
      .select('*')
      .order('sort_order')
    if (data) items.value = data
    loading.value = false
  }

  const filtered = computed(() =>
    activeCategory.value === 'all'
      ? items.value
      : items.value.filter(i => i.category === activeCategory.value)
  )

  return { items, categories, activeCategory, filtered, loading, fetchItems }
}
```

---

### useOverlay.ts
```typescript
export function useProductOverlay() {
  const uiStore = useUiStore()
  const openOverlay = (p: Product) => uiStore.openProductOverlay(p)
  const closeOverlay = () => uiStore.closeProductOverlay()
  return { open: computed(() => uiStore.productOverlay.open), product: computed(() => uiStore.productOverlay.product), openOverlay, closeOverlay }
}

export function useGalleryOverlay() {
  const uiStore = useUiStore()
  const openOverlay = (i: number, items: GalleryItem[]) => uiStore.openGalleryOverlay(i, items)
  const closeOverlay = () => uiStore.closeGalleryOverlay()
  return { open: computed(() => uiStore.galleryOverlay.open), items: computed(() => uiStore.galleryOverlay.items), index: computed(() => uiStore.galleryOverlay.index), openOverlay, closeOverlay }
}
```

---

### useViewport.ts
```typescript
export function useViewport() {
  const breakpoints = useBreakpoints({ mobile: 640, tablet: 1024, desktop: 1280 })
  const isMobile = breakpoints.smaller('tablet')
  const isTablet = breakpoints.between('tablet', 'desktop')
  const isDesktop = breakpoints.greaterOrEqual('desktop')
  
  const currentSection = ref(0)
  const sectionIds = ['company', 'products', 'gallery', 'contact']

  // Section detection using vueuse IntersectionObserver
  const targetMap = new Map()
  onMounted(() => {
    sectionIds.forEach(id => {
      const el = document.getElementById(id)
      if (!el) return
      targetMap.set(id, useIntersectionObserver(
        el,
        ([entry]) => {
          if (entry.isIntersecting) currentSection.value = sectionIds.indexOf(id)
        },
        { rootMargin: '-50% 0px -50% 0px' }
      ))
    })
  })

  // Keyboard navigation
  const scrollToSection = (index: number) => {
    const el = document.getElementById(sectionIds[index])
    if (el) el.scrollIntoView({ behavior: 'smooth' })
  }

  // Mobile swipe via VueUse
  const swipeTarget = ref(null)
  const { direction } = useSwipe(swipeTarget)
  watch(direction, (dir) => {
    if (dir === 'up') scrollToSection(currentSection.value + 1)
    if (dir === 'down') scrollToSection(currentSection.value - 1)
  })

  return { currentSection, sectionIds, isMobile, isTablet, isDesktop, scrollToSection, swipeTarget }
}
```

---

### useTheme.ts
```typescript
export function useTheme() {
  const preferredDark = usePreferredDark()
  const colorMode = useColorMode({ storageKey: 'theme' })
  
  // Sync with system preference when mode is 'auto'
  const theme = computed(() => colorMode.value)
  const resolvedTheme = computed(() => 
    colorMode.value === 'auto' 
      ? (preferredDark.value ? 'dark' : 'light') 
      : colorMode.value
  )

  const setTheme = (newTheme: 'light' | 'dark' | 'system') => {
    colorMode.value = newTheme === 'system' ? 'auto' : newTheme
  }
  
  const toggleTheme = () => {
    colorMode.value = resolvedTheme.value === 'dark' ? 'light' : 'dark'
  }

  return { theme, resolvedTheme, setTheme, toggleTheme, preferredDark }
}
      html.classList.remove('dark')
    }
  }
  
  onMounted(() => {
    applyTheme()
    if (theme.value === 'system') {
      window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', applyTheme)
    }
  })
  
  onUnmounted(() => {
    window.matchMedia('(prefers-color-scheme: dark)').removeEventListener('change', applyTheme)
  })
  
  return { theme, resolvedTheme, setTheme, toggleTheme }
}
```

## Data Files (Supabase Tables — no static data files)

All content is stored in Supabase PostgreSQL, not in static TypeScript files.
The `app/data/` directory is not needed. Composables fetch directly via Supabase client.

### Supabase: products table
```sql
-- Products table
CREATE TABLE products (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  category TEXT NOT NULL CHECK (category IN ('cocopeat', 'cocofiber')),
  slug TEXT UNIQUE NOT NULL,
  short_description TEXT,
  description TEXT,
  images TEXT[],
  thumbnail TEXT,
  specifications JSONB DEFAULT '[]',
  applications TEXT[] DEFAULT '{}',
  packaging JSONB DEFAULT '{}',
  moq TEXT,
  lead_time TEXT,
  origin TEXT DEFAULT 'Indonesia',
  sort_order INT DEFAULT 0,
  published BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public can view published products" ON products
  FOR SELECT TO anon, authenticated
  USING (published = true);
CREATE POLICY "Admin can manage products" ON products
  FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);
```

---

### Supabase: gallery_items table
```sql
CREATE TABLE gallery_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  category TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  image TEXT NOT NULL,
  thumbnail TEXT,
  alt TEXT,
  sort_order INT DEFAULT 0,
  published BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE gallery_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public can view published gallery" ON gallery_items
  FOR SELECT TO anon, authenticated
  USING (published = true);
CREATE POLICY "Admin can manage gallery" ON gallery_items
  FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);
```

---

### Supabase: company_info table
```sql
CREATE TABLE company_info (
  id INT PRIMARY KEY DEFAULT 1,
  name TEXT NOT NULL,
  tagline TEXT,
  mission TEXT,
  vision TEXT,
  values JSONB DEFAULT '[]',
  description TEXT,
  logo_url TEXT,
  contact JSONB DEFAULT '{}',
  social JSONB DEFAULT '{}',
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT single_row CHECK (id = 1)
);

ALTER TABLE company_info ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public can view company info" ON company_info
  FOR SELECT TO anon, authenticated
  USING (true);
CREATE POLICY "Admin can update company info" ON company_info
  FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);
```

---

## Pinia Store

### ui.ts
```typescript
export const useUiStore = defineStore('ui', () => {
  // Overlay
  const productOverlay = ref({ open: false, product: null as Product | null })
  const galleryOverlay = ref({ open: false, items: [] as GalleryItem[], index: 0 })
  
  // Viewport
  const currentSection = ref(0)
  const sectionCount = ref(4)
  const sectionIds = ref(['company', 'products', 'gallery', 'contact'])

  // Mobile
  const mobileMenuOpen = ref(false)
  
  // Actions
  function openProductOverlay(product: Product) { productOverlay.value = { open: true, product } }
  function closeProductOverlay() { productOverlay.value = { open: false, product: null } }
  function openGalleryOverlay(index: number, items: GalleryItem[]) { galleryOverlay.value = { open: true, items, index } }
  function closeGalleryOverlay() { galleryOverlay.value = { open: false, items: [], index: 0 } }
  function scrollToSection(index: number) { ... }
  
  return { productOverlay, galleryOverlay, currentSection, sectionCount, sectionIds, mobileMenuOpen, openProductOverlay, closeProductOverlay, openGalleryOverlay, closeGalleryOverlay, scrollToSection }
})
```

---

## Component Registry

| Component | File | Category |
|-----------|------|----------|
| AppHeader | layout/AppHeader.vue | Layout |
| AppFooter | layout/AppFooter.vue | Layout |
| MobileMenu | layout/MobileMenu.vue | Layout |
| Container | common/Container.vue | Common |
| Section | common/Section.vue | Common |
| Button | common/Button.vue | Common |
| Icon | common/Icon.vue | Common |
| CompanySection | sections/CompanySection.vue | Section |
| ProductsSection | sections/ProductsSection.vue | Section |
| GallerySection | sections/GallerySection.vue | Section |
| ContactSection | sections/ContactSection.vue | Section |
| ProductCard | products/ProductCard.vue | Product |
| ProductSwiper | products/ProductSwiper.vue | Product |
| ProductDetailOverlay | products/ProductDetailOverlay.vue | Product |
| GallerySwiper | gallery/GallerySwiper.vue | Gallery |
| GalleryDetailOverlay | gallery/GalleryDetailOverlay.vue | Gallery |