<script setup lang="ts">
import { useSupabase } from "~/utils/supabase";
import Section from "~/components/common/Section.vue";
import TrueFocus from "~/components/bits/TrueFocus.vue";
import BlurText from "~/components/bits/BlurText.vue";
import ShinyText from "~/components/bits/ShinyText.vue";
import SplitText from "~/components/bits/SplitText.vue";

const supabase = useSupabase();

const focusIndex = ref(0);
let focusTimer: ReturnType<typeof setInterval> | null = null;

const section = ref({
    title: "Our Company",
    mission: "Loading...",
    vision: "Loading...",
    values: [] as { icon: string; title: string; description: string }[],
    hero_image_url: undefined as string | undefined,
    hero_video_url: undefined as string | undefined,
});
const loading = ref(true);

const hasMediaBg = computed(() => !!(section.value.hero_image_url || section.value.hero_video_url));

onMounted(async () => {
    const { data } = await supabase
        .from("about_section")
        .select("title, mission, vision, values, hero_image_url, hero_video_url")
        .eq("published", true)
        .single();
    if (data) section.value = { ...section.value, ...data };
    loading.value = false;
});

onMounted(() => {
    focusTimer = setInterval(() => {
        focusIndex.value = (focusIndex.value + 1) % 2;
    }, 5500);
});

onUnmounted(() => {
    if (focusTimer) clearInterval(focusTimer);
});
</script>

<template>
    <Section id="about" class="relative overflow-hidden" :dark="hasMediaBg">
        <!-- Background video -->
        <video
            v-if="section.hero_video_url"
            autoplay
            muted
            loop
            playsinline
            :poster="section.hero_image_url || undefined"
            class="absolute inset-0 w-full h-full object-cover z-0"
        >
            <source :src="section.hero_video_url" type="video/mp4" />
        </video>
        <!-- Background image -->
        <img
            v-else-if="section.hero_image_url"
            :src="section.hero_image_url"
            alt=""
            class="absolute inset-0 w-full h-full object-cover z-0"
        />
        <!-- Overlay -->
        <div
            v-if="section.hero_image_url || section.hero_video_url"
            class="absolute inset-0 z-[1] bg-[var(--color-charcoal)]/60 backdrop-blur-md"
        ></div>

        <div
            class="relative z-[2] max-w-(--spacing-container) mx-auto px-(--spacing-gutter) w-full section-content h-full"
        >
            <div class="flex-shrink-0">
                <div class="mb-3">
                    <SplitText
                        text="02 &mdash; About"
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

                <div class="animate-entry delay-1">
                    <BlurText
                        :text="section.title"
                        className="label-caps !text-[var(--color-husk)] dark:!text-white"
                        :delay="60"
                        :step-duration="0.3"
                        animate-by="words"
                        direction="bottom"
                    />
                </div>
            </div>

            <div
                v-if="!loading"
                class="animate-entry delay-2 flex-1 flex flex-col justify-center"
            >
                <TrueFocus
                    sentence="Mission Vision"
                    :manual-mode="false"
                    :blur-amount="5"
                    border-color="#B4CDB8"
                    :animation-duration="0.5"
                    :pause-between-animations="5"
                    class="about-truefocus mt-2"
                />
                <div
                    class="min-h-[60px] flex items-start mt-10 max-w-2xl"
                >
                    <BlurText
                        v-if="focusIndex === 0"
                        key="mission"
                        :text="section.mission"
                        className="text-[15px] text-[var(--color-ink)] dark:text-[var(--color-charcoal-ink)] leading-relaxed"
                        :delay="60"
                        :step-duration="0.25"
                        animate-by="words"
                        direction="bottom"
                    />
                    <BlurText
                        v-else
                        key="vision"
                        :text="section.vision"
                        className="text-[15px] text-[var(--color-ink)] dark:text-[var(--color-charcoal-ink)] leading-relaxed"
                        :delay="60"
                        :step-duration="0.25"
                        animate-by="words"
                        direction="bottom"
                    />
                </div>

                <div
                    v-if="section.values?.length"
                    class="mt-8 md:mt-12 grid grid-cols-1 sm:grid-cols-2 gap-4 md:gap-5"
                >
                    <div
                        v-for="v in section.values"
                        :key="v.title"
                        class="flex flex-col gap-1"
                    >
                        <ShinyText
                            :text="v.icon + ' ' + v.title"
                            :speed="1.5"
                            :color="hasMediaBg ? 'rgba(255,255,255,0.85)' : 'var(--color-ink-muted)'"
                            shine-color="var(--color-forest)"
                            :spread="120"
                            direction="left"
                            class="text-xs md:text-sm font-semibold uppercase tracking-[0.1em]"
                        />
                        <span
                            class="text-xs md:text-sm leading-relaxed text-[var(--color-ink-muted)] dark:text-white/70"
                        >{{ v.description }}</span>
                    </div>
                </div>
            </div>
        </div>
    </Section>
</template>

<style scoped>
.about-truefocus :deep(span) {
    font-size: clamp(24px, 4vw, 48px) !important;
}
</style>

<style>
.dark .about-truefocus span {
    color: white;
}
</style>
