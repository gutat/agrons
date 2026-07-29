# Deployment Guide

## Overview

Static Site Generation (SSG) + Single Page Application (SPA) hybrid deployment to **Cloudflare Pages** using **Nuxt 4**.

## Build Configuration

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

  // Tailwind CSS dark mode
  tailwindcss: {
    config: {
      darkMode: 'class',
    },
  },

  // Runtime config
  runtimeConfig: {
    // Server-side only
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
  
  // App head
  app: {
    head: {
      title: 'PT Agro Nusa Sejahtera',
      meta: [
        { name: 'description', content: 'Premium Cocopeat & Cocofiber from Indonesia' },
      ],
      link: [
        { rel: 'preload', as: 'font', href: 'https://fonts.googleapis.com/css2?family=Source+Serif+4:wght@400;600;700&family=Hanken+Grotesk:wght@400;700&display=swap', crossorigin: '' },
        { rel: 'stylesheet', href: 'https://fonts.googleapis.com/css2?family=Source+Serif+4:wght@400;600;700&family=Hanken+Grotesk:wght@400;700&display=swap' },
      ]
    }
  },
  
  // Static generation
  nitro: {
    prerender: {
      routes: ['/']
    }
  }
})
```

## Environment Variables

### Required (Build Time)

```env
# .env
SUPABASE_URL="https://kulobdwegcyjtoeancet.supabase.co"
SUPABASE_KEY="sb_publishable__KJNmpoQK7dmhVxZqqTsgA_X1EJ_aji"

# Client-side (NUXT_PUBLIC_* env vars)
NUXT_PUBLIC_APP_URL="https://agronusa.co.id"
NUXT_PUBLIC_R2_PUBLIC_URL="https://pub-<hash>.r2.dev"
NUXT_PUBLIC_WHATSAPP_NUMBER="6281234567890"
NUXT_PUBLIC_WHATSAPP_MESSAGE="Hello, I'm interested in your cocopeat/cocofiber products."
NUXT_PUBLIC_MAP_EMBED_URL="https://..."
NUXT_PUBLIC_ADMIN_PATH="admin"
NUXT_PUBLIC_DEFAULT_THEME="system"

