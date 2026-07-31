# Rumah Web Migration Plan — Hybrid (Supabase Data + Rumah Web Storage)

> Status: **Decided** — data stays in Supabase, files live on Rumah Web hosting.
> Supersedes the earlier full-MySQL/PHP-API draft.

---

## 1. Overview

PT Agro Nusa Sejahtera is a Nuxt 4 SPA (`ssr: false`, static output) currently
deployed on Cloudflare Pages, backed by Supabase for everything.

**Target architecture:**

| Layer | Provider | Notes |
|---|---|---|
| Static site hosting | Rumah Web (cPanel `public_html`) | Build locally, upload |
| Database (all content) | **Supabase (PostgreSQL)** | products, gallery, home_section, about_section, company_info, contact_submissions |
| Admin auth | **Supabase Auth** | unchanged — JWT sessions |
| File storage (images/videos) | **Rumah Web disk** (`/uploads`) | served from the same domain |
| Upload auth | **PHP, two-step token flow** | `upload-token.php` + `upload.php` |
| Domain/DNS | Cloudflare DNS (recommended) | free CDN + SSL, point origin to Rumah Web |

**Why this split:** database, auth, and RLS stay exactly as they are (zero
rework of data logic). Files move off Supabase Storage to the hosting disk to
use the hosting quota and avoid Supabase storage limits. The only new code is
two small PHP endpoints and a rewritten upload composable.

---

## 2. Upload Flow (two-step token flow)

```
[Admin: AdminProductEditor.vue]
   │  user selects file (image / video)
   ▼
[useStorage.uploadFile(file, path)]            app/composables/useStorage.ts
   │  ① fetch upload API key from `admin_settings` (Supabase, RLS-protected)
   │  ② POST /api/upload-token.php
   │     Headers: X-Api-Key: <upload api key>
   │     → { "token": "<hmac token>", "exp": <unix ts> }
   │  ③ POST /api/upload.php
   │     Headers: X-Upload-Token: <token>
   │     Body:    multipart/form-data (file, folder)
   ▼
[api/upload-token.php — Rumah Web]
   1. verify upload API key (hash_equals — no JWT parsing needed)
   2. rate limit (max 5 tokens/hour per IP)
   3. issue HMAC token: HMAC-SHA256(signing_key, "upload:{exp}:{nonce}"), exp 10 min
   ▼
[api/upload.php — Rumah Web]
   1. verify custom token only (HMAC + exp 10 min + one-time nonce)
   2. validate type (extension + real MIME) + max size (20 MB)
   3. save to public_html/uploads/{folder}/{timestamp}-{name}
   4. return { "ok": true, "url": "https://domain/uploads/..." }
   ▼
[AdminProductEditor.vue]
   push { type, url } into form.media  →  saved to Supabase products.media
```

The frontend only ever stores **public URLs** in Supabase — identical to today,
so `ProductsSection.vue` / gallery rendering need no changes.

**Security chain of trust:**

```
admin login (Supabase)
   → client fetches upload API key from `admin_settings` (RLS: authenticated only)
      → upload-token.php verifies the key, issues short-lived HMAC token (10 min)
         → upload.php accepts token only
```

An anonymous visitor can't enter anywhere along the chain: they have no
Supabase session, so they can't read the API key, so they can't mint a token —
uploads reject them with 401.

---

## 3. Files to Create / Change

### 3.1 New: `api/upload-token.php` (project root → `public_html/api/`)

Issues short-lived HMAC upload tokens. Requires the upload API key (fetched
from Supabase `admin_settings` after login — RLS-protected).

