<script setup lang="ts">
import { useSupabase } from "~/utils/supabase";
import Section from "~/components/common/Section.vue";
import TrueFocus from "~/components/bits/TrueFocus.vue";
import BlurText from "~/components/bits/BlurText.vue";
import ShinyText from "~/components/bits/ShinyText.vue";

const supabase = useSupabase();

const focusIndex = ref(0);
let focusTimer: ReturnType<typeof setInterval> | null = null;

const company = ref({
    name: "PT Agro Nusa Sejahtera",
    mission: "Loading...",
    vision: "Loading...",
    values: [] as { icon: string; title: string; description: string }[],
});
const loading = ref(true);

onMounted(async () => {
    const { data } = await supabase.from("company_info").select("*").single();
    if (data) company.value = data;
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
    <Section id="about">
        <div
            class="max-w-(--spacing-container) mx-auto px-(--spacing-gutter) w-full section-content h-full"
        >
            <div class="flex-shrink-0">
                <!-- Numbered Header -->
                <div class="section-header animate-entry">
                    <span class="section-number">02 &mdash; About</span>
                    <span class="section-divider" />
                </div>

                <!-- Section Title -->
                <div class="animate-entry delay-1">
                    <BlurText
                        text="Our Company"
                        className="headline-md mb-3"
                        :delay="60"
                        :step-duration="0.3"
                        animate-by="words"
                        direction="bottom"
                    />
                </div>
            </div>

            <!-- Mission & Vision -->
            <div
                v-if="!loading"
                class="animate-entry delay-2 flex-1 flex flex-col justify-center"
            >
                <TrueFocus
                    sentence="Mission Vision"
                    :manual-mode="false"
                    :blur-amount="5"
                    border-color="#1B3022"
                    :animation-duration="0.5"
                    :pause-between-animations="5"
                    class="about-truefocus"
                />
                <div class="min-h-[60px] flex items-start mt-3 max-w-2xl">
                    <BlurText
                        v-if="focusIndex === 0"
                        key="mission"
                        :text="company.mission"
                        className="text-sm md:text-[15px] text-[var(--color-ink-muted)] dark:text-[var(--color-charcoal-ink-muted)] leading-relaxed"
                        :delay="60"
                        :step-duration="0.25"
                        animate-by="words"
                        direction="bottom"
                    />
                    <BlurText
                        v-else
                        key="vision"
                        :text="company.vision"
                        className="text-sm md:text-[15px] text-[var(--color-ink-muted)] dark:text-[var(--color-charcoal-ink-muted)] leading-relaxed"
                        :delay="60"
                        :step-duration="0.25"
                        animate-by="words"
                        direction="bottom"
                    />
                </div>

                <!-- Values as ShinyText -->
                <div
                    v-if="company.values?.length"
                    class="mt-5 md:mt-8 flex flex-wrap items-center gap-x-8 gap-y-2"
                >
                    <ShinyText
                        v-for="v in company.values"
                        :key="v.title"
                        :text="v.icon + ' ' + v.title"
                        :speed="1.5"
                        color="var(--color-ink-faint)"
                        shine-color="var(--color-forest)"
                        :spread="120"
                        direction="left"
                        class="text-xs md:text-sm uppercase tracking-[0.15em]"
                    />
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