# Server-side only (not exposed to client)
R2_ACCESS_KEY_ID="..."
R2_SECRET_ACCESS_KEY="..."
R2_BUCKET_NAME="agro-nusa-images"
R2_ACCOUNT_ID="..."
```

## Nuxt 4 Scripts

```json
{
  "scripts": {
    "dev": "nuxt dev",
    "build": "nuxt build",
    "generate": "nuxt generate",
    "preview": "nuxt preview",
    "postinstall": "nuxt prepare"
  }
}
```

- `bun run dev` - Start development server
- `bun run build` - Build for production
- `bun run generate` - Generate static site (SSG)
- `bun run preview` - Preview production build

## Cloudflare Pages Deployment

### Configuration
```
Build command: bun run generate
Build output directory: .output/public
Root directory: /
Node version: 20
```

### Custom Headers (`public/_headers`)

```
/*
  X-Frame-Options: DENY
  X-Content-Type-Options: nosniff
  Referrer-Policy: strict-origin-when-cross-origin
  Permissions-Policy: camera=(), microphone=(), geolocation=()
  
/assets/*
  Cache-Control: public, max-age=31536000, immutable
  
/*.html
  Cache-Control: public, max-age=0, must-revalidate
```

### Redirects (`public/_redirects`)

```
/*  /index.html  200
```

## CI/CD Pipeline

### GitHub Actions (`.github/workflows/deploy.yml`)

```yaml
name: Deploy to Cloudflare Pages

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

env:
  NODE_VERSION: '20'

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      deployments: write
      id-token: write
    
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Bun
        uses: oven-sh/setup-bun@v1

      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'bun'

      - name: Install dependencies
        working-directory: ./agrons
        run: bun install

      - name: Lint
        working-directory: ./agrons
        run: bun run lint

      - name: Generate
        working-directory: ./agrons
        run: bun run generate
        env:
          NUXT_PUBLIC_APP_URL: ${{ secrets.NUXT_PUBLIC_APP_URL }}
          NUXT_PUBLIC_R2_PUBLIC_URL: ${{ secrets.NUXT_PUBLIC_R2_PUBLIC_URL }}
          NUXT_PUBLIC_WHATSAPP_NUMBER: ${{ secrets.NUXT_PUBLIC_WHATSAPP_NUMBER }}
          NUXT_PUBLIC_MAP_EMBED_URL: ${{ secrets.NUXT_PUBLIC_MAP_EMBED_URL }}
          R2_ACCESS_KEY_ID: ${{ secrets.R2_ACCESS_KEY_ID }}
          R2_SECRET_ACCESS_KEY: ${{ secrets.R2_SECRET_ACCESS_KEY }}
          R2_BUCKET_NAME: ${{ secrets.R2_BUCKET_NAME }}
          R2_ACCOUNT_ID: ${{ secrets.R2_ACCOUNT_ID }}

      - name: Deploy to Cloudflare Pages
        uses: cloudflare/pages-action@v1
        with:
          apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
          accountId: ${{ secrets.CLOUDFLARE_ACCOUNT_ID }}
          projectName: agro-nusa-sejahtera
          directory: agrons/.output/public
          branch: main
          gitHubToken: ${{ secrets.GITHUB_TOKEN }}
```

### Preview Deployments

Every PR gets a unique preview URL:
- Cloudflare: `https://<hash>.agro-nusa-sejahtera.pages.dev`

## Performance Budget

| Metric | Target | Tool |
|--------|--------|------|
| LCP | < 2.5s | Lighthouse |
| FID | < 100ms | Lighthouse |
| CLS | < 0.1 | Lighthouse |
| TTI | < 3.5s | Lighthouse |

## Pre-Launch Checklist

### SEO
- [ ] Meta tags via `useHead()` / `useSeoMeta()` in pages
- [ ] JSON-LD structured data (Organization, Product, WebSite)
- [ ] Canonical URLs

### Performance
- [ ] Images: WebP, responsive (srcset), lazy-loaded
- [ ] Fonts: Source Serif 4 + Hanken Grotesk preloaded, font-display: swap
- [ ] Compression: Brotli/Gzip enabled on Cloudflare

### Design Verification
- [ ] Color tokens match DESIGN.md palette (light + dark mode)
- [ ] Typography: display-lg on hero, headline-md on sections, label-caps on badges
- [ ] Glassmorphism: backdrop-blur on cards, 1px ghost borders
- [ ] Spacing: section-gap 120px desktop / 64px mobile
- [ ] Buttons: 4px rounded, Deep Forest Green primary, ghost variants available
- [ ] Dark mode: verify all surfaces, text, and primary colors swap correctly
- [ ] Reduced motion: animations disabled via prefers-reduced-motion

### Accessibility
- [ ] Semantic HTML5
- [ ] Focus indicators visible
- [ ] ARIA labels on interactive elements
- [ ] Alt text on all images
- [ ] Keyboard navigation works

### Scroll Snap
- [ ] CSS scroll-snap-type: y mandatory on html
- [ ] Each section has scroll-snap-align: start
- [ ] scroll-snap-stop: always prevents section skipping
- [ ] prefers-reduced-motion disables smooth scroll

## Post-Launch

### Monitoring
- Analytics: Cloudflare Web Analytics (privacy-friendly, free)

### Maintenance
- Dependency updates: `bun audit` monthly
- SSL cert: Auto-renewed by Cloudflare

## Domain Configuration

### Cloudflare DNS
```
Type    Name    Content                    Proxy
A       @       192.0.2.1 (dummy)          Proxied
CNAME   www     agro-nusa-sejahtera.pages.dev  Proxied
```

### SSL/TLS
- Cloudflare: Full (Strict) - auto managed

## Cost Estimate (Free Tiers)

| Service | Free Tier Limits | Cost |
|---------|------------------|------|
| Cloudflare Pages | Unlimited sites, 500 builds/mo | $0 |
| Cloudflare R2 | 10GB storage, 1M Class A ops/mo | $0 |
| Cloudflare Web Analytics | Unlimited | $0 |
| GitHub Actions | 2000 mins/mo | $0 |
| **Total** | | **$0/month** |