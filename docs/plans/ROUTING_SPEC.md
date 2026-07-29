# Routing & Navigation Specification

## Overview
Single route (`/`) with 5 full-viewport sections. Pure SPA navigation via anchor links + CSS Scroll Snap. No page reloads, no traditional scrolling.

---

## Route Configuration

### Only Route
```
/
```

- **File**: `app/pages/index.vue`
- **Type**: Static generation (`nuxt generate`)
- **Prerender**: `nitro.prerender.routes = ['/']`

### No Other Routes
- No `/products`, `/gallery`, `/about`, etc.
- No dynamic routes (`/product/:id`, `/gallery/:id`)
- All content rendered in `index.vue`

---

## Navigation

### Anchor Links (in AppHeader, MobileMenu)
```html
<nav>
  <a href="#company">Company</a>
  <a href="#products">Products</a>
  <a href="#gallery">Gallery</a>
  <a href="#contact">Contact</a>
</nav>
```

### Section IDs (in Section.vue)
```vue
<Section id="company" full-viewport>...</Section>
<Section id="products" full-viewport>...</Section>
<Section id="gallery" full-viewport>...</Section>
<Section id="contact" full-viewport>...</Section>
```

### Scroll Behavior
- **CSS Scroll Snap**: Native browser scroll snap (no JS scroll libraries)
- **Smooth Scroll**: `html { scroll-behavior: smooth }` (respects `prefers-reduced-motion`)
- **Trigger**: Click anchor link → browser smooth scrolls → CSS snap locks to section

---

## Scroll Snap Implementation

### CSS (in main.css)
```css
/* Root scroll container */
html {
  scroll-snap-type: y mandatory;
  scroll-behavior: smooth;
  overflow-y: auto;
  overflow-x: hidden;
}

/* Reduced motion support */
@media (prefers-reduced-motion: reduce) {
  html {
    scroll-behavior: auto;
  }
}

/* Each section */
.section {
  height: 100vh;
  height: 100dvh;
  scroll-snap-align: start;
  scroll-snap-stop: always; /* Prevent skipping on fast scroll */
  display: flex;
  flex-direction: column;
  justify-content: center;
  position: relative;
}

/* Mobile touch: native scroll with snap, no JS interference */
```

### Section Component (Section.vue)
```vue
<script setup lang="ts">
interface Props {
  id: string
  fullViewport?: boolean
  class?: string
  'aria-label'?: string
}
const props = defineProps<Props>()
</script>

<template>
  <section
    :id="id"
    :class="['section', { 'full-viewport': fullViewport }, class]"
    :aria-label="ariaLabel"
  >
    <slot />
  </section>
</template>
```

---

## SPA Fallback (Cloudflare Pages)

### public/_redirects
```
/*  /index.html  200
```

### Cloudflare Pages Config
- **Build**: `bun run generate`
- **Output**: `.output/public`
- **SPA Mode**: Handled by `_redirects` (no `_routes.json` needed)

---

## Keyboard Navigation

| Key | Action |
|-----|--------|
| `ArrowDown` / `PageDown` | Next section |
| `ArrowUp` / `PageUp` | Previous section |
| `Home` | First section (Company)
| `End` | Last section (Contact) |
| `Tab` | Focus next interactive element |
| `Enter` / `Space` | Activate focused link/button |

