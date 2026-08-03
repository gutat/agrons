<script setup lang="ts">
import { useSupabase } from "~/utils/supabase";
import Section from "~/components/common/Section.vue";
import Button from "~/components/common/Button.vue";
import RotatingText from "~/components/bits/RotatingText.vue";
import BlurText from "~/components/bits/BlurText.vue";
import TrueFocus from "~/components/bits/TrueFocus.vue";
import ShinyText from "~/components/bits/ShinyText.vue";
import StarBorder from "~/components/bits/StarBorder.vue";

const supabase = useSupabase();

// Sync with TrueFocus cycle: animationDuration(0.5) + pauseBetweenAnimations(1) = 1.5s
const focusIndex = ref(0);
let focusTimer: ReturnType<typeof setInterval> | null = null;

const company = ref({
    name: "PT Agro Nusa Sejahtera",
    tagline: "Premium Cocopeat & Cocofiber from Indonesia",
    mission: "Loading...",
    vision: "Loading...",
    values: [] as { icon: string; title: string; description: string }[],
});
const loading = ref(true);

onMounted(async () => {
    try {
        const { data, error } = await supabase.from("company_info").select("*").maybeSingle();
        if (error) {
            console.error("company_info load failed:", error);
        } else if (data) {
            company.value = data;
        }
    } finally {
        loading.value = false;
    }
});

onMounted(() => {
    focusTimer = setInterval(() => {
        focusIndex.value = (focusIndex.value + 1) % 2;
    }, 5500); // matches TrueFocus cycle: (animationDuration + pauseBetweenAnimations) * 1000
});

onUnmounted(() => {
    if (focusTimer) clearInterval(focusTimer);
});
</script>

