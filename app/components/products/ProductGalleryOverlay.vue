<script setup lang="ts">
import { register } from "swiper/element/bundle";
import gsap from "gsap";
import type { ProductMedia } from "~/types";
register();

interface Props {
  items: ProductMedia[]
  title?: string
  open: boolean
  initialIndex?: number
}

const props = withDefaults(defineProps<Props>(), {
  initialIndex: 0,
})

const emit = defineEmits<{
  close: []
}>()

const overlayRef = ref<HTMLElement | null>(null)
const panelRef = ref<HTMLElement | null>(null)
const contentRef = ref<HTMLElement | null>(null)
const swiperRef = ref<any>(null)
const currentIndex = ref(props.initialIndex)

let closeTween: gsap.core.Tween | null = null

watch(() => props.open, (val) => {
  if (val) {
    document.body.style.overflow = "hidden"
    nextTick(() => playOpen())
  } else {
    playClose()
  }
})

function playOpen() {
  if (!panelRef.value || !contentRef.value) return

  const panel = panelRef.value
  const children = Array.from(contentRef.value.children) as HTMLElement[]

  gsap.set(overlayRef.value, { display: "flex" })
  gsap.set(panel, { xPercent: 100 })
  gsap.set(children, { y: 40, opacity: 0 })

  const tl = gsap.timeline({ defaults: { ease: "power3.out" } })

  tl.to(overlayRef.value, { opacity: 1, duration: 0.3 }, 0)
  tl.to(panel, { xPercent: 0, duration: 0.5 }, 0.1)
  tl.to(children, { y: 0, opacity: 1, duration: 0.4, stagger: 0.04 }, 0.3)
}

function playClose() {
  if (!panelRef.value || !contentRef.value) return

  const panel = panelRef.value
  const children = Array.from(contentRef.value.children) as HTMLElement[]

  if (closeTween) closeTween.kill()

  closeTween = gsap.timeline({
    defaults: { ease: "power3.in" },
    onComplete: () => {
      document.body.style.overflow = ""
      gsap.set(overlayRef.value, { display: "none" })
      emit("close")
    },
  })
    .to(children, { y: 20, opacity: 0, duration: 0.2, stagger: 0.02 })
    .to(panel, { xPercent: 100, duration: 0.35 }, 0)
    .to(overlayRef.value, { opacity: 0, duration: 0.2 }, 0.15)
}

function close() {
  if (closeTween) closeTween.kill()
  playClose()
}

function prev() {
  if (swiperRef.value?.swiper) {
    swiperRef.value.swiper.slidePrev()
  }
}

function next() {
  if (swiperRef.value?.swiper) {
    swiperRef.value.swiper.slideNext()
  }
}

function onBackdropClick(e: MouseEvent) {
  if (e.target === overlayRef.value) close()
}

function onSlideChange(e: CustomEvent) {
  currentIndex.value = e.detail[0].activeIndex
}

onMounted(() => {
  window.addEventListener("keydown", handleKeydown)
})
onUnmounted(() => {
  window.removeEventListener("keydown", handleKeydown)
})

function handleKeydown(e: KeyboardEvent) {
  if (!props.open) return
  if (e.key === "Escape") close()
  if (e.key === "ArrowLeft") prev()
  if (e.key === "ArrowRight") next()
}
</script>

<template>
  <Teleport to="body">
    <div
      ref="overlayRef"
      class="fixed inset-0 z-50 items-center justify-center"
      style="display: none; opacity: 0"
      @click="onBackdropClick"
    >
      <!-- Dark backdrop -->
      <div class="absolute inset-0 bg-black/90" />

      <!-- Panel (slides in from right) -->
      <div
        ref="panelRef"
        class="relative w-full h-full md:w-[85vw] md:h-[90vh] md:rounded-2xl bg-[var(--color-charcoal)] flex flex-col overflow-hidden"
      >
        <!-- Header bar -->
        <div
          ref="contentRef"
          class="flex items-start justify-between px-4 md:px-6 py-3 md:py-4 flex-shrink-0"
        >
          <div>
            <span class="text-base md:text-lg font-medium text-white/50">{{ currentIndex + 1 }} / {{ items.length }}</span>
            <h3 v-if="title" class="text-lg md:text-xl font-semibold text-white mt-0.5">{{ title }} Gallery</h3>
          </div>
          <button
            class="w-9 h-9 rounded-full bg-white/10 flex items-center justify-center hover:bg-white/20 transition-all mt-1 flex-shrink-0"
            @click="close"
            aria-label="Close gallery"
          >
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2" class="stroke-white">
              <path stroke-linecap="round" d="M6 6l12 12M18 6l-12 12" />
            </svg>
          </button>
        </div>

        <!-- Swiper area -->
        <div class="flex-1 min-h-0 relative">
          <swiper-container
            ref="swiperRef"
            class="h-full w-full"
            slides-per-view="1"
            speed="400"
            grab-cursor
            @slidechange="onSlideChange"
          >
            <swiper-slide
              v-for="(media, i) in items"
              :key="i"
              class="h-full flex items-center justify-center"
            >
              <!-- Video slide -->
              <video
                v-if="media.type === 'video'"
                :src="media.url"
                autoplay
                muted
                loop
                playsinline
                :poster="media.thumbnail || undefined"
                class="max-w-full max-h-full w-full h-full object-contain p-4"
                controls
              ></video>
              <!-- Image slide -->
              <img
                v-else
                :src="media.url"
                :alt="media.alt || ''"
                class="max-w-full max-h-full w-full h-full object-contain p-4"
                loading="lazy"
              />
            </swiper-slide>
          </swiper-container>

          <!-- Prev/Next arrows -->
          <button
            v-if="currentIndex > 0"
            class="absolute left-3 top-1/2 -translate-y-1/2 z-10 w-10 h-10 rounded-full bg-white/10 flex items-center justify-center hover:bg-white/20 transition-all"
            @click="prev"
            aria-label="Previous"
          >
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2" class="stroke-white">
              <path stroke-linecap="round" stroke-linejoin="round" d="M15 19l-7-7 7-7" />
            </svg>
          </button>
          <button
            v-if="currentIndex < items.length - 1"
            class="absolute right-3 top-1/2 -translate-y-1/2 z-10 w-10 h-10 rounded-full bg-white/10 flex items-center justify-center hover:bg-white/20 transition-all"
            @click="next"
            aria-label="Next"
          >
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2" class="stroke-white">
              <path stroke-linecap="round" stroke-linejoin="round" d="M9 5l7 7-7 7" />
            </svg>
          </button>
        </div>
      </div>
    </div>
  </Teleport>
</template>
