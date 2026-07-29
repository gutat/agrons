<script setup lang="ts">
useHead({
  title: 'PT Agro Nusa Sejahtera',
  meta: [
    { name: 'description', content: 'Premium Cocopeat and Cocofiber Products from Indonesia' },
    { property: 'og:title', content: 'PT Agro Nusa Sejahtera' },
    { property: 'og:description', content: 'Premium Cocopeat and Cocofiber from Indonesia' },
    { property: 'og:type', content: 'website' },
    { name: 'twitter:card', content: 'summary_large_image' },
  ],
})
</script>

<template>
  <div>
    <AppHeader />
    <main>
      <CompanySection />
      <ProductsSection />
      <GallerySection />
      <ContactSection />
    </main>
    <AppFooter />
  </div>
</template>
