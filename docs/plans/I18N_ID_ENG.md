# Content i18n Plan — Bahasa Indonesia (id) & English (en)

Status: PLAN — review before implementing
Scope: all site content + static UI strings on the public site

---

## 1. Current state audit (checked 2026-08-03)

### 1.1 Content comes from Supabase (single-language today)

| Table | Translatable fields | Rendered in |
|---|---|---|
| `home_section` | company_name, tagline, description, subtitle | HomeSection |
| `about_section` | title, mission, vision, values[] (icon/title/description) | AboutSection |
| `gallery_section` | title, description | GallerySection header |
| `gallery_items` | category, title, description, alt | GallerySection cards + overlay |
| `products` | name, short_description, description, specifications[] (name/value/unit), applications[], moq, lead_time, packaging | ProductsSection |
| `company_info` | name (brand — keep untranslated), contact.address (optional) | header/admin/contact |

### 1.2 Hardcoded UI strings (not in DB)

- AppHeader nav: Home / About / Products / Gallery / Contact
- Section numbers: "01 — Home", "02 — About", "03 — Our Products", "04 — Gallery", "05 — Contact"
- Buttons: Our Products, Chat on WhatsApp (floating button tooltip), Contact Us (CompanySection)
- Hero: "Premium", "from Indonesia", rotating words (Cocopeat/Cocofiber/Derivatives)
- ProductsSection: "Premium Coconut Products" + subtitle
- ContactSection: "Get in Touch" + subtitle, Address/Email/WhatsApp labels, "Follow Us", "Chat on WhatsApp"
- Empty states: "No products in this category yet.", "No images in this category yet.", gallery overlay "Gallery" title suffix
- Contact form (if any) labels/placeholders

### 1.3 No i18n infrastructure

- No vue-i18n / @nuxtjs/i18n installed
- No locale state, no URL prefixes, no translation columns
- Site is `ssr: false` SPA with scroll-snap + hash anchors — URL-prefix routing would break anchors and the catch-all admin route

---

## 2. Architecture decisions

### 2.1 Locale mechanism — persisted, no URL prefix
- Locales: `id` (default), `en`
- Stored in cookie `agrons-locale` + localStorage; set by a **language switcher** in the AppHeader
- No `/id/` URL prefix — the site is a single scroll page with hash anchors; prefixes would complicate anchors, the `[...admin]` catch-all, and the static prerender
- Default: `id` (Indonesian); switching is sticky; missing keys fall back to `en`

### 2.2 Static UI strings — vue-i18n
- Add `vue-i18n` (lightweight; no need for the full @nuxtjs/i18n module since we have no real routes)
- Small Nuxt plugin + locale files `app/i18n/en.ts`, `app/i18n/id.ts`
- Components use `$t('nav.products')` etc.

### 2.3 Content strings — `translations` JSONB column
- Add **one** `translations JSONB DEFAULT '{}'` column to each content table
- Shape: field-level locale map
  ```json
  {
    "title": { "en": "Our Facilities", "id": "Fasilitas Kami" },
    "description": { "en": "...", "id": "..." }
  }
  ```
- Arrays (`values`, `specifications`, `applications`): elements become `{ "en": "...", "id": "..." }` objects
- **Existing columns stay untouched** as the fallback chain:
  `translations[field][locale] → translations[field].en → legacy column → ''`
- Result: zero data migration; old rows keep working, admins fill in ID variants gradually

---

## 3. Migration steps (implementation order)

### Phase 1 — Infrastructure
1. Install `vue-i18n`
2. `app/plugins/i18n.ts` — init vue-i18n, read cookie, expose locale
3. `app/composables/useLocale.ts` — `locale` ref, `setLocale()`, persisted
4. `app/i18n/en.ts` + `app/i18n/id.ts` — all static strings
5. Language switcher in `AppHeader.vue` (EN | ID pill, desktop + mobile menu)

