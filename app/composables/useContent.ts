import { useI18n } from 'vue-i18n'

/**
 * Localized content helpers (Phase 2 of the i18n plan).
 *
 * Scalar fields resolve through the `translations` JSONB column:
 *   translations[field][locale] → translations[field].en → legacy column → ''
 *
 * Array elements (values/specifications/applications) are { en, id } objects;
 * plain strings pass through unchanged (legacy data keeps working).
 */
export function useContent() {
  const { locale } = useI18n({ useScope: 'global' })

  /** Scalar field with fallback chain. */
  function contentText(row: Record<string, any> | null | undefined, field: string): string {
    const tr = row?.translations?.[field]
    if (tr && typeof tr === 'object') {
      const v = tr[locale.value] ?? tr.en
      if (typeof v === 'string' && v.trim()) return v
    }
    return row?.[field] ?? ''
  }

  /** Localized element: { en, id } object, or plain string passthrough. */
  function pick(obj: any): string {
    if (obj == null) return ''
    if (typeof obj === 'string') return obj
    if (typeof obj === 'object') {
      const v = obj[locale.value] ?? obj.en
      if (typeof v === 'string' && v.trim()) return v
    }
    return ''
  }

  /** Array of localized strings → resolved array. */
  function contentList(arr: any[] | null | undefined): string[] {
    return (arr ?? []).map((el) => pick(el)).filter(Boolean)
  }

  return { contentText, pick, contentList }
}
