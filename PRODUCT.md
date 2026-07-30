# Product

<!-- impeccable:product-schema 1 -->

## Platform

web

## Users

International distributors and import partners sourcing coconut derivatives (cocopeat, cocofiber, coconut charcoal, copra) for their local markets. They evaluate suppliers on consistency of quality, certification credibility, lead time reliability, and communication responsiveness before placing bulk orders.

Secondary audience: greenhouse operators, hydroponic farms, erosion control contractors, and mattress/upholstery manufacturers who may be end-users but typically buy through the distributor/import channel.

## Product Purpose

PT Agro Nusa Sejahtera is a B2B export supplier of premium coconut derivatives from Indonesia. The website exists to establish credibility, communicate product specifications and certifications, and convert qualified distributor/import partners into inquiries via WhatsApp or the contact form. Success means a visitor requests a quote or sample.

## Positioning

Reliable, certified quality on every shipment — not just a commodity trader. Where other suppliers compete on price alone, PT Agro Nusa Sejahtera competes on a **specific quality guarantee**: consistent batch-to-batch specifications (EC, pH, moisture, fiber length) backed by certifications (RHP, OMRI, ISO) and documented quality control. This reduces the risk for import partners who need to trust that what they order is what they receive.

## Operating Context

- The visitor lands on the site from search, referral, or WhatsApp link
- They browse through 5 scroll-snap sections: Home → About → Products → Gallery → Contact
- Product swiper shows detailed specifications (EC, pH, moisture, fiber length, applications) alongside product photos/videos
- Gallery shows production facility, team, and certifications as social proof
- The CTA flows toward WhatsApp chat (the primary inquiry channel) or the contact form
- All content is managed via Supabase admin panel — no static data files
- Images and videos are served from Cloudflare R2 CDN
- The site is a single-page application (no SSR), pre-rendered as static HTML via Nuxt generate, deployed on Cloudflare Pages
- Dark/light theme follows system preference with manual toggle

## Capabilities and Constraints

**Capabilities:**
- 5 full-viewport scroll-snap sections (Home, About, Products, Gallery, Contact)
- Product filtering by category (cocopeat / cocofiber)
- Product swiper with specifications and media (image/video)
- Full-screen product gallery overlay with GSAP slide-in animation
- Masonry gallery grid with fullscreen overlay
- Supabase-powered content management (products, gallery, home section, about section, company info)
- WhatsApp integration (primary inquiry channel)
- Contact form with Supabase submission storage
- Admin panel at configurable path
- Dark/light theme
- Configurable hero backgrounds (video or image) for Home and About sections

**Constraints:**
- Single-page architecture — no separate route per product, per gallery item, or per section
- SPA mode (ssr: false) — content rendered client-side after static HTML shell
- Static generation (nuxt generate) — pre-rendered at build time
- All runtime data fetched from Supabase via createClient()
- Media stored in Cloudflare R2 (images and videos)
- No authentication on public pages — admin only at configurable path
- Performance target must account for low-end mobile devices (Samsung M20-class)
- No PWA, no offline support

## Brand Commitments

- **Company name:** PT Agro Nusa Sejahtera
- **Brand personality:** "Industrial-Organic" — combining the precision of export logistics with the natural essence of coconut processing
- **Visual identity:** Deep Forest Green (#1B3022) primary, Husk Brown (#7E562E) accent, Soft Cream (#F7FAFB) surface
- **Typography:** Source Serif 4 (headings — authoritative, heritage-driven) + Hanken Grotesk (body — clean, contemporary)
- **Design approach:** Modern Minimalism with Glassmorphism; clean whitespace, thin borders, backdrop-blur effects
- **Voice:** Professional, trustworthy, export-grade. Not casual, not overly technical. Speaks to business partners, not consumers.
- **Key claims:** Zero-waste coconut processing, RHP/OMRI/ISO certifications, sustainable sourcing, 4+ years industry experience
- **Primary inquiry channel:** WhatsApp

## Evidence on Hand

- Supabase schema and seed data with product specifications, gallery items, company info
- Scraped content from mazreanusantara.com as structural reference
- Design tokens and typography defined in Tailwind CSS theme and main.css
- DESIGN.md with full color palette, typography scale, spacing, and component patterns
- Product specifications with real EC/pH/moisture values for cocopeat and cocofiber
- Gallery categories: production, factory, certifications, team
- Placeholder asset URLs (picsum.photos) — real product photography needed
- Cloudflare R2 bucket configured for production media

## Product Principles

1. **Trust through specificity.** Every product page shows measurable specifications (EC, pH, moisture, fiber length) — not generic marketing copy. Import partners evaluate on data, not adjectives.

2. **The inquiry is the conversion.** The site's job is not to sell directly but to make the visitor confident enough to start a WhatsApp conversation. Every section builds credibility toward that moment.

3. **Content is infrastructure.** All product, gallery, and company content lives in Supabase and is editable via admin — the site is a delivery vehicle, not a static brochure.

4. **Performance is a product feature.** The site must work smoothly on the devices import partners actually use — including mid-range Android phones common in emerging markets.

5. **One page, one story.** The scroll-snap structure forces a linear narrative from brand introduction through product proof to contact. No distracting sub-routes or internal navigation labyrinths.

## Accessibility & Inclusion

- Full keyboard navigation (arrow keys between sections, Tab through interactive elements)
- Respects prefers-reduced-motion (disables smooth scroll and animations)
- Semantic HTML sections with aria-labels
- Dark/light theme follows system preference
- Images carry alt text from Supabase content
- Video elements respect autoplay restrictions (muted, playsinline)
