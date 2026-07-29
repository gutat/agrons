<script setup lang="ts">
const config = useRuntimeConfig()
const adminPath = config.public.adminPath || 'admin'

const route = useRoute()
const params = (route.params.admin as string[]) || []
const matched = params[0] === adminPath

if (!matched) {
  throw createError({ statusCode: 404, statusMessage: 'Page Not Found' })
}

const section = params[1] || 'dashboard'
const slug = params.slice(2).join('/') || undefined
</script>

<template>
  <AdminLayout :section="section" :slug="slug" />
</template>
