/**
 * File uploads via the Rumah Web PHP API (two-step token flow).
 *
 * Flow:
 *   1. fetch upload API key from Supabase `admin_settings` (RLS-protected —
 *      requires a logged-in admin session)
 *   2. POST /api/upload-token.php with X-Api-Key → short-lived HMAC token
 *   3. POST /api/upload.php with X-Upload-Token + file → public URL
 *
 * The returned URL is stored in Supabase rows (products.media, etc.).
 *
 * Server files: api/upload-token.php, api/upload.php (see docs/plans/RUMAH_WEB_MIGRATION.md)
 */
export function useStorage() {
  const config = useRuntimeConfig()
  const supabase = useSupabase()
  const apiBase = () => `${config.public.appUrl || ''}/api`

  async function uploadFile(file: File, path: string): Promise<string | null> {
    // ① fetch the upload API key (RLS-protected — requires a logged-in admin)
    const { data, error } = await supabase
      .from('admin_settings')
      .select('upload_api_key')
      .single()
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

  async function deleteFile(_url: string): Promise<boolean> {
    // Best-effort no-op — orphaned files are cleaned via cPanel File Manager
    // or a later batch script.
    return true
  }

  return { uploadFile, deleteFile }
}