```php
<?php
// upload-token.php — verifies upload API key, issues short-lived upload token
declare(strict_types=1);

// --- Config -------------------------------------------------------------
$uploadApiKey = getenv('UPLOAD_API_KEY');    // same key as admin_settings row
$signingKey   = getenv('UPLOAD_SIGNING_KEY'); // custom HMAC key (openssl rand -hex 32)
$tokenTtl     = 600;                           // 10 minutes
$rateLimit    = 5;                             // max tokens per hour per IP
// ------------------------------------------------------------------------

header('Content-Type: application/json');

// 1) Auth: upload API key in X-Api-Key header (constant-time compare)
$provided = $_SERVER['HTTP_X_API_KEY'] ?? '';
if (!hash_equals($uploadApiKey, $provided)) {
  http_response_code(401);
  echo json_encode(['ok' => false, 'error' => 'Unauthorized']);
  exit;
}

// 2) Rate limit: simple file-based counter per IP (one bucket per hour)
$ip   = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
$hour = date('YmdH');
$file = sys_get_temp_dir() . "/upl_rt_{$ip}_{$hour}";
$count = is_file($file) ? (int)file_get_contents($file) : 0;
if ($count >= $rateLimit) {
  http_response_code(429);
  echo json_encode(['ok' => false, 'error' => 'Rate limit exceeded']);
  exit;
}
file_put_contents($file, (string)($count + 1));

// 3) Issue token: HMAC("upload:{exp}:{nonce}") — nonce marks it one-time use
$exp   = time() + $tokenTtl;
$nonce = bin2hex(random_bytes(16));
$sig   = hash_hmac('sha256', "upload:$exp:$nonce", $signingKey);

echo json_encode([
  'ok'    => true,
  'token' => "$exp.$nonce.$sig",
  'exp'   => $exp,
]);
```

> **Note:** the one-time nonce is checked by `upload.php` against a small
> store (e.g. `sys_get_temp_dir()/upl_used_nonces.txt` or a `used_tokens`
> folder). A token that was already used is rejected.

### 3.2 New: `api/upload.php` (project root → `public_html/api/`)

Accepts the custom token only — **no JWT logic here**. ~90 lines, zero
dependencies:

```php
<?php
// upload.php — accepts valid upload tokens, saves files to /uploads
declare(strict_types=1);

// --- Config -------------------------------------------------------------
$signingKey  = getenv('UPLOAD_SIGNING_KEY'); // same key as upload-token.php
$uploadDir   = __DIR__ . '/../uploads';
$maxBytes    = 20 * 1024 * 1024;             // 20 MB
$allowedExt  = ['jpg','jpeg','png','webp','gif','mp4','webm'];
$allowedMime = ['image/jpeg','image/png','image/webp','image/gif','video/mp4','video/webm'];
// ------------------------------------------------------------------------

header('Content-Type: application/json');

// 1) Verify custom token: "exp.nonce.sig"
$token = $_SERVER['HTTP_X_UPLOAD_TOKEN'] ?? '';
[$exp, $nonce, $sig] = array_pad(explode('.', $token, 3), 3, '');
$expected = hash_hmac('sha256', "upload:$exp:$nonce", $signingKey);
if (!hash_equals($expected, $sig)) {
  http_response_code(401);
  echo json_encode(['ok' => false, 'error' => 'Invalid token']);
  exit;
}
if ((int)$exp < time()) {
  http_response_code(401);
  echo json_encode(['ok' => false, 'error' => 'Token expired']);
  exit;
}
// One-time use: reject if nonce was already consumed
$usedFile = sys_get_temp_dir() . "/upl_used_{$nonce}";
if (is_file($usedFile)) {
  http_response_code(401);
  echo json_encode(['ok' => false, 'error' => 'Token already used']);
  exit;
}
file_put_contents($usedFile, (string)time());

// 2) File checks — extension AND real MIME (spoof-proof)
if (empty($_FILES['file']) || $_FILES['file']['error'] !== UPLOAD_ERR_OK) {
  http_response_code(400);
  echo json_encode(['ok' => false, 'error' => 'No file uploaded']);
  exit;
}
$file = $_FILES['file'];
if ($file['size'] > $maxBytes) {
  http_response_code(413);
  echo json_encode(['ok' => false, 'error' => 'File too large (max 20 MB)']);
  exit;
}
$ext = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));
if (!in_array($ext, $allowedExt, true)) {
  http_response_code(415);
  echo json_encode(['ok' => false, 'error' => 'Unsupported file type']);
  exit;
}
$finfo = finfo_open(FILEINFO_MIME_TYPE);
$mime  = finfo_file($finfo, $file['tmp_name']);
finfo_close($finfo);
if (!in_array($mime, $allowedMime, true)) {
  http_response_code(415);
  echo json_encode(['ok' => false, 'error' => 'Unsupported file type']);
  exit;
}

// 3) Save: uploads/{folder}/{timestamp}-{safe-name}
$folder = preg_replace('/[^a-z0-9_-]/', '', $_POST['folder'] ?? 'misc') ?: 'misc';
$dir    = "$uploadDir/$folder";
if (!is_dir($dir)) mkdir($dir, 0755, true);
$name = time() . '-' . preg_replace('/[^a-zA-Z0-9._-]/', '', basename($file['name']));
if (!move_uploaded_file($file['tmp_name'], "$dir/$name")) {
  http_response_code(500);
  echo json_encode(['ok' => false, 'error' => 'Save failed']);
  exit;
}

$base = (isset($_SERVER['HTTPS']) ? 'https' : 'http') . "://{$_SERVER['HTTP_HOST']}";
echo json_encode(['ok' => true, 'url' => "$base/uploads/$folder/$name"]);
```

