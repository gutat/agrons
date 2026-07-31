import { createClient } from '@supabase/supabase-js'

// Use globalThis to survive HMR in dev mode
const key = '__supabase_client__'
const g = globalThis as any

export function useSupabase() {
  if (g[key]) return g[key]

  const config = useRuntimeConfig()
  g[key] = createClient(
    config.public.supabaseUrl,
    config.public.supabaseKey,
    {
      auth: {
        autoRefreshToken: true,
        persistSession: true,
        detectSessionInUrl: true,
        storageKey: 'agrons-supabase-key',
      },
    }
  )
  return g[key]
}
