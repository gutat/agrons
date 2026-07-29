# Data Structures & API

## TypeScript Interfaces

### Core Product Types

```typescript
// src/types/product.ts

export interface Specification {
  name: string
  value: string
  unit?: string
}

export interface PackagingInfo {
  type: 'block' | 'bale' | 'bag' | 'pallet' | 'container'
  weight: string           // e.g., "5kg", "25kg", "1 ton"
  dimensions?: string      // e.g., "30x30x15 cm"
  pallet?: string          // e.g., "200 blocks/pallet"
  containerLoad?: string   // e.g., "20 tons/20ft"
}

export interface Product {
  // Identity
  id: string               // kebab-case, unique: "cocopeat-block-5kg"
  name: string             // Display name: "Cocopeat Block 5kg"
  category: ProductCategory
  slug: string             // URL-friendly: "cocopeat-block-5kg"
  
  // Content
  shortDescription: string // Max 160 chars for card/SEO
  description: string      // Full HTML/Markdown description
  
  // Media
  images: string[]         // WebP URLs, ordered: [hero, detail1, detail2...]
  thumbnail: string        // WebP, 400x300 for cards
  gallery?: string[]       // Additional gallery images
  
  // Specifications
  specifications: Specification[]
  
  // Usage
  applications: string[]   // ["Seed starting", "Hydroponics", ...]
  certifications: string[] // ["RHP", "OMRI", "ISO 9001", ...]
  
  // Logistics
  packaging: PackagingInfo
  moq: string              // "1x20ft Container (~10 tons)"
  leadTime: string         // "2-3 weeks"
  origin: string           // "Indonesia"
  hsCode?: string          // Harmonized System code
  incoterms?: string[]     // ["FOB", "CIF", "EXW"]
  
  // SEO
  metaTitle?: string
  metaDescription?: string
  ogImage?: string
}

export type ProductCategory = 'cocopeat' | 'cocofiber'

export interface ProductCategoryInfo {
  id: ProductCategory
  name: string
  description: string
  icon: string             // Icon name from Icon component
  image: string            // Category hero image
  productCount: number
}
```

### Gallery Types

```typescript
// src/types/gallery.ts

export interface GalleryItem {
  id: string
  category: GalleryCategory
  title: string
  description: string
  image: string            // Full-size WebP (1920w)
  thumbnail: string        // WebP (400w)
  alt: string              // Accessibility
  // Optional metadata
  location?: string        // "Medan Factory, Indonesia"
  date?: string            // "2024-03-15"
  tags?: string[]          // ["washing", "buffering", "automation"]
  // SEO
  metaTitle?: string
  metaDescription?: string
}

export type GalleryCategory = 
  | 'all'
  | 'production'      // Manufacturing process
  | 'factory'         // Facility, machinery
  | 'certifications'  // Certificates, audits
  | 'team'            // Staff, workers
  | 'products'        // Product close-ups
  | 'logistics'       // Loading, shipping
  | 'farm'            // Coconut farms

export interface GalleryCategoryInfo {
  id: GalleryCategory
  name: string
  description: string
  icon: string
  count: number
}
```


```typescript
// src/types/company.ts

export interface CompanyInfo {
  name: string
  legalName: string        // "PT Agro Nusa Sejahtera"
  tagline: string
  shortDescription: string // One paragraph
  description: string      // Full about content
  
  // Mission & Vision
  mission: string
  vision: string
  
  // Values
  values: CompanyValue[]

  // Contact
  contact: ContactInfo
  
  // Social
  social: SocialLink[]
  
  // Legal
  registrationNumber: string
  taxId: string
  establishedYear: number
}

export interface CompanyValue {
  icon: string
  title: string
  description: string
}

export interface ContactInfo {
  address: Address
  phone: string
  fax?: string
  email: string
  whatsapp: string
  whatsappLink: string     // "https://wa.me/6281234567890?text=..."
  mapEmbed: string         // Google Maps iframe src
  mapLat: number
  mapLng: number
  businessHours: BusinessHours
}

export interface Address {
  street: string
  city: string
  province: string
  postalCode: string
  country: string
  formatted: string        // Full formatted address
}

export interface BusinessHours {
  weekdays: string         // "08:00 - 17:00 WIB"
  saturday: string         // "08:00 - 13:00 WIB"
  sunday: string           // "Closed"
  timezone: string         // "Asia/Jakarta"
}

export interface SocialLink {
  platform: 'linkedin' | 'instagram' | 'facebook' | 'youtube' | 'twitter'
  url: string
  handle?: string
}
```