### 3.3 Change: `app/composables/useStorage.ts`

Same public API (`uploadFile`, `deleteFile`). New flow: mint token → upload:

```ts
const config = useRuntimeConfig()
const apiBase = () => `${config.public.appUrl || ''}/api`

async function uploadFile(file: File, path: string): Promise<string | null> {
  const supabase = useSupabase()
  // ① fetch the upload API key (RLS-protected — requires a logged-in admin)
  const { data, error } = await supabase.from('admin_settings').select('upload_api_key').single()
  const apiKey = data?.upload_api_key
  if (error || !apiKey) return null

  // ② mint a short-lived upload token
  const tokenRes = await fetch(`${apiBase()}/upload-token.php`, {
    headers: { 'X-Api-Key': apiKey },
  })
  const tokenJson = await tokenRes.json().catch(() => null)
  if (!tokenJson?.ok) return null

  // ③ upload with the custom token
  const fd = new FormData()
  fd.append('file', file)
  fd.append('folder', path.split('/')[0]) // e.g. "products"
  const res = await fetch(`${apiBase()}/upload.php`, {
    method: 'POST',
    headers: { 'X-Upload-Token': tokenJson.token },
    body: fd,
  })
  const json = await res.json().catch(() => null)
  return json?.ok ? json.url : null
}

async function deleteFile(url: string): Promise<boolean> {
  // best-effort: files cleaned via cPanel File Manager or a later batch script
  return true
}
```

### 3.4 Change: `nuxt.config.ts`

```ts
runtimeConfig: {
  public: {
    supabaseUrl: process.env.SUPABASE_URL,
    supabaseKey: process.env.SUPABASE_KEY,
    appUrl: "https://yourdomain.com", // used for upload endpoints
    // ...rest unchanged
  },
},
```

### 3.5 No changes

- All section components (`HomeSection`, `AboutSection`, `ProductsSection`,
  `GallerySection`, `ContactSection`) — they read URLs from Supabase rows
- All admin components except the storage calls inside `AdminProductEditor`
- `app/types/index.ts`
- RLS policies, seed data — untouched

---

## 4. Deployment Steps