<template>
    <Section id="company" dark>
        <!-- Video Background -->
        <div
            aria-hidden="true"
            class="absolute inset-0 overflow-hidden"
            style="z-index: 0"
        >
            <video
                autoplay
                muted
                loop
                playsinline
                poster="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='640' height='640'%3E%3Crect fill='%231B3022' width='640' height='640'/%3E%3C/svg%3E"
                class="absolute inset-0 w-full h-full object-cover"
                style="filter: saturate(0.7) brightness(0.5)"
            >
                <source
                    src="https://media.istockphoto.com/id/1393846455/id/video/tumpukan-massal-fireweed-fermentasi.mp4?s=mp4-640x640-is&k=20&c=wZw1TnAOy5adYfckZWpFdh9DCCSyvAM0Jz2dHkNZQQ8="
                    type="video/mp4"
                />
            </video>
            <!-- Dark overlay -->
            <div
                class="absolute inset-0 bg-gradient-to-b from-[var(--color-forest)]/80 via-[var(--color-forest)]/70 to-[var(--color-forest)]/85"
            ></div>
            <div
                class="absolute inset-0"
                style="
                    background:
                        radial-gradient(
                            ellipse at 20% 30%,
                            rgba(180, 205, 184, 0.12),
                            transparent 60%
                        ),
                        radial-gradient(
                            ellipse at 80% 20%,
                            rgba(241, 188, 140, 0.08),
                            transparent 60%
                        ),
                        radial-gradient(
                            ellipse at 50% 80%,
                            rgba(27, 48, 34, 0.2),
                            transparent 60%
                        );
                "
            ></div>
        </div>

        <div class="relative" style="z-index: 1">
            <div
                class="max-w-(--spacing-container) mx-auto px-(--spacing-gutter) w-full section-content"
            >
                <!-- Numbered Header -->
                <div class="section-header animate-entry">
                    <span class="section-number"
                        >01 &mdash; Our Company</span
                    >
                    <span class="section-divider" />
                </div>

                <!-- Hero -->
                <div
                    class="max-w-3xl mx-auto animate-entry delay-1 text-center md:text-left"
                >
                    <BlurText
                        text="PT Agro Nusa Sejahtera"
                        className="label-caps tracking-[0.2em] !block !text-white/70"
                        :delay="80"
                        :step-duration="0.25"
                        animate-by="letters"
                        direction="bottom"
                    />

                    <h1
                        class="display-lg mt-3 md:mt-4 mb-2 md:mb-3 leading-[1.08] "
                    >
                        <span class="text-white">Premium</span>
                        <span
                            class="inline-block min-w-[200px] md:min-w-[280px] text-left relative"
                        >
                            <RotatingText
                                :texts="[
                                    'Cocopeat',
                                    'Cocofiber',
                                    'Growing Media',
                                    'Sustainable Fiber',
                                ]"
                                :rotation-interval="2800"
                                split-by="characters"
                                :stagger-duration="0.035"
                                stagger-from="center"
                                :transition="{
                                    type: 'spring',
                                    damping: 28,
                                    stiffness: 320,
                                }"
                                :initial="{ y: '80%', opacity: 0 }"
                                :animate="{ y: 0, opacity: 1 }"
                                :exit="{ y: '-80%', opacity: 0 }"
                                main-class-name="inline-flex"
                                element-level-class-name="text-[var(--color-husk-light)]"
                            />
                        </span>
                        <br /><span class="text-white">from Indonesia</span>
                    </h1>

                    <BlurText
                        text="Sustainable, high-quality coconut-based growing media for global agriculture."
                        className="!text-white/80 body-lg leading-relaxed max-w-xl !mt-2 text-left"
                        :delay="100"
                        :step-duration="0.3"
                        animate-by="words"
                        direction="bottom"
                    />

                    <!-- Mission & Vision -->
                    <div
                        v-if="!loading"
                        class="mt-4 md:mt-6 space-y-2 text-white text-xs"
                    >
                        <TrueFocus
                            sentence="Mission Vision"
                            :manual-mode="false"
                            :blur-amount="5"
                            border-color="#B4CDB8"
                            :animation-duration="0.5"
                            :pause-between-animations="5"
                            class="mission-vision-focus"
                        />
                        <div class="min-h-[56px] flex items-start text-left">
                            <BlurText
                                v-if="focusIndex === 0"
                                key="mission"
                                :text="company.mission"
                                className="text-sm md:text-[15px] text-white/80 leading-relaxed text-left"
                                :delay="60"
                                :step-duration="0.25"
                                animate-by="words"
                                direction="bottom"
                            />
                            <BlurText
                                v-else
                                key="vision"
                                :text="company.vision"
                                className="text-sm md:text-[15px] text-white/80 leading-relaxed text-left"
                                :delay="60"
                                :step-duration="0.25"
                                animate-by="words"
                                direction="bottom"
                            />
                        </div>
                    </div>

                    <!-- Values as ShinyText -->
                    <div
                        v-if="company.values?.length"
                        class="mt-3 md:mt-5 flex flex-wrap items-center justify-center gap-x-8 gap-y-1"
                    >
                        <ShinyText
                            v-for="v in company.values"
                            :key="v.title"
                            :text="v.icon + ' ' + v.title"
                            :speed="1.5"
                            color="rgba(255,255,255,0.4)"
                            shine-color="#ffffff"
                            :spread="120"
                            direction="left"
                            class="text-xs md:text-sm uppercase tracking-[0.15em]"
                        />
                    </div>

                    <!-- CTAs -->
                    <div
                        class="flex flex-wrap items-center justify-center gap-4 mt-4 md:mt-6"
                    >
                        <StarBorder
                            as="a"
                            href="#products"
                            color="white"
                            speed="2s"
                            :thickness="6"
                            custom-class="explore-btn"
                        >
                            <span
                                class="flex items-center gap-2 text-sm font-semibold"
                            >
                                Explore Products
                                <svg
                                    xmlns="http://www.w3.org/2000/svg"
                                    width="16"
                                    height="16"
                                    fill="none"
                                    stroke="currentColor"
                                    viewBox="0 0 24 24"
                                    stroke-width="2"
                                    class="stroke-current"
                                >
                                    <path
                                        stroke-linecap="round"
                                        stroke-linejoin="round"
                                        d="M13.5 4.5L21 12m0 0l-7.5 7.5M21 12H3"
                                    />
                                </svg>
                            </span>
                        </StarBorder>
                        <Button
                            variant="outline"
                            size="md"
                            href="#contact"
                            class="!py-[18px]"
                            >Contact Us</Button
                        >
                    </div>
                </div>
            </div>
        </div>
    </Section>
</template>

<style scoped>
.crossfade-enter-active,
.crossfade-leave-active {
    transition:
        opacity 0.4s ease,
        transform 0.4s ease;
}
.crossfade-enter-from {
    opacity: 0;
    transform: translateY(6px);
}
.crossfade-leave-to {
    opacity: 0;
    transform: translateY(-6px);
}

.mission-vision-focus :deep(span) {
    font-size: clamp(24px, 4vw, 48px) !important;
}

.explore-btn :deep(> div:last-child) {
    background: var(--color-forest) !important;
    border-color: transparent !important;
}
</style>
