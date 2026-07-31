<script setup lang="ts">
import { useWindowScroll, useMediaQuery } from "@vueuse/core";
import ThemeSwitcher from "~/components/layout/ThemeSwitcher.vue";
import Button from "~/components/common/Button.vue";
import StaggeredMenu from "~/components/bits/StaggeredMenu.vue";
import GooeyNav from "~/components/bits/GooeyNav.vue";

// Mount nav components only for the viewport that uses them — GooeyNav's
// ResizeObserver + effect positioning and StaggeredMenu's GSAP timeline
// don't need to exist on screens where they're never visible.
const isDesktop = useMediaQuery("(min-width: 768px)");

const { y: scrollY } = useWindowScroll();
const supabase = useSupabase();
const {
    currentSection,
    sectionIds,
    scrollToSection,
    setupScrollSpy,
    setupEntryAnimations,
} = useViewport();

const scrolled = computed(() => scrollY.value > 50);

function onNavClick(id: string) {
    scrollToSection(sectionIds.indexOf(id));
}

setupScrollSpy();
setupEntryAnimations();

const menuItems = computed(() =>
    sectionIds.map((id) => ({
        label:
            id === "home"
                ? "Home"
                : id === "about"
                  ? "About"
                  : id.charAt(0).toUpperCase() + id.slice(1),
        ariaLabel: `Go to ${id} section`,
        link: `#${id}`,
    })),
);

const socialItems = ref<{ label: string; link: string }[]>([
    { label: "WA", link: "https://wa.me/6281234567890" },
    { label: "Email", link: "mailto:export@agronusa.co.id" },
]);

onMounted(async () => {
    const { data } = await supabase
        .from("company_info")
        .select("contact, social")
        .single();
    if (data) {
        const items: { label: string; link: string }[] = [];
        if (data.contact?.whatsapp) {
            const num = String(data.contact.whatsapp).replace(/[^0-9]/g, "");
            items.push({ label: "WA", link: `https://wa.me/${num}` });
        }
        if (data.contact?.email) {
            items.push({ label: "Email", link: `mailto:${data.contact.email}` });
        }
        if (data.social) {
            const platformLabels: Record<string, string> = {
                instagram: "Instagram",
                linkedin: "LinkedIn",
                youtube: "YouTube",
                tiktok: "TikTok",
                facebook: "Facebook",
                twitter: "Twitter",
            };
            for (const [platform, url] of Object.entries(data.social)) {
                if (url) {
                    items.push({ label: platformLabels[platform] || platform, link: String(url) });
                }
            }
        }
        if (items.length > 0) socialItems.value = items;
    }
});

const menuOpen = ref(false);

// Company branding — fetched from company_info (admin-editable)
const companyName = ref("Agro Nusa Sejahtera");
const companyLogo = ref("/logo.png");

onMounted(async () => {
  const { data } = await supabase
    .from("company_info")
    .select("name, logo_url")
    .single();
  if (data) {
    if (data.name) companyName.value = data.name;
    if (data.logo_url) companyLogo.value = data.logo_url;
  }
});

function handleMenuClose() {
    setTimeout(() => {
        menuOpen.value = false;
    }, 500);
}

const logoUrl = "/logo.png";

// Dark sections: Home=0, About=1
const isDarkSection = computed(() => [0, 1].includes(currentSection.value));

const activeDotStyle = computed(() => {
    if (isDarkSection.value) {
        return {
            background: "white",
            boxShadow: "0 0 10px 3px rgba(255, 255, 255, 0.3)",
        };
    }
    return {
        background: "var(--color-forest)",
        boxShadow: "0 0 8px 2px color-mix(in oklch, var(--color-forest) 40%, transparent)",
    };
});

const inactiveDotStyle = computed(() => ({
    background: isDarkSection.value
        ? "color-mix(in oklch, white 50%, transparent)"
        : "color-mix(in oklch, var(--color-ink) 25%, transparent)",
}));
</script>

<template>
    <!-- Desktop Glass Header -->
    <header
        :class="[
            'fixed top-0 left-0 right-0 z-50 transition-shadow duration-300',
            { 'shadow-lg': scrolled },
        ]"
        style="
            background: color-mix(
                in oklch,
                var(--color-parchment) 55%,
                transparent
            );
            backdrop-filter: blur(20px) saturate(180%);
            -webkit-backdrop-filter: blur(20px) saturate(180%);
            border-bottom: 1px solid color-mix(in oklch, var(--color-ink) 6%, transparent);
        "
    >
        <div
            class="max-w-(--spacing-container) mx-auto px-(--spacing-gutter) h-14 md:h-16 flex items-center justify-between"
        >
            <a
                href="#home"
                class="flex items-center gap-3 no-underline select-none"
                @click.prevent="onNavClick('home')"
            >
                <img :src="companyLogo" alt="Agro Nusa" class="h-8 w-auto" />
                <span class="sm:inline text-sm md:text-base font-semibold  leading-none">{{ companyName }}</span>
            </a>

            <div v-if="isDesktop" class="hidden md:flex items-center gap-2 self-stretch">
                <GooeyNav
                    :items="[
                        { label: 'Home', href: '#home' },
                        { label: 'About', href: '#about' },
                        { label: 'Products', href: '#products' },
                        { label: 'Gallery', href: '#gallery' },
                        { label: 'Contact', href: '#contact' },
                    ]"
                    :particle-count="10"
                    :particle-distances="[80, 10]"
                    :particle-r="80"
                    :initial-active-index="0"
                    :animation-time="500"
                    :time-variance="250"
                    :colors="[1, 2, 3, 4, 5, 1, 2, 3, 4, 5]"
                    style="color: white"
                />
                <!-- <div class="flex items-center gap-1">
                    <ThemeSwitcher />
                </div> -->
            </div>

            <!-- Mobile: StaggeredMenu (mounted only on small screens) -->
            <div v-if="!isDesktop" class="md:hidden flex items-center">
                <StaggeredMenu
                    position="right"
                    :items="menuItems"
                    :social-items="socialItems"
                    :display-socials="true"
                    :display-item-numbering="true"
                    menu-button-color="#1B3022"
                    open-menu-button-color="#1B3022"
                    :change-menu-color-on-open="true"
                    :colors="['#1B3022', '#2A4A3A']"
                    accent-color="#B4CDB8"
                    :is-fixed="true"
                    v-bind="menuOpen ? { 'logo-url': logoUrl } : {}"
                    :on-menu-open="() => (menuOpen = true)"
                    :on-menu-close="handleMenuClose"
                />
            </div>
        </div>
    </header>

    <!-- Scroll Snap Dots -->
    <nav class="snap-dots hidden md:flex" aria-label="Section navigation">
        <button
            v-for="(id, i) in sectionIds"
            :key="id"
            :class="['snap-dot', { active: currentSection === i }]"
            :style="currentSection === i ? activeDotStyle : inactiveDotStyle"
            :aria-label="`Go to ${id}`"
            :title="id === 'home' ? 'Home' : id === 'about' ? 'About' : id.charAt(0).toUpperCase() + id.slice(1)"
            @click="scrollToSection(i)"
        ></button>
    </nav>
</template>

<style>
:root {
    --color-1: #1b3022;
    --color-2: #b4cdb8;
    --color-3: #7e562e;
    --color-4: #f1bc8c;
}

/* Center StaggeredMenu toggle button in header height */
.md\:hidden .sm-scope .sm-toggle {
    top: -12px !important;
    right: -14px !important;
}
</style>