### Implementation (useViewport.ts with @vueuse/core)
```typescript
import { useIntersectionObserver, useSwipe } from '@vueuse/core'

export function useViewport() {
  const currentSection = ref(0)
  const sectionIds = ['company', 'products', 'gallery', 'contact']

  // IntersectionObserver for scroll spy (updates header active link)
  onMounted(() => {
    sectionIds.forEach(id => {
      const el = document.getElementById(id)
      if (!el) return
      useIntersectionObserver(
        el,
        ([entry]) => {
          if (entry.isIntersecting) currentSection.value = sectionIds.indexOf(id)
        },
        { rootMargin: '-50% 0px -50% 0px' }
      )
    })

  // Keyboard navigation
  const handleKeydown = (e: KeyboardEvent) => {
    const { key } = e
    const max = sectionIds.length - 1
    
    if (['ArrowDown', 'PageDown'].includes(key)) {
      e.preventDefault()
      scrollToSection(Math.min(currentSection.value + 1, max))
    } else if (['ArrowUp', 'PageUp'].includes(key)) {
      e.preventDefault()
      scrollToSection(Math.max(currentSection.value - 1, 0))
    } else if (key === 'Home') {
      e.preventDefault()
      scrollToSection(0)
    } else if (key === 'End') {
      e.preventDefault()
      scrollToSection(max)
    }
  }

  onMounted(() => {
    sectionIds.forEach(id => {
      const el = document.getElementById(id)
      if (el) observer.observe(el)
    })
    window.addEventListener('keydown', handleKeydown)
  })

  onUnmounted(() => {
    window.removeEventListener('keydown', handleKeydown)
    observer.disconnect()
  })

  const scrollToSection = (index: number) => {
    const el = document.getElementById(sectionIds[index])
    if (el) el.scrollIntoView({ behavior: 'smooth' })
  }

  return { currentSection, sectionIds, scrollToSection }
}
```

---

## Mobile Touch Behavior

- **Native scroll** with CSS snap (no JS touch handlers)
- **No pull-to-refresh interference** (CSS snap handles it)
- **iOS Safari**: `height: 100dvh` for dynamic viewport
- **Android Chrome**: Native momentum scroll + snap

---

## Accessibility

| Requirement | Implementation |
|-------------|----------------|
| Semantic sections | `<section id="...">` with `aria-label` |
| Focus visible | `:focus-visible` on all interactive elements |
| Skip to main | `<a href="#main" class="skip-link">Skip to content</a>` |
| Reduced motion | `@media (prefers-reduced-motion: reduce)` disables smooth scroll |
| Screen reader | Section changes announced via `aria-live` region |
| Focus trap | In overlays (ProductDetailOverlay, GalleryDetailOverlay) |

---

## What NOT to Implement

| ❌ Don't Do | Reason |
|-------------|--------|
| `vue-router` push/replace for sections | Use anchor links (`#id`) |
| `window.scrollTo()` programmatically | CSS snap handles it |
| Separate `/product/:id` routes | Product detail in overlay |
| Separate `/gallery/:id` routes | Gallery detail in overlay |
| Infinite scroll / pagination | All content in 5 sections |
| Traditional scrolling | CSS scroll snap only |

---

## File References

| File | Purpose |
|------|---------|
| `app/pages/index.vue` | Only page, composes all sections |
| `app/components/common/Section.vue` | Section wrapper with scroll-snap |
| `app/components/layout/AppHeader.vue` | Navigation with anchor links |
| `app/components/layout/MobileMenu.vue` | Mobile nav with anchor links |
| `app/composables/useViewport.ts` | Scroll spy, keyboard nav, IntersectionObserver |
| `app/assets/css/main.css` | CSS Scroll Snap styles |
| `public/_redirects` | SPA fallback for Cloudflare Pages |
| `nuxt.config.ts` | `ssr: false`, `nitro.prerender.routes: ['/']` |

---

## Testing Checklist

- [ ] `bun run generate` produces only `.output/public/index.html`
- [ ] Click header nav → smooth scrolls to section → snaps
- [ ] Mobile swipe scroll → snaps to next section
- [ ] Fast scroll → `scroll-snap-stop: always` prevents skipping
- [ ] Keyboard arrows → navigate sections
- [ ] `prefers-reduced-motion` → instant scroll, no animation
- [ ] Direct URL `/#products` → loads index.html → scrolls to products
- [ ] Refresh on `/#gallery` → stays on gallery section
- [ ] Overlay open → body scroll locked, focus trapped
- [ ] Overlay close → focus returns to trigger element