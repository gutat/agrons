# Cloudflare + Supabase Infrastructure Setup Guide

## Overview
Complete guide to set up free hosting infrastructure for PT Agro Nusa Sejahtera website:
- **Cloudflare Pages** — Static hosting + auto-deploy from GitHub
- **Cloudflare R2** — S3-compatible image storage (free tier)
- **GitHub Actions** — CI/CD pipeline auto-deploy
- **Supabase PostgreSQL** — Form data, analytics, admin auth

---

## 1. Cloudflare Pages — Static Hosting

### 1.1 Create Account
1. Go to [dash.cloudflare.com](https://dash.cloudflare.com) → Sign up (free)
2. Verify email, complete onboarding

### 1.2 Create Pages Project

```
Dashboard → Workers & Pages → Pages → Create → Connect to Git
```

1. Click **Create application** → **Pages** tab
2. Click **Connect to Git** → Authorize GitHub
3. Select `agro-nusa-sejahtera` repository
4. Configure:

| Setting | Value |
|---------|-------|
| **Project name** | `agro-nusa-sejahtera` |
| **Production branch** | `main` |
| **Build command** | `bun run generate` |
| **Build output directory** | `.output/public` |
| **Root directory** | `/` |
| **Node version** | `20` |

5. Click **Save and Deploy**
6. First build takes ~2 minutes
7. URL: `https://agro-nusa-sejahtera.pages.dev` (free subdomain)

### 1.3 Custom Domain (Optional)
```
Pages → agro-nusa-sejahtera → Custom domains → Set up custom domain
```

1. Enter your domain (e.g., `agronusa.co.id`)
2. Cloudflare auto-provisions SSL certificate
3. Update nameservers at your domain registrar to Cloudflare's NS records
4. Wait for DNS propagation (5-30 minutes)

### 1.4 Environment Variables

```
Pages → agro-nusa-sejahtera → Settings → Environment variables → Production
```

Add these **Production** variables. **IMPORTANT**: Prefix determines client exposure.

### Exposed to Client (`NUXT_PUBLIC_*` � in `runtimeConfig.public`)
These appear in client-side JS bundle. Supabase anon key is designed for public use (RLS protects data).

| Key | Value | Purpose |
|-----|-------|---------|
| `NUXT_PUBLIC_APP_URL` | `https://agronusa.co.id` | Site URL for meta tags |
| `NUXT_PUBLIC_R2_PUBLIC_URL` | `https://pub-<hash>.r2.dev` | Public R2 images URL |
| `NUXT_PUBLIC_WHATSAPP_NUMBER` | `6281234567890` | WhatsApp click-to-chat |
| `NUXT_PUBLIC_WHATSAPP_MESSAGE` | `Hello, I'm interested in your products.` | Prefilled WhatsApp msg |
| `NUXT_PUBLIC_MAP_EMBED_URL` | `https://...` | Google Maps embed |
| `NUXT_PUBLIC_ADMIN_PATH` | `admin` | Admin panel path (configurable) |
| `NUXT_PUBLIC_DEFAULT_THEME` | `system` | Default theme (light/dark/system) |
| `SUPABASE_URL` | `https://xxx.supabase.co` | Supabase project URL |
| `SUPABASE_KEY` | `sb_publishable_...` | Supabase anon key (public by design) |

### Server-Side Only (`R2_*` � in `runtimeConfig`, NOT `public`)
These are NEVER exposed to the client. Only accessible in `server/` API routes.
For SPA mode (`ssr: false`), these are unused at runtime (no server). They exist for future admin API routes or build-time processing.

| Key | Value | Purpose |
|-----|-------|---------|
| `R2_ACCESS_KEY_ID` | `...` | R2 API access key |
| `R2_SECRET_ACCESS_KEY` | `...` | R2 API secret key |
| `R2_BUCKET_NAME` | `agro-nusa-images` | R2 bucket name |
| `R2_ACCOUNT_ID` | `...` | Cloudflare account ID for R2 endpoint |

### 1.5 Custom Headers (`public/_headers`)

Create `public/_headers`:
```
/*
  X-Frame-Options: DENY
  X-Content-Type-Options: nosniff
  Referrer-Policy: strict-origin-when-cross-origin
  Permissions-Policy: camera=(), microphone=(), geolocation=(), interest-cohort=()

/assets/*
  Cache-Control: public, max-age=31536000, immutable

/*.html
  Cache-Control: public, max-age=0, must-revalidate
```

### 1.6 SPA Redirects (`public/_redirects`)

Create `public/_redirects`:
```
/*  /index.html  200
```

---

## 2. Cloudflare R2 — Image Storage

### 2.1 Enable R2

```
Dashboard → R2 → Get started (free plan: 10GB storage, 1M operations/month)
```

### 2.2 Create Bucket

```
R2 → Create bucket
```

| Setting | Value |
|---------|-------|
| **Bucket name** | `agro-nusa-images` |
| **Location** | Automatic |
| **Public access** | Enable (allow public read) |

### 2.3 Get Public URL

```
R2 → agro-nusa-images → Settings → Public URL
```

Copy URL: `https://pub-<hash>.r2.dev`

### 2.4 Create API Token

```
R2 → Manage R2 API tokens → Create API token
```

| Setting | Value |
|---------|-------|
| **Token name** | `agro-nusa-pages-deploy` |
| **Permissions** | `Admin Read & Write` |
| **TTL** | `Never` |

Save these credentials:
- **Access Key ID**: `xxx`
- **Secret Access Key**: `yyy`
- **Endpoint**: `https://<account-id>.r2.cloudflarestorage.com`
- **Account ID**: Found in Dashboard → Right sidebar

### 2.5 Upload Images

```
R2 → agro-nusa-images → Upload
```

Create folder structure and upload images:

```
agro-nusa-images/
├── products/
│   ├── cocopeat-block-5kg-hero.webp
│   ├── cocopeat-block-5kg-thumb.webp
│   ├── cocopeat-block-5kg-detail-1.webp
│   ├── cocopeat-briquette-650g-hero.webp
│   ├── cocopeat-briquette-650g-thumb.webp
│   ├── cocopeat-growbag-100l-hero.webp
│   ├── cocopeat-growbag-100l-thumb.webp
│   ├── cocofiber-bale-250kg-hero.webp
│   ├── cocofiber-bale-250kg-thumb.webp
│   ├── cocofiber-rope-20mm-hero.webp
│   ├── cocofiber-rope-20mm-thumb.webp
│   ├── cocofiber-mat-2m-hero.webp
│   └── cocofiber-mat-2m-thumb.webp
├── gallery/
│   ├── production-1.webp
│   ├── production-1-thumb.webp
│   ├── factory-1.webp
│   ├── factory-1-thumb.webp
│   ├── certification-1.webp
│   ├── certification-1-thumb.webp
│   ├── team-1.webp
│   └── team-1-thumb.webp
├── company/
│   ├── logo.svg
│   ├── logo-dark.svg
│   ├── hero.webp
│   └── about.webp
```

### 2.6 Batch Upload Script

Create `scripts/r2-upload.sh`:
```bash
#!/bin/bash
# Requires: aws-cli configured with R2 credentials

R2_ENDPOINT="https://<account-id>.r2.cloudflarestorage.com"
R2_BUCKET="agro-nusa-images"
LOCAL_DIR="./public/images"

aws s3 sync $LOCAL_DIR s3://$R2_BUCKET \
  --endpoint-url=$R2_ENDPOINT \
  --acl public-read \
  --content-type "image/webp" \
  --cache-control "public, max-age=31536000, immutable"
```

### 2.7 R2 Config in nuxt.config.ts

```typescript
runtimeConfig: {
  r2AccessKeyId: process.env.R2_ACCESS_KEY_ID,
  r2SecretAccessKey: process.env.R2_SECRET_ACCESS_KEY,
  r2BucketName: process.env.R2_BUCKET_NAME,
  r2AccountId: process.env.R2_ACCOUNT_ID,
  public: {
    r2PublicUrl: process.env.NUXT_PUBLIC_R2_PUBLIC_URL,
  }
}
```

---

## 3. GitHub Actions — Auto-Deploy

### 3.1 GitHub Secrets

```
GitHub Repository → Settings → Secrets and variables → Actions → New repository secret
```

Add these secrets:

| Secret | Value |
|--------|-------|
| `CLOUDFLARE_API_TOKEN` | From Cloudflare dashboard |
| `CLOUDFLARE_ACCOUNT_ID` | From Cloudflare dashboard |
| `R2_ACCESS_KEY_ID` | From R2 API token |
| `R2_SECRET_ACCESS_KEY` | From R2 API token |
| `R2_BUCKET_NAME` | `agro-nusa-images` |
| `R2_ACCOUNT_ID` | From Cloudflare dashboard |
| `NUXT_PUBLIC_APP_URL` | `https://agronusa.co.id` |
| `NUXT_PUBLIC_R2_PUBLIC_URL` | `https://pub-<hash>.r2.dev` |
| `NUXT_PUBLIC_WHATSAPP_NUMBER` | `6281234567890` |
| `NUXT_PUBLIC_WHATSAPP_MESSAGE` | Your WhatsApp message |
| `NUXT_PUBLIC_MAP_EMBED_URL` | Google Maps embed URL |
| `NUXT_PUBLIC_ADMIN_PATH` | `admin` |
| `SUPABASE_URL` | Supabase project URL |
| `SUPABASE_KEY` | Supabase anon key |

### 3.2 Create Cloudflare API Token

```
Cloudflare Dashboard → My Profile → API Tokens → Create Token
```

Use **Edit Cloudflare Workers** template:
- Permissions: `Cloudflare Pages — Edit`
- Account Resources: Include your account
- Create → Copy token

### 3.3 Workflow File

Create `.github/workflows/deploy.yml`:

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

      - name: Install dependencies
        run: bun install

      - name: Lint
        run: bun run lint

      - name: Generate
        run: bun run generate
        env:
          NUXT_PUBLIC_APP_URL: ${{ secrets.NUXT_PUBLIC_APP_URL }}
          NUXT_PUBLIC_R2_PUBLIC_URL: ${{ secrets.NUXT_PUBLIC_R2_PUBLIC_URL }}
          NUXT_PUBLIC_WHATSAPP_NUMBER: ${{ secrets.NUXT_PUBLIC_WHATSAPP_NUMBER }}
          NUXT_PUBLIC_MAP_EMBED_URL: ${{ secrets.NUXT_PUBLIC_MAP_EMBED_URL }}
          NUXT_PUBLIC_ADMIN_PATH: ${{ secrets.NUXT_PUBLIC_ADMIN_PATH }}
          SUPABASE_URL: ${{ secrets.SUPABASE_URL }}
          SUPABASE_KEY: ${{ secrets.SUPABASE_KEY }}
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
          directory: .output/public
          branch: main
          gitHubToken: ${{ secrets.GITHUB_TOKEN }}
```

### 3.4 How Auto-Deploy Works

```
Push to main → GitHub Actions triggers → bun install → bun run generate → Deploy to Cloudflare Pages
```

1. Every push to `main` branch triggers the workflow
2. Bun installs dependencies
3. `nuxt generate` builds static site
4. Cloudflare Pages Action uploads `.output/public/`
5. Cloudflare deploys to edge (global CDN)
6. Live at `https://agro-nusa-sejahtera.pages.dev` (or custom domain)
7. ~60 seconds total from push to live

### 3.5 Preview Deployments

Every PR automatically gets a preview URL:
- `https://<hash>.agro-nusa-sejahtera.pages.dev`
- Great for testing before merging to main
- Comment auto-posted on PR with preview link

---

## 4. Supabase PostgreSQL — Database

### 4.1 Create Supabase Project

1. Go to [supabase.com](https://supabase.com) → **Start your project**
2. Sign up with GitHub (free plan: 500MB DB, 50,000 monthly active users)

| Setting | Value |
|---------|-------|
| **Organization** | `Agro Nusa Sejahtera` |
| **Project name** | `agro-nusa-website` |
| **Database password** | Generate strong password |
| **Region** | `Southeast Asia (Singapore)` — nearest to Indonesia |
| **Pricing plan** | Free |

### 4.2 Get Project Credentials

```
Supabase Dashboard → Project Settings → API
```

| Key | Value |
|-----|-------|
| **Project URL** | `https://xxx.supabase.co` |
| **Anon / Public key** | `eyJ...` |
| **Service role key** | `eyJ...` (secret, server-only) |

Add these to GitHub Secrets and Cloudflare Pages env vars.

### 4.3 Install Supabase Package

```bash
bun add @supabase/supabase-js
```

### 4.4 Supabase Client Setup

Create `app/utils/supabase.ts`:
```typescript
import { createClient } from '@supabase/supabase-js'

const config = useRuntimeConfig()
export const supabase = createClient(
  config.public.supabaseUrl,
  config.public.supabaseKey
)
```

Then in `nuxt.config.ts`, add to `runtimeConfig.public`:
```typescript
runtimeConfig: {
  public: {
    supabaseUrl: process.env.SUPABASE_URL,
    supabaseKey: process.env.SUPABASE_KEY,
  }
}
```

### 4.5 Database Tables

Run these SQL scripts in Supabase SQL Editor:

#### Products Table
```sql
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
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public can view published products" ON products
  FOR SELECT TO anon, authenticated
  USING (published = true);
CREATE POLICY "Admin can manage products" ON products
  FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);

#### Gallery Items Table
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

#### Company Info Table (single row)
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

#### Contact Form Submissions
```sql
CREATE TABLE contact_submissions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  company TEXT,
  phone TEXT,
  country TEXT,
  message TEXT NOT NULL,
  inquiry_type TEXT CHECK (inquiry_type IN ('general', 'quote', 'sample', 'partnership', 'technical')),
  product_interest TEXT[],
  source TEXT DEFAULT 'website',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  read BOOLEAN DEFAULT FALSE
);

-- Enable RLS
ALTER TABLE contact_submissions ENABLE ROW LEVEL SECURITY;

-- Allow insert from public (anon key)
CREATE POLICY "Anyone can submit contact form" 
  ON contact_submissions FOR INSERT TO anon, authenticated
  WITH CHECK (true);

-- Only authenticated users can view
CREATE POLICY "Only admin can view submissions" 
  ON contact_submissions FOR SELECT TO authenticated
  USING (true);
```

#### Admin Users
```sql
CREATE TABLE admin_users (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  role TEXT DEFAULT 'editor' CHECK (role IN ('admin', 'editor', 'viewer')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  last_login TIMESTAMPTZ
);

-- Trigger: auto-create admin_user on auth signup
CREATE FUNCTION public.handle_new_admin()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.admin_users (id, email, role)
  VALUES (NEW.id, NEW.email, 'editor');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_admin();
```

#### Audit Log (Admin Actions)
```sql
CREATE TABLE admin_audit_log (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  admin_id UUID REFERENCES admin_users(id),
  action TEXT NOT NULL,
  target_type TEXT,
  target_id TEXT,
  details JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE admin_audit_log ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Only admin can view audit log" 
  ON admin_audit_log FOR SELECT TO authenticated
  USING (true);
```

#### Newsletter Subscriptions
```sql
CREATE TABLE newsletter_subscriptions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  name TEXT,
  subscribed BOOLEAN DEFAULT TRUE,
  subscribed_at TIMESTAMPTZ DEFAULT NOW(),
  unsubscribed_at TIMESTAMPTZ
);

ALTER TABLE newsletter_subscriptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can subscribe" 
  ON newsletter_subscriptions FOR INSERT TO anon, authenticated
  WITH CHECK (true);

CREATE POLICY "Anyone can unsubscribe" 
  ON newsletter_subscriptions FOR UPDATE 
  USING (email = current_setting('request.jwt.claim.email', true));
```

### 4.5 Supabase Client Usage

#### Contact Form (Public)
```typescript
// app/composables/useContactForm.ts
export function useContactForm() {
  const config = useRuntimeConfig()
  const supabase = createClient(config.public.supabaseUrl, config.public.supabaseKey)
  const submitting = ref(false)

  const submitContactForm = async (data: ContactFormData) => {
    submitting.value = true
    try {
      const { error } = await supabase
        .from('contact_submissions')
        .insert([{
          name: data.name,
          email: data.email,
          company: data.company,
          phone: data.phone,
          country: data.country,
          message: data.message,
          inquiry_type: data.inquiryType,
          product_interest: data.productInterest,
          source: 'website',
        }])
      if (error) throw error
      return { success: true }
    } catch (err) {
      console.error('Contact form error:', err)
      return { success: false, error: err }
    } finally {
      submitting.value = false
    }
  }

  return { submitContactForm, submitting }
}
```

#### Admin Auth
```typescript
// app/admin/composables/useAdminAuth.ts
export function useAdminAuth() {
  const config = useRuntimeConfig()
  const supabase = createClient(config.public.supabaseUrl, config.public.supabaseKey)
  const user = ref(null)

  const signIn = async (email: string, password: string) => {
    const { data, error } = await supabase.auth.signInWithPassword({ email, password })
    if (error) throw error
    user.value = data.user
  }

  const signOut = async () => {
    await supabase.auth.signOut()
    navigateTo('/')
  }

  return { user, signIn, signOut }
}
```

#### Fetch Submissions (Admin Only)
```typescript
// app/admin/composables/useContacts.ts
export function useContacts() {
  const supabase = createClient(config.public.supabaseUrl, config.public.supabaseKey)

  const getSubmissions = async () => {
    const { data, error } = await supabase
      .from('contact_submissions')
      .select('*')
      .order('created_at', { ascending: false })
    
    if (error) throw error
    return data
  }

  const markAsRead = async (id: string) => {
    const { error } = await supabase
      .from('contact_submissions')
      .update({ read: true })
      .eq('id', id)
    
    if (error) throw error
  }

  return { getSubmissions, markAsRead }
}
```

### 4.6 Supabase Auth for Admin

```bash
Supabase Dashboard → Authentication → Settings
```

| Setting | Value |
|---------|-------|
| **Site URL** | `https://agronusa.co.id` |
| **Redirect URLs** | `https://agronusa.co.id/{adminPath}/*` |
| **Auth providers** | Email (enable), Google (optional) |

### 4.7 Row Level Security (RLS) Summary

| Table | Insert | Select | Update | Delete |
|-------|--------|--------|--------|--------|
| `contact_submissions` | Public (anon) | Admin only | Admin only | Admin only |
| `admin_users` | System only | Admin only | Admin only | Admin only |
| `admin_audit_log` | System only | Admin only | — | — |
| `newsletter_subscriptions` | Public (anon) | Admin only | Email owner | — |

### 4.8 Data Flow Diagram

```
User fills contact form
       │
       ▼
Supabase .from('contact_submissions').insert()
       │
       ▼
RLS: Allow insert for anon key (public)
       │
       ▼
Data stored in PostgreSQL
       │
       ▼
Admin logs in → auth.signInWithPassword()
       │
       ▼
RLS: Allow select for authenticated users only
       │
       ▼
Admin dashboard displays submissions
```

---

## 5. First Deployment Steps

### Step-by-Step Checklist

- [ ] Cloudflare account created
- [ ] Cloudflare Pages project created, first deploy success
- [ ] `public/_headers` and `public/_redirects` added to repo
- [ ] GitHub Secrets configured (all env vars)
- [ ] GitHub Actions workflow committed
- [ ] Supabase project created
- [ ] Database tables created (SQL run in Supabase Editor)
- [ ] R2 bucket created
- [ ] All images uploaded to R2
- [ ] Data files updated with R2 public URLs
- [ ] `bun run generate` builds locally without errors
- [ ] Push to main → auto-deploy success
- [ ] Verify live site: `https://agro-nusa-sejahtera.pages.dev`
- [ ] Test contact form submission → appears in Supabase
- [ ] Test admin login → can view submissions

### Commands Reference

```bash
# Local development
bun run dev

# Build and preview locally
bun run generate
bun run preview

# Upload images to R2 (requires aws-cli)
bash scripts/r2-upload.sh

# Push to deploy
git add .
git commit -m "update"
git push origin main
```

---

## 6. Cost Breakdown

| Service | Free Tier | Paid Upgrade |
|---------|-----------|--------------|
| **Cloudflare Pages** | Unlimited builds, 500 builds/month | Pro $20/mo |
| **Cloudflare R2** | 10GB storage, 1M ops/month | $0.015/GB/mo |
| **Cloudflare Web Analytics** | Unlimited | Free |
| **GitHub Actions** | 2,000 min/month | Pro $4/mo |
| **Supabase** | 500MB DB, 50k MAU | Pro $25/mo |
| **Total** | **$0/month** | |

## 7. Troubleshooting

| Problem | Solution |
|---------|----------|
| Build fails on Cloudflare Pages | Check build command: `bun run generate`; verify all env vars set |
| Images not loading | Check R2 bucket is public; verify `NUXT_PUBLIC_R2_PUBLIC_URL` |
| Contact form not submitting | Check Supabase RLS policy allows insert; verify anon key |
| Admin login fails | Check auth provider enabled; verify redirect URLs |
| _redirects not working | File must be in `public/` directory at build time |
| PR preview shows 404 | Check that `_redirects` file is committed |
| Supabase connection refused | Check if IP is allowlisted (Supabase → Settings → API) |