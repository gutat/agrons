<script setup lang="ts">
import AppHeader from '~/components/layout/AppHeader.vue'
import AppFooter from '~/components/layout/AppFooter.vue'
import HomeSection from '~/components/sections/HomeSection.vue'
import AboutSection from '~/components/sections/AboutSection.vue'
import ProductsSection from '~/components/sections/ProductsSection.vue'
import GallerySection from '~/components/sections/GallerySection.vue'
import ContactSection from '~/components/sections/ContactSection.vue'

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
  <div class="page-enter">
    <AppHeader />
    <main>
      <HomeSection />
      <AboutSection />
      <ProductsSection />
      <GallerySection />
      <ContactSection />
    </main>
    <AppFooter />
  </div>
</template>
