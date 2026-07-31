<script setup lang="ts">
import { useSupabase } from "~/utils/supabase";
import Section from "~/components/common/Section.vue";
import Button from "~/components/common/Button.vue";
import BlurText from "~/components/bits/BlurText.vue";
import SplitText from "~/components/bits/SplitText.vue";

const supabase = useSupabase();

const defaults = {
    address: "Medan Industrial Estate, Indonesia",
    email: "export@agronusa.co.id",
    whatsapp: "+6281234567890",
    whatsappLink: "https://wa.me/6281234567890",
};

const contact = ref({ ...defaults });
const social = ref<Record<string, string>>({});
const loaded = ref(false);

// Brand icon paths. Keys are normalized (trimmed + lowercased) before lookup;
// unknown platforms fall back to a generic globe icon instead of a blank box.
const socialPaths: Record<string, { viewBox: string; d: string }> = {
    linkedin: { viewBox: "0 0 256 256", d: "M218.123,218.127h-37.931v-59.403c0-14.165-0.253-32.4-19.728-32.4-19.756,0-22.779,15.434-22.779,31.369v60.43h-37.93V95.967h36.413v16.694h0.51c5.067-9.602,17.449-19.73,35.93-19.73,38.435,0,45.532,25.303,45.532,58.183L218.123,218.127zM66.871,79.629c-12.135,0-21.964-9.841-21.964-21.968c0-12.132,9.828-21.969,21.964-21.969c12.135,0,21.964,9.837,21.964,21.969C88.835,69.788,79.006,79.629,66.871,79.629zM87.267,218.127H46.466V95.967h40.801V218.127z" },
    instagram: { viewBox: "0 0 256 256", d: "M128 24a104 104 0 1 0 0 208 104 104 0 0 0 0-208zm40 120c0 12-10 22-22 22H86c-12 0-22-10-22-22V86c0-12 10-22 22-22h60c12 0 22 10 22 22v58zm-40-48c-10 0-18 8-18 18s8 18 18 18 18-8 18-18-8-18-18-18zm20-18a8 8 0 1 1 0 16 8 8 0 0 1 0-16z" },
    facebook: { viewBox: "0 0 256 256", d: "M128 24a104 104 0 1 0 0 208 104 104 0 0 0 0-208zm16 80h-12v-8c0-4 2-6 6-6h6V72h-10c-12 0-18 8-18 18v14h-10v18h10v40h18v-40h12l2-18z" },
    youtube: { viewBox: "0 0 256 256", d: "M128 24a104 104 0 1 0 0 208 104 104 0 0 0 0-208zm56 128c0 8-6 14-14 14H86c-8 0-14-6-14-14V88c0-8 6-14 14-14h84c8 0 14 6 14 14v64zm-32-40l-28-16v32l28-16z" },
    twitter: { viewBox: "0 0 256 256", d: "M128 24a104 104 0 1 0 0 208 104 104 0 0 0 0-208zm48 84v4c0 28-22 50-50 50-14 0-26-4-36-10 2 0 4 0 6 0 12 0 22-4 30-10-10 0-18-8-20-18 2 0 4 0 6 0 2 0 4 0 6 0-10-2-18-12-18-24v-2c4 2 8 4 12 4-6-4-10-10-10-18 0-4 2-8 4-12 12 14 28 24 48 26-2-4-2-8-2-12 0-12 10-22 22-22 6 0 12 2 16 6 4-2 10-4 14-6-2 6-6 10-12 14 4 0 8-2 12-4-2 4-6 10-10 14z" },
    whatsapp: { viewBox: "0 0 256 256", d: "M187.58,144.84l-32-16a8,8,0,0,0-8,.5l-14.69,9.8a40.55,40.55,0,0,1-16-16l9.8-14.69a8,8,0,0,0,.5-8l-16-32A8,8,0,0,0,104,64a40,40,0,0,0-40,40,88.1,88.1,0,0,0,88,88,40,40,0,0,0,40-40A8,8,0,0,0,187.58,144.84Z" },
    tiktok: { viewBox: "0 0 24 24", d: "M12.525.02c1.31-.02 2.61-.01 3.91-.02.08 1.53.63 3.09 1.75 4.17 1.12 1.11 2.7 1.62 4.24 1.79v4.03c-1.44-.05-2.89-.35-4.2-.97-.57-.26-1.1-.59-1.62-.93-.01 2.92.01 5.84-.02 8.75-.08 1.4-.54 2.79-1.35 3.94-1.31 1.92-3.58 3.17-5.91 3.21-1.43.08-2.86-.31-4.08-1.03-2.02-1.19-3.44-3.37-3.65-5.71-.02-.5-.03-1-.01-1.49.18-1.9 1.12-3.72 2.58-4.96 1.66-1.44 3.98-2.13 6.15-1.72.02 1.48-.04 2.96-.04 4.44-.99-.32-2.15-.23-3.02.37-.63.41-1.11 1.04-1.36 1.75-.21.51-.15 1.07-.14 1.61.24 1.64 1.82 3.02 3.5 2.87 1.12-.01 2.19-.66 2.77-1.61.19-.33.4-.67.41-1.06.1-1.79.06-3.57.07-5.36.01-4.03-.01-8.05.02-12.07z" },
    telegram: { viewBox: "0 0 24 24", d: "M11.944 0A12 12 0 0 0 0 12a12 12 0 0 0 12 12 12 12 0 0 0 12-12A12 12 0 0 0 12 0a12 12 0 0 0-.056 0zm4.962 7.224c.1-.002.321.023.465.14a.506.506 0 0 1 .171.325c.016.093.036.306.02.472-.18 1.898-.962 6.502-1.36 8.627-.168.9-.499 1.201-.82 1.23-.696.065-1.225-.46-1.9-.902-1.056-.693-1.653-1.124-2.678-1.8-1.185-.78-.417-1.21.258-1.91.177-.184 3.247-2.977 3.307-3.23.007-.032.014-.15-.056-.212s-.174-.041-.249-.024c-.106.024-1.793 1.14-5.061 3.345-.48.33-.913.49-1.302.48-.428-.008-1.252-.241-1.865-.44-.752-.245-1.349-.374-1.297-.789.027-.216.325-.437.893-.663 3.498-1.524 5.83-2.529 6.998-3.014 3.332-1.386 4.025-1.627 4.476-1.635z" },
};

