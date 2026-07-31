<script setup lang="ts">
import { register } from "swiper/element";
import { useSupabase } from "~/utils/supabase";
import type { Product, ProductMedia } from "~/types";
import Section from "~/components/common/Section.vue";
import Button from "~/components/common/Button.vue";
import BlurText from "~/components/bits/BlurText.vue";
import SplitText from "~/components/bits/SplitText.vue";
import ProductGalleryOverlay from "~/components/products/ProductGalleryOverlay.vue";
register();

const supabase = useSupabase();

const products = ref<Product[]>([]);
const activeCategory = ref<"cocopeat" | "cocofiber">("cocopeat");
const loading = ref(true);
const galleryOpen = ref(false);
const galleryMedia = ref<ProductMedia[]>([]);
const galleryTitle = ref("");

const filteredProducts = computed(() =>
    products.value.filter((p) => p.category === activeCategory.value),
);

const { supportsVideo } = useMediaSupport();
const activeIndex = ref(0);
const swiperRef = ref<any>(null);

function onSlideChange(e: Event) {
    activeIndex.value = (e.target as any)?.activeIndex ?? 0;
}

function prevSlide() {
    swiperRef.value?.swiper?.slidePrev()
}
function nextSlide() {
    swiperRef.value?.swiper?.slideNext()
}

watch(activeCategory, () => {
    activeIndex.value = 0;
});

function openGallery(product: Product) {
    galleryMedia.value = product.media || [];
    galleryTitle.value = product.name;
    galleryOpen.value = true;
}

function closeGallery() {
    galleryOpen.value = false;
}

onMounted(async () => {
    const { data } = await supabase
        .from("products")
        .select("*")
        .eq("published", true)
        .order("sort_order");
    if (data) products.value = data;
    loading.value = false;
});
</script>