### Phase 2 — Content resolution
6. `app/composables/useContent.ts` — `contentText(row, field)` resolver (fallback chain above) + `contentTexts(arr, field)` for arrays; reactive to locale
7. Update sections to resolve through it:
   - HomeSection (tagline, description, subtitle)
   - AboutSection (title, mission, vision, values[])
   - GallerySection (section title/desc + item title/desc/alt)
   - ProductsSection (name, short_desc, description, specs, applications)
   - ContactSection (labels via $t; contact data untranslated except address)

### Phase 3 — Database
8. SQL migration: add `translations JSONB DEFAULT '{}'` to `home_section`, `about_section`, `gallery_section`, `gallery_items`, `products` (+ RLS unchanged)
9. Update `supabase_seed.sql` with the new column + ID seed values
10. (Optional) Backfill script copying en values into `translations[field].en`

### Phase 4 — Admin
11. New `app/admin/components/editors/TranslatedField.vue` — EN/ID dual input (tabs or side-by-side)
12. Wire into editors:
    - AdminHome (tagline, description, subtitle)
    - AdminAbout (title, mission, vision, values editor → {en,id})
    - AdminGallery (section title/desc; item title/desc/alt)
    - AdminProductEditor (name, short_description, description, moq, lead_time, specs editor, applications editor)
13. Admin UI itself stays English (reduces scope; recommend)

### Phase 5 — Polish
14. `document.documentElement.lang` sync
15. Font/length checks: ID text is often longer — verify hero badge, section headers, buttons don't overflow

---

## 4. File-by-file breakdown

### New files
- `app/plugins/i18n.ts`
- `app/composables/useLocale.ts`
- `app/composables/useContent.ts`
- `app/i18n/en.ts`, `app/i18n/id.ts`
- `app/admin/components/editors/TranslatedField.vue`

### Modified
- `app/components/layout/AppHeader.vue` — switcher + $t nav labels
- `app/components/sections/HomeSection.vue`, `AboutSection.vue`, `GallerySection.vue`, `ProductsSection.vue`, `ContactSection.vue`, `CompanySection.vue`
- `app/components/common/FloatingWhatsApp.vue` — tooltip $t
- `app/admin/components/AdminHome.vue`, `AdminAbout.vue`, `AdminGallery.vue`, `AdminProductEditor.vue`, `AdminCompany.vue` (address)
- `app/admin/components/editors/SpecsEditor.vue`, `TagsEditor.vue`, `ValuesCardsEditor.vue` — {en,id} value editing
- `supabase_seed.sql`
- `package.json`

---

## 5. Decisions needed from you

1. **Default locale**: `id` (per user decision) — English fallback for anything untranslated
2. **Admin UI**: keep English-only (recommended) or also bilingual?
3. **Company name** "PT Agro Nusa Sejahtera": keep single (recommended — brand name) — confirm
4. **ID translations source**: do you provide them, or should I draft ID translations for review (based on the EN seed content)?
5. **Product deep content** (specifications/applications): translate everything, or v1 = names + descriptions only, specs/apps English-only?
6. **Scope check**: `CompanySection.vue` exists (with hardcoded "PT Agro Nusa Sejahtera", "from Indonesia", mission/vision) — is it used on the page or legacy? (index.vue currently renders Home/About/Products/Gallery/Contact only)

---

## 6. Risks / notes

- **Hash anchors + scroll-snap**: language switch must not scroll or remount sections; keep it a pure text swap (composables resolve reactively)
- **Animation components** (BlurText/SplitText) take `text` as a prop — they re-render on locale change; verify they handle prop change (they use `watch`) or force re-key
- **ID text is ~15–30% longer** than EN on average — hero badge, rotating words, and buttons may need responsive tweaks
- **Prerender/SEO**: static SPA already has no per-locale pages; cookie-based locale means search engines see EN only. Acceptable for this site; flag if SEO matters
- **Admin translations**: editors get more complex — TranslatedField keeps it manageable
