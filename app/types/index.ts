// ===== Product Types =====
export interface Specification {
  name: string
  value: string
  unit?: string
}

export interface PackagingInfo {
  type: string
  weight: string
  dimensions?: string
  pallet?: string
  containerLoad?: string
}

export interface ProductMedia {
  type: 'image' | 'video'
  url: string
  thumbnail?: string
  alt?: string
}

export interface Product {
  id: string
  name: string
  category: 'cocopeat' | 'cocofiber'
  slug: string
  short_description: string
  description: string
  images: string[]
  thumbnail: string
  video_url?: string
  media?: ProductMedia[]
  specifications: Specification[]
  applications: string[]
  certifications: string[]
  packaging: PackagingInfo
  moq: string
  lead_time: string
  origin: string
  sort_order: number
  published: boolean
}

export interface GalleryItem {
  id: string
  category: string
  title: string
  description: string
  image: string
  thumbnail: string
  alt: string
  type?: 'image' | 'video'
  sort_order: number
  published: boolean
}

export interface HomeSection {
  id: number
  company_name: string
  tagline: string
  description?: string
  subtitle: string
  hero_video_url?: string
  hero_image_url?: string
  published: boolean
}

export interface AboutSection {
  id: number
  title: string
  mission: string
  vision: string
  values: { icon: string; title: string; description: string }[]
  hero_video_url?: string
  hero_image_url?: string
  published: boolean
}

export interface CompanyInfo {
  name?: string
  logo_url?: string
  contact?: {
    address: string
    phone: string
    email: string
    whatsapp: string
    mapEmbed?: string
  }
  social?: Record<string, string>
}

export interface ContactFormData {
  name: string
  email: string
  company?: string
  phone?: string
  message: string
  inquiryType: 'general' | 'quote' | 'sample' | 'partnership'
}