### Form Types

```typescript
// src/types/form.ts

export interface ContactFormData {
  name: string
  email: string
  company?: string
  country: string
  phone?: string
  productInterest: ProductCategory[]
  message: string
  inquiryType: 'general' | 'quote' | 'sample' | 'partnership' | 'technical'
  // Hidden
  source: string           // "website-contact-form"
  utmSource?: string
  utmMedium?: string
  utmCampaign?: string
}

export interface FormField {
  name: keyof ContactFormData
  label: string
  type: 'text' | 'email' | 'tel' | 'select' | 'multiselect' | 'textarea' | 'checkbox'
  required: boolean
  placeholder?: string
  options?: { value: string; label: string }[]
  validation?: {
    minLength?: number
    maxLength?: number
    pattern?: string
    message?: string
  }
}
```

### UI State Types

```typescript
// src/types/ui.ts

export type ThemeMode = 'light' | 'dark' | 'system'

interface UIState {
  // Overlays
  productOverlay: OverlayState<Product>
  galleryOverlay: GalleryOverlayState

  // Viewport
  currentSection: number
  sectionIds: string[]

  // Theme
  theme: ThemeMode
  resolvedTheme: 'light' | 'dark'

  // Mobile
  mobileMenuOpen: boolean

  // Loading
  imagesLoading: Set<string>

  // Notifications
  toast: Toast | null
}

export interface OverlayState<T> {
  open: boolean
  data: T | null
  loading: boolean
}

export interface GalleryOverlayState {
  open: boolean
  items: GalleryItem[]
  index: number
  loading: boolean
}

export interface Toast {
  id: string
  type: 'success' | 'error' | 'warning' | 'info'
  title: string
  message?: string
  duration?: number
  action?: { label: string; onClick: () => void }
}
```

## Data Files Structure

```
src/data/
├── products.ts       # Product[] + ProductCategoryInfo[]
├── gallery.ts        # GalleryItem[] + GalleryCategoryInfo[]

├── company.ts        # CompanyInfo
├── forms.ts          # FormField[] for contact form
└── index.ts          # Barrel export
```

## Sample Data (products.ts)