// Aliases so common spellings resolve to a known brand icon.
const socialAliases: Record<string, string> = {
    x: "twitter",
    wa: "whatsapp",
};

// Generic globe used for unknown platforms so the link stays visible.
const fallbackPath = {
    viewBox: "0 0 256 256",
    d: "M128,24A104,104,0,1,0,232,128,104.11,104.11,0,0,0,128,24Zm0,16a88.09,88.09,0,0,1,87.66,80H40.34A88.09,88.09,0,0,1,128,40Zm0,176a88.09,88.09,0,0,1-87.66-80h175.32A88.09,88.09,0,0,1,128,216Z",
};

// Normalized + filtered list ready for rendering.
const socialItems = computed(() =>
    Object.entries(social.value)
        .map(([platform, url]) => {
            const key = platform.trim().toLowerCase();
            return {
                platform: socialAliases[key] || key,
                url: (url || "").trim(),
            };
        })
        .filter((item) => item.url.length > 0),
);

onMounted(async () => {
    const { data } = await supabase
        .from("company_info")
        .select("contact, social")
        .single();
    if (data) {
        if (data.contact) {
            const raw = data.contact as any;
            contact.value = {
                address: raw.address || defaults.address,
                email: raw.email || defaults.email,
                whatsapp: raw.whatsapp || defaults.whatsapp,
                whatsappLink: `https://wa.me/${(raw.whatsapp || defaults.whatsapp).replace(/[^0-9]/g, "")}`,
            };
        }
        if (data.social) social.value = data.social as Record<string, string>;
    }
    loaded.value = true;
});
</script>

