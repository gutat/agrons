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

export interface Product {
  id: string
  name: string
  category: 'cocopeat' | 'cocofiber'
  slug: string
  short_description: string
  description: string
  images: string[]
  thumbnail: string
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
  sort_order: number
  published: boolean
}

export interface CompanyInfo {
  name: string
  tagline: string
  mission: string
  vision: string
  values: { icon: string; title: string; description: string }[]
  description: string
  logo_url: string
  contact: {
    address: string
    phone: string
    email: string
    whatsapp: string
    mapEmbed: string
  }
  social: Record<string, string>
}

export interface ContactFormData {
  name: string
  email: string
  company?: string
  phone?: string
  message: string
  inquiryType: 'general' | 'quote' | 'sample' | 'partnership'
}