```typescript
// src/data/products.ts
import type { Product, ProductCategoryInfo } from '@/types/product'

export const productCategories: ProductCategoryInfo[] = [
  {
    id: 'cocopeat',
    name: 'Cocopeat Products',
    description: 'Premium growing media from coconut husk pith',
    icon: 'leaf',
    image: '/images/categories/cocopeat-hero.webp',
    productCount: 8
  },
  {
    id: 'cocofiber',
    name: 'Cocofiber Products',
    description: 'Natural coconut fiber for industrial applications',
    icon: 'package',
    image: '/images/categories/cocofiber-hero.webp',
    productCount: 5
  }
]

export const products: Product[] = [
  // COCOPEAT
  {
    id: 'cocopeat-block-5kg',
    name: 'Cocopeat Block 5kg',
    category: 'cocopeat',
    slug: 'cocopeat-block-5kg',
    shortDescription: 'Premium compressed cocopeat block for professional horticulture',
    description: `
      <p>Our 5kg cocopeat blocks are manufactured from carefully selected coconut husks...</p>
      <h3>Key Benefits</h3>
      <ul>
        <li>Low EC (< 0.5 mS/cm) - safe for sensitive seedlings</li>
        <li>Optimal pH (5.5-6.5) - ready to use</li>
        <li>High water retention (8-9x weight)</li>
        <li>Excellent aeration for root development</li>
      </ul>
    `,
    images: [
      '/images/products/cocopeat-block-5kg-hero.webp',
      '/images/products/cocopeat-block-5kg-detail-1.webp',
      '/images/products/cocopeat-block-5kg-detail-2.webp'
    ],
    thumbnail: '/images/products/cocopeat-block-5kg-thumb.webp',
    gallery: [
      '/images/products/cocopeat-block-5kg-gallery-1.webp',
      '/images/products/cocopeat-block-5kg-gallery-2.webp'
    ],
    specifications: [
      { name: 'EC', value: '< 0.5', unit: 'mS/cm' },
      { name: 'pH', value: '5.5 - 6.5', unit: '' },
      { name: 'Moisture', value: '< 15', unit: '%' },
      { name: 'Expansion Ratio', value: '15-18', unit: 'L/kg' },
      { name: 'Fiber Content', value: '< 5', unit: '%' },
      { name: 'Particle Size', value: '0-5', unit: 'mm' }
    ],
    applications: [
      'Seed starting & propagation',
      'Hydroponic systems (NFT, DWC, drip)',
      'Greenhouse vegetable production',
      'Container gardening',
      'Soil amendment & conditioning',
      'Landscaping & turf establishment'
    ],
    certifications: ['RHP', 'OMRI Listed', 'ISO 9001:2015', 'ISO 14001:2015'],
    packaging: {
      type: 'block',
      weight: '5 kg',
      dimensions: '30 x 30 x 15 cm',
      pallet: '200 blocks',
      containerLoad: '20 tons / 20ft container'
    },
    moq: '1x20ft Container (~10 tons / 2000 blocks)',
    leadTime: '2-3 weeks after order confirmation',
    origin: 'Medan, North Sumatra, Indonesia',
    hsCode: '1404.90.90',
    incoterms: ['FOB Belawan', 'CIF', 'EXW Factory'],
    metaTitle: 'Cocopeat Block 5kg | Premium Growing Media | PT Agro Nusa Sejahtera',
    metaDescription: 'Professional 5kg cocopeat blocks with low EC, optimal pH. RHP & OMRI certified. Ideal for hydroponics, greenhouses, and seed starting. Export worldwide.',
    ogImage: '/images/products/cocopeat-block-5kg-og.webp'
  },
  
  {
    id: 'cocopeat-growbag-100l',
    name: 'Cocopeat Grow Bag 100L',
    category: 'cocopeat',
    slug: 'cocopeat-growbag-100l',
    shortDescription: 'Ready-to-use grow bags for commercial greenhouse production',
    description: 'Pre-buffered, pre-fertilized grow bags...',
    images: [
      '/images/products/cocopeat-growbag-100l-hero.webp',
      '/images/products/cocopeat-growbag-100l-detail-1.webp'
    ],
    thumbnail: '/images/products/cocopeat-growbag-100l-thumb.webp',
    specifications: [
      { name: 'Volume', value: '100', unit: 'L' },
      { name: 'EC', value: '< 0.8', unit: 'mS/cm' },
      { name: 'pH', value: '5.5 - 6.5', unit: '' },
      { name: 'Pre-fertilized', value: 'Yes', unit: '' },
      { name: 'Bag Material', value: 'UV-stabilized PE', unit: '' }
    ],
    applications: [
      'Tomato, cucumber, pepper greenhouse production',
      'Strawberry cultivation',
      'Cut flower production',
      'Medical cannabis (where legal)'
    ],
    certifications: ['RHP', 'ISO 9001:2015'],
    packaging: {
      type: 'bag',
      weight: '~12 kg',
      dimensions: '100 x 20 x 15 cm',
      pallet: '36 bags',
      containerLoad: '18 pallets / 20ft'
    },
    moq: '1x20ft Container (648 bags)',
    leadTime: '3-4 weeks',
    origin: 'Medan, North Sumatra, Indonesia',
    metaTitle: 'Cocopeat Grow Bag 100L | Pre-fertilized | PT Agro Nusa Sejahtera',
    metaDescription: 'Ready-to-use 100L cocopeat grow bags, pre-buffered and pre-fertilized. RHP certified for professional greenhouse vegetable production. Global shipping.',
    ogImage: '/images/products/cocopeat-growbag-100l-og.webp'
  },
  
  // COCOFIBER
  {
    id: 'cocofiber-bristle-fiber',
    name: 'Cocofiber Bristle Fiber',
    category: 'cocofiber',
    slug: 'cocofiber-bristle-fiber',
    shortDescription: 'Long, strong coconut fibers for brush and broom manufacturing',
    description: 'Premium grade bristle fiber extracted from mature coconut husks...',
    images: [
      '/images/products/cocofiber-bristle-hero.webp',
      '/images/products/cocofiber-bristle-detail-1.webp'
    ],
    thumbnail: '/images/products/cocofiber-bristle-thumb.webp',
    specifications: [
      { name: 'Fiber Length', value: '20-30', unit: 'cm' },
      { name: 'Color', value: 'Golden Brown', unit: '' },
      { name: 'Moisture', value: '12-15', unit: '%' },
      { name: 'Impurities', value: '< 2', unit: '%' },
      { name: 'Tensile Strength', value: 'High', unit: '' }
    ],
    applications: [
      'Broom & brush manufacturing',
      'Mattress & upholstery filling',
      'Rope & twine production',
      'Geotextiles & erosion control',
      'Automotive seat padding',
      'Horticultural mulch (coarse grade)'
    ],
    certifications: ['ISO 9001:2015'],
    packaging: {
      type: 'bale',
      weight: '125 kg',
      dimensions: '100 x 50 x 40 cm',
      pallet: '8 bales',
      containerLoad: '18 tons / 20ft'
    },
    moq: '1x20ft Container (~18 tons / 144 bales)',
    leadTime: '2-3 weeks',
    origin: 'Medan, North Sumatra, Indonesia',
    hsCode: '5305.00.10',
    incoterms: ['FOB Belawan', 'CIF', 'EXW Factory'],
    metaTitle: 'Cocofiber Bristle Fiber | Premium Grade | PT Agro Nusa Sejahtera',
    metaDescription: 'Premium golden brown bristle fiber (20-30cm) for brush, broom, mattress, and geotextile manufacturing. Consistent quality, global shipping from Indonesia.',
    ogImage: '/images/products/cocofiber-bristle-og.webp'
  },
  
  // ... more products (total 6: 3 cocopeat, 3 cocofiber)
]

// Helper functions
export function getProductBySlug(slug: string): Product | undefined {
  return products.find(p => p.slug === slug)
}

export function getProductsByCategory(category: ProductCategory): Product[] {
  return products.filter(p => p.category === category)
}

export function getFeaturedProducts(limit = 6): Product[] {
  return products.slice(0, limit)
}
```

