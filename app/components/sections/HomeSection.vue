<script setup lang="ts">
import { useSupabase } from "~/utils/supabase";
import Section from "~/components/common/Section.vue";
import RotatingText from "~/components/bits/RotatingText.vue";
import BlurText from "~/components/bits/BlurText.vue";
import SplitText from "~/components/bits/SplitText.vue";
import StarBorder from "~/components/bits/StarBorder.vue";
import ShinyText from "~/components/bits/ShinyText.vue";

const supabase = useSupabase();

const section = ref({
    company_name: "PT Agro Nusa Sejahtera",
    tagline: "Premium Cocopeat & Cocofiber from Indonesia",
    description: "",
    subtitle:
        "Sustainable, high-quality coconut-based growing media for global agriculture.",
    hero_video_url: undefined as string | undefined,
    hero_image_url: undefined as string | undefined,
});

const posterUrl = computed(() => {
    if (section.value.hero_image_url) return section.value.hero_image_url;
    return "data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='640' height='640'%3E%3Crect fill='%231B3022' width='640' height='640'/%3E%3C/svg%3E";
});

const { supportsVideo } = useMediaSupport();
const readyToPlay = ref(false);

onMounted(() => {
    const start = () => {
        readyToPlay.value = true;
    };
    if (document.readyState === "complete") start();
    else window.addEventListener("load", start, { once: true });
});

onMounted(async () => {
    const { data } = await supabase
        .from("home_section")
        .select(
            "company_name, tagline, description, subtitle, hero_video_url, hero_image_url",
        )
        .eq("published", true)
        .single();
  if (data) section.value = { ...section.value, ...data };
  console.log("Data section:", section.value);
  console.log("hero_video_url:", section.value.hero_video_url);
  console.log("supportsVideo:", supportsVideo.value); // Perhatikan .value karena ini ref
  console.log("readyToPlay:", readyToPlay.value);
});
</script>

<template>
    <Section id="home" dark>
        <!-- Video/Image Background -->
        <div
            aria-hidden="true"
            class="absolute inset-0 overflow-hidden"
            style="z-index: 0"
        >
            <video
                v-if="supportsVideo && readyToPlay && section.hero_video_url"
                autoplay
                preload="metadata"
                muted
                loop
                playsinline
                :poster="posterUrl"
                class="absolute inset-0 w-full h-full object-cover"
                style="filter: saturate(0.7) brightness(0.5)"
            >
                <source :src="section.hero_video_url" type="video/mp4" />
            </video>
            <img
                v-else-if="section.hero_image_url"
                :src="section.hero_image_url"
                alt=""
                class="absolute inset-0 w-full h-full object-cover"
                style="filter: saturate(0.7) brightness(0.5)"
            />
            <div v-else class="absolute inset-0 bg-[var(--color-forest)]"></div>
            <!-- Neutral dark overlay — lets video/image colors show through -->
            <div
                class="absolute inset-0 bg-gradient-to-b from-black/60 via-black/50 to-black/70"
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
                            rgba(241, 188, 140, 0.15),
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
                <div class="mb-3">
                    <SplitText
                        text="01 &mdash; Home"
                        className="section-number block text-[11px]"
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

                <div
                    class="max-w-3xl mx-auto animate-entry delay-1 text-center"
                >
                    <ShinyText
                        :text="section.tagline"
                        :speed="2"
                        color="rgba(255,255,255,0.7)"
                        shine-color="var(--color-husk-light)"
                        :spread="80"
                        direction="left"
                        class="label-caps !block tracking-[0.12em]"
                    />

                    <BlurText
                        v-if="section.description"
                        :text="section.description"
                        className="!text-white/90 body-lg leading-relaxed max-w-xl mx-auto mt-4"
                        :delay="100"
                        :step-duration="0.3"
                        animate-by="words"
                        direction="bottom"
                    />

                    <h1
                        class="display-lg mt-4 md:mt-10 mb-2 md:mb-4 leading-[1.08] home-headline flex justify-center items-center"
                    >
                        <SplitText
                            text="Premium"
                            tag="span"
                            className="inline text-white tracking-wide opacity-80 mr-2"
                            split-type="chars"
                            :delay="60"
                            :duration="0.4"
                            ease="power3.out"
                            :from="{ opacity: 0, y: 20 }"
                            :to="{ opacity: 1, y: 0 }"
                            :threshold="0.3"
                            root-margin="-50px"
                            text-align="left"
                        />
                            <RotatingText
                                :texts="[
                                    'Cocopeat',
                                    'Cocofiber',
                                    'Derivatives',
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
                                main-class-name="inline-flex items-center justify-center rounded-full border border-[var(--color-husk-light)]/40 bg-[var(--color-husk-light)]/10 px-4 md:px-5 py-1 md:py-1.5"
                                element-level-class-name="text-[var(--color-husk-light)]"
                            />
                    </h1>
                    <SplitText
                        text="from Indonesia"
                        tag="span"
                        className="inline text-white tracking-wide"
                        split-type="chars"
                        :delay="60"
                        :duration="0.4"
                        ease="power3.out"
                        :from="{ opacity: 0, y: 20 }"
                        :to="{ opacity: 1, y: 0 }"
                        :threshold="0.3"
                        root-margin="-50px"
                        text-align="left"
                    />
                    <div
                        class="flex flex-wrap items-center justify-center gap-4 mt-6 md:mt-16"
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
                                class="flex items-center gap-2 text-sm font-bold"
                            >
                                Our Products
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
                    </div>
                </div>
            </div>
        </div>
    </Section>
</template>

<style scoped>
.explore-btn :deep(> div:last-child) {
    background: var(--color-forest) !important;
    border-color: transparent !important;
}

/* Compact hero on small screens — content must fit within the snapped viewport */
@media (max-width: 767px) {
    .home-headline {
        font-size: clamp(26px, 7.5vw, 34px) !important;
        letter-spacing: -0.01em !important;
    }
}

@media (max-height: 700px) and (max-width: 767px) {
    .home-headline {
        font-size: clamp(22px, 6.5vw, 28px) !important;
    }
}
</style>