1. **Purchase Rumah Web shared hosting** (PHP 8.1+, MySQL not even needed).
   Ensure SSL (Let's Encrypt) is enabled in cPanel.
2. **Build locally with env vars:**
   ```bash
   SUPABASE_URL=https://xxx.supabase.co \
   SUPABASE_KEY=<anon key> \
   npm run generate
   ```
3. **Upload** `.output/public/*` → `public_html/` (File Manager zip or FileZilla).
4. **Upload `api/upload-token.php` + `api/upload.php`** → `public_html/api/`.
5. **Create the `admin_settings` table** in Supabase SQL Editor (holds the
   upload API key, readable only by logged-in admins):
   ```sql
   CREATE TABLE IF NOT EXISTS admin_settings (
     id INT PRIMARY KEY DEFAULT 1,
     upload_api_key TEXT NOT NULL,
     CONSTRAINT single_row CHECK (id = 1)
   );
   ALTER TABLE admin_settings ENABLE ROW LEVEL SECURITY;
   CREATE POLICY "Auth users can read upload key"
     ON admin_settings FOR SELECT TO authenticated USING (true);
   INSERT INTO admin_settings (id, upload_api_key)
   VALUES (1, '<openssl rand -hex 32>')
   ON CONFLICT (id) DO NOTHING;
   ```
   (Generate the key first with `openssl rand -hex 32`, then paste it into
   the INSERT — the same value goes on the server in the next step.)
6. **Create uploads dir** `public_html/uploads/products` (chmod 755).
7. **Set secrets** — cPanel → MultiPHP INI Editor (or `.user.ini`):
   - `UPLOAD_API_KEY=<same key as the admin_settings row>` (shared secret
     — must match exactly)
   - `UPLOAD_SIGNING_KEY=<openssl rand -hex 32>` (generate once, keep private)
8. **`.htaccess` SPA fallback** in `public_html`:
   ```apache
   RewriteEngine On
   RewriteCond %{REQUEST_FILENAME} !-f
   RewriteCond %{REQUEST_FILENAME} !-d
   RewriteRule ^(?!uploads/).*$ /index.html [L]
   ```
   (Also add upload size limits if needed: `php_value upload_max_filesize 20M`,
   `php_value post_max_size 21M`.)
9. **CORS** — Supabase Dashboard → Authentication → URL Configuration →
   **Allowed Origins**: add `https://yourdomain.com`.
10. **DNS** — keep Cloudflare DNS; add A record for `yourdomain.com` →
   Rumah Web server IP (or change nameservers to Rumah Web if moving fully).
   Wait for SSL to issue.
11. **Test:**
    - Login to `/admin`, upload a test image in `/admin/products`
    - Confirm the file appears in `uploads/products/` and renders on the
      Products section
    - Confirm anonymous `curl -X POST /api/upload.php` returns 401

---

## 5. Securing the /uploads Directory

Uploaded files must stay **publicly readable** (the frontend loads them by
URL), so the goal is: readable but **never executable**, never listed, and
never spoofable.

### 5.1 `public_html/uploads/.htaccess`

```apache
# 1) No script execution — uploaded files must never run
php_flag engine off
<FilesMatch "\.(php|phtml|php5|phar|cgi|pl|py|sh|asp|aspx|jsp)$">
  Require all denied
</FilesMatch>

# 2) No directory listing
Options -Indexes

# 3) Long cache — files are immutable (timestamp-named)
<IfModule mod_expires.c>
  ExpiresActive On
  ExpiresByType image/* "access plus 1 year"
  ExpiresByType video/* "access plus 1 year"
</IfModule>

# 4) MIME spoofing defense
<IfModule mod_headers.c>
  Header set X-Content-Type-Options "nosniff"
</IfModule>
```

### 5.2 Hardening stack (cheap, effective)

| # | Measure | Where | Cost |
|---|---|---|---|
| 1 | **Disable public signup** — Supabase Dashboard → Authentication → Sign In/Up → Email → **disable "Allow new users to sign up"**. Only manually invited users can hold an `authenticated` JWT. *This is the single most important setting.* | Supabase dashboard | 1 min |
| 2 | **Short-lived tokens** — upload token `exp` = 10 min | `upload-token.php` | done |
| 3 | **One-time nonce** — each token usable once (replay-proof) | both PHP files | done |
| 4 | **Rate limit** — max 5 tokens/hour per IP on `upload-token.php` | `upload-token.php` | done |
| 5 | **Real MIME check** — `finfo` content sniffing, not just extension | `upload.php` | done |
| 6 | **No script execution** in uploads (`.htaccess`) | `uploads/.htaccess` | done |
| 7 | **Server-side rename** — `{timestamp}-{safe-name}` (path traversal + extension tricks) | `upload.php` | done |
| 8 | **Short Supabase session expiry** — Dashboard → Auth → Sessions: 1–2 hours | Supabase dashboard | 1 min |
| 9 | **Rotate signing key** if compromised — all outstanding tokens die instantly | cPanel `.user.ini` | 1 min |
| 10 | **Hotlink protection (optional)** — cPanel → Hotlink Protection, or referer check in `.htaccess` | cPanel | 1 min |
| 11 | **Uploads folder backups** — cPanel automatic backups cover `uploads/` | cPanel | enabled by default |

### 5.3 Secrets summary

> **Note:** upload auth uses a **custom API key** — no Supabase JWT parsing
> in PHP at all. The key lives in the `admin_settings` table (RLS-protected)
> and in `.user.ini` on the server. The only real server-side secret is
> `UPLOAD_SIGNING_KEY`.

| Secret | Where it lives | Never in |
|---|---|---|
| `UPLOAD_API_KEY` | server `.user.ini` + `admin_settings` table | client bundle |
| `UPLOAD_SIGNING_KEY` | server `.user.ini` | client bundle |
| Supabase anon key | client bundle (fine — RLS-limited) | — |
| Admin Supabase session | browser memory (short-lived) | localStorage if avoidable |

---

## 6. CI/CD — Automatic Deploy to Rumah Web

Shared hosting has no built-in pipeline, so **GitHub Actions + SFTP** gives the
same push-to-deploy workflow as Cloudflare Pages today.

### 6.1 Workflow: `.github/workflows/deploy.yml`

```yaml
name: Deploy to Rumah Web

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: oven-sh/setup-bun@v1
      - run: bun install
      - run: bun run generate
        env:
          SUPABASE_URL: ${{ secrets.SUPABASE_URL }}
          SUPABASE_KEY: ${{ secrets.SUPABASE_KEY }}
          NUXT_PUBLIC_ADMIN_PATH: ${{ secrets.NUXT_PUBLIC_ADMIN_PATH }}
          NUXT_PUBLIC_APP_URL: ${{ secrets.NUXT_PUBLIC_APP_URL }}
      - name: Deploy static site
        uses: SamKirkland/FTP-Deploy-Action@v4.3.5
        with:
          server: ${{ secrets.FTP_HOST }}
          username: ${{ secrets.FTP_USERNAME }}
          password: ${{ secrets.FTP_PASSWORD }}
          local-dir: .output/public/
          server-dir: /public_html/
          exclude: |
            **/uploads/**
            **/.htaccess
      - name: Deploy PHP API
        uses: SamKirkland/FTP-Deploy-Action@v4.3.5
        with:
          server: ${{ secrets.FTP_HOST }}
          username: ${{ secrets.FTP_USERNAME }}
          password: ${{ secrets.FTP_PASSWORD }}
          local-dir: api/
          server-dir: /public_html/api/
```

### 6.2 GitHub Secrets to add

Repo → Settings → Secrets and variables → Actions:

| Secret | Value |
|---|---|
| `FTP_HOST` | `ftp.yourdomain.com` (from cPanel FTP accounts) |
| `FTP_USERNAME` | cPanel FTP username |
| `FTP_PASSWORD` | FTP password |
| `SUPABASE_URL` | `https://xxx.supabase.co` |
| `SUPABASE_KEY` | Supabase anon key |
| `NUXT_PUBLIC_ADMIN_PATH` | `admin` |
| `NUXT_PUBLIC_APP_URL` | `https://yourdomain.com` |

### 6.3 Critical settings

- `exclude: **/uploads/**` — never overwrite or delete uploaded files
- Do **NOT** enable `dangerous-clean-slate` — it would wipe `uploads/` on
  every deploy
- Deploy `uploads/.htaccess` and both PHP files once manually first; CI
  updates `api/` from then on
- Rumah Web FTP has max execution time — keep the site small (SPA is a few
  MB); if syncs time out, split into two actions or use SSH (if the plan
  includes it)

### 6.4 Alternative: cPanel Git Version Control

If the Rumah Web plan includes cPanel's "Git Version Control": create a
repository in `public_html`, connect it to the GitHub repo, and click
"Update from Remote" after each push — semi-automatic, one click per deploy.

---

## 7. Migrating Existing Media (from Supabase Storage)

If there are files in Supabase Storage already:

1. Supabase Dashboard → Storage → `products` bucket → download all files
2. Re-upload into `public_html/uploads/products/` via cPanel
3. Update URLs in Supabase (or re-add media via the admin UI after re-upload)

Simplest path: keep old URLs in the DB and only new uploads go to Rumah Web;
or re-add media via the admin panel after re-upload.

---

## 8. Caveats & Notes

- **Secrets exposure**: `UPLOAD_API_KEY` and `UPLOAD_SIGNING_KEY` live only
  on the server (`.user.ini`), never in the client bundle. The browser fetches
  the API key from the `admin_settings` table (RLS-protected — only logged-in
  admins can read it), mints a 10-min token, then uploads. **Never** put
  either key in `NUXT_PUBLIC_*`. If the API key leaks, rotate it in both the
  table and `.user.ini`.
- **Anon key still in the bundle** — fine; it is a public key limited by RLS,
  exactly as it is today on Cloudflare Pages.
- **Upload limits**: shared hosting defaults are usually 32 MB; set 20 MB in
  `.htaccess` to be safe. Video files above ~20 MB should use an external host
  (YouTube unlisted / Cloudflare Stream) or the VPS plan later.
- **Supabase free tier**: project pauses after 7 days of inactivity (resumable).
  Upgrading to Pro ($25/mo) removes this.
- **Backups**: cPanel automatic backups cover static files + uploads; export
  Supabase DB periodically (Dashboard → Database → Backups, or a nightly SQL
  dump via a cron job using `pg_dump` on a local machine).
- **Contact form**: posts to Supabase directly (unchanged). PHP is only used
  for uploads.
- **Rumah Web cost**: shared hosting ~Rp 30–90k/mo. Supabase free tier stays
  free (or $25/mo Pro for always-on).

---

## 9. Implementation Checklist

- [ ] Purchase Rumah Web plan, enable SSL
- [ ] **Disable public signup** in Supabase (critical security step)
- [ ] Create `admin_settings` table + generate `UPLOAD_API_KEY` (`openssl rand -hex 32`)
- [ ] Generate `UPLOAD_SIGNING_KEY` (`openssl rand -hex 32`)
- [ ] Create `api/upload-token.php` (code above)
- [ ] Create `api/upload.php` (code above)
- [ ] Create `uploads/.htaccess` hardening rules
- [ ] Rewrite `app/composables/useStorage.ts`
- [ ] Add `appUrl` to `nuxt.config.ts` runtime config
- [ ] Create `.github/workflows/deploy.yml` + GitHub secrets
- [ ] Build with env vars, upload to `public_html/`
- [ ] Create `uploads/` dirs; set `UPLOAD_API_KEY` + `UPLOAD_SIGNING_KEY` in `.user.ini`
- [ ] `.htaccess` SPA fallback + upload limits
- [ ] Add domain to Supabase Allowed Origins
- [ ] DNS → Rumah Web IP (via Cloudflare)
- [ ] Test upload + display end-to-end + anonymous 401 test
- [ ] Migrate any existing Supabase Storage files
- [ ] Set up backups (cPanel + Supabase export)