## Data Validation

### Build-time Checks (TypeScript)
- All data files satisfy TypeScript interfaces
- No `any` types in data layer
- Required fields enforced

### Runtime Validation (Optional)
```typescript
// src/utils/validateData.ts
import { z } from 'zod'

export const ProductSchema = z.object({
  id: z.string().min(1),
  name: z.string().min(1),
  category: z.enum(['cocopeat', 'cocofiber']),
  slug: z.string().regex(/^[a-z0-9-]+$/),
  // ... rest of fields
})

export function validateProducts(data: unknown): Product[] {
  return z.array(ProductSchema).parse(data)
}
```

## Image Naming Convention

```
/public/images/
├── products/
│   ├── {product-slug}-hero.webp          # 1200x800
│   ├── {product-slug}-detail-{n}.webp    # 1200x800
│   ├── {product-slug}-thumb.webp         # 400x300
│   ├── {product-slug}-og.webp            # 1200x630 (Open Graph)
│   └── {product-slug}-gallery-{n}.webp   # 1200x800
├── gallery/
│   ├── {gallery-id}.webp                 # 1920x1080
│   └── {gallery-id}-thumb.webp           # 400x300
├── categories/
│   ├── {category-id}-hero.webp           # 1200x600
├── company/
│   ├── logo.svg
│   ├── logo-dark.svg
│   ├── favicon.ico
│   ├── hero.webp
│   ├── about.webp
│   └── team-{n}.webp
└── certifications/
    ├── {cert-id}.webp
    └── {cert-id}-logo.svg
```

## SEO Data Requirements

Each product/gallery item MUST have:
- `metaTitle` (≤ 60 chars)
- `metaDescription` (≤ 160 chars)
- `ogImage` (1200x630 WebP)
- `alt` text for all images
- Images stored in Cloudflare R2: `https://pub-<hash>.r2.dev/{path}`

## Content Management

### Current: Static TypeScript Files
- Version controlled in Git
- Type-safe, IDE autocomplete
- Build-time inlined
- Simple deployment

### Future: Headless CMS (Optional)
- Contentful / Sanity / Strapi
- Webhook → rebuild on publish
- Visual editor for marketing team
- Same TypeScript interfaces via codegen