<template>
    <Section id="contact">
        <div
            class="max-w-(--spacing-container) mx-auto px-(--spacing-gutter) w-full h-full flex flex-col items-center justify-center"
        >
            <!-- Numbered Header -->
            <div class="mb-3 flex-shrink-0">
                <SplitText
                    text="05 &mdash; Contact"
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
            <div class="animate-entry delay-1 flex-shrink-0 w-full max-w-lg">
                <BlurText
                    text="Get in Touch"
                    className="headline-md mb-3"
                    :delay="60"
                    :step-duration="0.3"
                    animate-by="words"
                    direction="bottom"
                />
                <BlurText
                    text="Reach out for inquiries, sample requests, or partnership opportunities."
                    className="body-md max-w-lg leading-relaxed"
                    :delay="80"
                    :step-duration="0.25"
                    animate-by="words"
                    direction="bottom"
                />
            </div>

            <!-- Contact Info - Centered, Full Width -->
            <div
                class="animate-entry delay-2 mt-6 md:mt-10 w-full max-w-lg mx-auto"
            >
                <div class="card !p-6 md:!p-8">
                    <div class="space-y-4 md:space-y-5">
                        <!-- Address -->
                        <div class="flex items-center gap-3 md:gap-4">
                            <div
                                class="w-9 h-9 rounded-lg bg-[var(--color-husk-muted)] dark:bg-white/10 flex items-center justify-center flex-shrink-0"
                            >
                                <svg
                                    xmlns="http://www.w3.org/2000/svg"
                                    width="16"
                                    height="16"
                                    viewBox="0 0 256 256"
                                    class="fill-[var(--color-husk)] dark:fill-[var(--color-husk-light)]"
                                >
                                    <path
                                        d="M128,16a88.1,88.1,0,0,0-88,88c0,75.3,80,132.17,83.41,134.55a8,8,0,0,0,9.18,0C136,236.17,216,179.3,216,104A88.1,88.1,0,0,0,128,16Zm0,56a32,32,0,1,1-32,32A32,32,0,0,1,128,72Z"
                                    />
                                </svg>
                            </div>
                            <div>
                                <p
                                    class="label-caps "
                                >
                                    Address
                                </p>
                                <p
                                    class="text-sm mt-0.5 leading-relaxed"
                                >
                                    {{ contact.address }}
                                </p>
                            </div>
                        </div>

                        <!-- Email -->
                        <div class="flex items-center gap-3 md:gap-4">
                            <div
                                class="w-9 h-9 rounded-lg bg-[var(--color-forest-muted)] dark:bg-white/10 flex items-center justify-center flex-shrink-0"
                            >
                                <svg
                                    xmlns="http://www.w3.org/2000/svg"
                                    width="16"
                                    height="16"
                                    viewBox="0 0 256 256"
                                    class="fill-[var(--color-forest)] dark:fill-[var(--color-forest-light)]"
                                >
                                    <path
                                        d="M224,48H32a8,8,0,0,0-8,8V192a16,16,0,0,0,16,16H216a16,16,0,0,0,16-16V56A8,8,0,0,0,224,48ZM203.43,64,128,127.72,52.57,64ZM216,192H40V74.19l82.59,75.71a8,8,0,0,0,10.82,0L216,74.19V192Z"
                                    />
                                </svg>
                            </div>
                            <div>
                                <p
                                    class="label-caps "
                                >
                                    Email
                                </p>
                                <a
                                    :href="`mailto:${contact.email}`"
                                    class="text-sm  hover:underline mt-0.5 block leading-relaxed"
                                    >{{ contact.email }}</a
                                >
                            </div>
                        </div>

                        <!-- WhatsApp -->
                        <div class="flex items-center gap-3 md:gap-4">
                            <div
                                class="w-9 h-9 rounded-lg bg-[#25D366]/10 flex items-center justify-center flex-shrink-0"
                            >
                                <svg
                                    xmlns="http://www.w3.org/2000/svg"
                                    width="16"
                                    height="16"
                                    fill="#25D366"
                                    viewBox="0 0 256 256"
                                >
                                    <path
                                        d="M187.58,144.84l-32-16a8,8,0,0,0-8,.5l-14.69,9.8a40.55,40.55,0,0,1-16-16l9.8-14.69a8,8,0,0,0,.5-8l-16-32A8,8,0,0,0,104,64a40,40,0,0,0-40,40,88.1,88.1,0,0,0,88,88,40,40,0,0,0,40-40A8,8,0,0,0,187.58,144.84Z"
                                    />
                                </svg>
                            </div>
                            <div>
                                <p
                                    class="label-caps "
                                >
                                    WhatsApp
                                </p>
                                <a
                                    :href="contact.whatsappLink"
                                    target="_blank"
                                    class="text-sm hover:underline mt-0.5 block leading-relaxed"
                                    >{{ contact.whatsapp }}</a
                                >
                            </div>
                        </div>
                    </div>

                    <!-- Social Media -->
                    <div v-if="socialItems.length" class="mt-5 pt-4 border-t border-[var(--color-ink)]/8 dark:border-white/10">
                        <p
                            class="label-caps dark:!text-[var(--color-husk-light)] mb-3"
                        >Follow Us</p>
                        <div class="flex items-center gap-3">
                            <a
                                v-for="item in socialItems"
                                :key="item.platform"
                                :href="item.url"
                                target="_blank"
                                rel="noopener noreferrer"
                                class="w-9 h-9 rounded-lg bg-[var(--color-ink)]/5 dark:bg-white/10 flex items-center justify-center hover:bg-[var(--color-forest)]/10 dark:hover:bg-white/20 transition-all"
                                :aria-label="item.platform"
                            >
                                <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" :viewBox="(socialPaths[item.platform] || fallbackPath).viewBox">
                                    <path :d="(socialPaths[item.platform] || fallbackPath).d" />
                                </svg>
                            </a>
                        </div>
                    </div>

                    <div class="mt-4 pt-4 border-t border-[var(--color-ink)]/8 dark:border-white/10">
                        <Button
                            variant="whatsapp"
                            size="md"
                            class="w-full justify-center"
                            :href="contact.whatsappLink"
                        >
                            <svg
                                xmlns="http://www.w3.org/2000/svg"
                                width="16"
                                height="16"
                                fill="currentColor"
                                viewBox="0 0 256 256"
                            >
                                <path
                                    d="M187.58,144.84l-32-16a8,8,0,0,0-8,.5l-14.69,9.8a40.55,40.55,0,0,1-16-16l9.8-14.69a8,8,0,0,0,.5-8l-16-32A8,8,0,0,0,104,64a40,40,0,0,0-40,40,88.1,88.1,0,0,0,88,88,40,40,0,0,0,40-40A8,8,0,0,0,187.58,144.84Z"
                                />
                            </svg>
                            Chat on WhatsApp
                        </Button>
                    </div>
                </div>
            </div>
        </div>
    </Section>
</template>