<template>
    <Section id="products" class="section-fixed overflow-hidden !pb-0 md:!pb-0">
        <div class="flex flex-col w-full flex-1 min-h-0">
            <!-- Header area (flex-shrink-0, contained) -->
            <div
                class="max-w-(--spacing-container) mx-auto px-(--spacing-gutter) w-full flex-shrink-0 pt-2 md:pt-4"
            >
                <!-- Numbered Header -->
                <div class="mb-3">
                    <SplitText
                        text="03 &mdash; Our Products"
                        className="section-number block"
                        :delay="80"
                        :duration="0.5"
                        ease="power3.out"
                        split-type="chars"
                        :from="{ opacity: 0, y: 30 }"
                        :to="{ opacity: 1, y: 0 }"
                        :threshold="0.1"
                        root-margin="-100px"
                        text-align="left"
                    />
                    <span class="section-divider mt-2 block" />
                </div>

                <!-- Section Title -->
                <div class="animate-entry delay-1">
                    <BlurText
                        text="Premium Coconut Products"
                        className="headline-md mb-3"
                        :delay="60"
                        :step-duration="0.3"
                        animate-by="words"
                        direction="bottom"
                    />
                    <BlurText
                        text="High-quality cocopeat and cocofiber for greenhouses, horticulture, and industrial applications."
                        className="body-md max-w-lg leading-relaxed"
                        :delay="80"
                        :step-duration="0.25"
                        animate-by="words"
                        direction="bottom"
                    />
                </div>

                <!-- Category Switcher -->
                <div
                    class="flex items-center gap-6 mt-3 md:mt-4 mb-3 md:mb-4 animate-entry delay-2"
                >
                    <button
                        v-for="cat in ['cocopeat', 'cocofiber']"
                        :key="cat"
                        :class="[
                            'relative text-sm md:text-base font-medium transition-all capitalize pb-1',
                            activeCategory === cat
                                ? 'text-white dark:text-black'
                                : 'text-[var(--color-ink-muted)] dark:text-[var(--color-charcoal-ink-muted)] hover:text-[var(--color-forest)] dark:hover:text-[var(--color-forest-light)]',
                        ]"
                        @click="
                            activeCategory = cat as 'cocopeat' | 'cocofiber'
                        "
                    >
                        {{ cat }}
                        <span
                            v-if="activeCategory === cat"
                            class="absolute bottom-0 left-0 right-0 h-0.5 bg-[var(--color-forest)] dark:bg-[var(--color-forest-light)] rounded-full"
                        />
                    </button>
                </div>
            </div>

            <!-- Loading -->
            <div
                v-if="loading"
                class="flex-1 flex items-center justify-center animate-entry delay-3"
            >
                <div
                    class="w-6 md:w-7 h-6 md:h-7 border-2 border-[var(--color-forest)] dark:border-[var(--color-forest-light)] border-t-transparent rounded-full animate-spin"
                />
            </div>

            <!-- Product Swiper (grows to fill remaining space, full-width) -->
            <div
                v-else
                class="flex-1 min-h-0 w-full relative animate-entry delay-3"
            >
                <!-- Desktop: constrained to container width, centered. Mobile: full width. -->
                <div
                    class="h-full w-full md:max-w-(--spacing-container) md:mx-auto md:px-(--spacing-gutter)"
                >
                <swiper-container
                    v-if="filteredProducts.length > 0"
                    ref="swiperRef"
                    slides-per-view="1"
                    speed="500"
                    grab-cursor
                    @slidechange="onSlideChange"
                    class="h-full w-full product-swiper"
                >
                    <swiper-slide
                        v-for="(product, index) in filteredProducts"
                        :key="product.id"
                        class="h-full"
                    >
                        <div
                            class="grid grid-cols-2 h-full w-full overflow-hidden rounded-t-[12px]"
                        >
                            <!-- Left: Specifications -->
                            <div
                                class="flex flex-col justify-center px-4 md:px-12 py-4 md:py-10 overflow-y-auto"
                            >
                                <span
                                    class="label-caps text-[var(--color-husk)] dark:text-[var(--color-husk-light)] mb-2"
                                    >{{ product.category }}</span
                                >
                                <h3
                                    class="text-xl md:text-2xl font-semibold mb-3"
                                >
                                    {{ product.name }}
                                </h3>
                                <p
                                    class="text-sm md:text-base leading-relaxed mb-3"
                                >
                                    {{ product.short_description }}
                                </p>

                                <!-- Specifications -->
                                <div
                                    v-if="product.specifications?.length"
                                    class="space-y-1.5 mb-4"
                                >
                                    <div
                                        v-for="spec in product.specifications"
                                        :key="spec.name"
                                        class="flex justify-between text-sm border-b border-[var(--color-ink)]/15 dark:border-white/15 py-1.5"
                                    >
                                        <span
                                            class="font-medium"
                                            >{{ spec.name }}</span
                                        >
                                        <span
                                            class="font-semibold "
                                            >{{ spec.value
                                            }}{{
                                                spec.unit ? " " + spec.unit : ""
                                            }}</span
                                        >
                                    </div>
                                </div>

                                <!-- Applications -->
                                <div
                                    v-if="product.applications?.length"
                                    class="flex flex-wrap gap-1.5 mb-4"
                                >
                                    <span
                                        v-for="app in product.applications"
                                        :key="app"
                                        class="px-3 py-1.5 bg-[var(--color-forest)]/12 dark:bg-white/12 rounded-lg text-sm font-semibold"
                                        >{{ app }}</span
                                    >
                                </div>

                                <button
                                    class="text-sm md:text-base font-bold  hover:underline transition-all self-start"
                                    @click.prevent="openGallery(product)"
                                >
                                    View Gallery &rarr;
                                </button>
                            </div>

                            <!-- Right: Product Photo / Video -->
                            <div
                                class="relative h-full overflow-hidden bg-[var(--color-parchment-dim)] dark:bg-[var(--color-charcoal-raised-higher)]"
                            >
                                <video
                                    v-if="supportsVideo && index === activeIndex && product.video_url"
                                    autoplay
                                    preload="none"
                                    muted
                                    loop
                                    playsinline
                                    :poster="product.thumbnail || undefined"
                                    class="absolute inset-0 w-full h-full object-cover"
                                >
                                    <source
                                        :src="product.video_url"
                                        type="video/mp4"
                                    />
                                </video>
                                <img
                                    v-else-if="product.thumbnail"
                                    :src="product.thumbnail"
                                    :alt="product.name"
                                    class="absolute inset-0 w-full h-full object-cover"
                                    loading="lazy"
                                />
                                <div
                                    v-else
                                    class="absolute inset-0 flex items-center justify-center"
                                >
                                    <svg
                                        xmlns="http://www.w3.org/2000/svg"
                                        width="48"
                                        height="48"
                                        fill="none"
                                        viewBox="0 0 24 24"
                                        stroke-width="1"
                                        class="stroke-[var(--color-ink-faint)] dark:stroke-[var(--color-charcoal-ink-faint)]"
                                    >
                                        <rect
                                            x="3"
                                            y="3"
                                            width="18"
                                            height="18"
                                            rx="2"
                                        />
                                        <circle cx="8.5" cy="8.5" r="1.5" />
                                        <path d="M21 15l-5-5L5 21" />
                                    </svg>
                                </div>
                            </div>
                        </div>
                    </swiper-slide>
                </swiper-container>

                <!-- Custom prev/next arrows (core swiper has no built-in nav) -->
                <button
                    v-if="filteredProducts.length > 1 && activeIndex > 0"
                    class="absolute left-3 top-1/2 -translate-y-1/2 z-10 w-11 h-11 rounded-full bg-[var(--color-parchment-raised)]/85 dark:bg-[var(--color-charcoal-raised)]/85 backdrop-blur-md shadow-md flex items-center justify-center text-[var(--color-forest)] dark:text-[var(--color-forest-light)] hover:scale-105 transition-all"
                    @click="prevSlide"
                    aria-label="Previous product"
                >
                    <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M15 19l-7-7 7-7"/></svg>
                </button>
                <button
                    v-if="filteredProducts.length > 1 && activeIndex < filteredProducts.length - 1"
                    class="absolute right-3 top-1/2 -translate-y-1/2 z-10 w-11 h-11 rounded-full bg-[var(--color-parchment-raised)]/85 dark:bg-[var(--color-charcoal-raised)]/85 backdrop-blur-md shadow-md flex items-center justify-center text-[var(--color-forest)] dark:text-[var(--color-forest-light)] hover:scale-105 transition-all"
                    @click="nextSlide"
                    aria-label="Next product"
                >
                    <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M9 5l7 7-7 7"/></svg>
                </button>

                <!-- Empty state -->
                <div
                    v-else
                    class="flex items-center justify-center h-full text-[var(--color-ink-muted)] dark:text-[var(--color-charcoal-ink-muted)]"
                >
                    <p>No products in this category yet.</p>
                </div>
                </div>
            </div>
        </div>

        <!-- Product Gallery Overlay -->
        <ProductGalleryOverlay
            :items="galleryMedia"
            :title="galleryTitle"
            :open="galleryOpen"
            @close="closeGallery"
        />
    </Section>
</template>

<style scoped></style>
