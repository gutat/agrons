<script setup lang="ts">
import { useWindowScroll } from "@vueuse/core";
import ThemeSwitcher from "~/components/layout/ThemeSwitcher.vue";
import Button from "~/components/common/Button.vue";
import StaggeredMenu from "~/components/bits/StaggeredMenu.vue";
import GooeyNav from "~/components/bits/GooeyNav.vue";

const { y: scrollY } = useWindowScroll();
const {
    currentSection,
    sectionIds,
    scrollToSection,
    setupScrollSpy,
    setupEntryAnimations,
} = useViewport();

const scrolled = computed(() => false);

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

const socialItems = [
    { label: "WA", link: "https://wa.me/6281234567890" },
    { label: "Email", link: "mailto:export@agronusa.co.id" },
];

const menuOpen = ref(false);

function handleMenuClose() {
    setTimeout(() => {
        menuOpen.value = false;
    }, 500);
}

// Inline logo SVG for StaggeredMenu
const logoUrl = "/logo.png";
</script>

<template>
    <!-- Desktop Pill Nav -->
    <header
        :class="['nav-glass mx-auto max-w-(--spacing-container)', { scrolled }]"
        style="
            border-radius: 9999px;
            background: color-mix(
                in oklch,
                var(--color-parchment) 25%,
                transparent
            );
            box-shadow: 0 2px 12px rgba(0,0,0,0.08);
        "
    >
        <div
            class="h-14 md:h-16 flex items-center justify-between px-4 md:px-6"
        >
            <a
                href="#home"
                class="flex items-center gap-2.5 no-underline select-none"
                @click.prevent="onNavClick('home')"
            >
                <img src="/logo.png" alt="Agro Nusa" class="h-8 w-auto" />
            </a>

            <div class="hidden md:flex items-center gap-2">
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
                <div class="flex items-center gap-1">
                    <ThemeSwitcher />
                </div>
            </div>
        </div>
    </header>

    <!-- Mobile: StaggeredMenu full-screen overlay -->
    <div
        class="md:hidden fixed z-50"
        :style="{
            top: menuOpen ? '0' : '16px',
            right: menuOpen ? '0' : '16px',
            left: menuOpen ? '0' : 'auto',
            bottom: menuOpen ? '0' : 'auto',
            width: menuOpen ? '100%' : 'auto',
            height: menuOpen ? '100dvh' : 'auto',
        }"
    >
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
            :logo-url="logoUrl"
            :on-menu-open="() => (menuOpen = true)"
            :on-menu-close="handleMenuClose"
        />
    </div>

    <!-- Scroll Snap Dots -->
    <nav class="snap-dots hidden md:flex" aria-label="Section navigation">
        <button
            v-for="(id, i) in sectionIds"
            :key="id"
            :class="['snap-dot', { active: currentSection === i }]"
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
</style>
