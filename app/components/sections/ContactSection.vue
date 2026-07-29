<script setup lang="ts">
import Section from "~/components/common/Section.vue";
import Button from "~/components/common/Button.vue";
import LightPillar from "~/components/bits/LightPillar.vue";
import BlurText from "~/components/bits/BlurText.vue";
</script>

<template>
    <Section id="contact" dark class="relative overflow-hidden">
        <!-- Dark background for LightPillar visibility -->
        <div class="absolute inset-0 z-0 !bg-[var(--color-charcoal)]">
            <LightPillar
                top-color="#1B3022"
                bottom-color="#4A7A5A"
                :intensity="1.0"
                :rotation-speed="0.3"
                :glow-amount="0.005"
                :pillar-width="3.0"
                :pillar-height="0.4"
                :noise-intensity="0.5"
                :pillar-rotation="0"
                :interactive="false"
            />
        </div>

        <div
            class="relative z-10 max-w-(--spacing-container) mx-auto px-(--spacing-gutter) w-full h-full flex flex-col items-center justify-center"
        >
            <!-- Numbered Header -->
            <div class="section-header animate-entry flex-shrink-0">
                <span class="section-number"
                    >04 &mdash; Contact</span
                >
                <span class="section-divider" />
            </div>

            <!-- Section Title -->
            <div class="animate-entry delay-1 flex-shrink-0 text-center">
                text-left">
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
                <div
                    class="card !p-6 md:!p-8 !bg-white/10 !backdrop-blur-md !border-white/10"
                >
                    <div class="space-y-4 md:space-y-5">
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
                                    class="text-xs font-bold uppercase tracking-widest text-[var(--color-husk-light)]"
                                >
                                    Address
                                </p>
                                <p class="text-sm text-white/80 mt-0.5">
                                    Medan Industrial Estate, Indonesia
                                </p>
                            </div>
                        </div>
                        <div class="flex items-center gap-3 md:gap-4">
                            <div
                                class="w-9 h-9 rounded-lg bg-[var(--color-forest-muted)] dark:bg-white/10 flex items-center justify-center flex-shrink-0"
                            >
                                <svg
                                    xmlns="http://www.w3.org/2000/svg"
                                    width="16"
                                    height="16"
                                    viewBox="0 0 256 256"
                                    class="fill-[var(--color-forest-light)]"
                                >
                                    <path
                                        d="M224,48H32a8,8,0,0,0-8,8V192a16,16,0,0,0,16,16H216a16,16,0,0,0,16-16V56A8,8,0,0,0,224,48ZM203.43,64,128,127.72,52.57,64ZM216,192H40V74.19l82.59,75.71a8,8,0,0,0,10.82,0L216,74.19V192Z"
                                    />
                                </svg>
                            </div>
                            <div>
                                <p
                                    class="text-xs font-bold uppercase tracking-widest text-[var(--color-husk-light)]"
                                >
                                    Email
                                </p>
                                <a
                                    href="mailto:export@agronusa.co.id"
                                    class="text-sm text-[var(--color-forest-light)] hover:underline mt-0.5 block"
                                    >export@agronusa.co.id</a
                                >
                            </div>
                        </div>
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
                                    class="text-xs font-bold uppercase tracking-widest text-[var(--color-husk-light)]"
                                >
                                    WhatsApp
                                </p>
                                <a
                                    href="https://wa.me/6281234567890"
                                    target="_blank"
                                    class="text-sm text-[var(--color-forest-light)] hover:underline mt-0.5 block"
                                    >+62 812 3456 7890</a
                                >
                            </div>
                        </div>
                    </div>

                    <div class="mt-5 pt-4 border-t border-white/10">
                        <Button
                            variant="whatsapp"
                            size="md"
                            class="w-full justify-center"
                            href="https://wa.me/6281234567890"
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
